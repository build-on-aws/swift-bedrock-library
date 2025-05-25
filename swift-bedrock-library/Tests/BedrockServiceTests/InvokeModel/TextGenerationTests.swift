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

// Text completion

extension BedrockServiceTests {

    // Models
    @Test(
        "Complete text using an implemented model",
        arguments: NovaTestConstants.textCompletionModels
    )
    func completeTextWithValidModel(model: BedrockModel) async throws {
        let completion: TextCompletion = try await bedrock.completeText(
            "This is a test",
            with: model
        )
        #expect(completion.completion == "This is the textcompletion for: This is a test")
    }

    @Test(
        "Complete text using an invalid model",
        arguments: NovaTestConstants.imageGenerationModels
    )
    func completeTextWithInvalidModel(model: BedrockModel) async throws {
        await #expect(throws: BedrockServiceError.self) {
            let _: TextCompletion = try await bedrock.completeText(
                "This is a test",
                with: model,
                temperature: 0.8
            )
        }
    }

    // Parameter combinations
    @Test(
        "Complete text using an implemented model and a valid combination of parameters"
    )
    func completeTextWithValidModelValidParameters() async throws {
        let completion: TextCompletion = try await bedrock.completeText(
            "This is a test",
            with: BedrockModel.nova_micro,
            maxTokens: 512,
            temperature: 0.5,
            topK: 10,
            stopSequences: ["END", "\n\nHuman:"]
        )
        #expect(completion.completion == "This is the textcompletion for: This is a test")
    }

    @Test(
        "Complete text using an implemented model and an invalid combination of parameters"
    )
    func completeTextWithInvalidModelInvalidParameters() async throws {
        await #expect(throws: BedrockServiceError.self) {
            let _: TextCompletion = try await bedrock.completeText(
                "This is a test",
                with: BedrockModel.nova_lite,
                temperature: 0.5,
                topP: 0.5
            )
        }
    }

    // Temperature
    @Test("Complete text using a valid temperature", arguments: NovaTestConstants.TextGeneration.validTemperature)
    func completeTextWithValidTemperature(temperature: Double) async throws {
        let completion: TextCompletion = try await bedrock.completeText(
            "This is a test",
            with: BedrockModel.nova_micro,
            temperature: temperature
        )
        #expect(completion.completion == "This is the textcompletion for: This is a test")
    }

    @Test("Complete text using an invalid temperature", arguments: NovaTestConstants.TextGeneration.invalidTemperature)
    func completeTextWithInvalidTemperature(temperature: Double) async throws {
        await #expect(throws: BedrockServiceError.self) {
            let _: TextCompletion = try await bedrock.completeText(
                "This is a test",
                with: BedrockModel.nova_micro,
                temperature: temperature
            )
        }
    }

    // MaxTokens
    @Test(
        "Complete text using a valid maxTokens",
        arguments: NovaTestConstants.TextGeneration.validMaxTokens
    )
    func completeTextWithValidMaxTokens(maxTokens: Int) async throws {
        let completion: TextCompletion = try await bedrock.completeText(
            "This is a test",
            with: BedrockModel.nova_micro,
            maxTokens: maxTokens
        )
        #expect(completion.completion == "This is the textcompletion for: This is a test")
    }

    @Test(
        "Complete text using an invalid maxTokens",
        arguments: NovaTestConstants.TextGeneration.invalidMaxTokens
    )
    func completeTextWithInvalidMaxTokens(maxTokens: Int) async throws {
        await #expect(throws: BedrockServiceError.self) {
            let _: TextCompletion = try await bedrock.completeText(
                "This is a test",
                with: BedrockModel.nova_micro,
                maxTokens: maxTokens
            )
        }
    }

    // TopP
    @Test(
        "Complete text using a valid topP",
        arguments: NovaTestConstants.TextGeneration.validTopP
    )
    func completeTextWithValidTopP(topP: Double) async throws {
        let completion: TextCompletion = try await bedrock.completeText(
            "This is a test",
            with: BedrockModel.nova_micro,
            topP: topP
        )
        #expect(completion.completion == "This is the textcompletion for: This is a test")
    }

    @Test(
        "Complete text using an invalid topP",
        arguments: NovaTestConstants.TextGeneration.invalidTopP
    )
    func completeTextWithInvalidMaxTokens(topP: Double) async throws {
        await #expect(throws: BedrockServiceError.self) {
            let _: TextCompletion = try await bedrock.completeText(
                "This is a test",
                with: BedrockModel.nova_micro,
                topP: topP
            )
        }
    }

    // TopK
    @Test(
        "Complete text using a valid topK",
        arguments: NovaTestConstants.TextGeneration.validTopK
    )
    func completeTextWithValidTopK(topK: Int) async throws {
        let completion: TextCompletion = try await bedrock.completeText(
            "This is a test",
            with: BedrockModel.nova_micro,
            topK: topK
        )
        #expect(completion.completion == "This is the textcompletion for: This is a test")
    }

    @Test(
        "Complete text using an invalid topK",
        arguments: NovaTestConstants.TextGeneration.invalidTopK
    )
    func completeTextWithInvalidTopK(topK: Int) async throws {
        await #expect(throws: BedrockServiceError.self) {
            let _: TextCompletion = try await bedrock.completeText(
                "This is a test",
                with: BedrockModel.nova_micro,
                topK: topK
            )
        }
    }

    // StopSequences
    @Test(
        "Complete text using valid stopSequences",
        arguments: NovaTestConstants.TextGeneration.validStopSequences
    )
    func completeTextWithValidMaxTokens(stopSequences: [String]) async throws {
        let completion: TextCompletion = try await bedrock.completeText(
            "This is a test",
            with: BedrockModel.nova_micro,
            stopSequences: stopSequences
        )
        #expect(completion.completion == "This is the textcompletion for: This is a test")
    }

    // Prompt
    @Test(
        "Complete text using a valid prompt",
        arguments: NovaTestConstants.TextGeneration.validPrompts
    )
    func completeTextWithValidPrompt(prompt: String) async throws {
        let completion: TextCompletion = try await bedrock.completeText(
            prompt,
            with: BedrockModel.nova_micro,
            maxTokens: 200
        )
        #expect(completion.completion == "This is the textcompletion for: \(prompt)")
    }

    @Test(
        "Complete text using an invalid prompt",
        arguments: NovaTestConstants.TextGeneration.invalidPrompts
    )
    func completeTextWithInvalidPrompt(prompt: String) async throws {
        await #expect(throws: BedrockServiceError.self) {
            let _: TextCompletion = try await bedrock.completeText(
                prompt,
                with: BedrockModel.nova_canvas,
                maxTokens: 10
            )
        }
    }
}
