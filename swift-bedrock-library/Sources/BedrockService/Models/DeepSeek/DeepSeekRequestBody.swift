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

public struct DeepSeekRequestBody: BedrockBodyCodable {
    private let prompt: String
    private let temperature: Double
    private let top_p: Double
    private let max_tokens: Int
    private let stop: [String]

    public init(
        prompt: String,
        maxTokens: Int,
        temperature: Double,
        topP: Double,
        stopSequences: [String]
    ) {
        self.prompt = prompt
        self.temperature = temperature
        self.top_p = topP
        self.max_tokens = maxTokens
        self.stop = stopSequences
    }
}
