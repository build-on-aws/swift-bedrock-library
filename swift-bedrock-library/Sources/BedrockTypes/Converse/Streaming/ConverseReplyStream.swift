//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Foundation Models Playground open source project
//
// Copyright (c) 2025 Amazon.com, Inc. or its affiliates
//                    and the Swift Foundation Models Playground project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of Swift Foundation Models Playground project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//
@preconcurrency import AWSBedrockRuntime

// To consider: do we want the developer to use ConverseReplyStream or do we simply use it to return the stream?
// This will determine the visibility
package struct ConverseReplyStream {
    package var stream: AsyncThrowingStream<ConverseStreamElement, Error>

    package init(_ inputStream: AsyncThrowingStream<BedrockRuntimeClientTypes.ConverseStreamOutput, Error>) {

        self.stream = AsyncThrowingStream(ConverseStreamElement.self) { continuation in
            let t = Task {
                var indexes: [Int] = []
                var contentParts: [ContentSegment] = []
                var content: [Content] = []
                var toolUseStarts: [ToolUseStart] = []
                do {
                    for try await output in inputStream {
                        switch output {
                        case .contentblockstart(let event):
                            guard let index = event.contentBlockIndex else {
                                throw BedrockServiceError.invalidSDKType(
                                    "No contentBlockIndex found in ContentBlockStart"
                                )
                            }
                            indexes.append(index)
                            if let start: BedrockRuntimeClientTypes.ContentBlockStart = event.start {
                                if case .tooluse(let toolUseBlockStart) = start {
                                    toolUseStarts.append(
                                        try ToolUseStart(index: index, sdkToolUseStart: toolUseBlockStart)
                                    )
                                }
                            }
                        case .contentblockdelta(let event):
                            guard let index = event.contentBlockIndex else {
                                throw BedrockServiceError.invalidSDKType(
                                    "No contentBlockIndex found in ContentBlockDelta"
                                )
                            }
                            if !indexes.contains(index) {
                                indexes.append(index)
                            }
                            guard let delta = event.delta else {
                                throw BedrockServiceError.invalidSDKType("No delta found in ContentBlockDelta")
                            }
                            let segment = try ContentSegment(
                                index: index,
                                sdkContentBlockDelta: delta,
                                toolUseStarts: toolUseStarts
                            )
                            contentParts.append(segment)
                            continuation.yield(.contentSegment(segment))

                        case .contentblockstop(let event):
                            guard let completedIndex = event.contentBlockIndex else {
                                throw BedrockServiceError.invalidSDKType(
                                    "No contentBlockIndex found in ContentBlockStop"
                                )
                            }
                            guard indexes.contains(completedIndex) else {
                                throw BedrockServiceError.streamingError(
                                    "No matching index from ContentBlockStart or ContentBlockDelta found for index from ContentBlockStop"
                                )
                            }
                            let contentBlock = try Content.getFromSegements(with: completedIndex, from: contentParts)
                            content.append(contentBlock)
                            continuation.yield(.contentBlockComplete(completedIndex, contentBlock))

                        case .messagestop(_):
                            let message = Message(from: .assistant, content: content)
                            continuation.yield(.messageComplete(message))
                            continuation.finish()

                        default:
                            break
                        }
                    }
                    // when we reach here, the stream is finished or the Task is cancelled
                    // when cancelled, it will throw CancellationError
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
}
