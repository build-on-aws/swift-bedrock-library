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

import AwsCommonRuntimeKit
import Testing

@testable import BedrockService

@Suite("Chat Completions Service Tests")
struct ChatCompletionsServiceTests {
    let bedrock: BedrockService

    init() async throws {
        CommonRuntimeKit.initialize()
        self.bedrock = try await BedrockService(
            region: .useast1,
            bedrockClient: MockBedrockClient(),
            bedrockRuntimeClient: MockBedrockRuntimeClient()
        )
    }

    // MARK: - completeChatCompletion

    @Test("completeChatCompletion with Gemma 4 model returns correct output")
    func completeChatCompletionGemma4() async throws {
        let output = try await bedrock.completeChatCompletion(
            "Hello from Gemma 4",
            with: .gemma4_31b,
            authentication: .apiKey(key: "test-key"),
            mantleClient: MockBedrockMantleChatCompletionsClient()
        )

        #expect(output.text == "Mock completion for: Hello from Gemma 4")
        #expect(output.model == "google.gemma-4-31b")
        #expect(output.id == "chatcmpl-mock")
        #expect(output.usage.promptTokens == 5)
        #expect(output.usage.completionTokens == 10)
        #expect(output.usage.totalTokens == 15)
    }

    @Test("completeChatCompletion with Gemma 3 model returns correct output")
    func completeChatCompletionGemma3() async throws {
        let output = try await bedrock.completeChatCompletion(
            "Hello from Gemma 3",
            with: .gemma3_27b_it,
            authentication: .apiKey(key: "test-key"),
            mantleClient: MockBedrockMantleChatCompletionsClient()
        )

        #expect(output.text == "Mock completion for: Hello from Gemma 3")
        #expect(output.model == "google.gemma-3-27b-it")
        #expect(output.id == "chatcmpl-mock")
        #expect(output.usage.promptTokens == 5)
        #expect(output.usage.completionTokens == 10)
        #expect(output.usage.totalTokens == 15)
    }

    @Test("completeChatCompletion throws invalidModality for model without ChatCompletionsModality")
    func completeChatCompletionThrowsForInvalidModel() async throws {
        await #expect(throws: BedrockLibraryError.self) {
            _ = try await bedrock.completeChatCompletion(
                "Hello",
                with: .nova_micro,
                authentication: .apiKey(key: "test-key"),
                mantleClient: MockBedrockMantleChatCompletionsClient()
            )
        }
    }

    @Test("completeChatCompletion throws notSupported when both temperature and topP are provided")
    func completeChatCompletionThrowsForBothTemperatureAndTopP() async throws {
        await #expect(throws: BedrockLibraryError.self) {
            _ = try await bedrock.completeChatCompletion(
                "Hello",
                with: .gemma4_31b,
                temperature: 0.5,
                topP: 0.9,
                authentication: .apiKey(key: "test-key"),
                mantleClient: MockBedrockMantleChatCompletionsClient()
            )
        }
    }

    // MARK: - createResponse (Responses API with Gemma 4)

    @Test("createResponse with Gemma 4 model works via Responses API")
    func createResponseGemma4() async throws {
        let output = try await bedrock.createResponse(
            "Tell me about Gemma 4",
            with: .gemma4_31b,
            authentication: .apiKey(key: "test-key"),
            mantleClient: MockBedrockMantleClient()
        )

        #expect(output.text == "Mock response for: Tell me about Gemma 4")
        #expect(output.model == .gemma4_31b)
        #expect(output.id == "resp_mock_123")
        #expect(output.usage.inputTokens == 10)
        #expect(output.usage.outputTokens == 20)
    }

    // MARK: - completeText (InvokeModel with Gemma 3)

    @Test("completeText with Gemma 3 model via InvokeModel works")
    func completeTextGemma3() async throws {
        let completion: TextCompletion = try await bedrock.completeText(
            "Hello Gemma 3",
            with: .gemma3_27b_it
        )

        #expect(completion.completion == "Mock response for: Hello Gemma 3")
    }

    @Test("completeText with Gemma 3 throws when both temperature and topP provided")
    func completeTextGemma3ThrowsForBothTemperatureAndTopP() async throws {
        await #expect(throws: BedrockLibraryError.self) {
            let _: TextCompletion = try await bedrock.completeText(
                "Hello",
                with: .gemma3_27b_it,
                temperature: 0.5,
                topP: 0.9
            )
        }
    }

    @Test("completeText with Gemma 3 throws when topK is provided")
    func completeTextGemma3ThrowsForTopK() async throws {
        await #expect(throws: BedrockLibraryError.self) {
            let _: TextCompletion = try await bedrock.completeText(
                "Hello",
                with: .gemma3_27b_it,
                topK: 10
            )
        }
    }
}
