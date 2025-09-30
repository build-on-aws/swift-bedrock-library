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

@preconcurrency import AWSBedrockRuntime
import Smithy

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

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

    func getConverseInput(forRegion region: Region) throws -> ConverseInput {
        ConverseInput(
            additionalModelRequestFields: try getAdditionalModelRequestFields(),
            inferenceConfig: inferenceConfig?.getSDKInferenceConfig(),
            messages: try getSDKMessages(),
            modelId: model.getModelIdWithCrossRegionInferencePrefix(region: region),
            system: getSDKSystemPrompts(),
            toolConfig: try toolConfig?.getSDKToolConfig()
        )
    }

    func getAdditionalModelRequestFields() throws -> Smithy.Document? {
        //FIXME: this is incorrect. We should check for all Claude models
        if model == .claudev3_7_sonnet, let maxReasoningTokens {
            let reasoningConfigJSON = JSON(
                with: .array(
                    [
                        .object([
                            "thinking": .object([
                                "type": .string("enabled"),
                                "budget_tokens": .int(maxReasoningTokens),
                            ])
                        ])
                    ]
                )
            )

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
