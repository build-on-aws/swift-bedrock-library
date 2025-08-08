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

public struct TextCompletion: Codable, Sendable {
    public let completion: String
    public let reasoning: String?

    public init(_ completion: String) {
        let (extractedCompletion, extractedReasoning) = Self.extractReasoning(from: completion)
        self.completion = extractedCompletion
        self.reasoning = extractedReasoning
    }

    private static func extractReasoning(from text: String) -> (completion: String, reasoning: String?) {
        let reasoningRegex = /<reasoning>(.*?)<\/reasoning>/
        guard let match = text.firstMatch(of: reasoningRegex) else {
            return (text, nil)
        }

        let reasoning = String(match.1)
        let cleanedText = text.replacing(reasoningRegex, with: "")

        return (cleanedText, reasoning)
    }
}
