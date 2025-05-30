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

// MARK: text generation
// https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-titan-text.html

typealias TitanTextPremierV1 = TitanText
typealias TitanTextExpressV1 = TitanText
typealias TitanTextLiteV1 = TitanText

extension BedrockModel {
    public static let titan_text_g1_premier: BedrockModel = BedrockModel(
        id: "amazon.titan-text-premier-v1:0",
        name: "Titan Premier",
        modality: TitanTextPremierV1(
            parameters: TextGenerationParameters(
                temperature: Parameter(.temperature, minValue: 0, maxValue: 1, defaultValue: 0.7),
                maxTokens: Parameter(.maxTokens, minValue: 0, maxValue: 3_072, defaultValue: 512),
                topP: Parameter(.topP, minValue: 0, maxValue: 1, defaultValue: 0.9),
                topK: Parameter.notSupported(.topK),
                stopSequences: StopSequenceParams(maxSequences: nil, defaultValue: []),
                maxPromptSize: nil
            ),
            features: [.textGeneration]
        )
    )
    public static let titan_text_g1_express: BedrockModel = BedrockModel(
        id: "amazon.titan-text-express-v1",
        name: "Titan Express",
        modality: TitanTextExpressV1(
            parameters: TextGenerationParameters(
                temperature: Parameter(.temperature, minValue: 0, maxValue: 1, defaultValue: 0.7),
                maxTokens: Parameter(.maxTokens, minValue: 0, maxValue: 8_192, defaultValue: 512),
                topP: Parameter(.topP, minValue: 0, maxValue: 1, defaultValue: 0.9),
                topK: Parameter.notSupported(.topK),
                stopSequences: StopSequenceParams(maxSequences: nil, defaultValue: []),
                maxPromptSize: nil
            )
        )
    )
    public static let titan_text_g1_lite: BedrockModel = BedrockModel(
        id: "amazon.titan-text-lite-v1",
        name: "Titan Lite",
        modality: TitanTextLiteV1(
            parameters: TextGenerationParameters(
                temperature: Parameter(.temperature, minValue: 0, maxValue: 1, defaultValue: 0.7),
                maxTokens: Parameter(.maxTokens, minValue: 0, maxValue: 4_096, defaultValue: 512),
                topP: Parameter(.topP, minValue: 0, maxValue: 1, defaultValue: 0.9),
                topK: Parameter.notSupported(.topK),
                stopSequences: StopSequenceParams(maxSequences: nil, defaultValue: []),
                maxPromptSize: nil
            )
        )
    )
}

// MARK: image generation
// https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-titan-image.html

typealias TitanImageG1V1 = AmazonImage
typealias TitanImageG1V2 = AmazonImage

extension BedrockModel {
    public static let titan_image_g1_v1: BedrockModel = BedrockModel(
        id: "amazon.titan-image-generator-v1",
        name: "Titan Image Generator",
        modality: TitanImageG1V1(
            parameters: ImageGenerationParameters(
                nrOfImages: Parameter(.nrOfImages, minValue: 1, maxValue: 5, defaultValue: 1),
                cfgScale: Parameter(.cfgScale, minValue: 1.1, maxValue: 10, defaultValue: 8.0),
                seed: Parameter(.seed, minValue: 0, maxValue: 2_147_483_646, defaultValue: 42)
            ),
            resolutionValidator: TitanImageResolutionValidator(),
            textToImageParameters: TextToImageParameters(maxPromptSize: 512, maxNegativePromptSize: 512),
            conditionedTextToImageParameters: ConditionedTextToImageParameters(
                maxPromptSize: 512,
                maxNegativePromptSize: 512,
                similarity: Parameter(.similarity, minValue: 0, maxValue: 1.0, defaultValue: 0.7)
            ),
            imageVariationParameters: ImageVariationParameters(
                images: Parameter(.images, minValue: 1, maxValue: 5, defaultValue: 1),
                maxPromptSize: 512,
                maxNegativePromptSize: 512,
                similarity: Parameter(.similarity, minValue: 0.2, maxValue: 1.0, defaultValue: 0.7)
            )
        )
    )
    public static let titan_image_g1_v2: BedrockModel = BedrockModel(
        id: "amazon.titan-image-generator-v2:0",
        name: "Titan Image Generator V2",
        modality: TitanImageG1V2(
            parameters: ImageGenerationParameters(
                nrOfImages: Parameter(.nrOfImages, minValue: 1, maxValue: 5, defaultValue: 1),
                cfgScale: Parameter(.cfgScale, minValue: 1.1, maxValue: 10, defaultValue: 8.0),
                seed: Parameter(.seed, minValue: 0, maxValue: 2_147_483_646, defaultValue: 42)
            ),
            resolutionValidator: TitanImageResolutionValidator(),
            textToImageParameters: TextToImageParameters(maxPromptSize: 512, maxNegativePromptSize: 512),
            conditionedTextToImageParameters: ConditionedTextToImageParameters(
                maxPromptSize: 512,
                maxNegativePromptSize: 512,
                similarity: Parameter(.similarity, minValue: 0, maxValue: 1.0, defaultValue: 0.7)
            ),
            imageVariationParameters: ImageVariationParameters(
                images: Parameter(.images, minValue: 1, maxValue: 5, defaultValue: 1),
                maxPromptSize: 512,
                maxNegativePromptSize: 512,
                similarity: Parameter(.similarity, minValue: 0.2, maxValue: 1.0, defaultValue: 0.7)
            )
        )
    )
}
