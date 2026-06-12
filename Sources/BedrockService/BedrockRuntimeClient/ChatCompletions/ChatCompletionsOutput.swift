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

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// The response from a Chat Completions API call.
///
/// Contains the generated text, model identifier, and token usage statistics.
public struct ChatCompletionsOutput: Sendable {
    /// The unique identifier for this completion.
    public let id: String
    /// The generated text extracted from the first choice.
    public let text: String
    /// The model identifier that generated this completion.
    public let model: String
    /// Token usage statistics for this completion.
    public let usage: ChatCompletionsUsage

    init(from raw: ChatCompletionsRawOutput) throws {
        self.id = raw.id
        self.model = raw.model
        guard let firstChoice = raw.choices.first else {
            throw BedrockLibraryError.completionNotFound(
                "No choices available in Chat Completions response"
            )
        }
        self.text = firstChoice.message.content
        self.usage = ChatCompletionsUsage(
            promptTokens: raw.usage.prompt_tokens,
            completionTokens: raw.usage.completion_tokens,
            totalTokens: raw.usage.total_tokens
        )
    }
}

/// Token usage statistics from a Chat Completions response.
public struct ChatCompletionsUsage: Sendable {
    /// The number of tokens in the prompt.
    public let promptTokens: Int
    /// The number of tokens in the generated completion.
    public let completionTokens: Int
    /// The total number of tokens used (prompt + completion).
    public let totalTokens: Int
}

struct ChatCompletionsRawOutput: Codable, Sendable {
    let id: String
    let choices: [ChatCompletionsChoice]
    let created: Int
    let model: String
    let object: String
    let usage: ChatCompletionsRawUsage
}

struct ChatCompletionsChoice: Codable, Sendable {
    let finish_reason: String
    let index: Int
    let message: ChatCompletionsResponseMessage
}

struct ChatCompletionsResponseMessage: Codable, Sendable {
    let content: String
    let role: String
}

struct ChatCompletionsRawUsage: Codable, Sendable {
    let completion_tokens: Int
    let prompt_tokens: Int
    let total_tokens: Int
}
