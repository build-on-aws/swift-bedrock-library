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

import Testing

@testable import BedrockService

extension BedrockServiceTests {

    // MARK: model dispatch

    @Test(
        "Generate image using a Stability model",
        arguments: StabilityTestConstants.imageGenerationModels
    )
    func generateImageWithStabilityModel(model: BedrockModel) async throws {
        let output: ImageGenerationOutput = try await bedrock.generateImage(
            "A serene landscape with mountains at sunset",
            with: model
        )
        #expect(output.images.count == 1)
        #expect(output.images.first?.isEmpty == false)
    }

    // MARK: prompt validation

    @Test(
        "Stability: valid prompts succeed",
        arguments: StabilityTestConstants.ImageGeneration.validImagePrompts
    )
    func generateImageWithValidPromptStability(prompt: String) async throws {
        let output: ImageGenerationOutput = try await bedrock.generateImage(
            prompt,
            with: BedrockModel.stable_image_core
        )
        #expect(output.images.count == 1)
    }

    @Test(
        "Stability: invalid prompts throw",
        arguments: StabilityTestConstants.ImageGeneration.invalidImagePrompts
    )
    func generateImageWithInvalidPromptStability(prompt: String) async throws {
        await #expect(throws: BedrockLibraryError.self) {
            let _: ImageGenerationOutput = try await bedrock.generateImage(
                prompt,
                with: BedrockModel.stable_image_core
            )
        }
    }

    // MARK: nrOfImages

    @Test("Stability: nrOfImages = 1 succeeds")
    func generateImageWithNrOfImagesOne() async throws {
        let output = try await bedrock.generateImage(
            "test",
            with: BedrockModel.stable_image_core,
            nrOfImages: 1
        )
        #expect(output.images.count == 1)
    }

    @Test(
        "Stability: nrOfImages != 1 throws",
        arguments: StabilityTestConstants.ImageGeneration.invalidNrOfImages
    )
    func generateImageWithInvalidNrOfImagesStability(nrOfImages: Int) async throws {
        await #expect(throws: BedrockLibraryError.self) {
            let _ = try await bedrock.generateImage(
                "test",
                with: BedrockModel.stable_image_core,
                nrOfImages: nrOfImages
            )
        }
    }

    // MARK: cfgScale (unsupported)

    @Test(
        "Stability: any cfgScale throws notSupported",
        arguments: StabilityTestConstants.ImageGeneration.invalidCfgScale
    )
    func generateImageWithCfgScaleStability(cfgScale: Double) async throws {
        await #expect(throws: BedrockLibraryError.self) {
            let _ = try await bedrock.generateImage(
                "test",
                with: BedrockModel.stable_image_core,
                cfgScale: cfgScale
            )
        }
    }

    // MARK: quality (unsupported)

    @Test("Stability: quality throws notSupported")
    func generateImageWithQualityStability() async throws {
        await #expect(throws: BedrockLibraryError.self) {
            let _ = try await bedrock.generateImage(
                "test",
                with: BedrockModel.stable_image_core,
                quality: .standard
            )
        }
    }

    // MARK: negativePrompt rules

    @Test(
        "Stability Core/Ultra: negativePrompt throws notSupported",
        arguments: StabilityTestConstants.modelsRejectingNegativePrompt
    )
    func generateImageWithNegativePromptOnUnsupportedModel(model: BedrockModel) async throws {
        await #expect(throws: BedrockLibraryError.self) {
            let _ = try await bedrock.generateImage(
                "test",
                with: model,
                negativePrompt: "blurry"
            )
        }
    }

    @Test("SD 3.5 Large: negativePrompt is accepted")
    func generateImageWithNegativePromptOnSD35() async throws {
        let output = try await bedrock.generateImage(
            "test",
            with: StabilityTestConstants.modelAcceptingNegativePrompt,
            negativePrompt: "blurry, low quality"
        )
        #expect(output.images.count == 1)
    }

    // MARK: seed

    @Test(
        "Stability: valid seed values succeed",
        arguments: StabilityTestConstants.ImageGeneration.validSeed
    )
    func generateImageWithValidSeedStability(seed: Int) async throws {
        let output = try await bedrock.generateImage(
            "test",
            with: BedrockModel.stable_image_core,
            seed: seed
        )
        #expect(output.images.count == 1)
    }

    @Test(
        "Stability: out-of-range seed throws",
        arguments: StabilityTestConstants.ImageGeneration.invalidSeed
    )
    func generateImageWithInvalidSeedStability(seed: Int) async throws {
        await #expect(throws: BedrockLibraryError.self) {
            let _ = try await bedrock.generateImage(
                "test",
                with: BedrockModel.stable_image_core,
                seed: seed
            )
        }
    }

    // MARK: resolution

    @Test("Stability: 1024x1024 succeeds and is mapped to 1:1")
    func generateImageWithSquareResolution() async throws {
        let output = try await bedrock.generateImage(
            "test",
            with: BedrockModel.stable_image_core,
            resolution: ImageResolution(width: 1024, height: 1024)
        )
        #expect(output.images.count == 1)
    }

    @Test("Stability: invalid resolution throws")
    func generateImageWithInvalidResolution() async throws {
        await #expect(throws: BedrockLibraryError.self) {
            let _ = try await bedrock.generateImage(
                "test",
                with: BedrockModel.stable_image_core,
                resolution: ImageResolution(width: 0, height: 1024)
            )
        }
    }

    // MARK: invalid model dispatch

    @Test("generateImage on a text model throws invalidModality")
    func generateImageWithTextModelStability() async throws {
        await #expect(throws: BedrockLibraryError.self) {
            let _ = try await bedrock.generateImage(
                "test",
                with: BedrockModel.nova_micro
            )
        }
    }

    // MARK: rawValue init coverage

    @Test(
        "BedrockModel(rawValue:) recognizes Stability IDs",
        arguments: StabilityTestConstants.imageGenerationModels
    )
    func bedrockModelInitFromRawValueStability(model: BedrockModel) async throws {
        let resolved = BedrockModel(rawValue: model.id)
        #expect(resolved?.id == model.id)
    }
}
