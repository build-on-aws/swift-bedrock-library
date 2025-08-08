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

public struct NovaResponseBody: ContainsTextCompletion {
    private let output: Output
    private let stopReason: String
    private let usage: Usage

    public func getTextCompletion() throws -> TextCompletion {
        guard output.message.content.count > 0 else {
            throw BedrockLibraryError.completionNotFound("NovaResponseBody: No content found")
        }
        guard output.message.role == .assistant else {
            throw BedrockLibraryError.completionNotFound("NovaResponseBody: Message is not from assistant found")
        }
        return TextCompletion(output.message.content[0].text)
    }

    private struct Output: Codable {
        let message: Message
    }

    private struct Message: Codable {
        let content: [Content]
        let role: Role
    }

    private struct Content: Codable {
        let text: String
    }

    private struct Usage: Codable {
        let inputTokens: Int
        let outputTokens: Int
        let totalTokens: Int
        let cacheReadInputTokenCount: Int
        let cacheWriteInputTokenCount: Int
    }
}
