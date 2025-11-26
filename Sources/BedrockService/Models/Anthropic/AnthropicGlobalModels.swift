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

// Wrapper structs for v4.5 models to support GlobalCrossRegionInferenceModality
struct Claude_Sonnet_v4_5: TextModality, ConverseModality, ConverseStreamingModality, GlobalCrossRegionInferenceModality
{
    private let anthropicText: AnthropicText

    let converseParameters: ConverseParameters
    let converseFeatures: [ConverseFeature]

    init(parameters: TextGenerationParameters, features: [ConverseFeature], maxReasoningTokens: Parameter<Int>) {
        self.anthropicText = AnthropicText(
            parameters: parameters,
            features: features,
            maxReasoningTokens: maxReasoningTokens
        )
        self.converseParameters = anthropicText.converseParameters
        self.converseFeatures = anthropicText.converseFeatures
    }

    func getName() -> String { anthropicText.getName() }
    func getParameters() -> TextGenerationParameters { anthropicText.getParameters() }
    func getConverseParameters() -> ConverseParameters { anthropicText.getConverseParameters() }
    func getConverseFeatures() -> [ConverseFeature] { anthropicText.getConverseFeatures() }

    func getTextRequestBody(
        prompt: String,
        maxTokens: Int?,
        temperature: Double?,
        topP: Double?,
        topK: Int?,
        stopSequences: [String]?,
        serviceTier: ServiceTier
    ) throws -> BedrockBodyCodable {
        try anthropicText.getTextRequestBody(
            prompt: prompt,
            maxTokens: maxTokens,
            temperature: temperature,
            topP: topP,
            topK: topK,
            stopSequences: stopSequences,
            serviceTier: serviceTier
        )
    }

    func getTextResponseBody(from data: Data) throws -> ContainsTextCompletion {
        try anthropicText.getTextResponseBody(from: data)
    }
}

struct Claude_Opus_v4_5: TextModality, ConverseModality, ConverseStreamingModality, GlobalCrossRegionInferenceModality {
    private let anthropicText: AnthropicText

    let converseParameters: ConverseParameters
    let converseFeatures: [ConverseFeature]

    init(parameters: TextGenerationParameters, features: [ConverseFeature], maxReasoningTokens: Parameter<Int>) {
        self.anthropicText = AnthropicText(
            parameters: parameters,
            features: features,
            maxReasoningTokens: maxReasoningTokens
        )
        self.converseParameters = anthropicText.converseParameters
        self.converseFeatures = anthropicText.converseFeatures
    }

    func getName() -> String { anthropicText.getName() }
    func getParameters() -> TextGenerationParameters { anthropicText.getParameters() }
    func getConverseParameters() -> ConverseParameters { anthropicText.getConverseParameters() }
    func getConverseFeatures() -> [ConverseFeature] { anthropicText.getConverseFeatures() }

    func getTextRequestBody(
        prompt: String,
        maxTokens: Int?,
        temperature: Double?,
        topP: Double?,
        topK: Int?,
        stopSequences: [String]?,
        serviceTier: ServiceTier
    ) throws -> BedrockBodyCodable {
        try anthropicText.getTextRequestBody(
            prompt: prompt,
            maxTokens: maxTokens,
            temperature: temperature,
            topP: topP,
            topK: topK,
            stopSequences: stopSequences,
            serviceTier: serviceTier
        )
    }

    func getTextResponseBody(from data: Data) throws -> ContainsTextCompletion {
        try anthropicText.getTextResponseBody(from: data)
    }
}
