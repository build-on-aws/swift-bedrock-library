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

import Foundation

public struct OpenAIResponseBody: ContainsTextCompletion {
    private let id: String
    private let choices: [Choice]
    private let created: Int
    private let model: String
    private let service_tier: String?
    private let system_fingerprint: String?
    private let object: String
    private let usage: Usage

    public func getTextCompletion() throws -> TextCompletion {
        guard let firstChoice = choices.first else {
            throw BedrockLibraryError.completionNotFound("OpenAIResponseBody: no choices available")
        }
        return TextCompletion(firstChoice.message.content)
    }

    private struct Choice: Codable {
        let finish_reason: String
        let index: Int
        let message: Message
    }

    private struct Message: Codable {
        let content: String
        let role: String
    }

    private struct Usage: Codable {
        let completion_tokens: Int
        let prompt_tokens: Int
        let total_tokens: Int
    }
}
