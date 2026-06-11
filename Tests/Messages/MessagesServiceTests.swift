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

@Suite("Messages Service Tests")
struct MessagesServiceTests {
    let bedrock: BedrockService

    init() async throws {
        CommonRuntimeKit.initialize()
        self.bedrock = try await BedrockService(
            region: .useast1,
            bedrockClient: MockBedrockClient(),
            bedrockRuntimeClient: MockBedrockRuntimeClient()
        )
    }

    @Test("createMessage with Claude Fable 5 returns text")
    func createMessageFable5() async throws {
        let output = try await bedrock.createMessage(
            "What is Bedrock?",
            with: .claude_fable_v5,
            authentication: .apiKey(key: "test-key"),
            mantleClient: MockBedrockMantleMessagesClient()
        )

        #expect(output.text == "Mock message for: What is Bedrock?")
        #expect(output.model == "anthropic.claude-fable-5")
        #expect(output.id == "msg_mock_456")
        #expect(output.usage.inputTokens == 15)
        #expect(output.usage.outputTokens == 25)
    }

    @Test("createMessage with custom maxTokens")
    func createMessageCustomMaxTokens() async throws {
        let output = try await bedrock.createMessage(
            "Hello",
            with: .claude_fable_v5,
            maxTokens: 4096,
            authentication: .apiKey(key: "test-key"),
            mantleClient: MockBedrockMantleMessagesClient()
        )

        #expect(output.text == "Mock message for: Hello")
    }

    @Test("createMessage throws for model without MessagesModality")
    func createMessageThrowsForInvalidModel() async throws {
        await #expect(throws: BedrockLibraryError.self) {
            _ = try await bedrock.createMessage(
                "Hello",
                with: .nova_micro,
                authentication: .apiKey(key: "test-key"),
                mantleClient: MockBedrockMantleMessagesClient()
            )
        }
    }
}
