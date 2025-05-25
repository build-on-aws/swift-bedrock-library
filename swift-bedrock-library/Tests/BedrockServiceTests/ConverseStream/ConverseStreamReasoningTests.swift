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

    @Test("Streaming converse with reasoning")
    func streamingConverseReasoning() async throws {

        // First call, with reasoning enabled
        var prompt = "What is this?"
        var builder = try ConverseRequestBuilder(with: .claudev3_7_sonnet)
            .withPrompt(prompt)
            .withReasoning()

        #expect(builder.prompt == prompt)
        #expect(builder.enableReasoning == true)
        #expect(builder.maxReasoningTokens == 4096)
        #expect(builder.history.count == 0)

        var stream = try await bedrock.converseStream(with: builder)
        var message: Message = try await validateStream(stream, elementsCount: 6)

        try checkReasoningContent(message)
        try checkTextContent(message, prompt: prompt)

        // Second call, still with reasoning enabled
        prompt = "Second prompt"
        builder = try ConverseRequestBuilder(from: builder, with: message)
            .withPrompt(prompt)

        #expect(builder.prompt == prompt)
        #expect(builder.enableReasoning == true)
        #expect(builder.maxReasoningTokens == 4096)
        #expect(builder.history.count == 2)

        stream = try await bedrock.converseStream(with: builder)
        message = try await validateStream(stream, elementsCount: 6)

        try checkReasoningContent(message)
        try checkTextContent(message, prompt: prompt)

        // Third call, without reasoning enabled
        prompt = "Third prompt"
        builder = try ConverseRequestBuilder(from: builder, with: message)
            .withPrompt(prompt)
            .withReasoning(false)

        #expect(builder.prompt == prompt)
        #expect(builder.enableReasoning == false)
        #expect(builder.maxReasoningTokens == nil)
        #expect(builder.history.count == 4)

        stream = try await bedrock.converseStream(with: builder)
        message = try await validateStream(stream, elementsCount: 6, contentCount: 1)
        try checkTextContent(message, prompt: prompt)
        try checkReasoningContent(message, hasReasoningContent: false)
    }

    // MARK - helper functions

    func validateStream(
        _ stream: AsyncThrowingStream<ConverseStreamElement, Error>,
        elementsCount: Int,
        contentCount: Int = 1
    ) async throws -> Message {
        var streamElements: [ConverseStreamElement] = []
        for try await element in stream {
            streamElements.append(element)
        }

        #expect(streamElements.count == elementsCount)

        if case .messageComplete(let message) = streamElements.last {
            #expect(message.role == .assistant)
            #expect(message.content.count == contentCount)
            return message
        } else {
            Issue.record("Expected message")
            return Message("WRONG")
        }
    }

    func checkTextContent(_ message: Message, prompt: String) throws {
        if case .text(let text) = message.content.last {
            #expect(text == "Hello, your prompt was: \(prompt)")
        }
    }

    func checkReasoningContent(_ message: Message, hasReasoningContent: Bool = true) throws {
        if hasReasoningContent {
            if case .reasoning(let reasoning) = message.content.first {
                #expect(reasoning.reasoning == "reasoning text")
            }
        } else {
            if case .reasoning = message.content.first {
                Issue.record("Expected no reasoning text")
            }
        }
    }
}
