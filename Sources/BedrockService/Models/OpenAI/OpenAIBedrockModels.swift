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

// https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-openai.html

extension BedrockModel {
    public static let openai_gpt_oss_20b: BedrockModel = BedrockModel(
        id: "openai.gpt-oss-20b-1:0",
        name: "OpenAI GPT OSS 20b",
        modality: OpenAIText(
            parameters: TextGenerationParameters(
                temperature: Parameter(.temperature, minValue: 0, maxValue: 1, defaultValue: 0.7),
                maxTokens: Parameter(.maxTokens, minValue: 0, maxValue: 2_048, defaultValue: 150),
                topP: Parameter(.topP, minValue: 0, maxValue: 1, defaultValue: 0.9),
                topK: Parameter.notSupported(.topK),
                stopSequences: StopSequenceParams.notSupported(),
                maxPromptSize: nil
            ),
            features: [.textGeneration, .systemPrompts, .document]
        )
    )
    public static let openai_gpt_oss_120b: BedrockModel = BedrockModel(
        id: "openai.gpt-oss-120b-1:0",
        name: "OpenAI GPT OSS 120b",
        modality: OpenAIText(
            parameters: TextGenerationParameters(
                temperature: Parameter(.temperature, minValue: 0, maxValue: 1, defaultValue: 0.7),
                maxTokens: Parameter(.maxTokens, minValue: 0, maxValue: 2_048, defaultValue: 150),
                topP: Parameter(.topP, minValue: 0, maxValue: 1, defaultValue: 0.9),
                topK: Parameter.notSupported(.topK),
                stopSequences: StopSequenceParams.notSupported(),
                maxPromptSize: nil
            ),
            features: [.textGeneration, .systemPrompts, .document]
        )
    )
    public static let openai_gpt_5_5: BedrockModel = BedrockModel(
        id: "openai.gpt-5.5",
        name: "OpenAI GPT 5.5",
        modality: OpenAIResponses(responsesPath: "/openai/v1/responses")
    )
    public static let openai_gpt_5_4: BedrockModel = BedrockModel(
        id: "openai.gpt-5.4",
        name: "OpenAI GPT 5.4",
        modality: OpenAIResponses(responsesPath: "/openai/v1/responses")
    )
}
