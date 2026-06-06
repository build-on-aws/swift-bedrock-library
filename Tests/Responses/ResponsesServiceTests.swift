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

@Suite("Responses Service Tests")
struct ResponsesServiceTests {
    let bedrock: BedrockService

    init() async throws {
        CommonRuntimeKit.initialize()
        self.bedrock = try await BedrockService(
            region: .useast2,
            bedrockClient: MockBedrockClient(),
            bedrockRuntimeClient: MockBedrockRuntimeClient()
        )
    }

    @Test("createResponse with GPT 5.5 returns text")
    func createResponseGpt55() async throws {
        let output = try await bedrock.createResponse(
            "What is Bedrock?",
            with: .openai_gpt_5_5,
            authentication: .apiKey("test-key"),
            mantleClient: MockBedrockMantleClient()
        )

        #expect(output.text == "Mock response for: What is Bedrock?")
        #expect(output.model == .openai_gpt_5_5)
        #expect(output.id == "resp_mock_123")
        #expect(output.usage.inputTokens == 10)
        #expect(output.usage.outputTokens == 20)
    }

    @Test("createResponse with GPT 5.4 returns text")
    func createResponseGpt54() async throws {
        let output = try await bedrock.createResponse(
            "Hello",
            with: .openai_gpt_5_4,
            authentication: .apiKey("test-key"),
            mantleClient: MockBedrockMantleClient()
        )

        #expect(output.text == "Mock response for: Hello")
        #expect(output.model == .openai_gpt_5_4)
    }

    @Test("createResponse with gpt-oss-20b via Responses API")
    func createResponseGptOss20b() async throws {
        let output = try await bedrock.createResponse(
            "Who are you?",
            with: .openai_gpt_oss_20b,
            authentication: .apiKey("test-key"),
            mantleClient: MockBedrockMantleClient()
        )

        #expect(output.text == "Mock response for: Who are you?")
        #expect(output.model == .openai_gpt_oss_20b)
    }

    @Test("createResponse throws for model without ResponsesModality")
    func createResponseThrowsForInvalidModel() async throws {
        await #expect(throws: BedrockLibraryError.self) {
            _ = try await bedrock.createResponse(
                "Hello",
                with: .nova_micro,
                authentication: .apiKey("test-key"),
                mantleClient: MockBedrockMantleClient()
            )
        }
    }
}
