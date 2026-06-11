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

@Suite("Messages Response Tests")
struct MessagesResponseTests {

    let sampleResponse = """
        {
            "id": "msg_abc123",
            "type": "message",
            "role": "assistant",
            "model": "anthropic.claude-fable-5",
            "content": [
                {
                    "type": "text",
                    "text": "Hello! I can help you with many things."
                }
            ],
            "stop_reason": "end_turn",
            "usage": {
                "input_tokens": 15,
                "output_tokens": 42
            }
        }
        """

    @Test("Parses response correctly")
    func parseResponse() throws {
        let data = sampleResponse.data(using: .utf8)!
        let raw = try JSONDecoder().decode(MessagesRawOutput.self, from: data)
        let output = try MessagesOutput(from: raw)

        #expect(output.id == "msg_abc123")
        #expect(output.model == "anthropic.claude-fable-5")
        #expect(output.text == "Hello! I can help you with many things.")
        #expect(output.stopReason == "end_turn")
        #expect(output.usage.inputTokens == 15)
        #expect(output.usage.outputTokens == 42)
    }

    @Test("Extracts text from content blocks")
    func extractText() throws {
        let data = sampleResponse.data(using: .utf8)!
        let raw = try JSONDecoder().decode(MessagesRawOutput.self, from: data)

        #expect(raw.extractText() == "Hello! I can help you with many things.")
    }

    @Test("Throws when no text in content")
    func throwsWhenNoText() throws {
        let noTextResponse = """
            {
                "id": "msg_empty",
                "type": "message",
                "role": "assistant",
                "model": "anthropic.claude-fable-5",
                "content": [],
                "stop_reason": "end_turn",
                "usage": {
                    "input_tokens": 5,
                    "output_tokens": 0
                }
            }
            """
        let data = noTextResponse.data(using: .utf8)!
        let raw = try JSONDecoder().decode(MessagesRawOutput.self, from: data)

        #expect(throws: BedrockLibraryError.self) {
            _ = try MessagesOutput(from: raw)
        }
    }

    @Test("Handles refusal stop reason")
    func handlesRefusal() throws {
        let refusalResponse = """
            {
                "id": "msg_refused",
                "type": "message",
                "role": "assistant",
                "model": "anthropic.claude-fable-5",
                "content": [
                    {
                        "type": "text",
                        "text": "I cannot help with that request."
                    }
                ],
                "stop_reason": "refusal",
                "usage": {
                    "input_tokens": 10,
                    "output_tokens": 8
                }
            }
            """
        let data = refusalResponse.data(using: .utf8)!
        let raw = try JSONDecoder().decode(MessagesRawOutput.self, from: data)
        let output = try MessagesOutput(from: raw)

        #expect(output.stopReason == "refusal")
        #expect(output.text == "I cannot help with that request.")
    }
}
