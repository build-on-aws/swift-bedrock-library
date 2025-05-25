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

// ConverseModality was taken out, because DeepSeek automatically uses reasoning
// and does not tolerate the way reasoning is handled in this library.
// DeepSeek always uses reasoning, meaning that with every response it returns a
// reasoning content block. However, DeepSeek does not tolerate reasoning
// content blocks in the conversation history.
// This library chooses not to manipulate the conversation history.
// Due to this difference, no more than one question could be sent to DeepSeek
// per conversation before an error would be thrown saying: "User messages cannot
// contain reasoning content. Please remove the reasoning content and try again."
// To avoid this problem altogether, the ConverseModality was taken out.
// If a developer would want to reintroduce DeepSeek to converse and converseStream
// a solution should be found where only in the case of DeepSeek, the history is
// filtered to remove the reasoning content blocks before it is sent to the model.
// The same goes for ConverseStreamingModality.

struct DeepSeekText: TextModality {
    let parameters: TextGenerationParameters
    let converseFeatures: [ConverseFeature]
    let converseParameters: ConverseParameters

    func getName() -> String { "DeepSeek Text Generation" }

    init(
        parameters: TextGenerationParameters,
        features: [ConverseFeature] = [.textGeneration, .systemPrompts, .document]  // .reasoning
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
            throw BedrockServiceError.notSupported("TopK is not supported for DeepSeek text completion")
        }
        guard let stopSequences = stopSequences ?? parameters.stopSequences.defaultValue else {
            throw BedrockServiceError.notFound("No value was given for stopSequences and no default value was found")
        }
        return DeepSeekRequestBody(
            prompt: prompt,
            maxTokens: maxTokens,
            temperature: temperature,
            topP: topP,
            stopSequences: stopSequences
        )
    }

    func getTextResponseBody(from data: Data) throws -> ContainsTextCompletion {
        let decoder = JSONDecoder()
        return try decoder.decode(DeepSeekResponseBody.self, from: data)
    }
}
