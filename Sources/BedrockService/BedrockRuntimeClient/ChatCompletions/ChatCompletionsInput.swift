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

struct ChatCompletionsRequestBody: Codable, Sendable {
    let model: String
    let max_completion_tokens: Int
    let messages: [ChatCompletionsMessage]
    let service_tier: String
    let temperature: Double?
    let top_p: Double?

    private enum CodingKeys: String, CodingKey {
        case model
        case max_completion_tokens
        case messages
        case service_tier
        case temperature
        case top_p
    }
}

/// A message in a Chat Completions conversation.
///
/// Each message has a ``role`` (system, user, or assistant) and text ``content``.
/// Build a conversation by appending messages to an array:
///
/// ```swift
/// var messages: [ChatCompletionsMessage] = []
/// messages.append("What is Swift?")
///
/// let reply = try await bedrock.completeChatCompletion(
///     messages,
///     with: .gemma4_31b,
///     authentication: authentication
/// )
///
/// messages.append(reply)
/// messages.append("How does it compare to Kotlin?")
/// ```
public struct ChatCompletionsMessage: Codable, Sendable {
    /// The role of the message author.
    public let role: ChatCompletionsRole
    /// The text content of the message.
    public let content: String

    /// Creates a new message with the given role and content.
    public init(role: ChatCompletionsRole, content: String) {
        self.role = role
        self.content = content
    }
}

/// The role of a message in a Chat Completions conversation.
public enum ChatCompletionsRole: String, Codable, Sendable {
    /// A system prompt that sets the behavior of the assistant.
    case system
    /// A message from the user.
    case user
    /// A reply from the model.
    case assistant
}

extension [ChatCompletionsMessage] {
    /// Appends the model's reply as an assistant message.
    public mutating func append(_ output: ChatCompletionsOutput) {
        append(ChatCompletionsMessage(role: .assistant, content: output.text))
    }

    /// Appends a user message from a plain string.
    public mutating func append(_ userMessage: String) {
        append(ChatCompletionsMessage(role: .user, content: userMessage))
    }
}
