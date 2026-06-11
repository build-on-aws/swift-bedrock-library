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

struct MessagesRequestBody: Codable, Sendable {
    let anthropicVersion: String
    let model: BedrockModel
    let maxTokens: Int
    let messages: [AnthropicMessage]

    init(model: BedrockModel, maxTokens: Int, messages: [AnthropicMessage]) {
        self.anthropicVersion = "bedrock-2023-05-31"
        self.model = model
        self.maxTokens = maxTokens
        self.messages = messages
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(anthropicVersion, forKey: .anthropicVersion)
        try container.encode(model.id, forKey: .model)
        try container.encode(maxTokens, forKey: .maxTokens)
        try container.encode(messages, forKey: .messages)
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.anthropicVersion = try container.decode(String.self, forKey: .anthropicVersion)
        let modelId = try container.decode(String.self, forKey: .model)
        guard let model = BedrockModel(rawValue: modelId) else {
            throw BedrockLibraryError.notFound("Unknown model: \(modelId)")
        }
        self.model = model
        self.maxTokens = try container.decode(Int.self, forKey: .maxTokens)
        self.messages = try container.decode([AnthropicMessage].self, forKey: .messages)
    }

    private enum CodingKeys: String, CodingKey {
        case anthropicVersion = "anthropic_version"
        case model
        case maxTokens = "max_tokens"
        case messages
    }
}

public struct AnthropicMessage: Codable, Sendable {
    public let role: Role
    public let content: String

    public init(role: Role, content: String) {
        self.role = role
        self.content = content
    }
}

extension [AnthropicMessage] {
    public mutating func append(_ output: MessagesOutput) {
        append(AnthropicMessage(role: .assistant, content: output.text))
    }

    public mutating func append(_ userMessage: String) {
        append(AnthropicMessage(role: .user, content: userMessage))
    }
}
