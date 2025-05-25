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

import Testing

@testable import BedrockService
@testable import BedrockTypes

// MARK - Streaming converse tekst

extension BedrockServiceTests {

    @Test("Continue conversation reusing builder")
    func converseStreamWithReusedBuilder() async throws {
        var builder = try ConverseRequestBuilder(with: .nova_lite)
            .withPrompt("First prompt")
            .withMaxTokens(100)
            .withTemperature(0.5)
            .withTopP(0.5)
            .withStopSequence("\n\nHuman:")
            .withSystemPrompt("You are a helpful assistant.")

        #expect(builder.prompt == "First prompt")
        #expect(builder.maxTokens == 100)
        #expect(builder.temperature == 0.5)
        #expect(builder.topP == 0.5)
        #expect(builder.stopSequences == ["\n\nHuman:"])
        #expect(builder.systemPrompts == ["You are a helpful assistant."])

        var stream = try await bedrock.converseStream(with: builder)

        // Collect all the stream elements
        var streamElements: [ConverseStreamElement] = []
        for try await element in stream {
            streamElements.append(element)
        }

        // Verify the stream elements
        #expect(streamElements.count == 6)

        var message: Message = Message("")
        if case .messageComplete(let msg) = streamElements.last {
            message = msg
        } else {
            Issue.record("Expected message")
        }

        #expect(message.content.count == 1)
        #expect(message.role == .assistant)

        if case .text(let text) = message.content.last {
            #expect(text == "Hello, your prompt was: First prompt")
        }

        builder = try ConverseRequestBuilder(from: builder, with: message)
            .withPrompt("Second prompt")
        #expect(builder.prompt == "Second prompt")
        #expect(builder.maxTokens == 100)
        #expect(builder.temperature == 0.5)
        #expect(builder.topP == 0.5)
        #expect(builder.stopSequences == ["\n\nHuman:"])
        #expect(builder.systemPrompts == ["You are a helpful assistant."])
        #expect(builder.history.count == 2)

        stream = try await bedrock.converseStream(with: builder)
        // Collect all the stream elements
        streamElements = []
        for try await element in stream {
            streamElements.append(element)
        }

        // Verify the stream elements
        #expect(streamElements.count == 6)

        message = Message("")
        if case .messageComplete(let msg) = streamElements.last {
            message = msg
        } else {
            Issue.record("Expected message")
        }

        #expect(message.content.count == 1)
        #expect(message.role == .assistant)

        if case .text(let text) = message.content.last {
            #expect(text == "Hello, your prompt was: Second prompt")
        }
    }
}
