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

public struct TitanRequestBody: BedrockBodyCodable {
    private let inputText: String
    private let textGenerationConfig: TextGenerationConfig

    public init(
        prompt: String,
        maxTokens: Int,
        temperature: Double,
        topP: Double,
        stopSequences: [String]
    ) {
        self.inputText = "User: \(prompt)\nBot:"
        self.textGenerationConfig = TextGenerationConfig(
            maxTokenCount: maxTokens,
            temperature: temperature,
            topP: topP,
            stopSequences: stopSequences
        )
    }

    private struct TextGenerationConfig: Codable {
        let maxTokenCount: Int
        let temperature: Double
        let topP: Double
        let stopSequences: [String]
    }
}
