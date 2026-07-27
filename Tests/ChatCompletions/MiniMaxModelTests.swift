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

import Foundation
import Testing

@testable import BedrockService

@Suite("MiniMax Model Tests")
struct MiniMaxModelTests {

    // MARK: - Model IDs and Names

    @Test("MiniMax M2 has correct model ID")
    func minimaxM2ModelId() {
        #expect(BedrockModel.minimax_m2.id == "minimax.minimax-m2")
    }

    @Test("MiniMax M2 has correct name")
    func minimaxM2ModelName() {
        #expect(BedrockModel.minimax_m2.name == "MiniMax M2")
    }

    @Test("MiniMax M2.1 has correct model ID")
    func minimaxM2_1ModelId() {
        #expect(BedrockModel.minimax_m2_1.id == "minimax.minimax-m2.1")
    }

    @Test("MiniMax M2.1 has correct name")
    func minimaxM2_1ModelName() {
        #expect(BedrockModel.minimax_m2_1.name == "MiniMax M2.1")
    }

    @Test("MiniMax M2.5 has correct model ID")
    func minimaxM2_5ModelId() {
        #expect(BedrockModel.minimax_m2_5.id == "minimax.minimax-m2.5")
    }

    @Test("MiniMax M2.5 has correct name")
    func minimaxM2_5ModelName() {
        #expect(BedrockModel.minimax_m2_5.name == "MiniMax M2.5")
    }

    // MARK: - hasChatCompletionsModality

    @Test("All MiniMax models have chat completions modality")
    func allMiniMaxHaveChatCompletionsModality() {
        #expect(BedrockModel.minimax_m2.hasChatCompletionsModality())
        #expect(BedrockModel.minimax_m2_1.hasChatCompletionsModality())
        #expect(BedrockModel.minimax_m2_5.hasChatCompletionsModality())
    }

    // MARK: - Unsupported modalities

    @Test("All MiniMax models do not have messages modality")
    func allMiniMaxNoMessagesModality() {
        #expect(!BedrockModel.minimax_m2.hasMessagesModality())
        #expect(!BedrockModel.minimax_m2_1.hasMessagesModality())
        #expect(!BedrockModel.minimax_m2_5.hasMessagesModality())
    }

    @Test("All MiniMax models do not have text modality")
    func allMiniMaxNoTextModality() {
        #expect(!BedrockModel.minimax_m2.hasTextModality())
        #expect(!BedrockModel.minimax_m2_1.hasTextModality())
        #expect(!BedrockModel.minimax_m2_5.hasTextModality())
    }

    @Test("All MiniMax models do not have converse modality")
    func allMiniMaxNoConverseModality() {
        #expect(!BedrockModel.minimax_m2.hasConverseModality())
        #expect(!BedrockModel.minimax_m2_1.hasConverseModality())
        #expect(!BedrockModel.minimax_m2_5.hasConverseModality())
    }

    @Test("All MiniMax models do not have responses modality")
    func allMiniMaxNoResponsesModality() {
        #expect(!BedrockModel.minimax_m2.hasResponsesModality())
        #expect(!BedrockModel.minimax_m2_1.hasResponsesModality())
        #expect(!BedrockModel.minimax_m2_5.hasResponsesModality())
    }

    @Test("All MiniMax models do not have image modality")
    func allMiniMaxNoImageModality() {
        #expect(!BedrockModel.minimax_m2.hasImageModality())
        #expect(!BedrockModel.minimax_m2_1.hasImageModality())
        #expect(!BedrockModel.minimax_m2_5.hasImageModality())
    }

    // MARK: - getChatCompletionsPath

    @Test("All MiniMax models use /v1/chat/completions path")
    func allMiniMaxChatCompletionsPath() throws {
        let modalityM2 = try BedrockModel.minimax_m2.getChatCompletionsModality()
        #expect(modalityM2.getChatCompletionsPath() == "/v1/chat/completions")

        let modalityM2_1 = try BedrockModel.minimax_m2_1.getChatCompletionsModality()
        #expect(modalityM2_1.getChatCompletionsPath() == "/v1/chat/completions")

        let modalityM2_5 = try BedrockModel.minimax_m2_5.getChatCompletionsModality()
        #expect(modalityM2_5.getChatCompletionsPath() == "/v1/chat/completions")
    }

    // MARK: - getMessagesModality throws

