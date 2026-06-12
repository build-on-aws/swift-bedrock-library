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

import AwsCommonRuntimeKit
import Foundation
import Testing

@testable import BedrockService

@Suite("ChatCompletions Model Tests")
struct ChatCompletionsModelTests {

    // MARK: - Model IDs and Names

    @Test("Gemma 4 31B has correct model ID")
    func gemma4_31bModelId() {
        #expect(BedrockModel.gemma4_31b.id == "google.gemma-4-31b")
    }

    @Test("Gemma 4 31B has correct name")
    func gemma4_31bModelName() {
        #expect(BedrockModel.gemma4_31b.name == "Gemma 4 31B")
    }

    @Test("Gemma 4 26B-A4B has correct model ID")
    func gemma4_26b_a4bModelId() {
        #expect(BedrockModel.gemma4_26b_a4b.id == "google.gemma-4-26b-a4b")
    }

    @Test("Gemma 4 26B-A4B has correct name")
    func gemma4_26b_a4bModelName() {
        #expect(BedrockModel.gemma4_26b_a4b.name == "Gemma 4 26B-A4B")
    }

    @Test("Gemma 4 E2B has correct model ID")
    func gemma4_e2bModelId() {
        #expect(BedrockModel.gemma4_e2b.id == "google.gemma-4-e2b")
    }

    @Test("Gemma 4 E2B has correct name")
    func gemma4_e2bModelName() {
        #expect(BedrockModel.gemma4_e2b.name == "Gemma 4 E2B")
    }

    @Test("Gemma 3 27B IT has correct model ID")
    func gemma3_27b_itModelId() {
        #expect(BedrockModel.gemma3_27b_it.id == "google.gemma-3-27b-it")
    }

    @Test("Gemma 3 27B IT has correct name")
    func gemma3_27b_itModelName() {
        #expect(BedrockModel.gemma3_27b_it.name == "Gemma 3 27B IT")
    }

    @Test("Gemma 3 12B IT has correct model ID")
    func gemma3_12b_itModelId() {
        #expect(BedrockModel.gemma3_12b_it.id == "google.gemma-3-12b-it")
    }

    @Test("Gemma 3 12B IT has correct name")
    func gemma3_12b_itModelName() {
        #expect(BedrockModel.gemma3_12b_it.name == "Gemma 3 12B IT")
    }

    @Test("Gemma 3 4B IT has correct model ID")
    func gemma3_4b_itModelId() {
        #expect(BedrockModel.gemma3_4b_it.id == "google.gemma-3-4b-it")
    }

    @Test("Gemma 3 4B IT has correct name")
    func gemma3_4b_itModelName() {
        #expect(BedrockModel.gemma3_4b_it.name == "Gemma 3 4B IT")
    }

    // MARK: - hasChatCompletionsModality

    @Test("All Gemma 4 models have chat completions modality")
    func gemma4HasChatCompletionsModality() {
        #expect(BedrockModel.gemma4_31b.hasChatCompletionsModality())
        #expect(BedrockModel.gemma4_26b_a4b.hasChatCompletionsModality())
        #expect(BedrockModel.gemma4_e2b.hasChatCompletionsModality())
    }

    @Test("All Gemma 3 models have chat completions modality")
    func gemma3HasChatCompletionsModality() {
        #expect(BedrockModel.gemma3_27b_it.hasChatCompletionsModality())
        #expect(BedrockModel.gemma3_12b_it.hasChatCompletionsModality())
        #expect(BedrockModel.gemma3_4b_it.hasChatCompletionsModality())
    }

    // MARK: - hasResponsesModality

    @Test("All Gemma 4 models have responses modality")
    func gemma4HasResponsesModality() {
        #expect(BedrockModel.gemma4_31b.hasResponsesModality())
        #expect(BedrockModel.gemma4_26b_a4b.hasResponsesModality())
        #expect(BedrockModel.gemma4_e2b.hasResponsesModality())
    }

