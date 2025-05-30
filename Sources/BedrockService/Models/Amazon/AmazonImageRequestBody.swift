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

public struct AmazonImageRequestBody: BedrockBodyCodable {
    let taskType: TaskType
    private let textToImageParams: TextToImageParams?
    private let imageVariationParams: ImageVariationParams?
    private let colorGuidedGenerationParams: ColorGuidedGenerationParams?
    private let imageGenerationConfig: ImageGenerationConfig

    // MARK: - Initialization

    /// Creates a text-to-image generation request body
    /// - Parameters:
    ///   - prompt: The text description of the image to generate
    ///   - nrOfImages: The number of images to generate
    ///   - negativeText: The text description of what to exclude from the generated image
    /// - Returns: A configured AmazonImageRequestBody for text-to-image generation
    public static func textToImage(
        prompt: String,
        negativeText: String?,
        nrOfImages: Int?,
        cfgScale: Double?,
        seed: Int?,
        quality: ImageQuality?,
        resolution: ImageResolution?
    ) -> Self {
        AmazonImageRequestBody(
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
        prompt: String,
        negativeText: String?,
        nrOfImages: Int?,
        cfgScale: Double?,
        seed: Int?,
        quality: ImageQuality?,
        resolution: ImageResolution?
    ) {
        self.taskType = .textToImage
        self.textToImageParams = TextToImageParams.textToImage(prompt: prompt, negativeText: negativeText)
        self.imageVariationParams = nil
        self.colorGuidedGenerationParams = nil
        self.imageGenerationConfig = ImageGenerationConfig(
            nrOfImages: nrOfImages,
            cfgScale: cfgScale,
            seed: seed,
            quality: quality,
            resolution: resolution
        )
    }

    /// Creates a text-to-image conditioned generation request body
    /// - Parameters:
    ///   - prompt: The text description of the image to generate
    ///   - nrOfImages: The number of images to generate
    ///   - negativeText: The text description of what to exclude from the generated image
    /// - Returns: A configured AmazonImageRequestBody for text-to-image generation
    public static func conditionedTextToImage(
        prompt: String,
        negativeText: String?,
        nrOfImages: Int?,
        cfgScale: Double?,
        seed: Int?,
        quality: ImageQuality?,
        resolution: ImageResolution?
    ) -> Self {
        AmazonImageRequestBody(
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
        prompt: String,
        negativeText: String?,
        conditionImage: String?,
        controlMode: ControlMode?,
        similarity: Double?,
        nrOfImages: Int?,
        cfgScale: Double?,
        seed: Int?,
        quality: ImageQuality?,
        resolution: ImageResolution?
    ) {
        self.taskType = .textToImage
        self.textToImageParams = TextToImageParams.conditionedTextToImage(
            prompt: prompt,
            negativeText: negativeText,
            conditionImage: conditionImage,
            controlMode: controlMode,
            controlStrength: similarity
        )
        self.imageVariationParams = nil
        self.colorGuidedGenerationParams = nil
        self.imageGenerationConfig = ImageGenerationConfig(
            nrOfImages: nrOfImages,
            cfgScale: cfgScale,
            seed: seed,
            quality: quality,
            resolution: resolution
        )
    }

    /// Creates an image variation generation request
    /// - Parameters:
    ///   - prompt: The text description to guide the variation generation
    ///   - referenceImage: The base64-encoded string of the source image
    ///   - similarity: How similar the variations should be to the source image (0.2-1.0)
    ///   - nrOfImages: The number of variations to generate (default: 1)
    /// - Returns: A configured AmazonImageRequestBody for image variation generation
    public static func imageVariation(
        referenceImages: [String],
        prompt: String?,
        negativeText: String?,
        similarity: Double?,
        nrOfImages: Int?,
        cfgScale: Double?,
        seed: Int?,
        quality: ImageQuality?,
        resolution: ImageResolution?
    ) -> Self {
        AmazonImageRequestBody(
            referenceImages: referenceImages,
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

    private init(
        referenceImages: [String],
        prompt: String?,
        negativeText: String?,
        similarity: Double?,
        nrOfImages: Int?,
        cfgScale: Double?,
        seed: Int?,
        quality: ImageQuality?,
        resolution: ImageResolution?
    ) {
        self.taskType = .imageVariation
        self.textToImageParams = nil
        self.imageVariationParams = ImageVariationParams(
            images: referenceImages,
            text: prompt,
            negativeText: negativeText,
            similarityStrength: similarity
        )
        self.colorGuidedGenerationParams = nil
        self.imageGenerationConfig = ImageGenerationConfig(
            nrOfImages: nrOfImages,
            cfgScale: cfgScale,
            seed: seed,
            quality: quality,
            resolution: resolution
        )
    }

    /// Creates a color guided image generation request
    /// - Parameters:
    ///   - prompt: The text description to guide the variation generation
    ///   - nrOfImages: The number of variations to generate (default: 1)
    ///   - colors: A list of color codes that will be used in the image, expressed as hexadecimal values in the form “#RRGGBB”.
    ///   - negativeText: The text description of what to exclude from the generated image
    ///   - referenceImage: The base64-encoded string of the source image (colors in this image will also be used in the generated image)
    /// - Returns: A configured AmazonImageRequestBody for color guided image generation
    public static func colorGuidedGeneration(
        prompt: String,
        colors: [String],
        negativeText: String?,
        referenceImage: String?,
        nrOfImages: Int?,
        cfgScale: Double?,
        seed: Int?,
        quality: ImageQuality?,
        resolution: ImageResolution?
    ) -> Self {
        AmazonImageRequestBody(
            prompt: prompt,
            colors: colors,
            negativeText: negativeText,
            referenceImage: referenceImage,
            nrOfImages: nrOfImages,
            cfgScale: cfgScale,
            seed: seed,
            quality: quality,
            resolution: resolution
        )
    }

    private init(
        prompt: String,
        colors: [String],
        negativeText: String?,
        referenceImage: String?,
        nrOfImages: Int?,
        cfgScale: Double?,
        seed: Int?,
        quality: ImageQuality?,
        resolution: ImageResolution?
    ) {
        self.taskType = .colorGuidedGeneration
        self.textToImageParams = nil
        self.imageVariationParams = nil
        self.colorGuidedGenerationParams = ColorGuidedGenerationParams(
            text: prompt,
            negativeText: negativeText,
            colors: colors,
            referenceImage: referenceImage
        )
        self.imageGenerationConfig = ImageGenerationConfig(
            nrOfImages: nrOfImages,
            cfgScale: cfgScale,
            seed: seed,
            quality: quality,
            resolution: resolution
        )
    }

    // MARK: - Nested Types

    // private struct

    private struct ColorGuidedGenerationParams: Codable {
        let text: String
        let negativeText: String?
        let colors: [String]  // list of hexadecimal color values
        let referenceImage: String?  // base64-encoded image string
    }

    private struct ImageVariationParams: Codable {
        let images: [String]
        let text: String?
        let negativeText: String?
        let similarityStrength: Double?
    }

    private struct TextToImageParams: Codable {
        let text: String
        let negativeText: String?
        let conditionImage: String?
        let controlMode: ControlMode?
        let controlStrength: Double?

        static func textToImage(prompt: String, negativeText: String?) -> Self {
            TextToImageParams(
                text: prompt,
                negativeText: negativeText,
                conditionImage: nil,
                controlMode: nil,
                controlStrength: nil
            )
        }

        static func conditionedTextToImage(
            prompt: String,
            negativeText: String?,
            conditionImage: String?,
            controlMode: ControlMode?,
            controlStrength: Double?
        ) -> Self {
            TextToImageParams(
                text: prompt,
                negativeText: negativeText,
                conditionImage: conditionImage,
                controlMode: controlMode,
                controlStrength: controlStrength
            )
        }
    }

    private enum ControlMode: String, Codable {
        case cannyEdge = "CANNY_EDGE"
        case segmentation = "SEGMENTATION"
    }

    private struct ImageGenerationConfig: Codable {
        let numberOfImages: Int?
        let cfgScale: Double?
        let seed: Int?
        let quality: ImageQuality?
        let width: Int?
        let height: Int?

        init(
            nrOfImages: Int? = nil,
            cfgScale: Double? = nil,
            seed: Int? = nil,
            quality: ImageQuality? = nil,
            resolution: ImageResolution? = nil
        ) {
            self.quality = quality
            self.width = resolution?.width ?? nil
            self.height = resolution?.height ?? nil
            self.cfgScale = cfgScale
            self.seed = seed
            self.numberOfImages = nrOfImages
        }
    }
}

public enum ImageQuality: String, Codable {
    case standard = "standard"
    case premium = "premium"
}
