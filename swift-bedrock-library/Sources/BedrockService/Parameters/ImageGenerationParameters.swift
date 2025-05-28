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

public struct ImageGenerationParameters: Parameters {
    public let nrOfImages: Parameter<Int>
    public let cfgScale: Parameter<Double>
    public let seed: Parameter<Int>

    public init(
        nrOfImages: Parameter<Int>,
        cfgScale: Parameter<Double>,
        seed: Parameter<Int>
    ) {
        self.nrOfImages = nrOfImages
        self.cfgScale = cfgScale
        self.seed = seed
    }

    public func validate(nrOfImages: Int? = nil, cfgScale: Double? = nil, seed: Int? = nil) throws {
        if let seed {
            try self.seed.validateValue(seed)
        }
        if let cfgScale {
            try self.cfgScale.validateValue(cfgScale)
        }
        if let nrOfImages {
            try self.nrOfImages.validateValue(nrOfImages)
        }
    }
}

public struct TextToImageParameters: Parameters {
    public let prompt: PromptParams
    public let negativePrompt: PromptParams

    public init(
        maxPromptSize: Int,
        maxNegativePromptSize: Int
    ) {
        self.prompt = PromptParams(maxSize: maxPromptSize)
        self.negativePrompt = PromptParams(maxSize: maxNegativePromptSize)
    }

    public func validate(prompt: String? = nil, negativePrompt: String? = nil) throws {
        if let prompt {
            try self.prompt.validateValue(prompt)
        }
        if let negativePrompt {
            try self.negativePrompt.validateValue(negativePrompt)
        }
    }
}

public struct ConditionedTextToImageParameters: Parameters {
    public let prompt: PromptParams
    public let negativePrompt: PromptParams
    public let similarity: Parameter<Double>

    public init(
        maxPromptSize: Int,
        maxNegativePromptSize: Int,
        similarity: Parameter<Double>
    ) {
        self.prompt = PromptParams(maxSize: maxPromptSize)
        self.negativePrompt = PromptParams(maxSize: maxNegativePromptSize)
        self.similarity = similarity
    }

    public func validate(prompt: String? = nil, negativePrompt: String? = nil, similarity: Double? = nil) throws {
        if let prompt {
            try self.prompt.validateValue(prompt)
        }
        if let negativePrompt {
            try self.negativePrompt.validateValue(negativePrompt)
        }
        if let similarity {
            try self.similarity.validateValue(similarity)
        }
    }
}

public struct ImageVariationParameters: Parameters {
    public let images: Parameter<Int>
    public let prompt: PromptParams
    public let negativePrompt: PromptParams
    public let similarity: Parameter<Double>

    public init(
        images: Parameter<Int>,
        maxPromptSize: Int,
        maxNegativePromptSize: Int,
        similarity: Parameter<Double>
    ) {
        self.prompt = PromptParams(maxSize: maxPromptSize)
        self.negativePrompt = PromptParams(maxSize: maxNegativePromptSize)
        self.similarity = similarity
        self.images = images
    }

    package func validate(
        images: Int? = nil,
        prompt: String? = nil,
        negativePrompt: String? = nil,
        similarity: Double? = nil
    ) throws {
        if let images {
            try self.images.validateValue(images)
        }
        if let prompt {
            try self.prompt.validateValue(prompt)
        }
        if let negativePrompt {
            try self.negativePrompt.validateValue(negativePrompt)
        }
        if let similarity {
            try self.similarity.validateValue(similarity)
        }
    }
}

public struct ColorGuidedImageGenerationParameters: Parameters {
    public let colors: Parameter<Int>
    public let prompt: PromptParams
    public let negativePrompt: PromptParams
    public let similarity: Parameter<Double>

    public init(
        colors: Parameter<Int>,
        maxPromptSize: Int,
        maxNegativePromptSize: Int,
        similarity: Parameter<Double>
    ) {
        self.prompt = PromptParams(maxSize: maxPromptSize)
        self.negativePrompt = PromptParams(maxSize: maxNegativePromptSize)
        self.colors = colors
        self.similarity = similarity
    }

    public func validate(
        colors: Int? = nil,
        prompt: String? = nil,
        negativePrompt: String? = nil,
        similarity: Double? = nil
    ) throws {
        if let colors {
            try self.colors.validateValue(colors)
        }
        if let prompt {
            try self.prompt.validateValue(prompt)
        }
        if let negativePrompt {
            try self.negativePrompt.validateValue(negativePrompt)
        }
        if let similarity {
            try self.similarity.validateValue(similarity)
        }
    }
}
