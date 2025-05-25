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

import Foundation

struct AmazonImage: ImageModality, TextToImageModality, ConditionedTextToImageModality, ImageVariationModality {
    func getName() -> String { "Amazon Image Generation" }

    let parameters: ImageGenerationParameters
    let resolutionValidator: any ImageResolutionValidator
    let textToImageParameters: TextToImageParameters
    let conditionedTextToImageParameters: ConditionedTextToImageParameters
    let imageVariationParameters: ImageVariationParameters

    init(
        parameters: ImageGenerationParameters,
        resolutionValidator: any ImageResolutionValidator,
        textToImageParameters: TextToImageParameters,
        conditionedTextToImageParameters: ConditionedTextToImageParameters,
        imageVariationParameters: ImageVariationParameters
    ) {
        self.parameters = parameters
        self.textToImageParameters = textToImageParameters
        self.conditionedTextToImageParameters = conditionedTextToImageParameters
        self.imageVariationParameters = imageVariationParameters
        self.resolutionValidator = resolutionValidator
    }

    func getParameters() -> ImageGenerationParameters { parameters }
    func getTextToImageParameters() -> TextToImageParameters { textToImageParameters }
    func getConditionedTextToImageParameters() -> ConditionedTextToImageParameters { conditionedTextToImageParameters }
    func getImageVariationParameters() -> ImageVariationParameters { imageVariationParameters }

    func validateResolution(_ resolution: ImageResolution) throws {
        try resolutionValidator.validateResolution(resolution)
    }

    func getImageResponseBody(from data: Data) throws -> ContainsImageGeneration {
        let decoder = JSONDecoder()
        return try decoder.decode(AmazonImageResponseBody.self, from: data)
    }

    func getTextToImageRequestBody(
        prompt: String,
        negativeText: String?,
        nrOfImages: Int?,
        cfgScale: Double?,
        seed: Int?,
        quality: ImageQuality?,
        resolution: ImageResolution?
    ) throws -> BedrockBodyCodable {
        AmazonImageRequestBody.textToImage(
            prompt: prompt,
            negativeText: negativeText,
            nrOfImages: nrOfImages,
            cfgScale: cfgScale,
            seed: seed,
            quality: quality,
            resolution: resolution
        )
    }

    func getConditionedTextToImageRequestBody(
        prompt: String,
        negativeText: String?,
        nrOfImages: Int?,
        cfgScale: Double?,
        seed: Int?,
        quality: ImageQuality?,
        resolution: ImageResolution?
    ) throws -> any BedrockBodyCodable {
        AmazonImageRequestBody.conditionedTextToImage(
            prompt: prompt,
            negativeText: negativeText,
            nrOfImages: nrOfImages,
            cfgScale: cfgScale,
            seed: seed,
            quality: quality,
            resolution: resolution
        )
    }

    func getImageVariationRequestBody(
        prompt: String?,
        negativeText: String?,
        images: [String],
        similarity: Double?,
        nrOfImages: Int?,
        cfgScale: Double?,
        seed: Int?,
        quality: ImageQuality?,
        resolution: ImageResolution?
    ) throws -> BedrockBodyCodable {
        AmazonImageRequestBody.imageVariation(
            referenceImages: images,
            prompt: prompt,
            negativeText: negativeText,
            similarity: similarity,
            nrOfImages: nrOfImages,
            cfgScale: cfgScale,
            seed: seed,
            quality: quality,
            resolution: resolution
        )
    }
}
