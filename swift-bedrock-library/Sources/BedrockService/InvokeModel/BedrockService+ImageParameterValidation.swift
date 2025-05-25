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

import BedrockTypes
import Foundation

extension BedrockService {

    /// Validates image generation parameters against the model's capabilities and constraints
    /// - Parameters:
    ///   - modality: The image modality of the model
    ///   - nrOfImages: Optional number of images to generate
    ///   - cfgScale: Optional classifier free guidance scale
    ///   - resolution: Optional image resolution settings
    ///   - seed: Optional seed for reproducible generation
    /// - Throws: BedrockServiceError for invalid parameters
    private func validateImageGenerationParams(
        model: BedrockModel,
        nrOfImages: Int? = nil,
        cfgScale: Double? = nil,
        resolution: ImageResolution? = nil,
        seed: Int? = nil
    ) throws {
        logger.trace(
            "Validating general image generation parameters",
            metadata: [
                "model": "\(model.id)",
                "nrOfImages": .stringConvertible(nrOfImages ?? "Not defined"),
                "cfgScale": .stringConvertible(cfgScale ?? "Not defined"),
                "resolution.height": .stringConvertible(resolution?.height ?? "Not defined"),
                "resolution.width": .stringConvertible(resolution?.width ?? "Not defined"),
                "seed": .stringConvertible(seed ?? "Not defined"),
            ]
        )
        let modality = try model.getImageModality()
        let parameters = modality.getParameters()
        if let nrOfImages {
            try parameters.nrOfImages.validateValue(nrOfImages)
        }
        if let cfgScale {
            try parameters.cfgScale.validateValue(cfgScale)
        }
        if let seed {
            try parameters.seed.validateValue(seed)
        }
        if let resolution {
            try modality.validateResolution(resolution)
        }
    }

    /// Validates parameters for text-to-image generation requests
    /// - Parameters:
    ///   - modality: The text-to-image modality of the model to use
    ///   - prompt: The input text prompt describing the desired image
    ///   - negativePrompt: Optional text describing what to avoid in the generated image
    /// - Throws: BedrockServiceError if the parameters are invalid or exceed model constraints
    public func validateTextToImageParams(
        model: BedrockModel,
        nrOfImages: Int? = nil,
        cfgScale: Double? = nil,
        resolution: ImageResolution? = nil,
        seed: Int? = nil,
        prompt: String,
        negativePrompt: String? = nil
    ) throws {
        try validateImageGenerationParams(
            model: model,
            nrOfImages: nrOfImages,
            cfgScale: cfgScale,
            resolution: resolution,
            seed: seed
        )
        logger.trace(
            "Validating text to image parameters",
            metadata: [
                "model": "\(model.id)",
                "prompt": "\(prompt)",
                "negativePrompt": .stringConvertible(negativePrompt ?? "Not defined"),
            ]
        )
        let modality = try model.getTextToImageModality()
        let parameters = modality.getTextToImageParameters()
        try parameters.prompt.validateValue(prompt)
        if let negativePrompt {
            try parameters.negativePrompt.validateValue(negativePrompt)
        }
    }

    /// Validates image variation generation parameters
    /// - Parameters:
    ///   - modality: The image variation modality of the model
    ///   - images: Array of base64 encoded images to use as reference
    ///   - prompt: Text prompt describing desired variations
    ///   - similarity: Optional parameter controlling variation similarity
    ///   - negativePrompt: Optional text describing what to avoid
    /// - Throws: BedrockServiceError for invalid parameters
    public func validateImageVariationParams(
        model: BedrockModel,
        nrOfImages: Int? = nil,
        cfgScale: Double? = nil,
        resolution: ImageResolution? = nil,
        seed: Int? = nil,
        images: [String],
        prompt: String? = nil,
        similarity: Double? = nil,
        negativePrompt: String? = nil
    ) throws {
        try validateImageGenerationParams(
            model: model,
            nrOfImages: nrOfImages,
            cfgScale: cfgScale,
            resolution: resolution,
            seed: seed
        )
        logger.trace(
            "Validating general image generation parameters",
            metadata: [
                "model": "\(model.id)",
                "prompt": .stringConvertible(prompt ?? "Not defined"),
                "negativePrompt": .stringConvertible(negativePrompt ?? "Not defined"),
                "similarity": .stringConvertible(similarity ?? "Not defined"),
                "images": "\(images.count)",
            ]
        )
        let modality = try model.getImageVariationModality()
        let parameters = modality.getImageVariationParameters()
        try parameters.images.validateValue(images.count)
        if let prompt {
            try parameters.prompt.validateValue(prompt)
        }
        if let similarity {
            try parameters.similarity.validateValue(similarity)
        }
        if let negativePrompt {
            try parameters.negativePrompt.validateValue(negativePrompt)
        }
    }
}
