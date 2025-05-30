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
// https://docs.aws.amazon.com/nova/latest/userguide/complete-request-schema.html

typealias NovaMicro = NovaText

extension BedrockModel {
    public static let nova_micro: BedrockModel = BedrockModel(
        id: "amazon.nova-micro-v1:0",
        name: "Nova Micro",
        modality: NovaText(
            parameters: TextGenerationParameters(
                temperature: Parameter(.temperature, minValue: 0.00001, maxValue: 1, defaultValue: 0.7),
                maxTokens: Parameter(.maxTokens, minValue: 1, maxValue: 5_000, defaultValue: 5_000),
                topP: Parameter(.topP, minValue: 0, maxValue: 1.0, defaultValue: 0.9),
                topK: Parameter(.topK, minValue: 0, maxValue: nil, defaultValue: 50),
                stopSequences: StopSequenceParams(maxSequences: nil, defaultValue: []),
                maxPromptSize: nil
            ),
            features: [.textGeneration, .systemPrompts, .toolUse]
        )
    )
    public static let nova_lite: BedrockModel = BedrockModel(
        id: "amazon.nova-lite-v1:0",
        name: "Nova Lite",
        modality: NovaText(
            parameters: TextGenerationParameters(
                temperature: Parameter(.temperature, minValue: 0.00001, maxValue: 1, defaultValue: 0.7),
                maxTokens: Parameter(.maxTokens, minValue: 1, maxValue: 5_000, defaultValue: 5_000),
                topP: Parameter(.topP, minValue: 0, maxValue: 1.0, defaultValue: 0.9),
                topK: Parameter(.topK, minValue: 0, maxValue: nil, defaultValue: 50),
                stopSequences: StopSequenceParams(maxSequences: nil, defaultValue: []),
                maxPromptSize: nil
            ),
            features: [.textGeneration, .vision, .systemPrompts, .document, .toolUse]
        )
    )
    public static let nova_pro: BedrockModel = BedrockModel(
        id: "amazon.nova-pro-v1:0",
        name: "Nova Pro",
        modality: NovaText(
            parameters: TextGenerationParameters(
                temperature: Parameter(.temperature, minValue: 0.00001, maxValue: 1, defaultValue: 0.7),
                maxTokens: Parameter(.maxTokens, minValue: 1, maxValue: 5_000, defaultValue: 5_000),
                topP: Parameter(.topP, minValue: 0, maxValue: 1.0, defaultValue: 0.9),
                topK: Parameter(.topK, minValue: 0, maxValue: nil, defaultValue: 50),
                stopSequences: StopSequenceParams(maxSequences: nil, defaultValue: []),
                maxPromptSize: nil
            ),
            features: [.textGeneration, .systemPrompts, .document, .vision, .toolUse]
        )
    )
}

// MARK: image generation

typealias NovaCanvas = AmazonImage

extension BedrockModel {
    public static let nova_canvas: BedrockModel = BedrockModel(
        id: "amazon.nova-canvas-v1:0",
        name: "Nova Canvas",
        modality: NovaCanvas(
            parameters: ImageGenerationParameters(
                nrOfImages: Parameter(.nrOfImages, minValue: 1, maxValue: 5, defaultValue: 1),
                cfgScale: Parameter(.cfgScale, minValue: 1.1, maxValue: 10, defaultValue: 6.5),
                seed: Parameter(.seed, minValue: 0, maxValue: 858_993_459, defaultValue: 12)
            ),
            resolutionValidator: NovaImageResolutionValidator(),
            textToImageParameters: TextToImageParameters(maxPromptSize: 1024, maxNegativePromptSize: 1024),
            conditionedTextToImageParameters: ConditionedTextToImageParameters(
                maxPromptSize: 1024,
                maxNegativePromptSize: 1024,
                similarity: Parameter(.similarity, minValue: 0, maxValue: 1.0, defaultValue: 0.7)
            ),
            imageVariationParameters: ImageVariationParameters(
                images: Parameter(.images, minValue: 1, maxValue: 5, defaultValue: 1),
                maxPromptSize: 1024,
                maxNegativePromptSize: 1024,
                similarity: Parameter(.similarity, minValue: 0.2, maxValue: 1.0, defaultValue: 0.6)
            )
        )
    )
}
