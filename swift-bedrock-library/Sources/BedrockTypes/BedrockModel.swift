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

public struct BedrockModel: Hashable, Sendable, Equatable, RawRepresentable {
    public var rawValue: String { id }

    public var id: String
    public var name: String
    public let modality: any Modality

    /// Creates a new BedrockModel instance
    /// - Parameters:
    ///   - id: The unique identifier for the model
    ///   - modality: The modality of the model
    public init(
        id: String,
        name: String,
        modality: any Modality
    ) {
        self.id = id
        self.modality = modality
        self.name = name
    }

    /// Creates an implemented BedrockModel instance from a raw string value
    /// - Parameter rawValue: The model identifier string
    /// - Returns: The corresponding BedrockModel instance or nil if the model is not implemented
    public init?(rawValue: String) {
        switch rawValue {
        // claude
        case BedrockModel.instant.id:
            self = BedrockModel.instant
        case BedrockModel.claudev1.id:
            self = BedrockModel.claudev1
        case BedrockModel.claudev2.id:
            self = BedrockModel.claudev2
        case BedrockModel.claudev2_1.id:
            self = BedrockModel.claudev2_1
        case BedrockModel.claudev3_haiku.id:
            self = BedrockModel.claudev3_haiku
        case BedrockModel.claudev3_5_haiku.id:
            self = BedrockModel.claudev3_5_haiku
        case BedrockModel.claudev3_opus.id:
            self = BedrockModel.claudev3_opus
        case BedrockModel.claudev3_5_sonnet.id:
            self = BedrockModel.claudev3_5_sonnet
        case BedrockModel.claudev3_5_sonnet_v2.id:
            self = BedrockModel.claudev3_5_sonnet_v2
        case BedrockModel.claudev3_7_sonnet.id:
            self = BedrockModel.claudev3_7_sonnet
        // titan
        case BedrockModel.titan_text_g1_premier.id:
            self = BedrockModel.titan_text_g1_premier
        case BedrockModel.titan_text_g1_express.id:
            self = BedrockModel.titan_text_g1_express
        case BedrockModel.titan_text_g1_lite.id:
            self = BedrockModel.titan_text_g1_lite
        case BedrockModel.titan_image_g1_v2.id:
            self = BedrockModel.titan_image_g1_v2
        case BedrockModel.titan_image_g1_v1.id:
            self = BedrockModel.titan_image_g1_v1
        // nova
        case BedrockModel.nova_micro.id:
            self = BedrockModel.nova_micro
        case BedrockModel.nova_lite.id:
            self = BedrockModel.nova_lite
        case BedrockModel.nova_pro.id:
            self = BedrockModel.nova_pro
        case BedrockModel.nova_canvas.id:
            self = BedrockModel.nova_canvas
        // deepseek
        case BedrockModel.deepseek_r1_v1.id:
            self = BedrockModel.deepseek_r1_v1
        // llama
        case BedrockModel.llama_3_8b_instruct.id: self = BedrockModel.llama_3_8b_instruct
        case BedrockModel.llama3_70b_instruct.id: self = BedrockModel.llama3_70b_instruct
        case BedrockModel.llama3_1_8b_instruct.id: self = BedrockModel.llama3_1_8b_instruct
        case BedrockModel.llama3_1_70b_instruct.id: self = BedrockModel.llama3_1_70b_instruct
        case BedrockModel.llama3_2_1b_instruct.id: self = BedrockModel.llama3_2_1b_instruct
        case BedrockModel.llama3_2_3b_instruct.id: self = BedrockModel.llama3_2_3b_instruct
        case BedrockModel.llama3_3_70b_instruct.id: self = BedrockModel.llama3_3_70b_instruct
        // mistral
        case BedrockModel.mistral_large_2402.id: self = BedrockModel.mistral_large_2402
        case BedrockModel.mistral_small_2402.id: self = BedrockModel.mistral_small_2402
        case BedrockModel.mistral_7B_instruct.id: self = BedrockModel.mistral_7B_instruct
        case BedrockModel.mistral_8x7B_instruct.id: self = BedrockModel.mistral_8x7B_instruct
        //cohere
        case BedrockModel.cohere_command_R_plus.id: self = BedrockModel.cohere_command_R_plus
        case BedrockModel.cohere_command_R.id: self = BedrockModel.cohere_command_R
        default:
            return nil
        }
    }

