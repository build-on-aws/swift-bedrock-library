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

// https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-meta.html

extension BedrockModel {
    public static let llama_3_8b_instruct: BedrockModel = BedrockModel(
        id: "meta.llama3-8b-instruct-v1:0",
        name: "Llama 3 8B Instruct",
        modality: LlamaText(
            parameters: TextGenerationParameters(
                temperature: Parameter(.temperature, minValue: 0, maxValue: 1, defaultValue: 0.5),
                maxTokens: Parameter(.maxTokens, minValue: 0, maxValue: 2_048, defaultValue: 512),
                topP: Parameter(.topP, minValue: 0, maxValue: 1, defaultValue: 0.9),
                topK: Parameter.notSupported(.topK),
                stopSequences: StopSequenceParams.notSupported(),
                maxPromptSize: nil
            ),
            features: [.textGeneration, .systemPrompts, .document]
        )
    )
    public static let llama3_70b_instruct: BedrockModel = BedrockModel(
        id: "meta.llama3-70b-instruct-v1:0",
        name: "Llama 3 70B Instruct",
        modality: LlamaText(
            parameters: TextGenerationParameters(
                temperature: Parameter(.temperature, minValue: 0, maxValue: 1, defaultValue: 0.5),
                maxTokens: Parameter(.maxTokens, minValue: 0, maxValue: 2_048, defaultValue: 512),
                topP: Parameter(.topP, minValue: 0, maxValue: 1, defaultValue: 0.9),
                topK: Parameter.notSupported(.topK),
                stopSequences: StopSequenceParams.notSupported(),
                maxPromptSize: nil
            ),
            features: [.textGeneration, .systemPrompts, .document]
        )
    )
    public static let llama3_1_8b_instruct: BedrockModel = BedrockModel(
        id: "us.meta.llama3-1-8b-instruct-v1:0",
        name: "Llama 3.1 8B Instruct",
        modality: LlamaText(
            parameters: TextGenerationParameters(
                temperature: Parameter(.temperature, minValue: 0, maxValue: 1, defaultValue: 0.5),
                maxTokens: Parameter(.maxTokens, minValue: 0, maxValue: 2_048, defaultValue: 512),
                topP: Parameter(.topP, minValue: 0, maxValue: 1, defaultValue: 0.9),
                topK: Parameter.notSupported(.topK),
                stopSequences: StopSequenceParams.notSupported(),
                maxPromptSize: nil
            ),
            features: [.textGeneration, .systemPrompts, .document, .toolUse]
        )
    )
    public static let llama3_1_70b_instruct: BedrockModel = BedrockModel(
        id: "us.meta.llama3-1-70b-instruct-v1:0",
        name: "Llama 3.1 70B Instruct",
        modality: LlamaText(
            parameters: TextGenerationParameters(
                temperature: Parameter(.temperature, minValue: 0, maxValue: 1, defaultValue: 0.5),
                maxTokens: Parameter(.maxTokens, minValue: 0, maxValue: 2_048, defaultValue: 512),
                topP: Parameter(.topP, minValue: 0, maxValue: 1, defaultValue: 0.9),
                topK: Parameter.notSupported(.topK),
                stopSequences: StopSequenceParams.notSupported(),
                maxPromptSize: nil
            ),
            features: [.textGeneration, .systemPrompts, .document, .toolUse]
        )
    )
    public static let llama3_2_1b_instruct: BedrockModel = BedrockModel(
        id: "us.meta.llama3-2-1b-instruct-v1:0",
        name: "Llama 3.2 1B Instruct",
        modality: LlamaText(
            parameters: TextGenerationParameters(
                temperature: Parameter(.temperature, minValue: 0, maxValue: 1, defaultValue: 0.5),
                maxTokens: Parameter(.maxTokens, minValue: 0, maxValue: 2_048, defaultValue: 512),
                topP: Parameter(.topP, minValue: 0, maxValue: 1, defaultValue: 0.9),
                topK: Parameter.notSupported(.topK),
                stopSequences: StopSequenceParams.notSupported(),
                maxPromptSize: nil
            ),
            features: [.textGeneration, .systemPrompts, .document]
        )
    )
    public static let llama3_2_3b_instruct: BedrockModel = BedrockModel(
        id: "us.meta.llama3-2-3b-instruct-v1:0",
        name: "Llama 3.2 3B Instruct",
        modality: LlamaText(
            parameters: TextGenerationParameters(
                temperature: Parameter(.temperature, minValue: 0, maxValue: 1, defaultValue: 0.5),
                maxTokens: Parameter(.maxTokens, minValue: 0, maxValue: 2_048, defaultValue: 512),
                topP: Parameter(.topP, minValue: 0, maxValue: 1, defaultValue: 0.9),
                topK: Parameter.notSupported(.topK),
                stopSequences: StopSequenceParams.notSupported(),
                maxPromptSize: nil
            ),
            features: [.textGeneration, .systemPrompts, .document]
        )
    )
    public static let llama3_3_70b_instruct: BedrockModel = BedrockModel(
        id: "us.meta.llama3-3-70b-instruct-v1:0",
        name: "Llama 3.3 70B Instruct",
        modality: LlamaText(
            parameters: TextGenerationParameters(
                temperature: Parameter(.temperature, minValue: 0, maxValue: 1, defaultValue: 0.5),
                maxTokens: Parameter(.maxTokens, minValue: 0, maxValue: 2_048, defaultValue: 512),
                topP: Parameter(.topP, minValue: 0, maxValue: 1, defaultValue: 0.9),
                topK: Parameter.notSupported(.topK),
                stopSequences: StopSequenceParams.notSupported(),
                maxPromptSize: nil
            ),
            features: []
        )
    )
}
