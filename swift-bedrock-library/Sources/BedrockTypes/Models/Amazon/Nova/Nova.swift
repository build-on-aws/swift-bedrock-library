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

struct NovaText: TextModality, ConverseModality, ConverseStreamingModality {
    func getName() -> String { "Nova Text Generation" }

    let parameters: TextGenerationParameters
    let converseFeatures: [ConverseFeature]
    let converseParameters: ConverseParameters

    init(parameters: TextGenerationParameters, features: [ConverseFeature] = [.textGeneration]) {
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
        stopSequences: [String]?
    ) throws -> BedrockBodyCodable {
        if topP != nil && temperature != nil {
            throw BedrockServiceError.notSupported("Alter either topP or temperature, but not both.")
        }
        return NovaRequestBody(
            prompt: prompt,
            maxTokens: maxTokens ?? parameters.maxTokens.defaultValue,
            temperature: temperature ?? parameters.temperature.defaultValue,
            topP: topP ?? parameters.topP.defaultValue,
            topK: topK ?? parameters.topK.defaultValue,
            stopSequences: stopSequences ?? parameters.stopSequences.defaultValue
        )
    }

    func getTextResponseBody(from data: Data) throws -> ContainsTextCompletion {
        let decoder = JSONDecoder()
        return try decoder.decode(NovaResponseBody.self, from: data)
    }
}
