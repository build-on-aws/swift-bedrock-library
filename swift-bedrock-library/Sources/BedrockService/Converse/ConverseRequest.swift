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

@preconcurrency import AWSBedrockRuntime
import BedrockTypes
import Foundation
import Smithy

public struct ConverseRequest {
    let model: BedrockModel
    let messages: [Message]
    let inferenceConfig: InferenceConfig?
    let toolConfig: ToolConfig?
    let systemPrompts: [String]?
    let maxReasoningTokens: Int?

    init(
        model: BedrockModel,
        messages: [Message] = [],
        maxTokens: Int?,
        temperature: Double?,
        topP: Double?,
        stopSequences: [String]?,
        systemPrompts: [String]?,
        tools: [Tool]?,
        maxReasoningTokens: Int?
    ) {
        self.messages = messages
        self.model = model
        self.inferenceConfig = InferenceConfig(
            maxTokens: maxTokens,
            temperature: temperature,
            topP: topP,
            stopSequences: stopSequences
        )
        self.systemPrompts = systemPrompts
        self.maxReasoningTokens = maxReasoningTokens
        if let tools {
            self.toolConfig = ToolConfig(tools: tools)
        } else {
            self.toolConfig = nil
        }
    }

    func getConverseInput() throws -> ConverseInput {
        ConverseInput(
            additionalModelRequestFields: try getAdditionalModelRequestFields(),
            inferenceConfig: inferenceConfig?.getSDKInferenceConfig(),
            messages: try getSDKMessages(),
            modelId: model.id,
            system: getSDKSystemPrompts(),
            toolConfig: try toolConfig?.getSDKToolConfig()
        )
    }

    func getAdditionalModelRequestFields() throws -> Smithy.Document? {
        if model == .claudev3_7_sonnet, let maxReasoningTokens {
            let reasoningConfigJSON = JSON(with: [
                "thinking": [
                    "type": "enabled",
                    "budget_tokens": maxReasoningTokens,
                ]
            ])
            return try reasoningConfigJSON.toDocument()
        }
        return nil
    }

    func getSDKMessages() throws -> [BedrockRuntimeClientTypes.Message] {
        try messages.map { try $0.getSDKMessage() }
    }

    func getSDKSystemPrompts() -> [BedrockRuntimeClientTypes.SystemContentBlock]? {
        systemPrompts?.map {
            BedrockRuntimeClientTypes.SystemContentBlock.text($0)
        }
    }

    struct InferenceConfig {
        let maxTokens: Int?
        let temperature: Double?
        let topP: Double?
        let stopSequences: [String]?

        func getSDKInferenceConfig() -> BedrockRuntimeClientTypes.InferenceConfiguration {
            let temperatureFloat: Float?
            if temperature != nil {
                temperatureFloat = Float(temperature!)
            } else {
                temperatureFloat = nil
            }
            let topPFloat: Float?
            if topP != nil {
                topPFloat = Float(topP!)
            } else {
                topPFloat = nil
            }
            return BedrockRuntimeClientTypes.InferenceConfiguration(
                maxTokens: maxTokens,
                stopSequences: stopSequences,
                temperature: temperatureFloat,
                topp: topPFloat
            )
        }
    }

    public struct ToolConfig {
        // let toolChoice: ToolChoice?
        let tools: [Tool]

        func getSDKToolConfig() throws -> BedrockRuntimeClientTypes.ToolConfiguration {
            BedrockRuntimeClientTypes.ToolConfiguration(
                tools: try tools.map { .toolspec(try $0.getSDKToolSpecification()) }
            )
        }
    }
}

// public enum ToolChoice {
//     /// (Default). The Model automatically decides if a tool should be called or whether to generate text instead.
//     case auto(_)
//     /// The model must request at least one tool (no text is generated).
//     case any(_)
//     /// The Model must request the specified tool. Only supported by Anthropic Claude 3 models.
//     case tool(String)
// }