    @Test("All Gemma 3 models do not have responses modality")
    func gemma3NoResponsesModality() {
        #expect(!BedrockModel.gemma3_27b_it.hasResponsesModality())
        #expect(!BedrockModel.gemma3_12b_it.hasResponsesModality())
        #expect(!BedrockModel.gemma3_4b_it.hasResponsesModality())
    }

    // MARK: - hasTextModality

    @Test("All Gemma 4 models do not have text modality")
    func gemma4NoTextModality() {
        #expect(!BedrockModel.gemma4_31b.hasTextModality())
        #expect(!BedrockModel.gemma4_26b_a4b.hasTextModality())
        #expect(!BedrockModel.gemma4_e2b.hasTextModality())
    }

    @Test("All Gemma 3 models have text modality")
    func gemma3HasTextModality() {
        #expect(BedrockModel.gemma3_27b_it.hasTextModality())
        #expect(BedrockModel.gemma3_12b_it.hasTextModality())
        #expect(BedrockModel.gemma3_4b_it.hasTextModality())
    }

    // MARK: - hasConverseModality

    @Test("All Gemma 4 models do not have converse modality")
    func gemma4NoConverseModality() {
        #expect(!BedrockModel.gemma4_31b.hasConverseModality())
        #expect(!BedrockModel.gemma4_26b_a4b.hasConverseModality())
        #expect(!BedrockModel.gemma4_e2b.hasConverseModality())
    }

    @Test("All Gemma 3 models have converse modality")
    func gemma3HasConverseModality() {
        #expect(BedrockModel.gemma3_27b_it.hasConverseModality())
        #expect(BedrockModel.gemma3_12b_it.hasConverseModality())
        #expect(BedrockModel.gemma3_4b_it.hasConverseModality())
    }

    // MARK: - hasMessagesModality

    @Test("All Gemma models do not have messages modality")
    func allGemmaNoMessagesModality() {
        #expect(!BedrockModel.gemma4_31b.hasMessagesModality())
        #expect(!BedrockModel.gemma4_26b_a4b.hasMessagesModality())
        #expect(!BedrockModel.gemma4_e2b.hasMessagesModality())
        #expect(!BedrockModel.gemma3_27b_it.hasMessagesModality())
        #expect(!BedrockModel.gemma3_12b_it.hasMessagesModality())
        #expect(!BedrockModel.gemma3_4b_it.hasMessagesModality())
    }

    // MARK: - hasImageModality

    @Test("All Gemma models do not have image modality")
    func allGemmaNoImageModality() {
        #expect(!BedrockModel.gemma4_31b.hasImageModality())
        #expect(!BedrockModel.gemma4_26b_a4b.hasImageModality())
        #expect(!BedrockModel.gemma4_e2b.hasImageModality())
        #expect(!BedrockModel.gemma3_27b_it.hasImageModality())
        #expect(!BedrockModel.gemma3_12b_it.hasImageModality())
        #expect(!BedrockModel.gemma3_4b_it.hasImageModality())
    }

    // MARK: - getChatCompletionsPath

    @Test("Gemma 4 models use /openai/v1/chat/completions path")
    func gemma4ChatCompletionsPath() throws {
        let modality31b = try BedrockModel.gemma4_31b.getChatCompletionsModality()
        #expect(modality31b.getChatCompletionsPath() == "/openai/v1/chat/completions")

        let modality26b = try BedrockModel.gemma4_26b_a4b.getChatCompletionsModality()
        #expect(modality26b.getChatCompletionsPath() == "/openai/v1/chat/completions")

        let modalityE2b = try BedrockModel.gemma4_e2b.getChatCompletionsModality()
        #expect(modalityE2b.getChatCompletionsPath() == "/openai/v1/chat/completions")
    }

