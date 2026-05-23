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

// MARK: image generation
// https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-stability-diffusion.html

extension BedrockModel {

    /// Stability AI Stable Image Core (text-to-image only).
    ///
    /// Available in `us-west-2`. Returns exactly one image per call. Does not
    /// support `negativePrompt`, `cfgScale`, `quality`, or `nrOfImages > 1`.
    public static let stable_image_core: BedrockModel = BedrockModel(
        id: "stability.stable-image-core-v1:1",
        name: "Stable Image Core",
        modality: StabilityImage(
            parameters: ImageGenerationParameters(
                nrOfImages: Parameter(.nrOfImages, minValue: 1, maxValue: 1, defaultValue: 1),
                cfgScale: .notSupported(.cfgScale),
                seed: Parameter(.seed, minValue: 0, maxValue: 4_294_967_295, defaultValue: 0)
            ),
            textToImageParameters: TextToImageParameters(maxPromptSize: 10_000, maxNegativePromptSize: 10_000),
            resolutionValidator: StabilityImageResolutionValidator(),
            supportsNegativePrompt: false,
            supportsMode: false
        )
    )

    /// Stability AI Stable Image Ultra (text-to-image only).
    ///
    /// Available in `us-west-2`. Returns exactly one image per call. Does not
    /// support `negativePrompt`, `cfgScale`, `quality`, or `nrOfImages > 1`.
    public static let stable_image_ultra: BedrockModel = BedrockModel(
        id: "stability.stable-image-ultra-v1:1",
        name: "Stable Image Ultra",
        modality: StabilityImage(
            parameters: ImageGenerationParameters(
                nrOfImages: Parameter(.nrOfImages, minValue: 1, maxValue: 1, defaultValue: 1),
                cfgScale: .notSupported(.cfgScale),
                seed: Parameter(.seed, minValue: 0, maxValue: 4_294_967_295, defaultValue: 0)
            ),
            textToImageParameters: TextToImageParameters(maxPromptSize: 10_000, maxNegativePromptSize: 10_000),
            resolutionValidator: StabilityImageResolutionValidator(),
            supportsNegativePrompt: false,
            supportsMode: false
        )
    )

    /// Stable Diffusion 3.5 Large (text-to-image; image-to-image registered as a follow-up).
    ///
    /// Available in `us-west-2`. Returns exactly one image per call. Supports
    /// `negativePrompt` (≤ 10 000 chars). Does not support `cfgScale`,
    /// `quality`, or `nrOfImages > 1`.
    public static let sd3_5_large: BedrockModel = BedrockModel(
        id: "stability.sd3-5-large-v1:0",
        name: "Stable Diffusion 3.5 Large",
        modality: StabilityImage(
            parameters: ImageGenerationParameters(
                nrOfImages: Parameter(.nrOfImages, minValue: 1, maxValue: 1, defaultValue: 1),
                cfgScale: .notSupported(.cfgScale),
                seed: Parameter(.seed, minValue: 0, maxValue: 4_294_967_295, defaultValue: 0)
            ),
            textToImageParameters: TextToImageParameters(maxPromptSize: 10_000, maxNegativePromptSize: 10_000),
            resolutionValidator: StabilityImageResolutionValidator(),
            supportsNegativePrompt: true,
            supportsMode: true
        )
    )
}
