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

typealias DeepSeekR1V1 = DeepSeekText

extension BedrockModel {
    public static let deepseek_r1_v1: BedrockModel = BedrockModel(
        id: "us.deepseek.r1-v1:0",
        name: "DeepSeek R1",
        modality: DeepSeekR1V1(
            parameters: TextGenerationParameters(
                temperature: Parameter(.temperature, minValue: 0, maxValue: 1, defaultValue: 1),
                maxTokens: Parameter(.maxTokens, minValue: 1, maxValue: 32_768, defaultValue: 32_768),
                topP: Parameter(.topP, minValue: 0, maxValue: 1, defaultValue: 1),
                topK: Parameter.notSupported(.topK),
                stopSequences: StopSequenceParams(maxSequences: 10, defaultValue: []),
                maxPromptSize: nil
            )
        )
    )
}
