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

/// Constants for testing based on the Nova parameters
enum NovaTestConstants {

    static let textCompletionModels = [
        BedrockModel.nova_micro,
        BedrockModel.nova_lite,
        BedrockModel.nova_pro,
    ]
    static let imageGenerationModels = [
        BedrockModel.titan_image_g1_v1,
        BedrockModel.titan_image_g1_v2,
        BedrockModel.nova_canvas,
    ]

    enum TextGeneration {
        static let validTemperature = [0.00001, 0.2, 0.6, 1]
        static let invalidTemperature = [-2.5, -1, 0, 1.00001, 2]
        static let validMaxTokens = [1, 10, 100, 5_000]
        static let invalidMaxTokens = [0, -2, 5_001]
        static let validTopP = [0, 0.2, 0.6, 1]
        static let invalidTopP = [-1, 1.00001, 2]
        static let validTopK = [0, 50]
        static let invalidTopK = [-1]
        static let validStopSequences = [
            ["\n\nHuman:"],
            ["\n\nHuman:", "\n\nAI:"],
            ["\n\nHuman:", "\n\nAI:", "\n\nHuman:"],
        ]
        static let validPrompts = [
            "This is a test",
            "!@#$%^&*()_+{}|:<>?",
            String(repeating: "test ", count: 10),
        ]
        static let invalidPrompts = [
            "", " ", " \n  ", "\t",
        ]
    }
    enum ImageGeneration {
        static let validNrOfImages = [1, 2, 3, 4, 5]
        static let invalidNrOfImages = [-4, 0, 6, 20]
        static let validCfgScale = [1.1, 6, 10]
        static let invalidCfgScale = [-4, 0, 1.0, 11, 20]
        static let validSeed = [0, 12, 900, 858_993_459]
        static let invalidSeed = [-4, 1_000_000_000]
        static let validImagePrompts = [
            "This is a test",
            "!@#$%^&*()_+{}|:<>?",
            String(repeating: "x", count: 1_024),
        ]
        static let invalidImagePrompts = [
            "", " ", " \n  ", "\t",
            String(repeating: "x", count: 1_025),
        ]
    }
    enum ImageVariation {
        static let validSimilarity = [0.2, 0.5, 1]
        static let invalidSimilarity = [-4, 0, 0.1, 1.1, 2]
        static let validNrOfReferenceImages = [1, 3, 5]
        static let invalidNrOfReferenceImages = [0, 6, 10]
    }
}
