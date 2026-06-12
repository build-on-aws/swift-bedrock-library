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
import Foundation
import Testing

@testable import BedrockService

@Suite("ChatCompletions Request Tests")
struct ChatCompletionsRequestTests {

    // MARK: - ChatCompletionsRequestBody encodes required fields correctly

    @Test("Request body encodes model field correctly")
    func encodesModelField() throws {
        let body = ChatCompletionsRequestBody(
            model: "google.gemma-4-31b",
            max_completion_tokens: 8192,
            messages: [ChatCompletionsMessage(role: .user, content: "Hello")],
            service_tier: "default",
            temperature: nil,
            top_p: nil
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(body)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["model"] as? String == "google.gemma-4-31b")
    }

    @Test("Request body encodes max_completion_tokens field correctly")
    func encodesMaxCompletionTokensField() throws {
        let body = ChatCompletionsRequestBody(
            model: "google.gemma-4-31b",
            max_completion_tokens: 4096,
            messages: [ChatCompletionsMessage(role: .user, content: "Hello")],
            service_tier: "default",
            temperature: nil,
            top_p: nil
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(body)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["max_completion_tokens"] as? Int == 4096)
    }

    @Test("Request body encodes messages field correctly")
    func encodesMessagesField() throws {
        let body = ChatCompletionsRequestBody(
            model: "google.gemma-4-31b",
            max_completion_tokens: 8192,
            messages: [
                ChatCompletionsMessage(role: .user, content: "What is Swift?")
            ],
            service_tier: "default",
            temperature: nil,
            top_p: nil
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(body)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        let messages = try #require(json["messages"] as? [[String: String]])
        #expect(messages.count == 1)
        #expect(messages[0]["role"] == "user")
        #expect(messages[0]["content"] == "What is Swift?")
    }

    @Test("Request body encodes service_tier field correctly")
    func encodesServiceTierField() throws {
        let body = ChatCompletionsRequestBody(
            model: "google.gemma-4-31b",
            max_completion_tokens: 8192,
            messages: [ChatCompletionsMessage(role: .user, content: "Hello")],
            service_tier: "priority",
            temperature: nil,
            top_p: nil
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(body)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["service_tier"] as? String == "priority")
    }

    // MARK: - Default service tier is "default" when not specified

    @Test("Default service tier value is 'default'")
    func defaultServiceTierIsDefault() throws {
        let body = ChatCompletionsRequestBody(
            model: "google.gemma-4-31b",
            max_completion_tokens: 8192,
            messages: [ChatCompletionsMessage(role: .user, content: "Hello")],
            service_tier: "default",
            temperature: nil,
            top_p: nil
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(body)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["service_tier"] as? String == "default")
    }

    // MARK: - Optional temperature and top_p fields are omitted when nil

    @Test("Temperature is omitted from JSON when nil")
    func temperatureOmittedWhenNil() throws {
        let body = ChatCompletionsRequestBody(
            model: "google.gemma-4-31b",
            max_completion_tokens: 8192,
            messages: [ChatCompletionsMessage(role: .user, content: "Hello")],
            service_tier: "default",
            temperature: nil,
            top_p: nil
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(body)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["temperature"] == nil)
    }

    @Test("top_p is omitted from JSON when nil")
    func topPOmittedWhenNil() throws {
        let body = ChatCompletionsRequestBody(
            model: "google.gemma-4-31b",
            max_completion_tokens: 8192,
            messages: [ChatCompletionsMessage(role: .user, content: "Hello")],
            service_tier: "default",
            temperature: nil,
            top_p: nil
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(body)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["top_p"] == nil)
    }

    @Test("Temperature is present in JSON when set")
    func temperaturePresentWhenSet() throws {
        let body = ChatCompletionsRequestBody(
            model: "google.gemma-4-31b",
            max_completion_tokens: 8192,
            messages: [ChatCompletionsMessage(role: .user, content: "Hello")],
            service_tier: "default",
            temperature: 0.7,
            top_p: nil
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(body)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["temperature"] as? Double == 0.7)
    }

    @Test("top_p is present in JSON when set")
    func topPPresentWhenSet() throws {
        let body = ChatCompletionsRequestBody(
            model: "google.gemma-4-31b",
            max_completion_tokens: 8192,
            messages: [ChatCompletionsMessage(role: .user, content: "Hello")],
            service_tier: "default",
            temperature: nil,
            top_p: 0.9
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(body)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["top_p"] as? Double == 0.9)
    }

    // MARK: - ChatCompletionsMessage serialization with role and content

    @Test("ChatCompletionsMessage encodes role and content")
    func messageEncodesRoleAndContent() throws {
        let message = ChatCompletionsMessage(role: .assistant, content: "Hi there!")

        let encoder = JSONEncoder()
        let data = try encoder.encode(message)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["role"] as? String == "assistant")
        #expect(json["content"] as? String == "Hi there!")
    }

