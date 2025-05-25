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

// Image variation

extension BedrockServiceTests {

    // Models
    @Test(
        "Generate image variation using an implemented model",
        arguments: NovaTestConstants.imageGenerationModels
    )
    func generateImageVariationWithValidModel(model: BedrockModel) async throws {
        let mockBase64Image =
            "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII="
        let output: ImageGenerationOutput = try await bedrock.generateImageVariation(
            image: mockBase64Image,
            prompt: "This is a test",
            with: model,
            nrOfImages: 3
        )
        #expect(output.images.count == 3)
    }

    @Test(
        "Generate image variation using an invalid model",
        arguments: NovaTestConstants.textCompletionModels
    )
    func generateImageVariationWithInvalidModel(model: BedrockModel) async throws {
        await #expect(throws: BedrockServiceError.self) {
            let mockBase64Image =
                "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII="
            let _: ImageGenerationOutput = try await bedrock.generateImageVariation(
                image: mockBase64Image,
                prompt: "This is a test",
                with: model,
                nrOfImages: 3
            )
        }
    }

    // NrOfImages
    @Test(
        "Generate image variation using a valid nrOfImages",
        arguments: NovaTestConstants.ImageGeneration.validNrOfImages
    )
    func generateImageVariationWithValidNrOfImages(nrOfImages: Int) async throws {
        let mockBase64Image =
            "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII="
        let output: ImageGenerationOutput = try await bedrock.generateImageVariation(
            image: mockBase64Image,
            prompt: "This is a test",
            with: BedrockModel.nova_canvas,
            nrOfImages: nrOfImages
        )
        #expect(output.images.count == nrOfImages)
    }

    @Test(
        "Generate image variation using an invalid nrOfImages",
        arguments: NovaTestConstants.ImageGeneration.invalidNrOfImages
    )
    func generateImageVariationWithInvalidNrOfImages(nrOfImages: Int) async throws {
        await #expect(throws: BedrockServiceError.self) {
            let mockBase64Image =
                "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII="
            let _: ImageGenerationOutput = try await bedrock.generateImageVariation(
                image: mockBase64Image,
                prompt: "This is a test",
                with: BedrockModel.nova_canvas,
                nrOfImages: nrOfImages
            )
        }
    }

    // Similarity
    @Test(
        "Generate image variation using a valid similarity",
        arguments: NovaTestConstants.ImageVariation.validSimilarity
    )
    func generateImageVariationWithValidSimilarity(similarity: Double) async throws {
        let mockBase64Image =
            "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII="
        let output: ImageGenerationOutput = try await bedrock.generateImageVariation(
            image: mockBase64Image,
            prompt: "This is a test",
            with: BedrockModel.nova_canvas,
            similarity: similarity,
            nrOfImages: 3
        )
        #expect(output.images.count == 3)
    }

    @Test(
        "Generate image variation using an invalid similarity",
        arguments: NovaTestConstants.ImageVariation.invalidSimilarity
    )
    func generateImageVariationWithInvalidSimilarity(similarity: Double) async throws {
        await #expect(throws: BedrockServiceError.self) {
            let mockBase64Image =
                "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII="
            let _: ImageGenerationOutput = try await bedrock.generateImageVariation(
                image: mockBase64Image,
                prompt: "This is a test",
                with: BedrockModel.nova_canvas,
                similarity: similarity,
                nrOfImages: 3
            )
        }
    }

    // Number of reference images
    @Test(
        "Generate image variation using a valid number of reference images",
        arguments: NovaTestConstants.ImageVariation.validNrOfReferenceImages
    )
    func generateImageVariationWithValidNrOfReferenceImages(nrOfReferenceImages: Int) async throws {
        let mockBase64Image =
            "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII="
        let mockImages = Array(repeating: mockBase64Image, count: nrOfReferenceImages)
        let output: ImageGenerationOutput = try await bedrock.generateImageVariation(
            images: mockImages,
            prompt: "This is a test",
            with: BedrockModel.nova_canvas
        )
        #expect(output.images.count == 1)
    }

    @Test(
        "Generate image variation using an invalid number of reference images",
        arguments: NovaTestConstants.ImageVariation.invalidNrOfReferenceImages
    )
    func generateImageVariationWithInvalidNrOfReferenceImages(nrOfReferenceImages: Int) async throws {
        await #expect(throws: BedrockServiceError.self) {
            let mockBase64Image =
                "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII="
            let mockImages = Array(repeating: mockBase64Image, count: nrOfReferenceImages)
            let _: ImageGenerationOutput = try await bedrock.generateImageVariation(
                images: mockImages,
                prompt: "This is a test",
                with: BedrockModel.nova_canvas
            )
        }
    }

    // Prompt
    @Test(
        "Generate image variation using a valid prompt",
        arguments: NovaTestConstants.ImageGeneration.validImagePrompts
    )
    func generateImageVariationWithValidPrompt(prompt: String) async throws {
        let mockBase64Image =
            "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII="
        let output: ImageGenerationOutput = try await bedrock.generateImageVariation(
            image: mockBase64Image,
            prompt: prompt,
            with: BedrockModel.nova_canvas,
            similarity: 0.6
        )
        #expect(output.images.count == 1)
    }

    @Test(
        "Generate image variation using an invalid prompt",
        arguments: NovaTestConstants.ImageGeneration.invalidImagePrompts
    )
    func generateImageVariationWithInvalidPrompt(prompt: String) async throws {
        await #expect(throws: BedrockServiceError.self) {
            let mockBase64Image =
                "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII="
            let _: ImageGenerationOutput = try await bedrock.generateImageVariation(
                image: mockBase64Image,
                prompt: prompt,
                with: BedrockModel.nova_canvas,
                similarity: 0.6
            )
        }
    }
}
