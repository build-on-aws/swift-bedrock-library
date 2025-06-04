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

extension ConverseReplyStreamTests {

    // Helper function to create a simulated stream with a single text block
    func createSingleTextBlockStream() -> AsyncThrowingStream<BedrockRuntimeClientTypes.ConverseStreamOutput, Error> {
        AsyncThrowingStream<BedrockRuntimeClientTypes.ConverseStreamOutput, Error> { continuation in
            // Message start
            let messageStartEvent = BedrockRuntimeClientTypes.MessageStartEvent(
                role: .assistant
            )
            continuation.yield(.messagestart(messageStartEvent))

            // Content block delta (first part)
            let contentBlockDelta1 = BedrockRuntimeClientTypes.ContentBlockDelta.text("Hello, ")
            let contentBlockDeltaEvent1 = BedrockRuntimeClientTypes.ContentBlockDeltaEvent(
                contentBlockIndex: 0,
                delta: contentBlockDelta1
            )
            continuation.yield(.contentblockdelta(contentBlockDeltaEvent1))

            // Content block delta (second part)
            let contentBlockDelta2 = BedrockRuntimeClientTypes.ContentBlockDelta.text("this is ")
            let contentBlockDeltaEvent2 = BedrockRuntimeClientTypes.ContentBlockDeltaEvent(
                contentBlockIndex: 0,
                delta: contentBlockDelta2
            )
            continuation.yield(.contentblockdelta(contentBlockDeltaEvent2))

            // Content block delta (third part)
            let contentBlockDelta3 = BedrockRuntimeClientTypes.ContentBlockDelta.text("a test message.")
            let contentBlockDeltaEvent3 = BedrockRuntimeClientTypes.ContentBlockDeltaEvent(
                contentBlockIndex: 0,
                delta: contentBlockDelta3
            )
            continuation.yield(.contentblockdelta(contentBlockDeltaEvent3))

            // Content block stop
            let contentBlockStopEvent = BedrockRuntimeClientTypes.ContentBlockStopEvent(
                contentBlockIndex: 0
            )
            continuation.yield(.contentblockstop(contentBlockStopEvent))

            // Message stop
            let messageStopEvent = BedrockRuntimeClientTypes.MessageStopEvent(
                additionalModelResponseFields: nil,
                stopReason: nil
            )
            continuation.yield(.messagestop(messageStopEvent))

            continuation.finish()
        }
    }

    // Helper function to create a simulated stream with multiple content blocks
    func createMultipleContentBlocksStream() -> AsyncThrowingStream<
        BedrockRuntimeClientTypes.ConverseStreamOutput, Error
    > {
        AsyncThrowingStream<BedrockRuntimeClientTypes.ConverseStreamOutput, Error> { continuation in
            // Message start
            let messageStartEvent = BedrockRuntimeClientTypes.MessageStartEvent(
                role: .assistant
            )
            continuation.yield(.messagestart(messageStartEvent))

            // First content block
            let contentBlockDelta1 = BedrockRuntimeClientTypes.ContentBlockDelta.text("First block content.")
            let contentBlockDeltaEvent1 = BedrockRuntimeClientTypes.ContentBlockDeltaEvent(
                contentBlockIndex: 0,
                delta: contentBlockDelta1
            )
            continuation.yield(.contentblockdelta(contentBlockDeltaEvent1))

            let contentBlockStopEvent1 = BedrockRuntimeClientTypes.ContentBlockStopEvent(
                contentBlockIndex: 0
            )
            continuation.yield(.contentblockstop(contentBlockStopEvent1))

            // Second content block
            let contentBlockDelta2 = BedrockRuntimeClientTypes.ContentBlockDelta.text("Second block content.")
            let contentBlockDeltaEvent2 = BedrockRuntimeClientTypes.ContentBlockDeltaEvent(
                contentBlockIndex: 1,
                delta: contentBlockDelta2
            )
            continuation.yield(.contentblockdelta(contentBlockDeltaEvent2))

            let contentBlockStopEvent2 = BedrockRuntimeClientTypes.ContentBlockStopEvent(
                contentBlockIndex: 1
            )
            continuation.yield(.contentblockstop(contentBlockStopEvent2))

            // Message stop
            let messageStopEvent = BedrockRuntimeClientTypes.MessageStopEvent(
                additionalModelResponseFields: nil,
                stopReason: .endTurn
            )
            continuation.yield(.messagestop(messageStopEvent))

            continuation.finish()
        }
    }

		// Helper function to create a never-ending stream that will continue indefinitely
    func createNeverEndingStream() -> AsyncThrowingStream<BedrockRuntimeClientTypes.ConverseStreamOutput, Error> {
        AsyncThrowingStream<BedrockRuntimeClientTypes.ConverseStreamOutput, Error> { continuation in
            // Message start
            let messageStartEvent = BedrockRuntimeClientTypes.MessageStartEvent(
                role: .assistant
            )
            continuation.yield(.messagestart(messageStartEvent))

            // Set up a counter to track how many deltas we've sent
            var counter = 0

            // Create a Task that will continuously send content block deltas
            // This simulates a never-ending stream of tokens from the model
            let continuousTask = Task {
                while !Task.isCancelled {
                    // Create a content block delta with a counter to track progress
                    let text = "Token \(counter) "
                    let contentBlockDelta = BedrockRuntimeClientTypes.ContentBlockDelta.text(text)
                    let contentBlockDeltaEvent = BedrockRuntimeClientTypes.ContentBlockDeltaEvent(
                        contentBlockIndex: 0,
                        delta: contentBlockDelta
                    )

                    // Yield the delta
                    continuation.yield(.contentblockdelta(contentBlockDeltaEvent))

                    // Increment counter
                    counter += 1

                    // Add a small delay to avoid overwhelming the system
                    try await Task.sleep(nanoseconds: 10_000_000)  // 10ms
                }

                // If we get here, the task was cancelled
                continuation.finish(throwing: CancellationError())
            }

            // When the stream is terminated, cancel our continuous task
            // this is not necessary for the test, but it's a good practice
            continuation.onTermination = { @Sendable _ in
                continuousTask.cancel()
            }
        }
    } 		
}