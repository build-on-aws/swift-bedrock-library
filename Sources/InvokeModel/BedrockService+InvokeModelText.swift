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

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

extension BedrockService {

    /// Generates a text completion using a specified model
    /// - Parameters:
    ///   - prompt: The text to be completed
    ///   - model: The BedrockModel that will be used to generate the completion
    ///   - maxTokens: The maximum amount of tokens in the completion (optional, default 300)
    ///   - temperature: The temperature used to generate the completion (optional, default 0.6)
    ///   - topP: Optional top-p parameter for nucleus sampling
    ///   - topK: Optional top-k parameter for filtering
    ///   - stopSequences: Optional array of sequences where generation should stop
    /// - Throws: BedrockLibraryError.notSupported for parameters or functionalities that are not supported
    ///           BedrockLibraryError.invalidParameter for invalid parameters
    ///           BedrockLibraryError.invalidPrompt for a prompt that is empty or too long
    ///           BedrockLibraryError.invalidStopSequences if too many stop sequences were provided
    ///           BedrockLibraryError.invalidModality for invalid modality from the selected model
    ///           BedrockLibraryError.invalidSDKResponse if the response body is missing
    /// - Returns: a TextCompletion object containing the generated text from the model
    public func completeText(
        _ prompt: String,
        with model: BedrockModel,
        maxTokens: Int? = nil,
        temperature: Double? = nil,
        topP: Double? = nil,
        topK: Int? = nil,
        stopSequences: [String]? = nil
    ) async throws -> TextCompletion {
        logger.trace(
            "Generating text completion",
            metadata: [
                "model.id": .string(model.id),
                "model.modality": .string(model.modality.getName()),
                "prompt": .string(prompt),
                "maxTokens": .stringConvertible(maxTokens ?? "not defined"),
                "temperature": .stringConvertible(temperature ?? "not defined"),
                "topP": .stringConvertible(topP ?? "not defined"),
                "topK": .stringConvertible(topK ?? "not defined"),
                "stopSequences": .stringConvertible(stopSequences ?? "not defined"),
            ]
        )
        do {
            let modality = try model.getTextModality()
            let parameters = modality.getParameters()
            try parameters.validate(
                prompt: prompt,
                maxTokens: maxTokens,
                temperature: temperature,
                topP: topP,
                topK: topK,
                stopSequences: stopSequences
            )

            logger.trace(
                "Creating InvokeModelRequest",
                metadata: [
                    "model": .string(model.id),
                    "prompt": "\(prompt)",
                ]
            )
            let request: InvokeModelRequest = try InvokeModelRequest.createTextRequest(
                model: model,
                prompt: prompt,
                maxTokens: maxTokens,
                temperature: temperature,
                topP: topP,
                topK: topK,
                stopSequences: stopSequences
            )
            let input: InvokeModelInput = try request.getInvokeModelInput(forRegion: self.region)
            logger.trace(
                "Sending request to invokeModel",
                metadata: [
                    "model": .string(model.id), "request": .string(String(describing: input)),
                ]
            )

            let response = try await self.bedrockRuntimeClient.invokeModel(input: input)
            logger.trace(
                "Received response from invokeModel",
                metadata: [
                    "model": .string(model.id), "response": .string(String(describing: response)),
                ]
            )

            guard let responseBody = response.body else {
                logger.trace(
                    "Invalid response",
                    metadata: [
                        "response": .string(String(describing: response)),
                        "hasBody": .stringConvertible(response.body != nil),
                    ]
                )
                throw BedrockLibraryError.invalidSDKResponse(
                    "Something went wrong while extracting body from response."
                )
            }
            if let bodyString = String(data: responseBody, encoding: .utf8) {
                logger.trace("Extracted body from response", metadata: ["response.body": "\(bodyString)"])
            }

            let invokemodelResponse: InvokeModelResponse = try InvokeModelResponse.createTextResponse(
                body: responseBody,
                model: model,
                logger: self.logger
            )
            logger.trace(
                "Generated text completion",
                metadata: [
                    "model": .string(model.id), "response": .string(String(describing: invokemodelResponse)),
                ]
            )
            return try invokemodelResponse.getTextCompletion()
        } catch {
            try handleCommonError(error, context: "listing foundation models")
        }
    }
}
