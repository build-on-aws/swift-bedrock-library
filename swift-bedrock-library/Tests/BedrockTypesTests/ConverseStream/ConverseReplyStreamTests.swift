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
import Testing

@testable import BedrockTypes

@Suite("ConverseReplyStreamTests")
struct ConverseReplyStreamTests {

    // Helper function to create a simulated stream with a single text block
    func createSingleTextBlockStream() -> AsyncThrowingStream<BedrockRuntimeClientTypes.ConverseStreamOutput, Error> {
        AsyncThrowingStream<BedrockRuntimeClientTypes.ConverseStreamOutput, Error> { continuation in
            // Message start
            let messageStartEvent = BedrockRuntimeClientTypes.MessageStartEvent(
                role: .assistant
            )
            continuation.yield(.messagestart(messageStartEvent))

            // Content block start
            let contentBlockStartEvent = BedrockRuntimeClientTypes.ContentBlockStartEvent(
                contentBlockIndex: 0,
                start: nil
            )
            continuation.yield(.contentblockstart(contentBlockStartEvent))

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
            let contentBlockStartEvent1 = BedrockRuntimeClientTypes.ContentBlockStartEvent(
                contentBlockIndex: 0,
                start: nil
            )
            continuation.yield(.contentblockstart(contentBlockStartEvent1))

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
            let contentBlockStartEvent2 = BedrockRuntimeClientTypes.ContentBlockStartEvent(
                contentBlockIndex: 1,
                start: nil
            )
            continuation.yield(.contentblockstart(contentBlockStartEvent2))

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
                stopReason: nil
            )
            continuation.yield(.messagestop(messageStopEvent))

            continuation.finish()
        }
    }

    @Test("Test streaming text response")
    func testStreamingTextResponse() async throws {
        // Create the ConverseReplyStream from the simulated stream
        let converseReplyStream = ConverseReplyStream(createSingleTextBlockStream())

        // Collect all the stream elements
        var streamElements: [ConverseStreamElement] = []
        for try await element in converseReplyStream.stream {
            streamElements.append(element)
        }

        // Verify the stream elements
        #expect(streamElements.count == 5)

        // Check content segments
        if case .contentSegment(let segment1) = streamElements[0] {
            if case .text(let index1, let text1) = segment1 {
                #expect(index1 == 0)
                #expect(text1 == "Hello, ")
            } else {
                Issue.record("Expected text segment")
            }
        } else {
            Issue.record("Expected contentSegment")
        }

        if case .contentSegment(let segment2) = streamElements[1] {
            if case .text(let index2, let text2) = segment2 {
                #expect(index2 == 0)
                #expect(text2 == "this is ")
            } else {
                Issue.record("Expected text segment")
            }
        } else {
            Issue.record("Expected contentSegment")
        }

        if case .contentSegment(let segment3) = streamElements[2] {
            if case .text(let index3, let text3) = segment3 {
                #expect(index3 == 0)
                #expect(text3 == "a test message.")
            } else {
                Issue.record("Expected text segment")
            }
        } else {
            Issue.record("Expected contentSegment")
        }

        // Check content block complete
        if case .contentBlockComplete(let index, let content) = streamElements[3] {
            #expect(index == 0)
            if case .text(let text) = content {
                #expect(text == "Hello, this is a test message.")
            } else {
                Issue.record("Expected text content")
            }
        } else {
            Issue.record("Expected contentBlockComplete")
        }

        // Check message complete
        if case .messageComplete(let message) = streamElements[4] {
            #expect(message.role == .assistant)
            #expect(message.content.count == 1)
            if case .text(let text) = message.content[0] {
                #expect(text == "Hello, this is a test message.")
            } else {
                Issue.record("Expected text content in message")
            }
        } else {
            Issue.record("Expected messageComplete")
        }
    }

    @Test("Test multiple content blocks")
    func testMultipleContentBlocks() async throws {
        // Create the ConverseReplyStream from the simulated stream
        let converseReplyStream = ConverseReplyStream(createMultipleContentBlocksStream())

        // Collect all the stream elements
        var streamElements: [ConverseStreamElement] = []
        for try await element in converseReplyStream.stream {
            streamElements.append(element)
        }

        // Verify the stream elements
        #expect(streamElements.count == 5)

        // Check first content segment
        if case .contentSegment(let segment1) = streamElements[0] {
            if case .text(let index1, let text1) = segment1 {
                #expect(index1 == 0)
                #expect(text1 == "First block content.")
            } else {
                Issue.record("Expected text segment")
            }
        } else {
            Issue.record("Expected contentSegment")
        }

        // Check first content block complete
        if case .contentBlockComplete(let index1, let content1) = streamElements[1] {
            #expect(index1 == 0)
            if case .text(let text1) = content1 {
                #expect(text1 == "First block content.")
            } else {
                Issue.record("Expected text content")
            }
        } else {
            Issue.record("Expected contentBlockComplete")
        }

        // Check second content segment
        if case .contentSegment(let segment2) = streamElements[2] {
            if case .text(let index2, let text2) = segment2 {
                #expect(index2 == 1)
                #expect(text2 == "Second block content.")
            } else {
                Issue.record("Expected text segment")
            }
        } else {
            Issue.record("Expected contentSegment")
        }

        // Check second content block complete
        if case .contentBlockComplete(let index2, let content2) = streamElements[3] {
            #expect(index2 == 1)
            if case .text(let text2) = content2 {
                #expect(text2 == "Second block content.")
            } else {
                Issue.record("Expected text content")
            }
        } else {
            Issue.record("Expected contentBlockComplete")
        }

        // Check message complete
        if case .messageComplete(let message) = streamElements[4] {
            #expect(message.role == .assistant)
            #expect(message.content.count == 2)
            if case .text(let text1) = message.content[0] {
                #expect(text1 == "First block content.")
            } else {
                Issue.record("Expected text content in first block")
            }
            if case .text(let text2) = message.content[1] {
                #expect(text2 == "Second block content.")
            } else {
                Issue.record("Expected text content in second block")
            }
        } else {
            Issue.record("Expected messageComplete")
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

            // Content block start
            let contentBlockStartEvent = BedrockRuntimeClientTypes.ContentBlockStartEvent(
                contentBlockIndex: 0,
                start: nil
            )
            continuation.yield(.contentblockstart(contentBlockStartEvent))

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

    @Test("Test cancellation of never-ending stream")
    func testCancellationOfNeverEndingStream() async throws {
        // Create the ConverseReplyStream from the simulated never-ending stream
        let converseReplyStream = ConverseReplyStream(createNeverEndingStream())

        // Create a task to consume the stream
        let consumptionTask = Task {
            var count = 0
            for try await element in converseReplyStream.stream {
                if case .contentSegment = element {
                    count += 1
                }
            }
            // this will be reached if the stream finishes (which can not happen here by design) or is cancelled
            return count
        }

        // Wait a short time to ensure the stream has started producing elements
        try await Task.sleep(nanoseconds: 100_000_000)  // 100ms

        // Cancel the consumption task
        consumptionTask.cancel()

        // Wait a short time to allow cancellation to propagate
        try await Task.sleep(nanoseconds: 100_000_000)  // 100ms

        // Try to get another element from the stream, this should return nil as the consumption task was cancelled,
        // which should, in turn also cancel the stream
        // in case the task was not cancelled, we will get a timeout
        let elementReceived = try await performWithTimeout(of: Duration.seconds(0.5)) {
            var receivedElementAfterCancellation = false
            for try await _ in converseReplyStream.stream {
                receivedElementAfterCancellation = true
                break
            }
            return receivedElementAfterCancellation
        }
        // and we should not have receive any elements after cancellation
        #expect(elementReceived == false)
    }

    @Test("Test timeout handling")
    func testTimeout() async throws {

        let _ = await #expect(throws: TimeoutError.self) {
            try await performWithTimeout(of: .seconds(0.5)) {
                // long task
                try await Task.sleep(for: .seconds(1))
            }
        }
    }

    @Test("Test no timeout ")
    func testNoTimeout() async throws {
        await #expect(throws: Never.self) {
            try await performWithTimeout(of: .seconds(1)) {
                // long task
                try await Task.sleep(for: .seconds(0.5))
            }
        }
    }

    enum TimeoutError: Error {
        case timeout
    }

    func performWithTimeout<T: Sendable>(
        of timeout: Duration,
        _ work: @Sendable @escaping () async throws -> T
    ) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            // Start the actual work
            group.addTask {
                try await work()
            }
            // Start the timeout task
            group.addTask {
                try await Task.sleep(until: .now + timeout)
                throw TimeoutError.timeout
            }
            // Return the result of the first task to finish
            let result = try await group.next()!
            group.cancelAll()  // Cancel the other task
            return result
        }
    }

}
