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
import Testing

@testable import BedrockService

@Suite("ConverseReplyStreamTests")
struct ConverseReplyStreamTests {

    let bedrock: BedrockService

    init() async throws {
        self.bedrock = try await BedrockService(
            bedrockClient: MockBedrockClient(),
            bedrockRuntimeClient: MockBedrockRuntimeClient()
        )
    }

    @Test("Test streaming text response")
    func testStreamingTextResponse() async throws {
        // Create the ConverseReplyStream from the simulated stream
        let converseReplyStream = try ConverseReplyStream(createSingleTextBlockStream())

        // Collect all the stream elements
        var streamElements: [ConverseStreamElement] = []
        for try await element in converseReplyStream.stream {
            streamElements.append(element)
        }

        // Verify the stream elements
        #expect(streamElements.count == 5)

        // Check content segments
        if case .messageStart(let segment1) = streamElements[0] {
            #expect(segment1 == .assistant)
        } else {
            Issue.record("Expected messageStart")
        }

        if case .text(let blockId, let textDelta) = streamElements[1] {
            #expect(blockId == 0)
            #expect(textDelta == "Hello, ")
        } else {
            Issue.record("Expected text segment")
        }

        // no need t test each text delta, let's skip to ful message

        // Check content block complete
        if case .messageComplete(let message) = streamElements[4] {
            #expect(message.role == .assistant)
            #expect(message.content.count == 1)
            if case .text(let text) = message.content[0] {
                #expect(text == "Hello, this is a test message.")
            } else {
                Issue.record("Expected text content in message")
            }
        } else {
            Issue.record("Expected a full message")
        }
    }

    @Test("Test multiple content blocks")
    func testMultipleContentBlocks() async throws {
        // Create the ConverseReplyStream from the simulated stream
        let converseReplyStream = try ConverseReplyStream(createMultipleContentBlocksStream())

        // Collect all the stream elements
        var streamElements: [ConverseStreamElement] = []
        for try await element in converseReplyStream.stream {
            streamElements.append(element)
        }

        // Verify the stream elements
        #expect(streamElements.count == 4)

        // Check first event
        if case .messageStart(let segment1) = streamElements[0] {
            #expect(segment1 == .assistant)
        } else {
            Issue.record("Expected messageStart")
        }

        // Check first content segment
        if case .text(let index1, let content1) = streamElements[1] {
            #expect(index1 == 0)
            #expect(content1 == "First block content.")
        } else {
            Issue.record("Expected contentBlockComplete")
        }

        // Check second content segment
        if case .text(let index1, let content1) = streamElements[2] {
            #expect(index1 == 1)
            #expect(content1 == "Second block content.")
        } else {
            Issue.record("Expected contentBlockComplete")
        }

        // Check message complete
        if case .messageComplete(let message) = streamElements[3] {
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

    @Test("Test cancellation of never-ending stream")
    func testCancellationOfNeverEndingStream() async throws {
        // Create the ConverseReplyStream from the simulated never-ending stream
        let converseReplyStream = try ConverseReplyStream(createNeverEndingStream())

        // Create a task to consume the stream
        let consumptionTask = Task {
            var count = 0
            for try await element in converseReplyStream.stream {
                if case .text = element {
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
