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
import AwsCommonRuntimeKit
import BedrockTypes
import Foundation

extension BedrockService {

    /// Generates 1 to 5 image(s) from a text prompt using a specific model
    /// - Parameters:
    ///   - prompt: The text prompt describing the image that should be generated
    ///   - model: The BedrockModel that will be used to generate the image
    ///   - negativePrompt: Optional text describing what to avoid in the generated image
    ///   - nrOfImages: Optional number of images to generate (must be between 1 and 5, default 3)
    ///   - cfgScale: Optional classifier free guidance scale to control prompt adherence
    ///   - seed: Optional seed for reproducible image generation
    ///   - quality: Optional parameter to control the quality of generated images
    ///   - resolution: Optional parameter to specify the desired image resolution
    /// - Throws: BedrockServiceError.notSupported for parameters or functionalities that are not supported
    ///           BedrockServiceError.invalidParameter for invalid parameters
    ///           BedrockServiceError.invalidPrompt if the prompt is empty or too long
    ///           BedrockServiceError.invalidModality for invalid modality from the selected model
    ///           BedrockServiceError.invalidSDKResponse if the response body is missing
    /// - Returns: An ImageGenerationOutput object containing an array of generated images
    public func generateImage(
        _ prompt: String,
        with model: BedrockModel,
        negativePrompt: String? = nil,
        nrOfImages: Int? = nil,
        cfgScale: Double? = nil,
        seed: Int? = nil,
        quality: ImageQuality? = nil,
        resolution: ImageResolution? = nil
    ) async throws -> ImageGenerationOutput {
        logger.trace(
            "Generating image(s)",
            metadata: [
                "model.id": .string(model.id),
                "model.modality": .string(model.modality.getName()),
                "prompt": .string(prompt),
                "negativePrompt": .stringConvertible(negativePrompt ?? "not defined"),
                "nrOfImages": .stringConvertible(nrOfImages ?? "not defined"),
                "cfgScale": .stringConvertible(cfgScale ?? "not defined"),
                "seed": .stringConvertible(seed ?? "not defined"),
            ]
        )
        do {
            try validateTextToImageParams(
                model: model,
                nrOfImages: nrOfImages,
                cfgScale: cfgScale,
                resolution: resolution,
                seed: seed,
                prompt: prompt,
                negativePrompt: negativePrompt
            )
            let request: InvokeModelRequest = try InvokeModelRequest.createTextToImageRequest(
                model: model,
                prompt: prompt,
                negativeText: negativePrompt,
                nrOfImages: nrOfImages,
                cfgScale: cfgScale,
                seed: seed,
                quality: quality,
                resolution: resolution
            )
            let input: InvokeModelInput = try request.getInvokeModelInput()
            logger.trace(
                "Sending request to invokeModel",
                metadata: [
                    "model": .string(model.id), "request": .string(String(describing: input)),
                ]
            )
            let response = try await self.bedrockRuntimeClient.invokeModel(input: input)
            guard let responseBody = response.body else {
                logger.trace(
                    "Invalid response",
                    metadata: [
                        "response": .string(String(describing: response)),
                        "hasBody": .stringConvertible(response.body != nil),
                    ]
                )
                throw BedrockServiceError.invalidSDKResponse(
                    "Something went wrong while extracting body from response."
                )
            }
            let invokemodelResponse: InvokeModelResponse = try InvokeModelResponse.createImageResponse(
                body: responseBody,
                model: model
            )
            return try invokemodelResponse.getGeneratedImage()
        } catch {
            try handleCommonError(error, context: "listing foundation models")
            throw BedrockServiceError.unknownError("\(error)")  // FIXME: handleCommonError will always throw
        }
    }

