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

// Converse text

extension BedrockServiceTests {

    // Prompt
    @Test(
        "Continue conversation using a valid prompt",
        arguments: NovaTestConstants.TextGeneration.validPrompts
    )
    func converseWithValidPrompt(prompt: String) async throws {
        let builder = try ConverseRequestBuilder(with: .nova_micro)
            .withPrompt(prompt)
        let reply = try await bedrock.converse(with: builder)
        #expect(reply.textReply == "Your prompt was: \(prompt)")
    }

    @Test(
        "Continue conversation variation using an invalid prompt",
        arguments: NovaTestConstants.TextGeneration.invalidPrompts
    )
    func converseWithInvalidPrompt(prompt: String) async throws {
        await #expect(throws: BedrockServiceError.self) {
            let builder = try ConverseRequestBuilder(with: .nova_micro)
                .withPrompt(prompt)
            let _ = try await bedrock.converse(with: builder)
        }
    }

    // Continue
    @Test(
        "Continue conversation using a valid prompt and reusing builder",
        arguments: NovaTestConstants.TextGeneration.validPrompts
    )
    func converseWithValidPromptAndReusedBuilder(prompt: String) async throws {
        var builder = try ConverseRequestBuilder(with: .nova_micro)
            .withPrompt(prompt)
        #expect(builder.prompt == prompt)
        var reply = try await bedrock.converse(with: builder)
        #expect(reply.textReply == "Your prompt was: \(prompt)")

        builder = try ConverseRequestBuilder(from: builder, with: reply)
            .withPrompt("New prompt")

        #expect(builder.prompt == "New prompt")

        reply = try await bedrock.converse(with: builder)
        #expect(reply.textReply == "Your prompt was: New prompt")
    }

    @Test("Continue conversation reusing builder")
    func converseWithReusedBuilder() async throws {
        var builder = try ConverseRequestBuilder(with: .nova_micro)
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
        #expect(builder.maxReasoningTokens == nil)

        var reply = try await bedrock.converse(with: builder)
        #expect(reply.textReply == "Your prompt was: First prompt")

        builder = try ConverseRequestBuilder(from: builder, with: reply)
            .withPrompt("Second prompt")

        #expect(builder.prompt == "Second prompt")
        #expect(builder.maxTokens == 100)
        #expect(builder.temperature == 0.5)
        #expect(builder.topP == 0.5)
        #expect(builder.stopSequences == ["\n\nHuman:"])
        #expect(builder.systemPrompts == ["You are a helpful assistant."])
        #expect(builder.history.count == 2)
        #expect(builder.maxReasoningTokens == nil)

        reply = try await bedrock.converse(with: builder)
        #expect(reply.textReply == "Your prompt was: Second prompt")

        builder = try ConverseRequestBuilder(from: builder, with: reply)
            .withPrompt("Third prompt")
            .withTemperature(1)
        #expect(builder.prompt == "Third prompt")
        #expect(builder.temperature == 1)
        #expect(builder.maxTokens == 100)
        #expect(builder.topP == 0.5)
        #expect(builder.stopSequences == ["\n\nHuman:"])
        #expect(builder.systemPrompts == ["You are a helpful assistant."])
        #expect(builder.history.count == 4)
        #expect(builder.maxReasoningTokens == nil)

        reply = try await bedrock.converse(with: builder)
        #expect(reply.textReply == "Your prompt was: Third prompt")
    }

    // Temperature
    @Test(
        "Continue conversation using a valid temperature",
        arguments: NovaTestConstants.TextGeneration.validTemperature
    )
    func converseWithValidTemperature(temperature: Double) async throws {
        let prompt = "This is a test"
        let builder = try ConverseRequestBuilder(with: .nova_micro)
            .withPrompt(prompt)
            .withTemperature(temperature)
        let reply = try await bedrock.converse(with: builder)
        #expect(reply.textReply == "Your prompt was: \(prompt)")
    }

    @Test(
        "Continue conversation variation using an invalid temperature",
        arguments: NovaTestConstants.TextGeneration.invalidTemperature
    )
    func converseWithInvalidTemperature(temperature: Double) async throws {
        await #expect(throws: BedrockServiceError.self) {
            let prompt = "This is a test"
            let builder = try ConverseRequestBuilder(with: .nova_micro)
                .withPrompt(prompt)
                .withTemperature(temperature)
            let _ = try await bedrock.converse(with: builder)
        }
    }

    // MaxTokens
    @Test(
        "Continue conversation using a valid maxTokens",
        arguments: NovaTestConstants.TextGeneration.validMaxTokens
    )
    func converseWithValidMaxTokens(maxTokens: Int) async throws {
        let prompt = "This is a test"
        let builder = try ConverseRequestBuilder(with: .nova_micro)
            .withPrompt(prompt)
            .withMaxTokens(maxTokens)
        let reply = try await bedrock.converse(with: builder)
        #expect(reply.textReply == "Your prompt was: \(prompt)")
    }

    @Test(
        "Continue conversation variation using an invalid maxTokens",
        arguments: NovaTestConstants.TextGeneration.invalidMaxTokens
    )
    func converseWithInvalidMaxTokens(maxTokens: Int) async throws {
        await #expect(throws: BedrockServiceError.self) {
            let prompt = "This is a test"
            let builder = try ConverseRequestBuilder(with: .nova_micro)
                .withPrompt(prompt)
                .withMaxTokens(maxTokens)
            let _ = try await bedrock.converse(with: builder)
        }
    }

    // TopP
    @Test(
        "Continue conversation using a valid temperature",
        arguments: NovaTestConstants.TextGeneration.validTopP
    )
    func converseWithValidTopP(topP: Double) async throws {
        let prompt = "This is a test"
        let builder = try ConverseRequestBuilder(with: .nova_micro)
            .withPrompt(prompt)
            .withTopP(topP)
        let reply = try await bedrock.converse(with: builder)
        #expect(reply.textReply == "Your prompt was: \(prompt)")
    }

    @Test(
        "Continue conversation variation using an invalid temperature",
        arguments: NovaTestConstants.TextGeneration.invalidTopP
    )
    func converseWithInvalidTopP(topP: Double) async throws {
        await #expect(throws: BedrockServiceError.self) {
            let prompt = "This is a test"
            let builder = try ConverseRequestBuilder(with: .nova_micro)
                .withPrompt(prompt)
                .withTopP(topP)
            let _ = try await bedrock.converse(with: builder)
        }
    }

    // StopSequences
    @Test(
        "Continue conversation using a valid stopSequences",
        arguments: NovaTestConstants.TextGeneration.validStopSequences
    )
    func converseWithValidTopK(stopSequences: [String]) async throws {
        let prompt = "This is a test"
        let builder = try ConverseRequestBuilder(with: .nova_micro)
            .withPrompt(prompt)
            .withStopSequences(stopSequences)
        let reply = try await bedrock.converse(with: builder)
        #expect(reply.textReply == "Your prompt was: \(prompt)")
    }
}
