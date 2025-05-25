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

import Foundation

public struct AnthropicResponseBody: ContainsTextCompletion {
    private let id: String
    private let type: String
    private let role: String
    private let model: String
    private let content: [Content]
    private let stop_reason: String
    private let stop_sequence: String?
    private let usage: Usage

    public func getTextCompletion() throws -> TextCompletion {
        guard content.count > 0 else {
            throw BedrockServiceError.completionNotFound("AnthropicResponseBody: content is empty")
        }
        guard let completion = content[0].text else {
            throw BedrockServiceError.completionNotFound("AnthropicResponseBody: content[0].text is nil")
        }
        return TextCompletion(completion)
    }

    private struct Content: Codable {
        let type: String
        let text: String?
        let thinking: String?
    }

    private struct Usage: Codable {
        let input_tokens: Int
        let output_tokens: Int
    }
}