    /// Generates 1 to 5 image variation(s) from reference images and a text prompt using a specific model
    /// - Parameters:
    ///   - images: Array of base64 encoded reference images to generate variations from
    ///   - prompt: The text prompt describing desired modifications to the reference images
    ///   - model: The BedrockModel that will be used to generate the variations
    ///   - negativePrompt: Optional text describing what to avoid in the generated variations
    ///   - similarity: Optional parameter controlling how closely variations should match reference (between 0.2 and 1.0)
    ///   - nrOfImages: Optional number of variations to generate (must be between 1 and 5, default 3)
    ///   - cfgScale: Optional classifier free guidance scale to control prompt adherence
    ///   - seed: Optional seed for reproducible variation generation
    ///   - quality: Optional parameter to control the quality of generated variations
    ///   - resolution: Optional parameter to specify the desired image resolution
    /// - Throws: BedrockServiceError.notSupported for parameters or functionalities that are not supported
    ///           BedrockServiceError.invalidParameter for invalid parameters
    ///           BedrockServiceError.invalidPrompt if the prompt is empty or too long
    ///           BedrockServiceError.invalidModality for invalid modality from the selected model
    ///           BedrockServiceError.invalidSDKResponse if the response body is missing
    /// - Returns: An ImageGenerationOutput object containing an array of generated image variations
    public func generateImageVariation(
        images: [String],
        prompt: String,
        with model: BedrockModel,
        negativePrompt: String? = nil,
        similarity: Double? = nil,
        nrOfImages: Int? = nil,
        cfgScale: Double? = nil,
        seed: Int? = nil,
        quality: ImageQuality? = nil,
        resolution: ImageResolution? = nil
    ) async throws -> ImageGenerationOutput {
        logger.trace(
            "Generating image(s) from reference image",
            metadata: [
                "model.id": .string(model.id),
                "model.modality": .string(model.modality.getName()),
                "prompt": .string(prompt),
                "nrOfImages": .stringConvertible(nrOfImages ?? "not defined"),
                "similarity": .stringConvertible(similarity ?? "not defined"),
                "negativePrompt": .stringConvertible(negativePrompt ?? "not defined"),
                "cfgScale": .stringConvertible(cfgScale ?? "not defined"),
                "seed": .stringConvertible(seed ?? "not defined"),
            ]
        )
        do {
            try validateImageVariationParams(
                model: model,
                nrOfImages: nrOfImages,
                cfgScale: cfgScale,
                resolution: resolution,
                seed: seed,
                images: images,
                prompt: prompt,
                similarity: similarity,
                negativePrompt: negativePrompt
            )
            let request: InvokeModelRequest = try InvokeModelRequest.createImageVariationRequest(
                model: model,
                prompt: prompt,
                negativeText: negativePrompt,
                images: images,
                similarity: similarity,
                nrOfImages: nrOfImages,
                cfgScale: cfgScale,
                seed: seed,
                quality: quality,
                resolution: resolution
            )
            let input: InvokeModelInput = try request.getInvokeModelInput()
            logger.trace(
                "Sending request to invokeModel",
                metadata: [
                    "model": .string(model.id), "request": .string(String(describing: input)),
                ]
            )
            let response = try await self.bedrockRuntimeClient.invokeModel(input: input)
            guard let responseBody = response.body else {
                logger.trace(
                    "Invalid response",
                    metadata: [
                        "response": .string(String(describing: response)),
                        "hasBody": .stringConvertible(response.body != nil),
                    ]
                )
                throw BedrockServiceError.invalidSDKResponse(
                    "Something went wrong while extracting body from response."
                )
            }
            let invokemodelResponse: InvokeModelResponse = try InvokeModelResponse.createImageResponse(
                body: responseBody,
                model: model
            )
            return try invokemodelResponse.getGeneratedImage()
        } catch {
            try handleCommonError(error, context: "listing foundation models")
            throw BedrockServiceError.unknownError("\(error)")  // FIXME: handleCommonError will always throw
        }
    }

    /// Generates 1 to 5 image variation(s) from reference images and a text prompt using a specific model
    /// - Parameters:
    ///   - image: A base64 encoded reference image to generate variations from
    ///   - prompt: The text prompt describing desired modifications to the reference images
    ///   - model: The BedrockModel that will be used to generate the variations
    ///   - negativePrompt: Optional text describing what to avoid in the generated variations
    ///   - similarity: Optional parameter controlling how closely variations should match reference (between 0.2 and 1.0)
    ///   - nrOfImages: Optional number of variations to generate (must be between 1 and 5, default 3)
    ///   - cfgScale: Optional classifier free guidance scale to control prompt adherence
    ///   - seed: Optional seed for reproducible variation generation
    ///   - quality: Optional parameter to control the quality of generated variations
    ///   - resolution: Optional parameter to specify the desired image resolution
    /// - Throws: BedrockServiceError.notSupported for parameters or functionalities that are not supported
    ///           BedrockServiceError.invalidParameter for invalid parameters
    ///           BedrockServiceError.invalidPrompt if the prompt is empty or too long
    ///           BedrockServiceError.invalidModality for invalid modality from the selected model
    ///           BedrockServiceError.invalidSDKResponse if the response body is missing
    /// - Returns: An ImageGenerationOutput object containing an array of generated image variations
    public func generateImageVariation(
        image: String,
        prompt: String,
        with model: BedrockModel,
        negativePrompt: String? = nil,
        similarity: Double? = nil,
        nrOfImages: Int? = nil,
        cfgScale: Double? = nil,
        seed: Int? = nil,
        quality: ImageQuality? = nil,
        resolution: ImageResolution? = nil
    ) async throws -> ImageGenerationOutput {
        try await generateImageVariation(
            images: [image],
            prompt: prompt,
            with: model,
            negativePrompt: negativePrompt,
            similarity: similarity,
            nrOfImages: nrOfImages,
            cfgScale: cfgScale,
            seed: seed,
            quality: quality,
            resolution: resolution
        )
    }
}
