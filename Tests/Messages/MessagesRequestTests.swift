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

@Suite("Messages Request Tests")
struct MessagesRequestTests {

    @Test("Request body encodes model and messages correctly")
    func requestBodyEncoding() throws {
        let request = MessagesRequestBody(
            model: .claude_fable_v5,
            maxTokens: 1024,
            messages: [AnthropicMessage(role: .user, content: "Hello")]
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        #expect(json?["anthropic_version"] as? String == "bedrock-2023-05-31")
        #expect(json?["model"] as? String == "anthropic.claude-fable-5")
        #expect(json?["max_tokens"] as? Int == 1024)
        let messages = json?["messages"] as? [[String: Any]]
        #expect(messages?.count == 1)
        #expect(messages?.first?["role"] as? String == "user")
        #expect(messages?.first?["content"] as? String == "Hello")
    }

    @Test("Request body encodes max_tokens in snake_case")
    func requestBodySnakeCase() throws {
        let request = MessagesRequestBody(
            model: .claude_fable_v5,
            maxTokens: 8192,
            messages: [AnthropicMessage(role: .user, content: "Hi")]
        )

        let data = try JSONEncoder().encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        #expect(json?["max_tokens"] != nil)
        #expect(json?["maxTokens"] == nil)
    }

    @Test("Request body decodes from JSON")
    func requestBodyDecoding() throws {
        let json = """
            {
                "anthropic_version": "bedrock-2023-05-31",
                "model": "anthropic.claude-fable-5",
                "max_tokens": 2048,
                "messages": [{"role": "user", "content": "Test"}]
            }
            """
        let data = json.data(using: .utf8)!
        let request = try JSONDecoder().decode(MessagesRequestBody.self, from: data)

        #expect(request.model == .claude_fable_v5)
        #expect(request.maxTokens == 2048)
        #expect(request.messages.count == 1)
        #expect(request.messages[0].content == "Test")
    }
}
