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

import Foundation
import Testing

@testable import BedrockService

@Suite("ChatCompletions Response Tests")
struct ChatCompletionsResponseTests {

    // MARK: - Successful decoding of a valid Chat Completions JSON response

    @Test("Decodes a valid Chat Completions JSON response")
    func decodesValidResponse() throws {
        let json = """
            {
                "id": "chatcmpl-abc123",
                "choices": [
                    {
                        "finish_reason": "stop",
                        "index": 0,
                        "message": {"content": "Hello, world!", "role": "assistant"}
                    }
                ],
                "created": 1234567890,
                "model": "google.gemma-4-31b",
                "object": "chat.completion",
                "usage": {"completion_tokens": 5, "prompt_tokens": 10, "total_tokens": 15}
            }
            """
        let data = try #require(json.data(using: .utf8))
        let raw = try JSONDecoder().decode(ChatCompletionsRawOutput.self, from: data)
        let output = try ChatCompletionsOutput(from: raw)

        #expect(output.id == "chatcmpl-abc123")
        #expect(output.model == "google.gemma-4-31b")
        #expect(output.text == "Hello, world!")
        #expect(output.usage.promptTokens == 10)
        #expect(output.usage.completionTokens == 5)
        #expect(output.usage.totalTokens == 15)
    }

    // MARK: - Text field is extracted from first choices[0].message.content

    @Test("Text is extracted from first choice message content")
    func textExtractedFromFirstChoice() throws {
        let json = """
            {
                "id": "chatcmpl-xyz789",
                "choices": [
                    {
                        "finish_reason": "stop",
                        "index": 0,
                        "message": {"content": "First choice content", "role": "assistant"}
                    },
                    {
                        "finish_reason": "stop",
                        "index": 1,
                        "message": {"content": "Second choice content", "role": "assistant"}
                    }
                ],
                "created": 1234567890,
                "model": "google.gemma-4-26b-a4b",
                "object": "chat.completion",
                "usage": {"completion_tokens": 20, "prompt_tokens": 8, "total_tokens": 28}
            }
            """
        let data = try #require(json.data(using: .utf8))
        let raw = try JSONDecoder().decode(ChatCompletionsRawOutput.self, from: data)
        let output = try ChatCompletionsOutput(from: raw)

        #expect(output.text == "First choice content")
    }

    // MARK: - Empty choices array throws completionNotFound

