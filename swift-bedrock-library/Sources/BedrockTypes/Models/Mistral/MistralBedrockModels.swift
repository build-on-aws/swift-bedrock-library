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

// MARK: converse only
// https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-mistral-text-completion.html
// https://docs.aws.amazon.com/bedrock/latest/userguide/conversation-inference-supported-models-features.html

typealias MistralConverse = StandardConverse

extension BedrockModel {
    public static let mistral_large_2402 = BedrockModel(
        id: "mistral.mistral-large-2402-v1:0",
        name: "Mistral Large (24.02)",
        modality: MistralConverse(
            parameters: ConverseParameters(
                temperature: Parameter(.temperature, minValue: 0, maxValue: 1, defaultValue: 0.7),
                maxTokens: Parameter(.maxTokens, minValue: 1, maxValue: 8_192, defaultValue: 8_192),
                topP: Parameter(.topP, minValue: 0, maxValue: 1, defaultValue: 1),
                stopSequences: StopSequenceParams(maxSequences: 10, defaultValue: []),
                maxPromptSize: nil
            ),
            features: [.textGeneration, .systemPrompts, .document, .toolUse]
        )
    )
    public static let mistral_small_2402 = BedrockModel(
        id: "mistral.mistral-small-2402-v1:0",
        name: "Mistral Small (24.02)",
        modality: MistralConverse(
            parameters: ConverseParameters(
                temperature: Parameter(.temperature, minValue: 0, maxValue: 1, defaultValue: 0.7),
                maxTokens: Parameter(.maxTokens, minValue: 1, maxValue: 8_192, defaultValue: 8_192),
                topP: Parameter(.topP, minValue: 0, maxValue: 1, defaultValue: 1),
                stopSequences: StopSequenceParams(maxSequences: 10, defaultValue: []),
                maxPromptSize: nil
            ),
            features: [.textGeneration, .systemPrompts, .toolUse]
        )
    )
    public static let mistral_7B_instruct = BedrockModel(
        id: "mistral.mistral-7b-instruct-v0:2",
        name: "Mistral 7B Instruct",
        modality: MistralConverse(
            parameters: ConverseParameters(
                temperature: Parameter(.temperature, minValue: 0, maxValue: 1, defaultValue: 0.5),
                maxTokens: Parameter(.maxTokens, minValue: 1, maxValue: 8_192, defaultValue: 512),
                topP: Parameter(.topP, minValue: 0, maxValue: 1, defaultValue: 0.9),
                stopSequences: StopSequenceParams(maxSequences: 10, defaultValue: []),
                maxPromptSize: nil
            ),
            features: [.textGeneration, .document]
        )
    )
    public static let mistral_8x7B_instruct = BedrockModel(
        id: "mistral.mixtral-8x7b-instruct-v0:1",
        name: "Mixtral 8x7B Instruct",
        modality: MistralConverse(
            parameters: ConverseParameters(
                temperature: Parameter(.temperature, minValue: 0, maxValue: 1, defaultValue: 0.5),
                maxTokens: Parameter(.maxTokens, minValue: 1, maxValue: 4_096, defaultValue: 512),
                topP: Parameter(.topP, minValue: 0, maxValue: 1, defaultValue: 0.9),
                stopSequences: StopSequenceParams(maxSequences: 10, defaultValue: []),
                maxPromptSize: nil
            ),
            features: [.textGeneration, .document]
        )
    )
}
