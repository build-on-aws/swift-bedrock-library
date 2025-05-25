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

public struct InvokeModelResponse {
    let model: BedrockModel
    let contentType: ContentType
    let textCompletionBody: ContainsTextCompletion?
    let imageGenerationBody: ContainsImageGeneration?

    private init(
        model: BedrockModel,
        contentType: ContentType = .json,
        textCompletionBody: ContainsTextCompletion
    ) {
        self.model = model
        self.contentType = contentType
        self.textCompletionBody = textCompletionBody
        self.imageGenerationBody = nil
    }

    private init(
        model: BedrockModel,
        contentType: ContentType = .json,
        imageGenerationBody: ContainsImageGeneration
    ) {
        self.model = model
        self.contentType = contentType
        self.imageGenerationBody = imageGenerationBody
        self.textCompletionBody = nil
    }

    /// Creates a BedrockResponse from raw response data containing text completion
    /// - Parameters:
    ///   - data: The raw response data from the Bedrock service
    ///   - model: The Bedrock model that generated the response
    /// - Throws: BedrockServiceError.invalidModel if the model is not supported
    ///          BedrockServiceError.invalidResponseBody if the response cannot be decoded
    static func createTextResponse(body data: Data, model: BedrockModel) throws -> Self {
        do {
            let textModality = try model.getTextModality()
            return self.init(model: model, textCompletionBody: try textModality.getTextResponseBody(from: data))
        } catch {
            throw BedrockServiceError.invalidSDKResponseBody(data)
        }
    }

    /// Creates a BedrockResponse from raw response data containing an image generation
    /// - Parameters:
    ///   - data: The raw response data from the Bedrock service
    ///   - model: The Bedrock model that generated the response
    /// - Throws: BedrockServiceError.invalidModel if the model is not supported
    ///          BedrockServiceError.invalidResponseBody if the response cannot be decoded
    static func createImageResponse(body data: Data, model: BedrockModel) throws -> Self {
        do {
            let imageModality = try model.getImageModality()
            return self.init(model: model, imageGenerationBody: try imageModality.getImageResponseBody(from: data))
        } catch {
            throw BedrockServiceError.invalidSDKResponseBody(data)
        }
    }

    /// Extracts the text completion from the response body
    /// - Returns: The text completion from the response
    /// - Throws: BedrockServiceError.decodingError if the completion cannot be extracted
    public func getTextCompletion() throws -> TextCompletion {
        do {
            guard let textCompletionBody = textCompletionBody else {
                throw BedrockServiceError.decodingError("No text completion body found in the response")
            }
            return try textCompletionBody.getTextCompletion()
        } catch {
            throw BedrockServiceError.decodingError(
                "Something went wrong while decoding the request body to find the completion: \(error)"
            )
        }
    }

    /// Extracts the image generation from the response body
    /// - Returns: The image generation from the response
    /// - Throws: BedrockServiceError.decodingError if the image generation cannot be extracted
    public func getGeneratedImage() throws -> ImageGenerationOutput {
        do {
            guard let imageGenerationBody = imageGenerationBody else {
                throw BedrockServiceError.decodingError("No image generation body found in the response")
            }
            return imageGenerationBody.getGeneratedImage()
        } catch {
            throw BedrockServiceError.decodingError(
                "Something went wrong while decoding the request body to find the completion: \(error)"
            )
        }
    }
}
