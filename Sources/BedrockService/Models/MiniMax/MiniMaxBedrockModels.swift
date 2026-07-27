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

// https://docs.aws.amazon.com/bedrock/latest/userguide/model-card-minimax-minimax-m2.html
// https://docs.aws.amazon.com/bedrock/latest/userguide/model-card-minimax-minimax-m2-1.html
// https://docs.aws.amazon.com/bedrock/latest/userguide/model-card-minimax-minimax-m2-5.html

extension BedrockModel {
    public static let minimax_m2: BedrockModel = BedrockModel(
        id: "minimax.minimax-m2",
        name: "MiniMax M2",
        modality: MiniMaxText(
            parameters: TextGenerationParameters(
                temperature: Parameter(.temperature, minValue: 0, maxValue: 1, defaultValue: 1),
                maxTokens: Parameter(.maxTokens, minValue: 1, maxValue: 8_192, defaultValue: 8_192),
                topP: Parameter(.topP, minValue: 0, maxValue: 1, defaultValue: 1),
                topK: Parameter.notSupported(.topK),
                stopSequences: StopSequenceParams.notSupported(),
                maxPromptSize: nil
            )
        )
    )

    public static let minimax_m2_1: BedrockModel = BedrockModel(
        id: "minimax.minimax-m2.1",
        name: "MiniMax M2.1",
        modality: MiniMaxText(
            parameters: TextGenerationParameters(
                temperature: Parameter(.temperature, minValue: 0, maxValue: 1, defaultValue: 1),
                maxTokens: Parameter(.maxTokens, minValue: 1, maxValue: 8_192, defaultValue: 8_192),
                topP: Parameter(.topP, minValue: 0, maxValue: 1, defaultValue: 1),
                topK: Parameter.notSupported(.topK),
                stopSequences: StopSequenceParams.notSupported(),
                maxPromptSize: nil
            )
        )
    )

    public static let minimax_m2_5: BedrockModel = BedrockModel(
        id: "minimax.minimax-m2.5",
        name: "MiniMax M2.5",
        modality: MiniMaxText(
            parameters: TextGenerationParameters(
                temperature: Parameter(.temperature, minValue: 0, maxValue: 1, defaultValue: 1),
                maxTokens: Parameter(.maxTokens, minValue: 1, maxValue: 8_192, defaultValue: 8_192),
                topP: Parameter(.topP, minValue: 0, maxValue: 1, defaultValue: 1),
                topK: Parameter.notSupported(.topK),
                stopSequences: StopSequenceParams.notSupported(),
                maxPromptSize: nil
            )
        )
    )
}
