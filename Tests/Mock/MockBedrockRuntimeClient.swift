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
import BedrockService
import Foundation
import Testing

public struct MockBedrockRuntimeClient: BedrockRuntimeClientProtocol {
    public init() {}

    // MARK: converseStream
    public func converseStream(input: ConverseStreamInput) async throws -> ConverseStreamOutput {

        guard let messages = input.messages,
            let content = messages.last?.content?.last
        else {
            throw AWSBedrockRuntime.ValidationException(message: "Missing required message content")
        }

        var stream: AsyncThrowingStream<BedrockRuntimeClientTypes.ConverseStreamOutput, Error>

        var reasoningEnabled: Bool?
        var maxReasoningTokens: Int?

        if let additionalModelRequestFields = input.additionalModelRequestFields {
            let json = try additionalModelRequestFields.toJSON()
            reasoningEnabled = json["thinking"]?["enabled"]
            maxReasoningTokens = json["thinking"]?["budget_tokens"]
        }

        if let reasoningEnabled, reasoningEnabled, let maxReasoningTokens {
            guard maxReasoningTokens >= 0 else {
                throw AWSBedrockRuntime.ValidationException(
                    message: "Invalid reasoning budget tokens: \(maxReasoningTokens)"
                )
            }
            stream = getReasoningStream()
            return ConverseStreamOutput(stream: stream)
        }

        switch content {
        case .text(let prompt):
            if prompt == "Use tool",
                input.toolConfig?.tools != nil
            {
                stream = getToolUseStream(for: "toolname")
            } else {
                stream = getTextStream(prompt)
            }
        case .toolresult(let block):
            let toolUseId = block.toolUseId ?? "not found"
            stream = getTextStream("Tool result received for toolUseId: \(toolUseId)")
        // "Hello, your prompt was: Tool result received for toolUseId: \(toolUseId)"
        case .image(_):
            stream = getTextStream("Image received")
        case .document(_):
            stream = getTextStream("Document received")
        case .video(_):
            stream = getTextStream("Video received")
        default:
            throw AWSBedrockRuntime.ValidationException(
                message: "Malformed input request, please reformat your input and try again."
            )
        }
        return ConverseStreamOutput(stream: stream)
    }

    // MARK: converse
    public func converse(input: ConverseInput) async throws -> ConverseOutput {
        guard let messages = input.messages,
            let content = messages.last?.content?.last
        else {
            throw AWSBedrockRuntime.ValidationException(message: "Missing required message content")
        }

        var replyContent: [BedrockRuntimeClientTypes.ContentBlock] = []
        guard let modelId = input.modelId else {
            throw AWSBedrockRuntime.ValidationException(message: "Missing required modelId")
        }
        // Only for testing purposes: Claude 3.7 will always add a reasoning block,
        // unless prompt "encrypted" is used
        if modelId == "us.anthropic.claude-3-7-sonnet-20250219-v1:0" {
            if case .text(let prompt) = content, prompt == "encrypted" {
                let data: Data = try JSONEncoder().encode(["redacted": "data"])
                replyContent.append(
                    .reasoningcontent(
                        .redactedcontent(data)
                    )
                )
            } else {
                replyContent.append(
                    .reasoningcontent(
                        .reasoningtext(
                            BedrockRuntimeClientTypes.ReasoningTextBlock(
                                signature: "reasoning signature",
                                text: "reasoning text"
                            )
                        )
                    )
                )
            }
        }

        switch content {
        case .text(let prompt):
            if prompt == "Use tool", let _ = input.toolConfig?.tools {
                let toolInputJson = JSON(with: .object(["code": .string("string")]))
                let toolInput = try? toolInputJson.toDocument()
                replyContent.append(
                    .tooluse(
                        BedrockRuntimeClientTypes.ToolUseBlock(
                            input: toolInput,
                            name: "toolName",
                            toolUseId: "toolId"
                        )
                    )
                )
                let message = BedrockRuntimeClientTypes.Message(
                    content: replyContent,
                    role: .assistant
                )
                return ConverseOutput(output: .message(message))
            }
            replyContent.append(
                .text("Your prompt was: \(prompt)")
            )
        case .toolresult(_):
            replyContent.append(.text("Tool result received"))
        case .image(_):
            replyContent.append(.text("Image received"))
        case .document(_):
            replyContent.append(.text("Document received"))
        default:
            throw AWSBedrockRuntime.ValidationException(
                message: "Malformed input request, please reformat your input and try again."
            )
        }
        return ConverseOutput(
            output: .message(
                BedrockRuntimeClientTypes.Message(
                    content: replyContent,
                    role: .assistant
                )
            )
        )
    }

    // MARK: invokeModel

