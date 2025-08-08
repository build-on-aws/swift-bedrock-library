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

public struct OpenAIRequestBody: BedrockBodyCodable {
    private let max_completion_tokens: Int
    private let temperature: Double?
    private let top_p: Double?
    private let messages: [OpenAIMessage]

    public init(
        prompt: String,
        maxTokens: Int,
        temperature: Double?,
        topP: Double?
    ) {
        self.max_completion_tokens = maxTokens
        self.temperature = temperature
        self.messages = [
            OpenAIMessage(role: .user, content: prompt)
        ]
        self.top_p = topP
    }

    private struct OpenAIMessage: Codable {
        let role: Role
        let content: String
    }
}
