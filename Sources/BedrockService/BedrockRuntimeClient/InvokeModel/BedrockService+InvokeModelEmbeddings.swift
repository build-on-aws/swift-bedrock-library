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

    /// Generates embeddings for the provided text using the specified model
    /// - Parameters:
    ///   - text: The input text to generate embeddings for
    ///   - model: The Bedrock model to use for embeddings generation
    ///   - vectorSize: The size of the output vector (default: 1024)
    ///   - normalize: Whether to normalize the output vectors (default: true)
    /// - Returns: A TextCompletion containing the generated embeddings
    /// - Throws: BedrockLibraryError if the model doesn't support embeddings or if the request fails
    public func embed(
        _ text: String,
        with model: BedrockModel,
        vectorSize: Int = 1024,
        normalize: Bool = true
    ) async throws -> Embeddings {
        logger.trace(
            "Generating Embeddings",
            metadata: [
                "model.id": .string(model.id),
                "model.modality": .string(model.modality.getName()),
                "text": .string(text),
                "vectorSize": .string("\(vectorSize)"),
            ]
        )
        do {
            let modality = try model.getEmbeddingsModality()
            let parameters = modality.getParameters()
            try parameters.validate(
                prompt: text
            )

            logger.trace(
                "Creating InvokeModelRequest",
                metadata: [
                    "model": .string(model.id),
                    "text": "\(text)",
                ]
            )
            let request: InvokeModelRequest = try InvokeModelRequest.createEmbeddingsRequest(
                model: model,
                text: text,
                dimensions: vectorSize,
                normalize: normalize
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
                logger.trace("Extracted body from response", metadata: ["response.body": "\(bodyString.prefix(100))"])
            }

            let invokemodelResponse = try InvokeModelResponse.createEmbeddingsResponse(
                body: responseBody,
                model: model,
                logger: self.logger
            )
            logger.trace(
                "Generated embeddings",
                metadata: [
                    "model": .string(model.id)
                ]
            )
            return try invokemodelResponse.getEmbeddings()
        } catch {
            try handleCommonError(error, context: "calling embeddings")
        }
    }
}