    // MARK: Modality checks

    // MARK - Text completion

    /// Checks if the model supports text generation
    /// - Returns: True if the model supports text generation
    public func hasTextModality() -> Bool {
        modality as? any TextModality != nil
    }

    /// Checks if the model supports text generation and returns TextModality
    /// - Returns: TextModality if the model supports text modality
    public func getTextModality() throws -> any TextModality {
        guard let textModality = modality as? any TextModality else {
            throw BedrockServiceError.invalidModality(
                self,
                modality,
                "Model \(id) does not support text generation"
            )
        }
        return textModality
    }

    // MARK - Image generation

    /// Checks if the model supports image generation
    /// - Returns: True if the model supports image generation
    public func hasImageModality() -> Bool {
        modality as? any ImageModality != nil
    }

    /// Checks if the model supports image generation and returns ImageModality
    /// - Returns: TextModality if the model supports image modality
    public func getImageModality() throws -> any ImageModality {
        guard let imageModality = modality as? any ImageModality else {
            throw BedrockServiceError.invalidModality(
                self,
                modality,
                "Model \(id) does not support image generation"
            )
        }
        return imageModality
    }

    /// Checks if the model supports text to image generation
    /// - Returns: True if the model supports text to image generation
    public func hasTextToImageModality() -> Bool {
        modality as? any TextToImageModality != nil
    }

    /// Checks if the model supports text to image generation and returns TextToImageModality
    /// - Returns: TextToImageModality if the model supports image modality
    public func getTextToImageModality() throws -> any TextToImageModality {
        guard let textToImageModality = modality as? any TextToImageModality else {
            throw BedrockServiceError.invalidModality(
                self,
                modality,
                "Model \(id) does not support text to image generation"
            )
        }
        return textToImageModality
    }

    /// Checks if the model supports image variation
    /// - Returns: True if the model supports image variation
    public func hasImageVariationModality() -> Bool {
        modality as? any ImageVariationModality != nil
    }

    /// Checks if the model supports image variation and returns ImageVariationModality
    /// - Returns: ImageVariationModality if the model supports image modality
    public func getImageVariationModality() throws -> any ImageVariationModality {
        guard let modality = modality as? any ImageVariationModality else {
            throw BedrockServiceError.invalidModality(
                self,
                modality,
                "Model \(id) does not support image variation"
            )
        }
        return modality
    }

    /// Checks if the model supports conditioned text to image generation
    /// - Returns: True if the model supports conditioned text to image generation
    public func hasConditionedTextToImageModality() -> Bool {
        modality as? any ConditionedTextToImageModality != nil
    }

    // MARK - Converse

    /// Checks if the model supports converse
    /// - Returns: True if the model supports converse
    public func hasConverseModality() -> Bool {
        modality as? any ConverseModality != nil
    }

    /// Checks if the model supports converse streaming
    /// - Returns: True if the model supports converse streaming
    public func hasConverseStreamingModality() -> Bool {
        modality as? any ConverseStreamingModality != nil
    }

    /// Checks if the model supports a specific converse feature
    /// - Parameters:
    ///         - feature: the ConverseFeature that will be checked
    /// - Returns: True if the model supports the converse feature
    public func hasConverseModality(_ feature: ConverseFeature = .textGeneration) -> Bool {
        if let converseModality = modality as? any ConverseModality {
            let features = converseModality.getConverseFeatures()
            return features.contains(feature)
        }
        return false
    }

    /// Checks if the model supports text generation and returns ConverseModality
    /// - Returns: ConverseModality if the model supports text modality
    public func getConverseModality() throws -> any ConverseModality {
        guard let modality = modality as? any ConverseModality else {
            throw BedrockServiceError.invalidModality(
                self,
                modality,
                "Model \(id) does not support text generation"
            )
        }
        return modality
    }
}

