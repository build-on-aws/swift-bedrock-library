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

struct Gemma4Text: ChatCompletionsModality, ResponsesModality {
    let parameters: TextGenerationParameters

    func getName() -> String { "Gemma 4 Text Generation" }
    func getChatCompletionsPath() -> String { "/openai/v1/chat/completions" }
    func getResponsesPath() -> String { "/openai/v1/responses" }
    func getTextGenerationParameters() -> TextGenerationParameters { parameters }
}

struct Gemma3Text: TextModality, ConverseModality, ChatCompletionsModality {
    let parameters: TextGenerationParameters
    let converseParameters: ConverseParameters
    let converseFeatures: [ConverseFeature]

    func getName() -> String { "Gemma 3 Text Generation" }
    func getChatCompletionsPath() -> String { "/v1/chat/completions" }
    func getTextGenerationParameters() -> TextGenerationParameters { parameters }

    init(
        parameters: TextGenerationParameters,
        features: [ConverseFeature] = [.textGeneration, .vision, .systemPrompts]
    ) {
        self.parameters = parameters
        self.converseFeatures = features
        self.converseParameters = ConverseParameters(textGenerationParameters: parameters)
    }

    func getParameters() -> TextGenerationParameters {
        parameters
    }

    func getTextRequestBody(
        prompt: String,
        maxTokens: Int?,
        temperature: Double?,
        topP: Double?,
        topK: Int?,
        stopSequences: [String]?,
        serviceTier: ServiceTier
    ) throws -> BedrockBodyCodable {
        guard let maxTokens = maxTokens ?? parameters.maxTokens.defaultValue else {
            throw BedrockLibraryError.notFound(
                "No value was given for maxTokens and no default value was found"
            )
        }
        if topP != nil && temperature != nil {
            throw BedrockLibraryError.notSupported(
                "Alter either topP or temperature, but not both."
            )
        }
        guard topK == nil else {
            throw BedrockLibraryError.notSupported(
                "TopK is not supported for Gemma 3 text completion"
            )
        }
        return OpenAIRequestBody(
            prompt: prompt,
            maxTokens: maxTokens,
            temperature: temperature ?? parameters.temperature.defaultValue,
            topP: topP ?? parameters.topP.defaultValue,
            serviceTier: serviceTier
        )
    }

    func getTextResponseBody(from data: Data) throws -> ContainsTextCompletion {
        let decoder = JSONDecoder()
        return try decoder.decode(OpenAIResponseBody.self, from: data)
    }
}