    @Test("Multiple messages serialize correctly in request body")
    func multipleMessagesSerializeCorrectly() throws {
        let body = ChatCompletionsRequestBody(
            model: "google.gemma-3-27b-it",
            max_completion_tokens: 2048,
            messages: [
                ChatCompletionsMessage(role: .system, content: "You are helpful."),
                ChatCompletionsMessage(role: .user, content: "Hello"),
            ],
            service_tier: "default",
            temperature: 1.0,
            top_p: nil
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(body)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        let messages = try #require(json["messages"] as? [[String: String]])
        #expect(messages.count == 2)
        #expect(messages[0]["role"] == "system")
        #expect(messages[0]["content"] == "You are helpful.")
        #expect(messages[1]["role"] == "user")
        #expect(messages[1]["content"] == "Hello")
    }

    // MARK: - Property-Based Tests

    // Feature: gemma4-model-support, Property 3: Request serialization contains required fields
    // Validates: Requirements 10.2, 11.2
    @Test(
        "Request serialization always contains required fields",
        arguments: ChatCompletionsRequestTests.randomRequestInputs
    )
    func requestSerializationContainsRequiredFields(input: (prompt: String, maxTokens: Int)) throws {
        let body = ChatCompletionsRequestBody(
            model: "google.gemma-4-31b",
            max_completion_tokens: input.maxTokens,
            messages: [ChatCompletionsMessage(role: .user, content: input.prompt)],
            service_tier: "default",
            temperature: nil,
            top_p: nil
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(body)
        let json = try #require(try JSONSerialization.jsonObject(with: data) as? [String: Any])

        #expect(json["model"] != nil, "JSON must contain 'model' key")
        #expect(json["max_completion_tokens"] != nil, "JSON must contain 'max_completion_tokens' key")
        #expect(json["messages"] != nil, "JSON must contain 'messages' key")
        #expect(json["service_tier"] != nil, "JSON must contain 'service_tier' key")
    }

    /// Generates 100 random (prompt, maxTokens) pairs for property testing.
    static let randomRequestInputs: [(prompt: String, maxTokens: Int)] = {
        let alphanumeric = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var inputs: [(String, Int)] = []
        for _ in 0..<100 {
            let length = Int.random(in: 1...500)
            let prompt = String((0..<length).map { _ in alphanumeric.randomElement()! })
            let maxTokens = Int.random(in: 1...8192)
            inputs.append((prompt, maxTokens))
        }
        return inputs
    }()

    // Feature: gemma4-model-support, Property 4: Unsupported parameter combinations throw errors
    // Validates: Requirements 10.4, 10.5, 11.3, 11.4, 20.4, 20.5

    @Test(
        "Both temperature and topP provided throws notSupported",
        arguments: ChatCompletionsRequestTests.randomTemperatureTopPPairs
    )
    func bothTemperatureAndTopPThrows(pair: (temperature: Double, topP: Double)) async throws {
        CommonRuntimeKit.initialize()
        let bedrock = try await BedrockService(
            region: .useast1,
            bedrockClient: MockBedrockClient(),
            bedrockRuntimeClient: MockBedrockRuntimeClient()
        )

        await #expect(throws: BedrockLibraryError.self) {
            _ = try await bedrock.completeChatCompletion(
                "Hello",
                with: .gemma4_31b,
                temperature: pair.temperature,
                topP: pair.topP,
                authentication: .apiKey(key: "test-key"),
                mantleClient: MockBedrockMantleChatCompletionsClient()
            )
        }
    }

    @Test(
        "TopK provided throws notSupported for Gemma 3",
        arguments: ChatCompletionsRequestTests.randomTopKValues
    )
    func topKThrowsForGemma3(topK: Int) async throws {
        CommonRuntimeKit.initialize()
        let bedrock = try await BedrockService(
            region: .useast1,
            bedrockClient: MockBedrockClient(),
            bedrockRuntimeClient: MockBedrockRuntimeClient()
        )

        await #expect(throws: BedrockLibraryError.self) {
            let _: TextCompletion = try await bedrock.completeText(
                "Hello",
                with: .gemma3_27b_it,
                topK: topK
            )
        }
    }

    /// Generates 100 random (temperature, topP) pairs where both are non-nil.
    static let randomTemperatureTopPPairs: [(temperature: Double, topP: Double)] = {
        var pairs: [(Double, Double)] = []
        for _ in 0..<100 {
            let temperature = Double.random(in: 0...2)
            let topP = Double.random(in: 0...1)
            pairs.append((temperature, topP))
        }
        return pairs
    }()

    /// Generates 100 random non-nil topK values.
    static let randomTopKValues: [Int] = {
        var values: [Int] = []
        for _ in 0..<100 {
            values.append(Int.random(in: 1...100))
        }
        return values
    }()
}
