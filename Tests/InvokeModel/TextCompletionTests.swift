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

import Testing

@testable import BedrockService

@Suite("TextCompletion Tests")
struct TextCompletionTests {

    @Test("Extract reasoning from text with reasoning tags")
    func extractReasoningWithTags() {
        let input =
            "<reasoning>We are ChatGPT, a language model. The user asks: \"Who are you?\" We should respond with a concise answer. Probably: \"I am ChatGPT, an AI language model.\" We'll keep it short.</reasoning>I'm ChatGPT, an AI language model created by OpenAI."

        let completion = TextCompletion(input)

        #expect(completion.completion == "I'm ChatGPT, an AI language model created by OpenAI.")
        #expect(
            completion.reasoning
                == "We are ChatGPT, a language model. The user asks: \"Who are you?\" We should respond with a concise answer. Probably: \"I am ChatGPT, an AI language model.\" We'll keep it short."
        )
    }

    @Test("Handle text without reasoning tags")
    func textWithoutReasoningTags() {
        let input = "I'm ChatGPT, an AI language model created by OpenAI."

        let completion = TextCompletion(input)

        #expect(completion.completion == "I'm ChatGPT, an AI language model created by OpenAI.")
        #expect(completion.reasoning == nil)
    }

    @Test("Handle empty text")
    func emptyText() {
        let completion = TextCompletion("")

        #expect(completion.completion == "")
        #expect(completion.reasoning == nil)
    }
}
