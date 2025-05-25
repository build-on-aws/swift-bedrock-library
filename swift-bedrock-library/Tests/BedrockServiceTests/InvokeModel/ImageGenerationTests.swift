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

import Testing

@testable import BedrockService
@testable import BedrockTypes

// Image generation

extension BedrockServiceTests {

    // Models
    @Test(
        "Generate image using an implemented model",
        arguments: NovaTestConstants.imageGenerationModels
    )
    func generateImageWithValidModel(model: BedrockModel) async throws {
        let output: ImageGenerationOutput = try await bedrock.generateImage(
            "This is a test",
            with: model
        )
        #expect(output.images.count == 1)
    }

    @Test(
        "Generate image using a wrong model",
        arguments: NovaTestConstants.textCompletionModels
    )
    func generateImageWithInvalidModel(model: BedrockModel) async throws {
        await #expect(throws: BedrockServiceError.self) {
            let _: ImageGenerationOutput = try await bedrock.generateImage(
                "This is a test",
                with: model,
                nrOfImages: 3
            )
        }
    }

    // NrOfmages
    @Test(
        "Generate image using a valid nrOfImages",
        arguments: NovaTestConstants.ImageGeneration.validNrOfImages
    )
    func generateImageWithValidNrOfImages(nrOfImages: Int) async throws {
        let output: ImageGenerationOutput = try await bedrock.generateImage(
            "This is a test",
            with: BedrockModel.nova_canvas,
            nrOfImages: nrOfImages
        )
        #expect(output.images.count == nrOfImages)
    }

    @Test(
        "Generate image using an invalid nrOfImages",
        arguments: NovaTestConstants.ImageGeneration.invalidNrOfImages
    )
    func generateImageWithInvalidNrOfImages(nrOfImages: Int) async throws {
        await #expect(throws: BedrockServiceError.self) {
            let _: ImageGenerationOutput = try await bedrock.generateImage(
                "This is a test",
                with: BedrockModel.nova_canvas,
                nrOfImages: nrOfImages
            )
        }
    }

    // CfgScale
    @Test(
        "Generate image using a valid cfgScale",
        arguments: NovaTestConstants.ImageGeneration.validCfgScale
    )
    func generateImageWithValidCfgScale(cfgScale: Double) async throws {
        let output: ImageGenerationOutput = try await bedrock.generateImage(
            "This is a test",
            with: BedrockModel.nova_canvas,
            cfgScale: cfgScale
        )
        #expect(output.images.count == 1)
    }

    @Test(
        "Generate image using an invalid cfgScale",
        arguments: NovaTestConstants.ImageGeneration.invalidCfgScale
    )
    func generateImageWithInvalidCfgScale(cfgScale: Double) async throws {
        await #expect(throws: BedrockServiceError.self) {
            let _: ImageGenerationOutput = try await bedrock.generateImage(
                "This is a test",
                with: BedrockModel.nova_canvas,
                cfgScale: cfgScale
            )
        }
    }

    // Seed
    @Test(
        "Generate image using a valid seed",
        arguments: NovaTestConstants.ImageGeneration.validSeed
    )
    func generateImageWithValidSeed(seed: Int) async throws {
        let output: ImageGenerationOutput = try await bedrock.generateImage(
            "This is a test",
            with: BedrockModel.nova_canvas,
            seed: seed
        )
        #expect(output.images.count == 1)
    }

    @Test(
        "Generate image using an invalid seed",
        arguments: NovaTestConstants.ImageGeneration.invalidSeed
    )
    func generateImageWithInvalidSeed(seed: Int) async throws {
        await #expect(throws: BedrockServiceError.self) {
            let _: ImageGenerationOutput = try await bedrock.generateImage(
                "This is a test",
                with: BedrockModel.nova_canvas,
                seed: seed
            )
        }
    }

    // Prompt
    @Test(
        "Generate image using a valid prompt",
        arguments: NovaTestConstants.ImageGeneration.validImagePrompts
    )
    func generateImageWithValidPrompt(prompt: String) async throws {
        let output: ImageGenerationOutput = try await bedrock.generateImage(
            prompt,
            with: BedrockModel.nova_canvas,
            nrOfImages: 3
        )
        #expect(output.images.count == 3)
    }

    @Test(
        "Generate image using an invalid prompt",
        arguments: NovaTestConstants.ImageGeneration.invalidImagePrompts
    )
    func generateImageWithInvalidPrompt(prompt: String) async throws {
        await #expect(throws: BedrockServiceError.self) {
            let _: ImageGenerationOutput = try await bedrock.generateImage(
                prompt,
                with: BedrockModel.nova_canvas
            )
        }
    }
}
