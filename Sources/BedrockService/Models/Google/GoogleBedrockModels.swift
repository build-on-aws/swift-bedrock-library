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

// https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-google.html

extension BedrockModel {
    public static let gemma4_31b: BedrockModel = BedrockModel(
        id: "google.gemma-4-31b",
        name: "Gemma 4 31B",
        modality: Gemma4Text(
            parameters: TextGenerationParameters(
                temperature: Parameter(.temperature, minValue: 0, maxValue: 2, defaultValue: 1),
                maxTokens: Parameter(.maxTokens, minValue: 1, maxValue: 8192, defaultValue: 8192),
                topP: Parameter(.topP, minValue: 0, maxValue: 1, defaultValue: 1),
                topK: Parameter.notSupported(.topK),
                stopSequences: StopSequenceParams.notSupported(),
                maxPromptSize: nil
            )
        )
    )
    public static let gemma4_26b_a4b: BedrockModel = BedrockModel(
        id: "google.gemma-4-26b-a4b",
        name: "Gemma 4 26B-A4B",
        modality: Gemma4Text(
            parameters: TextGenerationParameters(
                temperature: Parameter(.temperature, minValue: 0, maxValue: 2, defaultValue: 1),
                maxTokens: Parameter(.maxTokens, minValue: 1, maxValue: 8192, defaultValue: 8192),
                topP: Parameter(.topP, minValue: 0, maxValue: 1, defaultValue: 1),
                topK: Parameter.notSupported(.topK),
                stopSequences: StopSequenceParams.notSupported(),
                maxPromptSize: nil
            )
        )
    )
    public static let gemma4_e2b: BedrockModel = BedrockModel(
        id: "google.gemma-4-e2b",
        name: "Gemma 4 E2B",
        modality: Gemma4Text(
            parameters: TextGenerationParameters(
                temperature: Parameter(.temperature, minValue: 0, maxValue: 2, defaultValue: 1),
                maxTokens: Parameter(.maxTokens, minValue: 1, maxValue: 8192, defaultValue: 8192),
                topP: Parameter(.topP, minValue: 0, maxValue: 1, defaultValue: 1),
                topK: Parameter.notSupported(.topK),
                stopSequences: StopSequenceParams.notSupported(),
                maxPromptSize: nil
            )
        )
    )
    public static let gemma3_27b_it: BedrockModel = BedrockModel(
        id: "google.gemma-3-27b-it",
        name: "Gemma 3 27B IT",
        modality: Gemma3Text(
            parameters: TextGenerationParameters(
                temperature: Parameter(.temperature, minValue: 0, maxValue: 2, defaultValue: 1),
                maxTokens: Parameter(.maxTokens, minValue: 1, maxValue: 8192, defaultValue: 8192),
                topP: Parameter(.topP, minValue: 0, maxValue: 1, defaultValue: 1),
                topK: Parameter.notSupported(.topK),
                stopSequences: StopSequenceParams.notSupported(),
                maxPromptSize: nil
            )
        )
    )
    public static let gemma3_12b_it: BedrockModel = BedrockModel(
        id: "google.gemma-3-12b-it",
        name: "Gemma 3 12B IT",
        modality: Gemma3Text(
            parameters: TextGenerationParameters(
                temperature: Parameter(.temperature, minValue: 0, maxValue: 2, defaultValue: 1),
                maxTokens: Parameter(.maxTokens, minValue: 1, maxValue: 8192, defaultValue: 8192),
                topP: Parameter(.topP, minValue: 0, maxValue: 1, defaultValue: 1),
                topK: Parameter.notSupported(.topK),
                stopSequences: StopSequenceParams.notSupported(),
                maxPromptSize: nil
            )
        )
    )
    public static let gemma3_4b_it: BedrockModel = BedrockModel(
        id: "google.gemma-3-4b-it",
        name: "Gemma 3 4B IT",
        modality: Gemma3Text(
            parameters: TextGenerationParameters(
                temperature: Parameter(.temperature, minValue: 0, maxValue: 2, defaultValue: 1),
                maxTokens: Parameter(.maxTokens, minValue: 1, maxValue: 8192, defaultValue: 8192),
                topP: Parameter(.topP, minValue: 0, maxValue: 1, defaultValue: 1),
                topK: Parameter.notSupported(.topK),
                stopSequences: StopSequenceParams.notSupported(),
                maxPromptSize: nil
            )
        )
    )
}
