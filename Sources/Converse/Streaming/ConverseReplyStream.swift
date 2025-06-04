//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Bedrock Library open source project
//
// Copyright (c) 2025 Amazon.com, Inc. or its affiliates
//                    and the Swift Bedrock Library project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of Swift Bedrock Library project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//
@preconcurrency import AWSBedrockRuntime
import Foundation
import Logging

public struct ConverseReplyStream: Sendable {

    private let logger: Logger

    // This is the stream that the user will consume
    public let stream: AsyncThrowingStream<ConverseStreamElement, Error>

    // This is the stream that the SDK provides, which we will convert to our own stream
    // we expose it as a public property to allow demanding developers to access the raw SDK stream if needed
    public let sdkStream: AsyncThrowingStream<BedrockRuntimeClientTypes.ConverseStreamOutput, Error>

    package init(
        _ inputStream: AsyncThrowingStream<BedrockRuntimeClientTypes.ConverseStreamOutput, Error>,
        logger: Logger? = nil
    ) {

        self.logger = logger ?? .init(label: "ConverseReplyStream")

        // store the sdk-provided stream to expose it to developers if needed
        self.sdkStream = inputStream

        // build a new stream that will convert the SDK stream output to our own ConverseStreamElement
        self.stream = AsyncThrowingStream(ConverseStreamElement.self) { continuation in
            let t = Task {
                do {
                    var state: StreamState!

                    // Convert the SDK stream output to our own stream elements
                    for try await output in inputStream {

                        switch output {
                        case .messagestart(let event):
                            logger?.trace("Message Start", metadata: ["event": "\(event)"])

                            guard let sdkRole = event.role,
                                let role = try? Role(from: sdkRole)
                            else {
                                throw BedrockLibraryError.invalidSDKType("Role is missing in message start event")
                            }

                            state = StreamState(with: role)
                            continuation.yield(.messageStart(role))

                        // only received at the start of a tool use block
                        // https://docs.aws.amazon.com/bedrock/latest/userguide/conversation-inference-call.html#conversation-inference-call-response
                        case .contentblockstart(let event):
                            logger?.trace("Content Block Start")
                            guard state.currentBlockId == -1 else {
                                // If we already have a block started, this is an error
                                throw BedrockLibraryError.invalidSDKType(
                                    "ContentBlockStart received while another block is active"
                                )
                            }
                            guard let blockId = event.contentBlockIndex else {
                                throw BedrockLibraryError.invalidSDKType(
                                    "Block ID is missing in content block start event"
                                )
                            }
                            state.currentBlockId = blockId
                            state.toolUseStart = try ToolUseStart(index: blockId, sdkEventBlockStart: event.start)
                        // do not yield an event here, wait for full ToolUse block to arrive

                        case .contentblockdelta(let event):
                            logger?.trace("Content Block Delta")
                            guard let blockId = event.contentBlockIndex else {
                                // when there is no blockId, this is an error
                                throw BedrockLibraryError.invalidSDKType(
                                    "Block ID is missing in content block delta event"
                                )
                            }
                            guard state.currentBlockId == -1 || state.currentBlockId == blockId else {
                                // when the blockId doesn't match the current block, this is an error
                                throw BedrockLibraryError.invalidSDKType(
                                    "Block ID mismatch in content block delta event"
                                )
                            }
                            // for text and reasoning delta, we receive the block id at the first delta event
                            state.currentBlockId = blockId

                            switch event.delta {
                            case .text(let text):
                                state.bufferText += text
                                continuation.yield(.text(blockId, text))
                            case .tooluse(let toolUseDelta):
                                state.bufferToolUse += toolUseDelta.input ?? ""
                            // do not yield events for tooluse, wait for the full JSON to arrive
                            case .reasoningcontent(let reasoningDelta):
                                switch reasoningDelta {
                                case .text(let text):
                                    state.bufferReasoning += text
                                    continuation.yield(.reasoning(blockId, text))
                                case .signature(let signature):
                                    state.bufferReasoningSignature += signature
                                // do not yield partial signature, wait for full JSON data
                                case .redactedcontent(let redactedContent):
                                    state.bufferReasoningData.append(redactedContent)
                                // do not yield partial reasoning data, wait for full JSON data
                                case .sdkUnknown(let output):
                                    logger?.warning(
                                        "Received unknown SDK Reasoning Delta",
                                        metadata: ["reasoning delta": "\(output)"]
                                    )
                                }
                            case .sdkUnknown(let output):
                                logger?.warning(
                                    "Received unknown SDK Event Delta",
                                    metadata: ["delta": "\(output)"]
                                )
                            case .none:
                                logger?.warning("Received none SDK Event Delta")
                            }

                        case .contentblockstop(let event):
                            logger?.trace("Content Block Stop")
                            guard state.currentBlockId != -1 else {
                                // If we don't have a block started, this is an error
                                throw BedrockLibraryError.invalidSDKType(
                                    "ContentBlockStop received while no block is active"
                                )
                            }
                            guard let blockId = event.contentBlockIndex,
                                blockId == state.currentBlockId
                            else {
                                // If we don't have a block started, this is an error
                                throw BedrockLibraryError.invalidSDKType(
                                    "ContentBlockStop received while no block is active or block ID mismatch"
                                )
                            }

                            // reassemble buffered data and emit top-level event
                            try ConverseReplyStream.flushContent(state: &state, continuation: continuation)
                            guard let lastContentBlock = state.lastContentBlock else {
                                fatalError(
                                    String(
                                        "ContentBlockStop received but no content block was buffered for block ID \(blockId)"
                                    )
                                )
                            }
                            // just yield ToolUse, the partial text and reasoning are already yielded
                            if case .toolUse(let toolUse) = lastContentBlock.1 {
                                continuation.yield(.toolUse(blockId, toolUse))
                            }
                            // buffer this content block
                            state.contentBlocks[blockId] = lastContentBlock.1

                            // reset the current block ID
                            state.currentBlockId = -1

                        case .messagestop(let event):
                            logger?.trace("Message Stop")
                            state.messageComplete = true

                            // create a Message with all content blocks
                            let message = Message(
                                from: state.role,
                                content: state.contentBlocks.sorted { $0.key < $1.key }.map { $0.value },
                                stopReason: Message.stopReason(fromSDK: event.stopReason)
                            )
                            continuation.yield(.messageComplete(message))

                        case .metadata(let event):
                            logger?.trace("Metadata", metadata: ["event": "\(event)"])

                            // Convert the metadata event to our ResponseMetadata type
                            let metadata = try ResponseMetadata(from: event)
                            continuation.yield(.metaData(metadata))

                        case .sdkUnknown(let output):
                            // Handle unknown SDK output
                            // This is a catch-all for any future SDK output types that we don't handle yet
                            // We log it and continue, but we could also throw an error if desired
                            logger?.warning(
                                "Received unknown SDK ConverseStreamOutput",
                                metadata: ["output": "\(output)"]
                            )
                        }  // switch

                    }  // for try await

                    continuation.finish()

                    // when we reach here, the stream is finished or the Task is cancelled
                    // when cancelled, it should throw CancellationError
                    // not really necessary as this seems to be handled by the Stream anyway.
                    try Task.checkCancellation()

                } catch {
                    // report any error, including cancellation (but cancellation result in silent stream termination for the consumer)
                    // https://forums.swift.org/t/why-does-asyncthrowingstream-silently-finish-without-error-if-cancelled/72777
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = {
                (termination: AsyncThrowingStream<ConverseStreamElement, Error>.Continuation.Termination) -> Void in
                if case .cancelled = termination {
                    t.cancel()  // Cancel the task when the stream is terminated
                }
            }
        }
    }

    /// Flushes and processes the buffered content from the stream state
    ///
    /// This function processes any buffered content in the stream state and creates the appropriate Content type.
    /// It performs validation to ensure only one type of content buffer is non-empty at a time.
    ///
    /// The method is static to avoid callers to capture self, which is not allowed in async contexts.
    ///
    /// - Parameters:
    ///   - state: The current stream state containing buffered content
    ///   - continuation: The stream continuation for emitting events
    ///
    /// - Returns: A tuple containing the block ID and processed Content, or nil if no content to process
    ///
    /// - Throws: BedrockLibraryError.invalidSDKType if validation fails or buffers are in an invalid state
    private static func flushContent(
        state: inout StreamState,
        continuation: AsyncThrowingStream<ConverseStreamElement, any Error>.Continuation
    ) throws {
        guard isToolUseBufferValid(state) ||
              isReasoningDataBufferValid(state) ||
              isEmptyBufferValid(state) ||
              isReasoningBufferValid(state) ||
              isTextBufferValid(state)
        else {
            throw BedrockLibraryError.invalidSDKType("ContentBlockStop received while multiple buffers are not empty")
        }

    }

    private static func isToolUseBufferValid(_ state: StreamState) -> Bool {
        return state.bufferText.isEmpty && state.bufferReasoning.isEmpty && state.bufferReasoningData.isEmpty
            && !state.bufferToolUse.isEmpty
    }

    private static func isReasoningDataBufferValid(_ state: StreamState) -> Bool {
        return state.bufferText.isEmpty && state.bufferReasoning.isEmpty && !state.bufferReasoningData.isEmpty
            && state.bufferToolUse.isEmpty
    }

    private static func isEmptyBufferValid(_ state: StreamState) -> Bool {
        return state.bufferText.isEmpty && state.bufferReasoning.isEmpty && state.bufferReasoningData.isEmpty
            && state.bufferToolUse.isEmpty
    }

    private static func isReasoningBufferValid(_ state: StreamState) -> Bool {
        return state.bufferText.isEmpty && !state.bufferReasoning.isEmpty && state.bufferReasoningData.isEmpty
            && state.bufferToolUse.isEmpty
    }

    private static func isTextBufferValid(_ state: StreamState) -> Bool {
        return !state.bufferText.isEmpty && state.bufferReasoning.isEmpty && state.bufferReasoningData.isEmpty
            && state.bufferToolUse.isEmpty
    }
        if !state.bufferText.isEmpty {
            state.lastContentBlock = (state.currentBlockId, Content.text(state.bufferText))
            state.bufferText = ""
        }
        if !state.bufferReasoning.isEmpty {
            let signature = state.bufferReasoningSignature == "" ? nil : state.bufferReasoningSignature
            state.lastContentBlock = (
                state.currentBlockId, .reasoning(.init(state.bufferReasoning, signature: signature))
            )
            state.bufferReasoning = ""
        }
        // TODO: encrypted reasoning is not supported at the moment
        // if !bufferReasoningData.isEmpty {
        //     contentBlock[currentBlockId] = .reasoning(bufferReasoningData)
        //     bufferReasoningData = Data()
        // }
        if !state.bufferToolUse.isEmpty {
            guard let toolUseStart = state.toolUseStart else {
                throw BedrockLibraryError.invalidSDKType("Received a tool use delta without tool use start")
            }
            let json = try JSON(from: state.bufferToolUse)
            state.lastContentBlock = (
                state.currentBlockId, .toolUse(.init(id: toolUseStart.id, name: toolUseStart.name, input: json))
            )
            state.bufferToolUse = ""
        }
        state.currentBlockId = 0
    }

    // a simple struct to buffer whatever content we receive from the SDK
    // until final message is complete
    package struct StreamState {
        package init(with role: Role) {
            self.role = role
        }
        let role: Role
        var messageComplete: Bool = false
        var currentBlockId: Int = -1  // -1 means no block is active
        var bufferText: String = ""
        var bufferReasoning: String = ""
        var bufferReasoningSignature = ""
        var bufferReasoningData = Data()
        var bufferToolUse: String = ""
        var toolUseStart: ToolUseStart? = nil

        // list of content blocks to be accumulated while reading the stream
        var lastContentBlock: (Int, Content)? = nil
        var contentBlocks: [Int: Content] = [:]
    }
}