    @Test("Gemma 3 models use /v1/chat/completions path")
    func gemma3ChatCompletionsPath() throws {
        let modality27b = try BedrockModel.gemma3_27b_it.getChatCompletionsModality()
        #expect(modality27b.getChatCompletionsPath() == "/v1/chat/completions")

        let modality12b = try BedrockModel.gemma3_12b_it.getChatCompletionsModality()
        #expect(modality12b.getChatCompletionsPath() == "/v1/chat/completions")

        let modality4b = try BedrockModel.gemma3_4b_it.getChatCompletionsModality()
        #expect(modality4b.getChatCompletionsPath() == "/v1/chat/completions")
    }

    // MARK: - getResponsesPath

    @Test("Gemma 4 models use /openai/v1/responses path")
    func gemma4ResponsesPath() throws {
        let modality31b = try BedrockModel.gemma4_31b.getResponsesModality()
        #expect(modality31b.getResponsesPath() == "/openai/v1/responses")

        let modality26b = try BedrockModel.gemma4_26b_a4b.getResponsesModality()
        #expect(modality26b.getResponsesPath() == "/openai/v1/responses")

        let modalityE2b = try BedrockModel.gemma4_e2b.getResponsesModality()
        #expect(modalityE2b.getResponsesPath() == "/openai/v1/responses")
    }

    // MARK: - BedrockModel(rawValue:) resolves all 6 models

    @Test("Gemma 4 31B is resolvable from rawValue")
    func gemma4_31bRawValue() {
        let model = BedrockModel(rawValue: "google.gemma-4-31b")
        #expect(model != nil)
        #expect(model?.name == "Gemma 4 31B")
    }

    @Test("Gemma 4 26B-A4B is resolvable from rawValue")
    func gemma4_26b_a4bRawValue() {
        let model = BedrockModel(rawValue: "google.gemma-4-26b-a4b")
        #expect(model != nil)
        #expect(model?.name == "Gemma 4 26B-A4B")
    }

    @Test("Gemma 4 E2B is resolvable from rawValue")
    func gemma4_e2bRawValue() {
        let model = BedrockModel(rawValue: "google.gemma-4-e2b")
        #expect(model != nil)
        #expect(model?.name == "Gemma 4 E2B")
    }

    @Test("Gemma 3 27B IT is resolvable from rawValue")
    func gemma3_27b_itRawValue() {
        let model = BedrockModel(rawValue: "google.gemma-3-27b-it")
        #expect(model != nil)
        #expect(model?.name == "Gemma 3 27B IT")
    }

    @Test("Gemma 3 12B IT is resolvable from rawValue")
    func gemma3_12b_itRawValue() {
        let model = BedrockModel(rawValue: "google.gemma-3-12b-it")
        #expect(model != nil)
        #expect(model?.name == "Gemma 3 12B IT")
    }

    @Test("Gemma 3 4B IT is resolvable from rawValue")
    func gemma3_4b_itRawValue() {
        let model = BedrockModel(rawValue: "google.gemma-3-4b-it")
        #expect(model != nil)
        #expect(model?.name == "Gemma 3 4B IT")
    }

    // MARK: - Unknown raw values return nil

    @Test("Unknown model IDs return nil from rawValue initializer")
    func unknownRawValueReturnsNil() {
        #expect(BedrockModel(rawValue: "google.gemma-5-100b") == nil)
        #expect(BedrockModel(rawValue: "unknown.model") == nil)
        #expect(BedrockModel(rawValue: "") == nil)
    }

    // MARK: - getTextModality throws for Gemma 4

