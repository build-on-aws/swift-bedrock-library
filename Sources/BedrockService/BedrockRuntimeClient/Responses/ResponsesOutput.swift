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

public struct ResponsesOutput: Sendable {
    public let id: String
    public let text: String
    public let model: BedrockModel
    public let usage: ResponsesUsage

    init(from raw: ResponsesRawOutput) throws {
        self.id = raw.id
        guard let model = BedrockModel(rawValue: raw.model) else {
            throw BedrockLibraryError.notFound("Unknown model in response: \(raw.model)")
        }
        self.model = model
        self.usage = ResponsesUsage(
            inputTokens: raw.usage.input_tokens,
            outputTokens: raw.usage.output_tokens
        )
        guard let text = raw.extractText() else {
            throw BedrockLibraryError.completionNotFound(
                "No text output found in Responses API response"
            )
        }
        self.text = text
    }
}

public struct ResponsesUsage: Sendable {
    public let inputTokens: Int
    public let outputTokens: Int
}

struct ResponsesRawOutput: Codable, Sendable {
    let id: String
    let object: String
    let model: String
    let output: [ResponsesOutputItem]
    let usage: ResponsesRawUsage

    func extractText() -> String? {
        for item in output {
            if item.type == "message", let content = item.content {
                for block in content {
                    if block.type == "output_text", let text = block.text {
                        return text
                    }
                }
            }
        }
        return nil
    }
}

struct ResponsesOutputItem: Codable, Sendable {
    let type: String
    let role: String?
    let content: [ResponsesContentBlock]?
}

struct ResponsesContentBlock: Codable, Sendable {
    let type: String
    let text: String?
}

struct ResponsesRawUsage: Codable, Sendable {
    let input_tokens: Int
    let output_tokens: Int
    let total_tokens: Int?
}
