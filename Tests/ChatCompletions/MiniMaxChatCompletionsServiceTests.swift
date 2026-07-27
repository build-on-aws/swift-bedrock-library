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

@Suite("MiniMax Chat Completions Service Tests")
struct MiniMaxChatCompletionsServiceTests {
    let bedrock: BedrockService

    init() async throws {
        CommonRuntimeKit.initialize()
        self.bedrock = try await BedrockService(
            region: .useast1,
            bedrockClient: MockBedrockClient(),
            bedrockRuntimeClient: MockBedrockRuntimeClient()
        )
    }

    @Test("completeChatCompletion with MiniMax M2 returns correct output")
    func completeChatCompletionMiniMaxM2() async throws {
        let output = try await bedrock.completeChatCompletion(
            "Hello from MiniMax",
            with: .minimax_m2,
            authentication: .apiKey(key: "test-key"),
            mantleClient: MockBedrockMantleChatCompletionsClient()
        )

        #expect(output.text == "Mock completion for: Hello from MiniMax")
        #expect(output.model == "minimax.minimax-m2")
        #expect(output.id == "chatcmpl-mock")
        #expect(output.usage.promptTokens == 5)
        #expect(output.usage.completionTokens == 10)
        #expect(output.usage.totalTokens == 15)
    }

    @Test("completeChatCompletion with MiniMax M2.5 returns correct output")
    func completeChatCompletionMiniMaxM2_5() async throws {
        let output = try await bedrock.completeChatCompletion(
            "Hello from M2.5",
            with: .minimax_m2_5,
            authentication: .apiKey(key: "test-key"),
            mantleClient: MockBedrockMantleChatCompletionsClient()
        )

        #expect(output.text == "Mock completion for: Hello from M2.5")
        #expect(output.model == "minimax.minimax-m2.5")
    }

    @Test("completeChatCompletion with MiniMax M2.1 returns correct output")
    func completeChatCompletionMiniMaxM2_1() async throws {
        let output = try await bedrock.completeChatCompletion(
            "Hello from M2.1",
            with: .minimax_m2_1,
            authentication: .apiKey(key: "test-key"),
            mantleClient: MockBedrockMantleChatCompletionsClient()
        )

        #expect(output.text == "Mock completion for: Hello from M2.1")
        #expect(output.model == "minimax.minimax-m2.1")
    }
}
