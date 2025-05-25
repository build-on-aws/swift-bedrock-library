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

struct TitanText: TextModality, ConverseModality, ConverseStreamingModality {
    func getName() -> String { "Titan Text Generation" }

    let parameters: TextGenerationParameters
    let converseParameters: ConverseParameters
    let converseFeatures: [ConverseFeature]

    init(parameters: TextGenerationParameters, features: [ConverseFeature] = [.textGeneration, .document]) {
        self.parameters = parameters
        self.converseFeatures = features
        self.converseParameters = ConverseParameters(textGenerationParameters: parameters)
    }

    func getParameters() -> TextGenerationParameters {
        parameters
    }

    func getConverseParameters() -> ConverseParameters {
        ConverseParameters(textGenerationParameters: parameters)
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
        guard let temperature = temperature ?? parameters.temperature.defaultValue else {
            throw BedrockServiceError.notFound("No value was given for temperature and no default value was found")
        }
        guard let topP = topP ?? parameters.topP.defaultValue else {
            throw BedrockServiceError.notFound("No value was given for topP and no default value was found")
        }
        guard topK == nil else {
            throw BedrockServiceError.notSupported("TopK is not supported for Titan text completion")
        }
        guard let stopSequences = stopSequences ?? parameters.stopSequences.defaultValue else {
            throw BedrockServiceError.notFound("No value was given for stopSequences and no default value was found")
        }
        return TitanRequestBody(
            prompt: prompt,
            maxTokens: maxTokens,
            temperature: temperature,
            topP: topP,
            stopSequences: stopSequences
        )
    }

    func getTextResponseBody(from data: Data) throws -> ContainsTextCompletion {
        let decoder = JSONDecoder()
        return try decoder.decode(TitanResponseBody.self, from: data)
    }
}
