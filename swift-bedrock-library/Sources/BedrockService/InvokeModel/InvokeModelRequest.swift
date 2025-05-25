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

struct InvokeModelRequest {
    let model: BedrockModel
    let contentType: ContentType
    let accept: ContentType
    private let body: BedrockBodyCodable

    private init(
        model: BedrockModel,
        body: BedrockBodyCodable,
        contentType: ContentType = .json,
        accept: ContentType = .json
    ) {
        self.model = model
        self.body = body
        self.contentType = contentType
        self.accept = accept
    }

    // MARK: text
    /// Creates a BedrockRequest for a text request with the specified parameters
    /// - Parameters:
    ///   - model: The Bedrock model to use
    ///   - prompt: The input text prompt
    ///   - maxTokens: Maximum number of tokens to generate (default: 300)
    ///   - temperature: Temperature for text generation (default: 0.6)
    /// - Returns: A configured BedrockRequest for a text request
    /// - Throws: BedrockServiceError if the model doesn't support text output
    static func createTextRequest(
        model: BedrockModel,
        prompt: String,
        maxTokens: Int?,
        temperature: Double?,
        topP: Double?,
        topK: Int?,
        stopSequences: [String]?
    ) throws -> InvokeModelRequest {
        try .init(
            model: model,
            prompt: prompt,
            maxTokens: maxTokens,
            temperature: temperature,
            topP: topP,
            topK: topK,
            stopSequences: stopSequences
        )
    }

    private init(
        model: BedrockModel,
        prompt: String,
        maxTokens: Int?,
        temperature: Double?,
        topP: Double?,
        topK: Int?,
        stopSequences: [String]?
    ) throws {
        let textModality = try model.getTextModality()
        let body: BedrockBodyCodable = try textModality.getTextRequestBody(
            prompt: prompt,
            maxTokens: maxTokens,
            temperature: temperature,
            topP: topP,
            topK: topK,
            stopSequences: stopSequences
        )
        self.init(model: model, body: body)
    }

    // MARK: text to image
    /// Creates a BedrockRequest for a text-to-image request with the specified parameters
    /// - Parameters:
    ///   - model: The Bedrock model to use for image generation
    ///   - prompt: The text description of the image to generate
    ///   - nrOfImages: The number of images to generate
    /// - Returns: A configured BedrockRequest for image generation
    /// - Throws: BedrockServiceError if the model doesn't support text input or image output
    public static func createTextToImageRequest(
        model: BedrockModel,
        prompt: String,
        negativeText: String?,
        nrOfImages: Int?,
        cfgScale: Double?,
        seed: Int?,
        quality: ImageQuality?,
        resolution: ImageResolution?
    ) throws -> InvokeModelRequest {
        try .init(
            model: model,
            prompt: prompt,
            negativeText: negativeText,
            nrOfImages: nrOfImages,
            cfgScale: cfgScale,
            seed: seed,
            quality: quality,
            resolution: resolution
        )
    }

    private init(
        model: BedrockModel,
        prompt: String,
        negativeText: String?,
        nrOfImages: Int?,
        cfgScale: Double?,
        seed: Int?,
        quality: ImageQuality?,
        resolution: ImageResolution?
    ) throws {
        let textToImageModality = try model.getTextToImageModality()
        self.init(
            model: model,
            body: try textToImageModality.getTextToImageRequestBody(
                prompt: prompt,
                negativeText: negativeText,
                nrOfImages: nrOfImages,
                cfgScale: cfgScale,
                seed: seed,
                quality: quality,
                resolution: resolution
            )
        )
    }

    // MARK: image variation
    /// Creates a BedrockRequest for a request to generate variations of an existing image
    /// - Parameters:
    ///   - model: The Bedrock model to use for image variation generation
    ///   - prompt: The text description to guide the variation generation
    ///   - image: The base64-encoded string of the source image to create variations from
    ///   - similarity: A value between 0 and 1 indicating how similar the variations should be to the source image
    ///   - nrOfImages: The number of image variations to generate
    /// - Returns: A configured BedrockRequest for image variation generation
    /// - Throws: BedrockServiceError if the model doesn't support text and image input, or image output
    public static func createImageVariationRequest(
        model: BedrockModel,
        prompt: String,
        negativeText: String?,
        images: [String],
        similarity: Double?,
        nrOfImages: Int?,
        cfgScale: Double?,
        seed: Int?,
        quality: ImageQuality?,
        resolution: ImageResolution?
    ) throws -> InvokeModelRequest {
        try .init(
            model: model,
            prompt: prompt,
            negativeText: negativeText,
            images: images,
            similarity: similarity,
            nrOfImages: nrOfImages,
            cfgScale: cfgScale,
            seed: seed,
            quality: quality,
            resolution: resolution
        )
    }

    private init(
        model: BedrockModel,
        prompt: String,
        negativeText: String?,
        images: [String],
        similarity: Double?,
        nrOfImages: Int?,
        cfgScale: Double?,
        seed: Int?,
        quality: ImageQuality?,
        resolution: ImageResolution?
    ) throws {
        let modality = try model.getImageVariationModality()
        let body = try modality.getImageVariationRequestBody(
            prompt: prompt,
            negativeText: negativeText,
            images: images,
            similarity: similarity,
            nrOfImages: nrOfImages,
            cfgScale: cfgScale,
            seed: seed,
            quality: quality,
            resolution: resolution
        )
        self.init(model: model, body: body)
    }

    /// Creates an InvokeModelInput instance for making a request to Amazon Bedrock
    /// - Returns: A configured InvokeModelInput containing the model ID, content type, and encoded request body
    /// - Throws: BedrockServiceError.encodingError if the request body cannot be encoded to JSON
    public func getInvokeModelInput() throws -> InvokeModelInput {
        do {
            let jsonData: Data = try JSONEncoder().encode(self.body)
            return InvokeModelInput(
                accept: self.accept.headerValue,
                body: jsonData,
                contentType: self.contentType.headerValue,
                modelId: model.id
            )
        } catch {
            throw BedrockServiceError.encodingError(
                "Something went wrong while encoding the request body to JSON for InvokeModelInput: \(error)"
            )
        }
    }
}