    @Test("Empty choices array throws completionNotFound")
    func emptyChoicesThrowsCompletionNotFound() throws {
        let json = """
            {
                "id": "chatcmpl-empty",
                "choices": [],
                "created": 1234567890,
                "model": "google.gemma-4-31b",
                "object": "chat.completion",
                "usage": {"completion_tokens": 0, "prompt_tokens": 10, "total_tokens": 10}
            }
            """
        let data = try #require(json.data(using: .utf8))
        let raw = try JSONDecoder().decode(ChatCompletionsRawOutput.self, from: data)

        #expect(throws: BedrockLibraryError.self) {
            _ = try ChatCompletionsOutput(from: raw)
        }
    }

    // MARK: - Invalid JSON throws a decoding error

    @Test("Invalid JSON throws a decoding error")
    func invalidJSONThrowsDecodingError() throws {
        let invalidJSON = "{ not valid json at all }"
        let data = try #require(invalidJSON.data(using: .utf8))

        #expect(throws: DecodingError.self) {
            _ = try JSONDecoder().decode(ChatCompletionsRawOutput.self, from: data)
        }
    }

    @Test("Missing required field throws a decoding error")
    func missingFieldThrowsDecodingError() throws {
        let json = """
            {
                "id": "chatcmpl-abc123",
                "choices": [],
                "created": 1234567890,
                "object": "chat.completion",
                "usage": {"completion_tokens": 0, "prompt_tokens": 10, "total_tokens": 10}
            }
            """
        let data = try #require(json.data(using: .utf8))

        #expect(throws: DecodingError.self) {
            _ = try JSONDecoder().decode(ChatCompletionsRawOutput.self, from: data)
        }
    }

    // MARK: - OpenAIResponseBody decoding for Gemma 3 InvokeModel responses

    @Test("OpenAIResponseBody decodes Gemma 3 InvokeModel response and extracts completion text")
    func openAIResponseBodyDecodesGemma3Response() throws {
        let json = """
            {
                "id": "chatcmpl-gemma3",
                "choices": [
                    {
                        "finish_reason": "stop",
                        "index": 0,
                        "message": {"content": "Gemma 3 generated text", "role": "assistant"}
                    }
                ],
                "created": 1234567890,
                "model": "google.gemma-3-27b-it",
                "object": "chat.completion",
                "usage": {"completion_tokens": 12, "prompt_tokens": 5, "total_tokens": 17}
            }
            """
        let data = try #require(json.data(using: .utf8))
        let responseBody = try JSONDecoder().decode(OpenAIResponseBody.self, from: data)
        let textCompletion = try responseBody.getTextCompletion()

        #expect(textCompletion.completion == "Gemma 3 generated text")
    }

    @Test("OpenAIResponseBody with empty choices throws completionNotFound")
    func openAIResponseBodyEmptyChoicesThrows() throws {
        let json = """
            {
                "id": "chatcmpl-empty",
                "choices": [],
                "created": 1234567890,
                "model": "google.gemma-3-12b-it",
                "object": "chat.completion",
                "usage": {"completion_tokens": 0, "prompt_tokens": 5, "total_tokens": 5}
            }
            """
        let data = try #require(json.data(using: .utf8))
        let responseBody = try JSONDecoder().decode(OpenAIResponseBody.self, from: data)

        #expect(throws: BedrockLibraryError.self) {
            _ = try responseBody.getTextCompletion()
        }
    }

    // MARK: - Property-Based Tests

    // Feature: gemma4-model-support, Property 5: Response parsing preserves content text
    // Validates: Requirements 12.1, 12.2
    @Test(
        "Response parsing preserves content text across random inputs",
        arguments: ChatCompletionsResponseTests.randomContentStrings
    )
    func responseParsingPreservesContentText(content: String) throws {
        let json = """
            {
                "id": "chatcmpl-xxx",
                "choices": [{"finish_reason": "stop", "index": 0, "message": {"content": "\(content)", "role": "assistant"}}],
                "created": 1234567890,
                "model": "google.gemma-4-31b",
                "object": "chat.completion",
                "usage": {"completion_tokens": 10, "prompt_tokens": 5, "total_tokens": 15}
            }
            """
        let data = try #require(json.data(using: .utf8))
        let raw = try JSONDecoder().decode(ChatCompletionsRawOutput.self, from: data)
        let output = try ChatCompletionsOutput(from: raw)

        #expect(output.text == content)
    }

    // Feature: gemma4-model-support, Property 6: InvokeModel response parsing preserves content
    // Validates: Requirements 16.5, 20.1, 20.2
    @Test(
        "InvokeModel response parsing preserves content text (Gemma 3)",
        arguments: ChatCompletionsResponseTests.randomContentStrings
    )
    func invokeModelResponseParsingPreservesContentTextGemma3(content: String) throws {
        let json = """
            {
                "id": "chatcmpl-xxx",
                "choices": [{"finish_reason": "stop", "index": 0, "message": {"content": "\(content)", "role": "assistant"}}],
                "created": 1234567890,
                "model": "google.gemma-3-27b-it",
                "object": "chat.completion",
                "usage": {"completion_tokens": 10, "prompt_tokens": 5, "total_tokens": 15}
            }
            """
        let data = try #require(json.data(using: .utf8))
        let gemma3 = Gemma3Text(
            parameters: TextGenerationParameters(
                temperature: Parameter(.temperature, minValue: 0, maxValue: 2, defaultValue: 1),
                maxTokens: Parameter(.maxTokens, minValue: 1, maxValue: 8192, defaultValue: 8192),
                topP: Parameter(.topP, minValue: 0, maxValue: 1, defaultValue: 1),
                topK: Parameter.notSupported(.topK),
                stopSequences: StopSequenceParams.notSupported(),
                maxPromptSize: nil
            )
        )
        let responseBody = try gemma3.getTextResponseBody(from: data)
        let textCompletion = try responseBody.getTextCompletion()
        #expect(textCompletion.completion == content)
    }

    /// Generates 100 random alphanumeric content strings (1–200 chars) for property testing.
    static let randomContentStrings: [String] = {
        let alphanumeric = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var strings: [String] = []
        for _ in 0..<100 {
            let length = Int.random(in: 1...200)
            let content = String((0..<length).map { _ in alphanumeric.randomElement()! })
            strings.append(content)
        }
        return strings
    }()
}