    @Test("getTextModality throws for Gemma 4 models")
    func gemma4GetTextModalityThrows() {
        #expect(throws: BedrockLibraryError.self) {
            _ = try BedrockModel.gemma4_31b.getTextModality()
        }
        #expect(throws: BedrockLibraryError.self) {
            _ = try BedrockModel.gemma4_26b_a4b.getTextModality()
        }
        #expect(throws: BedrockLibraryError.self) {
            _ = try BedrockModel.gemma4_e2b.getTextModality()
        }
    }

    // MARK: - getConverseModality throws for Gemma 4

    @Test("getConverseModality throws for Gemma 4 models")
    func gemma4GetConverseModalityThrows() {
        #expect(throws: BedrockLibraryError.self) {
            _ = try BedrockModel.gemma4_31b.getConverseModality()
        }
        #expect(throws: BedrockLibraryError.self) {
            _ = try BedrockModel.gemma4_26b_a4b.getConverseModality()
        }
        #expect(throws: BedrockLibraryError.self) {
            _ = try BedrockModel.gemma4_e2b.getConverseModality()
        }
    }

    // MARK: - getResponsesModality throws for Gemma 3

    @Test("getResponsesModality throws for Gemma 3 models")
    func gemma3GetResponsesModalityThrows() {
        #expect(throws: BedrockLibraryError.self) {
            _ = try BedrockModel.gemma3_27b_it.getResponsesModality()
        }
        #expect(throws: BedrockLibraryError.self) {
            _ = try BedrockModel.gemma3_12b_it.getResponsesModality()
        }
        #expect(throws: BedrockLibraryError.self) {
            _ = try BedrockModel.gemma3_4b_it.getResponsesModality()
        }
    }

    // MARK: - getMessagesModality throws for all 6 models

    @Test("getMessagesModality throws for all Gemma models")
    func allGemmaGetMessagesModalityThrows() {
        #expect(throws: BedrockLibraryError.self) {
            _ = try BedrockModel.gemma4_31b.getMessagesModality()
        }
        #expect(throws: BedrockLibraryError.self) {
            _ = try BedrockModel.gemma4_26b_a4b.getMessagesModality()
        }
        #expect(throws: BedrockLibraryError.self) {
            _ = try BedrockModel.gemma4_e2b.getMessagesModality()
        }
        #expect(throws: BedrockLibraryError.self) {
            _ = try BedrockModel.gemma3_27b_it.getMessagesModality()
        }
        #expect(throws: BedrockLibraryError.self) {
            _ = try BedrockModel.gemma3_12b_it.getMessagesModality()
        }
        #expect(throws: BedrockLibraryError.self) {
            _ = try BedrockModel.gemma3_4b_it.getMessagesModality()
        }
    }

    // MARK: - Converse features for Gemma 3

    @Test("Gemma 3 models support textGeneration converse feature")
    func gemma3HasTextGenerationFeature() {
        #expect(BedrockModel.gemma3_27b_it.hasConverseModality(.textGeneration))
        #expect(BedrockModel.gemma3_12b_it.hasConverseModality(.textGeneration))
        #expect(BedrockModel.gemma3_4b_it.hasConverseModality(.textGeneration))
    }

    @Test("Gemma 3 models support vision converse feature")
    func gemma3HasVisionFeature() {
        #expect(BedrockModel.gemma3_27b_it.hasConverseModality(.vision))
        #expect(BedrockModel.gemma3_12b_it.hasConverseModality(.vision))
        #expect(BedrockModel.gemma3_4b_it.hasConverseModality(.vision))
    }

    @Test("Gemma 3 models support systemPrompts converse feature")
    func gemma3HasSystemPromptsFeature() {
        #expect(BedrockModel.gemma3_27b_it.hasConverseModality(.systemPrompts))
        #expect(BedrockModel.gemma3_12b_it.hasConverseModality(.systemPrompts))
        #expect(BedrockModel.gemma3_4b_it.hasConverseModality(.systemPrompts))
    }

    // MARK: - Property-Based Tests

    // Feature: gemma4-model-support, Property 1: Unknown raw values resolve to nil
    // Validates: Requirements 1.6
    @Test("Unknown raw values resolve to nil", arguments: (0..<100).map { _ in UUID().uuidString })
    func unknownRawValuesResolveToNil(randomId: String) {
        #expect(BedrockModel(rawValue: randomId) == nil)
    }

    // Feature: gemma4-model-support, Property 2: Out-of-range parameter values are rejected
    // Validates: Requirements 7.8, 8.8, 9.5
    @Test("Out-of-range temperature values are rejected for all Gemma models")
    func outOfRangeTemperatureRejected() async throws {
        CommonRuntimeKit.initialize()
        let bedrock = try await BedrockService(
            region: .useast1,
            bedrockClient: MockBedrockClient(),
            bedrockRuntimeClient: MockBedrockRuntimeClient()
        )

        let gemmaModels: [BedrockModel] = [
            .gemma4_31b, .gemma4_26b_a4b, .gemma4_e2b,
            .gemma3_27b_it, .gemma3_12b_it, .gemma3_4b_it,
        ]

        for _ in 0..<100 {
            // Generate random out-of-range temperature: either < 0 or > 2
            let outOfRange: Double
            if Bool.random() {
                outOfRange = -Double.random(in: 0.001...1000.0)
            } else {
                outOfRange = Double.random(in: 2.001...1000.0)
            }

            for model in gemmaModels {
                await #expect(throws: BedrockLibraryError.self) {
                    _ = try await bedrock.completeChatCompletion(
                        "test",
                        with: model,
                        temperature: outOfRange,
                        authentication: .apiKey(key: "test-key"),
                        mantleClient: MockBedrockMantleChatCompletionsClient()
                    )
                }
            }
        }
    }

    @Test("Out-of-range maxTokens values are rejected for all Gemma models")
    func outOfRangeMaxTokensRejected() async throws {
        CommonRuntimeKit.initialize()
        let bedrock = try await BedrockService(
            region: .useast1,
            bedrockClient: MockBedrockClient(),
            bedrockRuntimeClient: MockBedrockRuntimeClient()
        )

        let gemmaModels: [BedrockModel] = [
            .gemma4_31b, .gemma4_26b_a4b, .gemma4_e2b,
            .gemma3_27b_it, .gemma3_12b_it, .gemma3_4b_it,
        ]

        for _ in 0..<100 {
            // Generate random out-of-range maxTokens: either < 1 or > 8192
            let outOfRange: Int
            if Bool.random() {
                outOfRange = Int.random(in: -1000...0)
            } else {
                outOfRange = Int.random(in: 8193...100000)
            }

            for model in gemmaModels {
                await #expect(throws: BedrockLibraryError.self) {
                    _ = try await bedrock.completeChatCompletion(
                        "test",
                        with: model,
                        maxTokens: outOfRange,
                        authentication: .apiKey(key: "test-key"),
                        mantleClient: MockBedrockMantleChatCompletionsClient()
                    )
                }
            }
        }
    }

    @Test("Out-of-range topP values are rejected for all Gemma models")
    func outOfRangeTopPRejected() async throws {
        CommonRuntimeKit.initialize()
        let bedrock = try await BedrockService(
            region: .useast1,
            bedrockClient: MockBedrockClient(),
            bedrockRuntimeClient: MockBedrockRuntimeClient()
        )

        let gemmaModels: [BedrockModel] = [
            .gemma4_31b, .gemma4_26b_a4b, .gemma4_e2b,
            .gemma3_27b_it, .gemma3_12b_it, .gemma3_4b_it,
        ]

        for _ in 0..<100 {
            // Generate random out-of-range topP: either < 0 or > 1
            let outOfRange: Double
            if Bool.random() {
                outOfRange = -Double.random(in: 0.001...1000.0)
            } else {
                outOfRange = Double.random(in: 1.001...1000.0)
            }

            for model in gemmaModels {
                await #expect(throws: BedrockLibraryError.self) {
                    _ = try await bedrock.completeChatCompletion(
                        "test",
                        with: model,
                        topP: outOfRange,
                        authentication: .apiKey(key: "test-key"),
                        mantleClient: MockBedrockMantleChatCompletionsClient()
                    )
                }
            }
        }
    }
}
