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

@testable import BedrockService

enum StabilityTestConstants {

    static let imageGenerationModels: [BedrockModel] = [
        BedrockModel.stable_image_core,
        BedrockModel.stable_image_ultra,
        BedrockModel.sd3_5_large,
    ]

    static let modelsRejectingNegativePrompt: [BedrockModel] = [
        BedrockModel.stable_image_core,
        BedrockModel.stable_image_ultra,
    ]

    static let modelAcceptingNegativePrompt: BedrockModel = BedrockModel.sd3_5_large

    enum ImageGeneration {
        static let validNrOfImagesNonNil = [1]
        static let invalidNrOfImages = [-1, 0, 2, 5]
        static let invalidCfgScale: [Double] = [1.0, 5.0, 10.0]
        static let validSeed = [0, 1, 12, 4_294_967_295]
        static let invalidSeed = [-1, 4_294_967_296]
        static let validImagePrompts = [
            "This is a test",
            "!@#$%^&*()_+{}|:<>?",
            String(repeating: "x", count: 10_000),
        ]
        static let invalidImagePrompts = [
            "", " ", " \n  ", "\t",
            String(repeating: "x", count: 10_001),
        ]
    }
}