    @Test("getMessagesModality throws for all MiniMax models")
    func allMiniMaxGetMessagesModalityThrows() {
        #expect(throws: BedrockLibraryError.self) {
            _ = try BedrockModel.minimax_m2.getMessagesModality()
        }
        #expect(throws: BedrockLibraryError.self) {
            _ = try BedrockModel.minimax_m2_1.getMessagesModality()
        }
        #expect(throws: BedrockLibraryError.self) {
            _ = try BedrockModel.minimax_m2_5.getMessagesModality()
        }
    }

    // MARK: - BedrockModel(rawValue:)

    @Test("MiniMax M2 is resolvable from rawValue")
    func minimaxM2RawValue() {
        let model = BedrockModel(rawValue: "minimax.minimax-m2")
        #expect(model != nil)
        #expect(model?.name == "MiniMax M2")
    }

    @Test("MiniMax M2.1 is resolvable from rawValue")
    func minimaxM2_1RawValue() {
        let model = BedrockModel(rawValue: "minimax.minimax-m2.1")
        #expect(model != nil)
        #expect(model?.name == "MiniMax M2.1")
    }

    @Test("MiniMax M2.5 is resolvable from rawValue")
    func minimaxM2_5RawValue() {
        let model = BedrockModel(rawValue: "minimax.minimax-m2.5")
        #expect(model != nil)
        #expect(model?.name == "MiniMax M2.5")
    }

    @Test("Unknown model IDs return nil from rawValue initializer")
    func unknownRawValueReturnsNil() {
        #expect(BedrockModel(rawValue: "minimax.minimax-m3") == nil)
        #expect(BedrockModel(rawValue: "minimax.unknown") == nil)
        #expect(BedrockModel(rawValue: "") == nil)
    }

    // MARK: - getTextModality throws

    @Test("getTextModality throws for all MiniMax models")
    func allMiniMaxGetTextModalityThrows() {
        #expect(throws: BedrockLibraryError.self) {
            _ = try BedrockModel.minimax_m2.getTextModality()
        }
        #expect(throws: BedrockLibraryError.self) {
            _ = try BedrockModel.minimax_m2_1.getTextModality()
        }
        #expect(throws: BedrockLibraryError.self) {
            _ = try BedrockModel.minimax_m2_5.getTextModality()
        }
    }

    // MARK: - getResponsesModality throws

    @Test("getResponsesModality throws for all MiniMax models")
    func allMiniMaxGetResponsesModalityThrows() {
        #expect(throws: BedrockLibraryError.self) {
            _ = try BedrockModel.minimax_m2.getResponsesModality()
        }
        #expect(throws: BedrockLibraryError.self) {
            _ = try BedrockModel.minimax_m2_1.getResponsesModality()
        }
        #expect(throws: BedrockLibraryError.self) {
            _ = try BedrockModel.minimax_m2_5.getResponsesModality()
        }
    }

    // MARK: - Cross-region inference returns plain ID

    @Test("Cross-region inference returns plain model ID (no prefix)")
    func crossRegionReturnsPlainId() {
        let idM2 = BedrockModel.minimax_m2.getModelIdWithCrossRegionInferencePrefix(region: .useast1)
        #expect(idM2 == "minimax.minimax-m2")

        let idM2_1 = BedrockModel.minimax_m2_1.getModelIdWithCrossRegionInferencePrefix(region: .euwest1)
        #expect(idM2_1 == "minimax.minimax-m2.1")

        let idM2_5 = BedrockModel.minimax_m2_5.getModelIdWithCrossRegionInferencePrefix(region: .apnortheast1)
        #expect(idM2_5 == "minimax.minimax-m2.5")
    }

    // MARK: - Parameter defaults

    @Test("MiniMax parameter defaults match model cards")
    func minimaxParameterDefaults() throws {
        let modality = try BedrockModel.minimax_m2.getChatCompletionsModality()
        let params = modality.getTextGenerationParameters()
        #expect(params.temperature.defaultValue == 1)
        #expect(params.temperature.minValue == 0)
        #expect(params.temperature.maxValue == 1)
        #expect(params.topP.defaultValue == 1)
        #expect(params.topP.minValue == 0)
        #expect(params.topP.maxValue == 1)
        #expect(params.maxTokens.defaultValue == 8_192)
        #expect(params.maxTokens.minValue == 1)
        #expect(params.maxTokens.maxValue == 8_192)
        #expect(!params.topK.isSupported)
    }

    // MARK: - Property-Based Tests

    // Feature: minimax-model-support, Property 1: Unknown raw values resolve to nil
    @Test("Unknown raw values resolve to nil", arguments: (0..<100).map { _ in UUID().uuidString })
    func unknownRawValuesResolveToNil(randomId: String) {
        #expect(BedrockModel(rawValue: randomId) == nil)
    }

    // Feature: minimax-model-support, Property 2: rawValue round-trip
    @Test(
        "MiniMax model IDs resolve from rawValue",
        arguments: ["minimax.minimax-m2", "minimax.minimax-m2.1", "minimax.minimax-m2.5"]
    )
    func rawValueRoundTrip(modelId: String) {
        let model = BedrockModel(rawValue: modelId)
        #expect(model != nil)
        #expect(model?.id == modelId)
    }

    // Feature: minimax-model-support, Property 3: Consistent chat completions path
    @Test(
        "All MiniMax models have consistent chat completions path",
        arguments: [BedrockModel.minimax_m2, BedrockModel.minimax_m2_1, BedrockModel.minimax_m2_5]
    )
    func consistentChatCompletionsPath(model: BedrockModel) throws {
        let modality = try model.getChatCompletionsModality()
        #expect(modality.getChatCompletionsPath() == "/v1/chat/completions")
    }

    // Feature: minimax-model-support, Property 4: No unsupported modalities
    @Test(
        "MiniMax models do not have unsupported modalities",
        arguments: [BedrockModel.minimax_m2, BedrockModel.minimax_m2_1, BedrockModel.minimax_m2_5]
    )
    func noUnsupportedModalities(model: BedrockModel) {
        #expect(!model.hasTextModality())
        #expect(!model.hasConverseModality())
        #expect(!model.hasResponsesModality())
        #expect(!model.hasMessagesModality())
        #expect(!model.hasImageModality())
    }

    // Feature: minimax-model-support, Property 5: Plain model ID for cross-region
    @Test(
        "Cross-region inference returns plain model ID for all regions",
        arguments: [BedrockModel.minimax_m2, BedrockModel.minimax_m2_1, BedrockModel.minimax_m2_5]
    )
    func plainModelIdForCrossRegion(model: BedrockModel) {
        let regions: [Region] = [.useast1, .uswest2, .euwest1, .eucentral1, .apnortheast1]
        for region in regions {
            let result = model.getModelIdWithCrossRegionInferencePrefix(region: region)
            #expect(result == model.id)
        }
    }
}
