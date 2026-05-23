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

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// Modality conformance for Stability AI text-to-image models on Amazon Bedrock.
///
/// Stability models on Bedrock differ from Nova Canvas in several ways:
/// - they accept an `aspect_ratio` string instead of explicit width/height
/// - they always return exactly one image per request (no `numberOfImages`)
/// - they do not accept a `cfgScale` or a `quality` field
/// - only `sd3-5-large` accepts a `negative_prompt`
///
/// The shared `BedrockService.generateImage(...)` API surface remains unchanged.
/// Unsupported parameters are rejected with `BedrockLibraryError.notSupported`
/// so callers always get a clear error rather than a silent ignore.
struct StabilityImage: ImageModality, TextToImageModality {

    let parameters: ImageGenerationParameters
    let textToImageParameters: TextToImageParameters
    let resolutionValidator: any ImageResolutionValidator
    let supportsNegativePrompt: Bool
    let supportsMode: Bool

    init(
        parameters: ImageGenerationParameters,
        textToImageParameters: TextToImageParameters,
        resolutionValidator: any ImageResolutionValidator,
        supportsNegativePrompt: Bool,
        supportsMode: Bool
    ) {
        self.parameters = parameters
        self.textToImageParameters = textToImageParameters
        self.resolutionValidator = resolutionValidator
        self.supportsNegativePrompt = supportsNegativePrompt
        self.supportsMode = supportsMode
    }

    func getName() -> String { "Stability Image Generation" }

    func getParameters() -> ImageGenerationParameters { parameters }
    func getTextToImageParameters() -> TextToImageParameters { textToImageParameters }

    func validateResolution(_ resolution: ImageResolution) throws {
        try resolutionValidator.validateResolution(resolution)
    }

    func getImageResponseBody(from data: Data) throws -> ContainsImageGeneration {
        try JSONDecoder().decode(StabilityImageResponseBody.self, from: data)
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

        if let nrOfImages, nrOfImages != 1 {
            throw BedrockLibraryError.notSupported(
                "Stability models generate exactly 1 image per request; nrOfImages=\(nrOfImages) is not supported"
            )
        }
        if cfgScale != nil {
            throw BedrockLibraryError.notSupported("cfgScale is not supported by Stability models")
        }
        if quality != nil {
            throw BedrockLibraryError.notSupported("quality is not supported by Stability models")
        }
        if !supportsNegativePrompt, negativeText != nil {
            throw BedrockLibraryError.notSupported(
                "negativePrompt is only supported by stability.sd3-5-large-v1:0"
            )
        }

        let aspect = resolution.map(StabilityAspectRatio.nearest(to:))
        let mode: String? = supportsMode ? "text-to-image" : nil

        return StabilityImageRequestBody.textToImage(
            prompt: prompt,
            negativePrompt: supportsNegativePrompt ? negativeText : nil,
            aspectRatio: aspect,
            seed: seed,
            mode: mode
        )
    }
}
