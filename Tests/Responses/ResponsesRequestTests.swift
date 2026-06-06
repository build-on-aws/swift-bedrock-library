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

@Suite("Responses Request Tests")
struct ResponsesRequestTests {

    @Test("Request body encodes model and input correctly")
    func requestBodyEncoding() throws {
        let request = ResponsesRequestBody(
            model: .openai_gpt_5_5,
            input: [ResponsesMessage(role: .user, content: "Hello")]
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        #expect(json?["model"] as? String == "openai.gpt-5.5")
        let input = json?["input"] as? [[String: Any]]
        #expect(input?.count == 1)
        #expect(input?.first?["role"] as? String == "user")
        #expect(input?.first?["content"] as? String == "Hello")
    }

    @Test("Request body omits store when nil")
    func requestBodyOmitsStoreWhenNil() throws {
        let request = ResponsesRequestBody(
            model: .openai_gpt_5_5,
            input: [ResponsesMessage(role: .user, content: "Hi")],
            store: nil
        )

        let data = try JSONEncoder().encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        #expect(json?["store"] == nil)
    }

    @Test("Request body includes store when set")
    func requestBodyIncludesStore() throws {
        let request = ResponsesRequestBody(
            model: .openai_gpt_5_4,
            input: [ResponsesMessage(role: .user, content: "Hi")],
            store: false
        )

        let data = try JSONEncoder().encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        #expect(json?["store"] as? Bool == false)
    }
}