extension BedrockModel: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        // Encode basic information
        try container.encode(name, forKey: .modelName)
        try container.encode(id, forKey: .modelId)
        try container.encode(String(describing: type(of: modality)), forKey: .supportedModality)

        if hasTextModality() {
            try encodeTextParameters(to: &container)
        }

        if hasImageModality() {
            try encodeImageParameters(to: &container)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case modelName
        case modelId
        case temperatureRange
        case maxTokenRange
        case topPRange
        case topKRange
        case nrOfImagesRange
        case cfgScaleRange
        case seedRange
        case similarityRange
        case supportedModality
    }

    private enum RangeKeys: String, CodingKey {
        case min
        case max
        case `default`
    }

    private func encodeTextParameters(to container: inout KeyedEncodingContainer<CodingKeys>) throws {
        let textModality = try getTextModality()
        let params = textModality.getParameters()

        if params.temperature.isSupported {
            var tempContainer = container.nestedContainer(keyedBy: RangeKeys.self, forKey: .temperatureRange)
            try tempContainer.encode(params.temperature.minValue, forKey: .min)
            try tempContainer.encode(params.temperature.maxValue, forKey: .max)
            try tempContainer.encode(params.temperature.defaultValue, forKey: .default)
        }
        if params.maxTokens.isSupported {
            var tokenContainer = container.nestedContainer(keyedBy: RangeKeys.self, forKey: .maxTokenRange)
            try tokenContainer.encode(params.maxTokens.minValue, forKey: .min)
            try tokenContainer.encode(params.maxTokens.maxValue, forKey: .max)
            try tokenContainer.encode(params.maxTokens.defaultValue, forKey: .default)
        }
        if params.topP.isSupported {
            var topPContainer = container.nestedContainer(keyedBy: RangeKeys.self, forKey: .topPRange)
            try topPContainer.encode(params.topP.minValue, forKey: .min)
            try topPContainer.encode(params.topP.maxValue, forKey: .max)
            try topPContainer.encode(params.topP.defaultValue, forKey: .default)
        }
        if params.topK.isSupported {
            var topKContainer = container.nestedContainer(keyedBy: RangeKeys.self, forKey: .topKRange)
            try topKContainer.encode(params.topK.minValue, forKey: .min)
            try topKContainer.encode(params.topK.maxValue, forKey: .max)
            try topKContainer.encode(params.topK.defaultValue, forKey: .default)
        }
    }

    private func encodeImageParameters(to container: inout KeyedEncodingContainer<CodingKeys>) throws {
        let imageModality = try getImageModality()
        let params = imageModality.getParameters()

        // General image generation inference parameters
        if params.nrOfImages.isSupported {
            var imagesContainer = container.nestedContainer(keyedBy: RangeKeys.self, forKey: .nrOfImagesRange)
            try imagesContainer.encode(params.nrOfImages.minValue, forKey: .min)
            try imagesContainer.encode(params.nrOfImages.maxValue, forKey: .max)
            try imagesContainer.encode(params.nrOfImages.defaultValue, forKey: .default)
        }
        if params.cfgScale.isSupported {
            var cfgScaleContainer = container.nestedContainer(keyedBy: RangeKeys.self, forKey: .cfgScaleRange)
            try cfgScaleContainer.encode(params.cfgScale.minValue, forKey: .min)
            try cfgScaleContainer.encode(params.cfgScale.maxValue, forKey: .max)
            try cfgScaleContainer.encode(params.cfgScale.defaultValue, forKey: .default)
        }
        if params.seed.isSupported {
            var seedContainer = container.nestedContainer(keyedBy: RangeKeys.self, forKey: .seedRange)
            try seedContainer.encode(params.seed.minValue, forKey: .min)
            try seedContainer.encode(params.seed.maxValue, forKey: .max)
            try seedContainer.encode(params.seed.defaultValue, forKey: .default)
        }

        // If the model supports image variation, encode similarity range
        if hasImageVariationModality() {
            let variationModality = try getImageVariationModality()
            let variationParams = variationModality.getImageVariationParameters()
            if variationParams.similarity.isSupported {
                var similarityContainer = container.nestedContainer(
                    keyedBy: RangeKeys.self,
                    forKey: .similarityRange
                )
                try similarityContainer.encode(variationParams.similarity.minValue, forKey: .min)
                try similarityContainer.encode(variationParams.similarity.maxValue, forKey: .max)
                try similarityContainer.encode(variationParams.similarity.defaultValue, forKey: .default)
            }
        }
    }
}
