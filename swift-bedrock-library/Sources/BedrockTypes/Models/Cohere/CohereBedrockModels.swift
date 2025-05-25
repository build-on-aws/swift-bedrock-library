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

// import BedrockTypes
import Foundation

// https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-cohere-command-r-plus.html
typealias CohereConverse = StandardConverse

extension BedrockModel {
    public static let cohere_command_R_plus = BedrockModel(
        id: "cohere.command-r-plus-v1:0",
        name: "Cohere Command R+",
        modality: CohereConverse(
            parameters: ConverseParameters(
                temperature: Parameter(.temperature, minValue: 0, maxValue: 1, defaultValue: 0.3),
                maxTokens: Parameter(.maxTokens, minValue: 1, maxValue: nil, defaultValue: nil),
                topP: Parameter(.topP, minValue: 0.01, maxValue: 0.99, defaultValue: 0.75),
                stopSequences: StopSequenceParams(maxSequences: nil, defaultValue: []),
                maxPromptSize: nil
            ),
            features: [.textGeneration, .systemPrompts, .document, .toolUse]
        )
    )

    public static let cohere_command_R = BedrockModel(
        id: "cohere.command-r-v1:0",
        name: "Cohere Command R",
        modality: CohereConverse(
            parameters: ConverseParameters(
                temperature: Parameter(.temperature, minValue: 0, maxValue: 1, defaultValue: 0.3),
                maxTokens: Parameter(.maxTokens, minValue: 1, maxValue: nil, defaultValue: nil),
                topP: Parameter(.topP, minValue: 0.01, maxValue: 0.99, defaultValue: 0.75),
                stopSequences: StopSequenceParams(maxSequences: nil, defaultValue: []),
                maxPromptSize: nil
            ),
            features: [.textGeneration, .systemPrompts, .document, .toolUse]
        )
    )
}
