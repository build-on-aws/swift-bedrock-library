//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Foundation Models Playground open source project
//
// Copyright (c) 2025 Amazon.com, Inc. or its affiliates
//                    and the Swift Foundation Models Playground project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of Swift Foundation Models Playground project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import Testing

@testable import BedrockService
@testable import BedrockTypes

// Converse reasoning

extension BedrockServiceTests {

    @Test("Converse with reasoning")
    func converseReasoning() async throws {
        let builder = try ConverseRequestBuilder(with: .claudev3_7_sonnet)
            .withPrompt("What is this?")
        let reply = try await bedrock.converse(with: builder)

        #expect(reply.textReply == "Your prompt was: What is this?")
        #expect(reply.reasoningBlock != nil)
        #expect(reply.reasoningBlock?.reasoning == "reasoning text")
        #expect(reply.reasoningBlock?.signature == "reasoning signature")
    }

    @Test("Converse with encrypted reasoning")
    func converseEncryptedReasoning() async throws {
        let builder = try ConverseRequestBuilder(with: .claudev3_7_sonnet)
            .withPrompt("encrypted")
        let reply = try await bedrock.converse(with: builder)

        #expect(reply.textReply == "Your prompt was: encrypted")
        #expect(reply.reasoningBlock == nil)
        #expect(reply.encryptedReasoning != nil)
        #expect(reply.encryptedReasoning?.reasoning != nil)
    }

    @Test("Converse without reasoning when not supported by model")
    func converseReasoningWrongModel() async throws {
        let builder = try ConverseRequestBuilder(with: .nova_micro)
            .withPrompt("What is this?")
        let reply = try await bedrock.converse(with: builder)

        #expect(reply.textReply == "Your prompt was: What is this?")
        #expect(reply.reasoningBlock == nil)
    }
}
