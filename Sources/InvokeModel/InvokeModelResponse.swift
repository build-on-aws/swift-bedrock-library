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
import Logging

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

public struct InvokeModelResponse {
    let model: BedrockModel
    let contentType: ContentType

    let body: BodyType

    public enum BodyType {
        case textCompletion(ContainsTextCompletion)
        case imageGeneration(ContainsImageGeneration)
        case embeddings(ContainsEmbeddings)
    }

    private init(
        model: BedrockModel,
        contentType: ContentType = .json,
        textCompletionBody: ContainsTextCompletion
    ) {
        self.model = model
        self.contentType = contentType
        self.body = .textCompletion(textCompletionBody)
    }

    private init(
        model: BedrockModel,
        contentType: ContentType = .json,
        imageGenerationBody: ContainsImageGeneration
    ) {
        self.model = model
        self.contentType = contentType
        self.body = .imageGeneration(imageGenerationBody)
    }

    private init(
        model: BedrockModel,
        contentType: ContentType = .json,
        embeddingsBody: ContainsEmbeddings
    ) {
        self.model = model
        self.contentType = contentType
        self.body = .embeddings(embeddingsBody)
    }

    /// Creates a BedrockResponse from raw response data containing text completion
    /// - Parameters:
    ///   - data: The raw response data from the Bedrock service
    ///   - model: The Bedrock model that generated the response
    /// - Throws: BedrockLibraryError.invalidModel if the model is not supported
    ///          BedrockLibraryError.invalidResponseBody if the response cannot be decoded
    static func createTextResponse(body data: Data, model: BedrockModel, logger: Logger) throws -> Self {
        do {
            let textModality = try model.getTextModality()
            logger.trace("Raw response data:\n\(String(data: data, encoding: .utf8) ?? "")\n")
            return self.init(model: model, textCompletionBody: try textModality.getTextResponseBody(from: data))
        } catch {
            throw BedrockLibraryError.invalidSDKResponseBody(data)
        }
    }

    /// Creates a BedrockResponse from raw response data containing an image generation
    /// - Parameters:
    ///   - data: The raw response data from the Bedrock service
    ///   - model: The Bedrock model that generated the response
    /// - Throws: BedrockLibraryError.invalidModel if the model is not supported
    ///          BedrockLibraryError.invalidResponseBody if the response cannot be decoded
    static func createImageResponse(body data: Data, model: BedrockModel, logger: Logger) throws -> Self {
        do {
            let imageModality = try model.getImageModality()
            logger.trace("Raw response", metadata: ["Data": "\(String(data: data, encoding: .utf8) ?? "")"])
            return self.init(model: model, imageGenerationBody: try imageModality.getImageResponseBody(from: data))
        } catch {
            throw BedrockLibraryError.invalidSDKResponseBody(data)
        }
    }

    static func createEmbeddingsResponse(body data: Data, model: BedrockModel, logger: Logger) throws -> Self {
        do {
            let embeddingModality = try model.getEmbeddingsModality()
            logger.trace("Raw response data:\n\(String(data: data, encoding: .utf8)?.prefix(100) ?? "")\n")
            return self.init(model: model, embeddingsBody: try embeddingModality.getEmbeddingsResponseBody(from: data))
        } catch {
            throw BedrockLibraryError.invalidSDKResponseBody(data)
        }

    }

    /// Extracts the text completion from the response body
    /// - Returns: The text completion from the response
    /// - Throws: BedrockLibraryError.decodingError if the completion cannot be extracted
    public func getTextCompletion() throws -> TextCompletion {
        do {
            guard case .textCompletion(let textCompletionBody) = self.body else {
                throw BedrockLibraryError.decodingError("No text completion body found in the response")
            }
            return try textCompletionBody.getTextCompletion()
        } catch {
            throw BedrockLibraryError.decodingError(
                "Something went wrong while decoding the request body to find the completion: \(error)"
            )
        }
    }

    /// Extracts the image generation from the response body
    /// - Returns: The image generation from the response
    /// - Throws: BedrockLibraryError.decodingError if the image generation cannot be extracted
    public func getGeneratedImage() throws -> ImageGenerationOutput {
        do {
            guard case .imageGeneration(let imageGenerationBody) = self.body else {
                throw BedrockLibraryError.decodingError("No image generation body found in the response")
            }
            return imageGenerationBody.getGeneratedImage()
        } catch {
            throw BedrockLibraryError.decodingError(
                "Something went wrong while decoding the request body to find the completion: \(error)"
            )
        }
    }

    public func getEmbeddings() throws -> Embeddings {
        do {
            guard case .embeddings(let embeddingsBody) = self.body else {
                throw BedrockLibraryError.decodingError("No embeddings body found in the response")
            }
            return embeddingsBody.getEmbeddings()
        } catch {
            throw BedrockLibraryError.decodingError(
                "Something went wrong while decoding the request body to find the embeddings: \(error)"
            )
        }
    }
}