    public func invokeModel(input: InvokeModelInput) async throws -> InvokeModelOutput {
        guard let modelId = input.modelId else {
            throw AWSBedrockRuntime.ValidationException(
                message: "Malformed input request, please reformat your input and try again."
            )
        }
        guard let inputBody = input.body else {
            throw AWSBedrockRuntime.ValidationException(
                message: "Malformed input request, please reformat your input and try again."
            )
        }

        // remove the cross region inference prefix if it exists
        // when modelId starts with "us.", "eu.", "ap.", remove it"
        let prefixPattern: String = "^(us|eu|ap)\\."
        let modelIdWithoutPrefix = modelId.replacingOccurrences(
            of: prefixPattern,
            with: "",
            options: .regularExpression
        )
        let model: BedrockModel? = BedrockModel(rawValue: modelIdWithoutPrefix)
        #expect(model != nil, "Model with id \(modelIdWithoutPrefix) not found")

        switch model?.modality.getName() {
        case "Amazon Image Generation":
            return InvokeModelOutput(body: try getImageGeneration(body: inputBody))
        case "Nova Text Generation":
            return InvokeModelOutput(body: try invokeNovaModel(body: inputBody))
        case "Titan Text Generation":
            return InvokeModelOutput(body: try invokeTitanModel(body: inputBody))
        case "Anthropic Text Generation":
            return InvokeModelOutput(body: try invokeAnthropicModel(body: inputBody))
        default:
            throw AWSBedrockRuntime.ValidationException(
                message: "Malformed input request, please reformat your input and try again."
            )
        }
    }

    private func getImageGeneration(body: Data) throws -> Data {
        guard
            let json: [String: Any] = try? JSONSerialization.jsonObject(
                with: body,
                options: []
            )
                as? [String: Any],
            let imageGenerationConfig = json["imageGenerationConfig"] as? [String: Any]
        else {
            throw AWSBedrockRuntime.ValidationException(
                message: "Malformed input request, please reformat your input and try again."
            )
        }
        let nrOfImages = imageGenerationConfig["numberOfImages"] as? Int ?? 1
        let mockBase64Image =
            "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII="
        let imageArray = Array(repeating: "\"\(mockBase64Image)\"", count: nrOfImages)
        return """
            {
                "images": [
                    \(imageArray.joined(separator: ",\n                "))
                ]
            }
            """.data(using: .utf8)!
    }

    private func invokeNovaModel(body: Data) throws -> Data? {
        guard
            let json: [String: Any] = try? JSONSerialization.jsonObject(
                with: body,
                options: []
            )
                as? [String: Any]
        else {
            throw AWSBedrockRuntime.ValidationException(
                message: "Malformed input request, please reformat your input and try again."
            )
        }
        if let messages = json["messages"] as? [[String: Any]],
            let firstMessage = messages.first,
            let content = firstMessage["content"] as? [[String: Any]],
            let firstContent = content.first,
            let inputText = firstContent["text"] as? String
        {
            return """
                {
                    "output":{
                        "message":{
                            "content":[
                                {"text":"This is the textcompletion for: \(inputText)"}
                            ],
                            "role":"assistant"
                        }},
                    "stopReason":"end_turn",
                    "usage":{
                        "inputTokens":5,
                        "outputTokens":244,
                        "totalTokens":249,
                        "cacheReadInputTokenCount":0,
                        "cacheWriteInputTokenCount":0
                    }
                }
                """.data(using: .utf8)!
        } else {
            throw AWSBedrockRuntime.ValidationException(
                message: "Malformed input request, please reformat your input and try again."
            )
        }
    }

    private func invokeTitanModel(body: Data) throws -> Data? {
        guard
            let json: [String: Any] = try? JSONSerialization.jsonObject(
                with: body,
                options: []
            )
                as? [String: Any]
        else {
            throw AWSBedrockRuntime.ValidationException(
                message: "Hier is het)"
                    // message: "Malformed input request, please reformat your input and try again."
            )
        }
        if let inputText = json["inputText"] as? String {
            return """
                {
                    "inputTextTokenCount":5,
                    "results":[
                        {
                            "tokenCount":105,
                            "outputText":"This is the textcompletion for: \(inputText)",
                            "completionReason":"FINISH"
                            }
                    ]
                }
                """.data(using: .utf8)!
        } else {
            throw AWSBedrockRuntime.ValidationException(
                message: "Malformed input request, please reformat your input and try again."
            )
        }
    }

    private func invokeAnthropicModel(body: Data) throws -> Data? {
        guard
            let json: [String: Any] = try? JSONSerialization.jsonObject(
                with: body,
                options: []
            )
                as? [String: Any]
        else {
            throw AWSBedrockRuntime.ValidationException(
                message: "Malformed input request, please reformat your input and try again."
            )
        }
        if let messages = json["messages"] as? [[String: Any]],
            let firstMessage = messages.first,
            let content = firstMessage["content"] as? [[String: Any]],
            let firstContent = content.first,
            let inputText = firstContent["text"] as? String
        {
            return """
                {
                    "id":"msg_bdrk_0146cw8Wd6Dn8WZiQWeF6TEj",
                    "type":"message",
                    "role":"assistant",
                    "model":"claude-3-haiku-20240307",
                    "content":[
                        {
                            "type":"text",
                            "text":"This is the textcompletion for: \(inputText)"
                        }],
                    "stop_reason":"max_tokens",
                    "stop_sequence":null,
                    "usage":{
                        "input_tokens":12,
                        "output_tokens":100}
                }
                """.data(using: .utf8)!
        } else {
            throw AWSBedrockRuntime.ValidationException(
                message: "Malformed input request, please reformat your input and try again."
            )
        }
    }
}
