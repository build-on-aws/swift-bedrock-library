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

struct AnthropicText: TextModality, ConverseModality, ConverseStreamingModality {
    let parameters: TextGenerationParameters
    let converseParameters: ConverseParameters
    let converseFeatures: [ConverseFeature]
    let maxReasoningTokens: Parameter<Int>

    func getName() -> String { "Anthropic Text Generation" }

    init(
        parameters: TextGenerationParameters,
        features: [ConverseFeature] = [.textGeneration, .systemPrompts, .document],
        maxReasoningTokens: Parameter<Int> = .notSupported(.maxReasoningTokens)
    ) {
        self.parameters = parameters
        self.converseFeatures = features
        self.converseParameters = ConverseParameters(
            textGenerationParameters: parameters,
            maxReasoningTokens: maxReasoningTokens
        )
        self.maxReasoningTokens = maxReasoningTokens
    }

    func getParameters() -> TextGenerationParameters {
        parameters
    }

    func getConverseParameters() -> ConverseParameters {
        ConverseParameters(textGenerationParameters: parameters, maxReasoningTokens: maxReasoningTokens)
    }

    func getTextRequestBody(
        prompt: String,
        maxTokens: Int?,
        temperature: Double?,
        topP: Double?,
        topK: Int?,
        stopSequences: [String]?
    ) throws -> BedrockBodyCodable {
        guard let maxTokens = maxTokens ?? parameters.maxTokens.defaultValue else {
            throw BedrockServiceError.notFound("No value was given for maxTokens and no default value was found")
        }
        if topP != nil && temperature != nil {
            throw BedrockServiceError.notSupported("Alter either topP or temperature, but not both.")
        }
        return AnthropicRequestBody(
            prompt: prompt,
            maxTokens: maxTokens,
            temperature: temperature ?? parameters.temperature.defaultValue,
            topP: topP ?? parameters.topP.defaultValue,
            topK: topK ?? parameters.topK.defaultValue,
            stopSequences: stopSequences ?? parameters.stopSequences.defaultValue
        )
    }

    func getTextResponseBody(from data: Data) throws -> ContainsTextCompletion {
        let decoder = JSONDecoder()
        return try decoder.decode(AnthropicResponseBody.self, from: data)
    }
}
