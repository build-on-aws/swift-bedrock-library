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
import AWSClientRuntime
import AWSSDKIdentity
import BedrockService
import BedrockTypes
import Foundation

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
            let json: JSON = JSON(with: additionalModelRequestFields)
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

    // returns "Hello, your prompt was: \(textPrompt)"
    private func getTextStream(
        _ textPrompt: String = "Streaming Text"
    ) -> AsyncThrowingStream<BedrockRuntimeClientTypes.ConverseStreamOutput, Error> {
        AsyncThrowingStream<BedrockRuntimeClientTypes.ConverseStreamOutput, Error> { continuation in
            // Message start
            let messageStartEvent = BedrockRuntimeClientTypes.MessageStartEvent(
                role: .assistant
            )
            continuation.yield(.messagestart(messageStartEvent))

            // Content block start
            let contentBlockStartEvent = BedrockRuntimeClientTypes.ContentBlockStartEvent(
                contentBlockIndex: 0,
                start: nil
            )
            continuation.yield(.contentblockstart(contentBlockStartEvent))

            // Content block delta (first part)
            let contentBlockDelta1 = BedrockRuntimeClientTypes.ContentBlockDelta.text(
                "Hello, "
            )
            let contentBlockDeltaEvent1 = BedrockRuntimeClientTypes.ContentBlockDeltaEvent(
                contentBlockIndex: 0,
                delta: contentBlockDelta1
            )
            continuation.yield(.contentblockdelta(contentBlockDeltaEvent1))

            // Content block delta (second part)
            let contentBlockDelta2 = BedrockRuntimeClientTypes.ContentBlockDelta.text(
                "your prompt "
            )
            let contentBlockDeltaEvent2 = BedrockRuntimeClientTypes.ContentBlockDeltaEvent(
                contentBlockIndex: 0,
                delta: contentBlockDelta2
            )
            continuation.yield(.contentblockdelta(contentBlockDeltaEvent2))

            // Content block delta (third part)
            let contentBlockDelta3 = BedrockRuntimeClientTypes.ContentBlockDelta.text(
                "was: "
            )
            let contentBlockDeltaEvent3 = BedrockRuntimeClientTypes.ContentBlockDeltaEvent(
                contentBlockIndex: 0,
                delta: contentBlockDelta3
            )
            continuation.yield(.contentblockdelta(contentBlockDeltaEvent3))

            // Content block delta (third part)
            let contentBlockDelta4 = BedrockRuntimeClientTypes.ContentBlockDelta.text(
                textPrompt
            )
            let contentBlockDeltaEvent4 = BedrockRuntimeClientTypes.ContentBlockDeltaEvent(
                contentBlockIndex: 0,
                delta: contentBlockDelta4
            )
            continuation.yield(.contentblockdelta(contentBlockDeltaEvent4))

            // Content block stop
            let contentBlockStopEvent = BedrockRuntimeClientTypes.ContentBlockStopEvent(
                contentBlockIndex: 0
            )
            continuation.yield(.contentblockstop(contentBlockStopEvent))

            // Message stop
            let messageStopEvent = BedrockRuntimeClientTypes.MessageStopEvent(
                additionalModelResponseFields: nil,
                stopReason: nil
            )
            continuation.yield(.messagestop(messageStopEvent))

            continuation.finish()
        }
    }

    private func getToolUseStream(
        for toolName: String
    ) -> AsyncThrowingStream<BedrockRuntimeClientTypes.ConverseStreamOutput, Error> {
        AsyncThrowingStream<BedrockRuntimeClientTypes.ConverseStreamOutput, Error> { continuation in
            // Message start
            let messageStartEvent = BedrockRuntimeClientTypes.MessageStartEvent(
                role: .assistant
            )
            continuation.yield(.messagestart(messageStartEvent))

            // Content block start
            let contentBlockStartEvent = BedrockRuntimeClientTypes.ContentBlockStartEvent(
                contentBlockIndex: 0,
                start: .tooluse(BedrockRuntimeClientTypes.ToolUseBlockStart(name: toolName, toolUseId: "tooluseid"))
            )
            continuation.yield(.contentblockstart(contentBlockStartEvent))

            // Content block delta
            let contentBlockDelta = BedrockRuntimeClientTypes.ContentBlockDelta.tooluse(
                BedrockRuntimeClientTypes.ToolUseBlockDelta(input: "{\"key\": \"ABC\"}")
            )
            let contentBlockDeltaEvent = BedrockRuntimeClientTypes.ContentBlockDeltaEvent(
                contentBlockIndex: 0,
                delta: contentBlockDelta
            )
            continuation.yield(.contentblockdelta(contentBlockDeltaEvent))

            // Content block stop
            let contentBlockStopEvent = BedrockRuntimeClientTypes.ContentBlockStopEvent(
                contentBlockIndex: 0
            )
            continuation.yield(.contentblockstop(contentBlockStopEvent))

            // Message stop
            let messageStopEvent = BedrockRuntimeClientTypes.MessageStopEvent(
                additionalModelResponseFields: nil,
                stopReason: nil
            )
            continuation.yield(.messagestop(messageStopEvent))

            continuation.finish()
        }
    }

    private func getReasoningStream(
        _ textPrompt: String = "Streaming Text"
    ) -> AsyncThrowingStream<BedrockRuntimeClientTypes.ConverseStreamOutput, Error> {
        AsyncThrowingStream<BedrockRuntimeClientTypes.ConverseStreamOutput, Error> { continuation in
            // Message start
            let messageStartEvent = BedrockRuntimeClientTypes.MessageStartEvent(
                role: .assistant
            )
            continuation.yield(.messagestart(messageStartEvent))

            // Content block start 0
            let contentBlockStartEvent = BedrockRuntimeClientTypes.ContentBlockStartEvent(
                contentBlockIndex: 0,
                start: nil
            )
            continuation.yield(.contentblockstart(contentBlockStartEvent))

            // Content block delta (reasoning - first part)
            let contentBlockDeltaReasoning1 = BedrockRuntimeClientTypes.ContentBlockDelta.reasoningcontent(
                BedrockRuntimeClientTypes.ReasoningContentBlockDelta.text("reasoning ")
            )
            let contentBlockDeltaReasoningEvent1 = BedrockRuntimeClientTypes.ContentBlockDeltaEvent(
                contentBlockIndex: 0,
                delta: contentBlockDeltaReasoning1
            )
            continuation.yield(.contentblockdelta(contentBlockDeltaReasoningEvent1))

            // Content block delta (reasoning - second part)
            let contentBlockDeltaReasoning2 = BedrockRuntimeClientTypes.ContentBlockDelta.reasoningcontent(
                BedrockRuntimeClientTypes.ReasoningContentBlockDelta.text("text ")
            )
            let contentBlockDeltaReasoningEvent2 = BedrockRuntimeClientTypes.ContentBlockDeltaEvent(
                contentBlockIndex: 0,
                delta: contentBlockDeltaReasoning2
            )
            continuation.yield(.contentblockdelta(contentBlockDeltaReasoningEvent2))

            // Content block stop
            let contentBlockStopEvent = BedrockRuntimeClientTypes.ContentBlockStopEvent(
                contentBlockIndex: 0
            )
            continuation.yield(.contentblockstop(contentBlockStopEvent))

            // Content block start 1
            let contentBlockStartEvent1 = BedrockRuntimeClientTypes.ContentBlockStartEvent(
                contentBlockIndex: 1,
                start: nil
            )
            continuation.yield(.contentblockstart(contentBlockStartEvent1))

            // Content block delta (first part)
            let contentBlockDelta1 = BedrockRuntimeClientTypes.ContentBlockDelta.text(
                "Hello, "
            )
            let contentBlockDeltaEvent1 = BedrockRuntimeClientTypes.ContentBlockDeltaEvent(
                contentBlockIndex: 1,
                delta: contentBlockDelta1
            )
            continuation.yield(.contentblockdelta(contentBlockDeltaEvent1))

            // Content block delta (second part)
            let contentBlockDelta2 = BedrockRuntimeClientTypes.ContentBlockDelta.text(
                "your prompt "
            )
            let contentBlockDeltaEvent2 = BedrockRuntimeClientTypes.ContentBlockDeltaEvent(
                contentBlockIndex: 1,
                delta: contentBlockDelta2
            )
            continuation.yield(.contentblockdelta(contentBlockDeltaEvent2))

            // Content block delta (third part)
            let contentBlockDelta3 = BedrockRuntimeClientTypes.ContentBlockDelta.text(
                "was: "
            )
            let contentBlockDeltaEvent3 = BedrockRuntimeClientTypes.ContentBlockDeltaEvent(
                contentBlockIndex: 1,
                delta: contentBlockDelta3
            )
            continuation.yield(.contentblockdelta(contentBlockDeltaEvent3))

            // Content block delta (third part)
            let contentBlockDelta4 = BedrockRuntimeClientTypes.ContentBlockDelta.text(
                textPrompt
            )
            let contentBlockDeltaEvent4 = BedrockRuntimeClientTypes.ContentBlockDeltaEvent(
                contentBlockIndex: 1,
                delta: contentBlockDelta4
            )
            continuation.yield(.contentblockdelta(contentBlockDeltaEvent4))

            // Content block stop
            let contentBlockStopEvent1 = BedrockRuntimeClientTypes.ContentBlockStopEvent(
                contentBlockIndex: 1
            )
            continuation.yield(.contentblockstop(contentBlockStopEvent1))

            // Message stop
            let messageStopEvent = BedrockRuntimeClientTypes.MessageStopEvent(
                additionalModelResponseFields: nil,
                stopReason: nil
            )
            continuation.yield(.messagestop(messageStopEvent))

            continuation.finish()
        }
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
                let toolInputJson = JSON(with: ["code": "abc"])
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
        let model: BedrockModel = BedrockModel(rawValue: modelId)!

        switch model.modality.getName() {
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
