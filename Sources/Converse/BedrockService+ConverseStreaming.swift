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
import AwsCommonRuntimeKit
import Foundation

extension BedrockService {

    /// Converse with a model using the Bedrock Converse Streaming API
    /// - Parameters:
    ///   - model: The BedrockModel to converse with
    ///   - conversation: Array of previous messages in the conversation
    ///   - maxTokens: Optional maximum number of tokens to generate
    ///   - temperature: Optional temperature parameter for controlling randomness
    ///   - topP: Optional top-p parameter for nucleus sampling
    ///   - stopSequences: Optional array of sequences where generation should stop
    ///   - systemPrompts: Optional array of system prompts to guide the conversation
    ///   - tools: Optional array of tools the model can use
    /// - Throws: BedrockLibraryError.notSupported for parameters or functionalities that are not supported
    ///           BedrockLibraryError.invalidParameter for invalid parameters
    ///           BedrockLibraryError.invalidPrompt if the prompt is empty or too long
    ///           BedrockLibraryError.invalidModality for invalid modality from the selected model
    ///           BedrockLibraryError.invalidSDKResponse if the response body is missing
    /// - Returns: A ConverseReplyStream object that gives access to the high-level stream of ConverseStreamElements objects
    ///            or the low-level stream provided by the AWS SDK.
    public func converseStream(
        with model: BedrockModel,
        conversation: [Message],
        maxTokens: Int? = nil,
        temperature: Double? = nil,
        topP: Double? = nil,
        stopSequences: [String]? = nil,
        systemPrompts: [String]? = nil,
        tools: [Tool]? = nil,
        enableReasoning: Bool? = false,
        maxReasoningTokens: Int? = nil
    ) async throws -> ConverseReplyStream {
        do {
            guard model.hasConverseStreamingModality() else {
                throw BedrockLibraryError.invalidModality(
                    model,
                    try model.getConverseModality(),
                    "This model does not support converse streaming."
                )
            }
            let modality = try model.getConverseModality()
            let parameters = modality.getConverseParameters()
            try parameters.validate(
                maxTokens: maxTokens,
                temperature: temperature,
                topP: topP,
                stopSequences: stopSequences
            )

            logger.trace(
                "Creating ConverseStreamingRequest",
                metadata: [
                    "model.name": "\(model.name)",
                    "model.id": "\(model.id)",
                    "conversation.count": "\(conversation.count)",
                    "maxToken": "\(String(describing: maxTokens))",
                    "temperature": "\(String(describing: temperature))",
                    "topP": "\(String(describing: topP))",
                    "stopSequences": "\(String(describing: stopSequences))",
                    "systemPrompts": "\(String(describing: systemPrompts))",
                    "tools": "\(String(describing: tools))",
                ]
            )
            let converseRequest = ConverseStreamingRequest(
                model: model,
                messages: conversation,
                maxTokens: maxTokens,
                temperature: temperature,
                topP: topP,
                stopSequences: stopSequences,
                systemPrompts: systemPrompts,
                tools: tools,
                maxReasoningTokens: maxReasoningTokens
            )

            logger.trace("Creating ConverseStreamingInput")
            let input = try converseRequest.getConverseStreamingInput(forRegion: region)

            logger.trace(
                "Sending ConverseStreaminInput to BedrockRuntimeClient",
                metadata: [
                    "input.messages.count": "\(String(describing:input.messages!.count))",
                    "input.modelId": "\(String(describing:input.modelId!))",
                ]
            )
            let response: ConverseStreamOutput = try await self.bedrockRuntimeClient.converseStream(input: input)

            logger.trace("Received response", metadata: ["response": "\(response)"])

            guard let sdkStream = response.stream else {
                throw BedrockLibraryError.invalidSDKResponse(
                    "The response stream is missing. This error should never happen."
                )
            }
            // at this time, we have a stream. The stream is a message, with multiple content blocks
            // - message start
            // - message content start
            // - message content delta
            // - message content end
            // - message stop
            // - message metadata
            // see https://github.com/awslabs/aws-sdk-swift/blob/2697fb44f607b9c43ad0ce5ca79867d8d6c545c2/Sources/Services/AWSBedrockRuntime/Sources/AWSBedrockRuntime/Models.swift#L3478
            // it will be the responsibility of the user to handle the stream and re-assemble the messages and content

            let reply = try ConverseReplyStream(sdkStream, logger: logger)

            // this time, a different stream is created from the previous one, this one has the following elements
            // - messageStart: this is the start of a message, it contains the role (assistant or user)
            // - text: this is a delta of the text content, it contains the partial text
            // - reasoning: this is a delta of the reasoning content, it contains the partial reasoning text
            // - toolUse: this is a buffered tool use response, it contains the tool name and id, and the input parameters
            // - message complete: this includes the complete Message, ready to be added to the history and used for future requests
            // - metaData: this is the metadata about the response, it contains statitics about the response, such as the number of tokens used and the latency

            return reply

        } catch {
            try handleCommonError(error, context: "invoking converse stream")
        }
    }

    /// Use Converse Stream API with the ConverseBuilder
    /// - Parameters:
    ///   - builder: ConverseBuilder object
    /// - Throws: BedrockLibraryError.invalidSDKResponse if the response body is missing
    /// - Returns: A stream of ConverseResponseStreaming objects
    public func converseStream(
        with builder: ConverseRequestBuilder
    ) async throws -> ConverseReplyStream {
        logger.trace("Conversing and streaming")
        do {
            var history = builder.history
            let userMessage = try builder.getUserMessage()
            history.append(userMessage)
            let streamingResponse = try await converseStream(
                with: builder.model,
                conversation: history,
                maxTokens: builder.maxTokens,
                temperature: builder.temperature,
                topP: builder.topP,
                stopSequences: builder.stopSequences,
                systemPrompts: builder.systemPrompts,
                tools: builder.tools,
                maxReasoningTokens: builder.maxReasoningTokens
            )
            return streamingResponse
        } catch {
            logger.trace("Error while conversing", metadata: ["error": "\(error)"])
            throw error
        }
    }
}
