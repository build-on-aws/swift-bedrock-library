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

@Suite("Responses Response Tests")
struct ResponsesResponseTests {

    let sampleResponse = """
        {
            "id": "resp_abc123",
            "object": "response",
            "model": "openai.gpt-5.5",
            "output": [
                {
                    "type": "message",
                    "role": "assistant",
                    "content": [
                        {
                            "type": "output_text",
                            "text": "Hello! I can help you with many things."
                        }
                    ]
                }
            ],
            "usage": {
                "input_tokens": 15,
                "output_tokens": 42,
                "total_tokens": 57
            }
        }
        """

    @Test("Parses response correctly")
    func parseResponse() throws {
        let data = sampleResponse.data(using: .utf8)!
        let raw = try JSONDecoder().decode(ResponsesRawOutput.self, from: data)
        let output = try ResponsesOutput(from: raw)

        #expect(output.id == "resp_abc123")
        #expect(output.model == .openai_gpt_5_5)
        #expect(output.text == "Hello! I can help you with many things.")
        #expect(output.usage.inputTokens == 15)
        #expect(output.usage.outputTokens == 42)
    }

    @Test("Extracts text from output blocks")
    func extractText() throws {
        let data = sampleResponse.data(using: .utf8)!
        let raw = try JSONDecoder().decode(ResponsesRawOutput.self, from: data)

        #expect(raw.extractText() == "Hello! I can help you with many things.")
    }

    @Test("Throws when no text in output")
    func throwsWhenNoText() throws {
        let noTextResponse = """
            {
                "id": "resp_empty",
                "object": "response",
                "model": "openai.gpt-5.5",
                "output": [],
                "usage": {
                    "input_tokens": 5,
                    "output_tokens": 0,
                    "total_tokens": 5
                }
            }
            """
        let data = noTextResponse.data(using: .utf8)!
        let raw = try JSONDecoder().decode(ResponsesRawOutput.self, from: data)

        #expect(throws: BedrockLibraryError.self) {
            _ = try ResponsesOutput(from: raw)
        }
    }
}
