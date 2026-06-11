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

public struct MessagesOutput: Sendable {
    public let id: String
    public let text: String
    public let model: String
    public let stopReason: String
    public let usage: MessagesUsage

    init(from raw: MessagesRawOutput) throws {
        self.id = raw.id
        self.model = raw.model
        self.stopReason = raw.stop_reason
        self.usage = MessagesUsage(
            inputTokens: raw.usage.input_tokens,
            outputTokens: raw.usage.output_tokens
        )
        guard let text = raw.extractText() else {
            throw BedrockLibraryError.completionNotFound(
                "No text output found in Messages API response"
            )
        }
        self.text = text
    }

}

public struct MessagesUsage: Sendable {
    public let inputTokens: Int
    public let outputTokens: Int
}

struct MessagesRawOutput: Codable, Sendable {
    let id: String
    let type: String
    let role: String
    let model: String
    let content: [MessagesContentBlock]
    let stop_reason: String
    let usage: MessagesRawUsage

    func extractText() -> String? {
        for block in content {
            if block.type == "text", let text = block.text {
                return text
            }
        }
        return nil
    }
}

struct MessagesContentBlock: Codable, Sendable {
    let type: String
    let text: String?
}

struct MessagesRawUsage: Codable, Sendable {
    let input_tokens: Int
    let output_tokens: Int
}
