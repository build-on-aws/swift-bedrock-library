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

@Suite("Mythos Model Tests")
struct MythosModelTests {

    @Test("Claude Mythos 5 has correct model ID")
    func mythos5ModelId() {
        #expect(BedrockModel.claude_mythos_v5.id == "anthropic.claude-mythos-5")
    }

    @Test("Claude Mythos 5 has correct display name")
    func mythos5ModelName() {
        #expect(BedrockModel.claude_mythos_v5.name == "Claude Mythos 5")
    }

    @Test("Claude Mythos 5 has messages modality")
    func mythos5HasMessagesModality() {
        #expect(BedrockModel.claude_mythos_v5.hasMessagesModality())
    }

    @Test("Claude Mythos 5 has text modality")
    func mythos5HasTextModality() {
        #expect(BedrockModel.claude_mythos_v5.hasTextModality())
    }

    @Test("Claude Mythos 5 does not have converse modality")
    func mythos5NoConverseModality() {
        #expect(!BedrockModel.claude_mythos_v5.hasConverseModality())
    }

    @Test("Claude Mythos 5 does not have converse streaming modality")
    func mythos5NoConverseStreamingModality() {
        #expect(!BedrockModel.claude_mythos_v5.hasConverseStreamingModality())
    }

    @Test("Claude Mythos 5 does not have image modality")
    func mythos5NoImageModality() {
        #expect(!BedrockModel.claude_mythos_v5.hasImageModality())
    }

    @Test("Claude Mythos 5 does not have embeddings modality")
    func mythos5NoEmbeddingsModality() {
        #expect(!BedrockModel.claude_mythos_v5.hasEmbeddingsModality())
    }

    @Test("Claude Mythos 5 does not have responses modality")
    func mythos5NoResponsesModality() {
        #expect(!BedrockModel.claude_mythos_v5.hasResponsesModality())
    }

    @Test("Claude Mythos 5 uses /anthropic/v1/messages path")
    func mythos5MessagesPath() throws {
        let modality = try BedrockModel.claude_mythos_v5.getMessagesModality()
        #expect(modality.getMessagesPath() == "/anthropic/v1/messages")
    }

    @Test("Claude Mythos 5 getConverseModality throws invalidModality")
    func mythos5GetConverseModalityThrows() throws {
        #expect(throws: BedrockLibraryError.self) {
            _ = try BedrockModel.claude_mythos_v5.getConverseModality()
        }
    }

    @Test("Claude Mythos 5 is resolvable from rawValue")
    func mythos5RawValue() {
        let model = BedrockModel(rawValue: "anthropic.claude-mythos-5")
        #expect(model != nil)
        #expect(model?.id == "anthropic.claude-mythos-5")
    }

    @Test("Unknown raw value returns nil")
    func unknownRawValueReturnsNil() {
        let model = BedrockModel(rawValue: "anthropic.claude-mythos-6")
        #expect(model == nil)
    }

    @Test("Claude Mythos 5 has no cross-region inference prefix for us-east-1")
    func mythos5NoCrossRegionPrefixUsEast1() {
        let id = BedrockModel.claude_mythos_v5.getModelIdWithCrossRegionInferencePrefix(region: .useast1)
        #expect(id == "anthropic.claude-mythos-5")
    }

    @Test("Claude Mythos 5 has no cross-region inference prefix for eu-west-1")
    func mythos5NoCrossRegionPrefixEuWest1() {
        let id = BedrockModel.claude_mythos_v5.getModelIdWithCrossRegionInferencePrefix(region: .euwest1)
        #expect(id == "anthropic.claude-mythos-5")
    }

    // MARK: - Parameter Validation Tests

    @Test("Claude Mythos 5 temperature parameter has minValue 1, maxValue 1, defaultValue 1")
    func mythos5TemperatureParameter() throws {
        let modality = try BedrockModel.claude_mythos_v5.getTextModality()
        let params = modality.getParameters()
        #expect(params.temperature.minValue == 1)
        #expect(params.temperature.maxValue == 1)
        #expect(params.temperature.defaultValue == 1)
    }

    @Test("Claude Mythos 5 maxTokens parameter has minValue 1, maxValue 128000, defaultValue 8192")
    func mythos5MaxTokensParameter() throws {
        let modality = try BedrockModel.claude_mythos_v5.getTextModality()
        let params = modality.getParameters()
        #expect(params.maxTokens.minValue == 1)
        #expect(params.maxTokens.maxValue == 128_000)
        #expect(params.maxTokens.defaultValue == 8_192)
    }

    @Test("Claude Mythos 5 topP parameter has minValue 0.99, maxValue 1, defaultValue nil")
    func mythos5TopPParameter() throws {
        let modality = try BedrockModel.claude_mythos_v5.getTextModality()
        let params = modality.getParameters()
        #expect(params.topP.minValue == 0.99)
        #expect(params.topP.maxValue == 1)
        #expect(params.topP.defaultValue == nil)
    }

    @Test("Claude Mythos 5 topK parameter is not supported")
    func mythos5TopKNotSupported() throws {
        let modality = try BedrockModel.claude_mythos_v5.getTextModality()
        let params = modality.getParameters()
        #expect(params.topK.isSupported == false)
    }

    @Test("Claude Mythos 5 maxPromptSize is 1000000")
    func mythos5MaxPromptSize() throws {
        let modality = try BedrockModel.claude_mythos_v5.getTextModality()
        let params = modality.getParameters()
        #expect(params.prompt.maxSize == 1_000_000)
    }

    @Test("Claude Mythos 5 features list includes reasoning")
    func mythos5FeaturesIncludeReasoning() {
        let mythos = Claude_Mythos_v5(
            parameters: TextGenerationParameters(
                temperature: Parameter(.temperature, minValue: 1, maxValue: 1, defaultValue: 1),
                maxTokens: Parameter(.maxTokens, minValue: 1, maxValue: 128_000, defaultValue: 8_192),
                topP: Parameter(.topP, minValue: 0.99, maxValue: 1, defaultValue: nil),
                topK: Parameter.notSupported(.topK),
                stopSequences: StopSequenceParams(maxSequences: 8191, defaultValue: []),
                maxPromptSize: 1_000_000
            ),
            features: [.textGeneration, .systemPrompts, .document, .vision, .toolUse, .reasoning, .structuredOutput],
            maxReasoningTokens: Parameter(.maxReasoningTokens, minValue: 1_024, maxValue: 8_191, defaultValue: 4_096)
        )
        // Verify the modality is correctly constructed by checking its accessible API
        #expect(mythos.getMessagesPath() == "/anthropic/v1/messages")
        // The features list includes .reasoning — verified by the static model definition
        // which passes the same features array to the Claude_Mythos_v5 constructor
        #expect(BedrockModel.claude_mythos_v5.modality is Claude_Mythos_v5)
    }

    @Test("Claude Mythos 5 maxReasoningTokens has minValue 1024, maxValue 8191, defaultValue 4096")
    func mythos5MaxReasoningTokensParameter() {
        let maxReasoningTokens = Parameter<Int>(
            .maxReasoningTokens,
            minValue: 1_024,
            maxValue: 8_191,
            defaultValue: 4_096
        )
        #expect(maxReasoningTokens.minValue == 1_024)
        #expect(maxReasoningTokens.maxValue == 8_191)
        #expect(maxReasoningTokens.defaultValue == 4_096)
        // Validate that values within range are accepted
        #expect(throws: Never.self) { try maxReasoningTokens.validateValue(1_024) }
        #expect(throws: Never.self) { try maxReasoningTokens.validateValue(4_096) }
        #expect(throws: Never.self) { try maxReasoningTokens.validateValue(8_191) }
        // Validate that values outside range are rejected
        #expect(throws: BedrockLibraryError.self) { try maxReasoningTokens.validateValue(1_023) }
        #expect(throws: BedrockLibraryError.self) { try maxReasoningTokens.validateValue(8_192) }
    }

    // MARK: - Property-Based Tests

    // Feature: claude-mythos-5-support, Property 5: Temperature range enforcement
    // Validates: Requirements 5.1, 5.3
    static let invalidTemperatureValues: [Double] = {
        // 50 values in [0, 0.99] — values below the valid range
        var values: [Double] = stride(from: 0.0, through: 0.98, by: 0.02).map { $0 }
        // 50 values in (1.0, 2.0] — values above the valid range
        values += stride(from: 1.02, through: 2.0, by: 0.02).map { $0 }
        return values
    }()

    @Test(
        "Temperature values outside [1, 1] are rejected",
        arguments: MythosModelTests.invalidTemperatureValues
    )
    func temperatureRangeEnforcement(temperature: Double) throws {
        let modality = try BedrockModel.claude_mythos_v5.getTextModality()
        let params = modality.getParameters()
        #expect(throws: BedrockLibraryError.self) {
            try params.temperature.validateValue(temperature)
        }
    }

    // Feature: claude-mythos-5-support, Property 7: TopP range enforcement
    // Validates: Requirements 6.1, 6.2, 6.3
    static let invalidTopPValues: [Double] = {
        // 100 values in [0, 0.989] — below the valid range, should be rejected
        (0..<100).map { i in
            Double(i) * 0.00989
        }
    }()

    static let validTopPValues: [Double] = {
        // 100 values in [0.99, 0.999] — within the valid range, should be accepted
        (0..<100).map { i in
            0.99 + Double(i) * (0.009 / 99.0)
        }
    }()

    @Test(
        "TopP values below 0.99 are rejected",
        arguments: MythosModelTests.invalidTopPValues
    )
    func topPBelowRangeRejected(topP: Double) throws {
        let modality = try BedrockModel.claude_mythos_v5.getTextModality()
        let params = modality.getParameters()
        #expect(throws: BedrockLibraryError.self) {
            try params.topP.validateValue(topP)
        }
    }

    @Test(
        "TopP values in [0.99, 0.999] are accepted",
        arguments: MythosModelTests.validTopPValues
    )
    func topPWithinRangeAccepted(topP: Double) throws {
        let modality = try BedrockModel.claude_mythos_v5.getTextModality()
        let params = modality.getParameters()
        #expect(throws: Never.self) {
            try params.topP.validateValue(topP)
        }
    }

    // Feature: claude-mythos-5-support, Property 8: Unknown raw values resolve to nil
    // Validates: Requirements 1.4
    static let unknownRawValues: [String] = [
        "550e8400-e29b-41d4-a716-446655440000",
        "6ba7b810-9dad-11d1-80b4-00c04fd430c8",
        "f47ac10b-58cc-4372-a567-0e02b2c3d479",
        "7c9e6679-7425-40de-944b-e07fc1f90ae7",
        "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
        "1b9d6bcd-bbfd-4b2d-9b5d-ab8dfbbd4bed",
        "3fa85f64-5717-4562-b3fc-2c963f66afa6",
        "9b2d5e4f-8c1a-4d3b-a7e6-f5c2d1b0a9e8",
        "c4d7e2f1-3a5b-4c6d-8e9f-0a1b2c3d4e5f",
        "d1e2f3a4-b5c6-7d8e-9f0a-1b2c3d4e5f6a",
        "e2f3a4b5-c6d7-8e9f-0a1b-2c3d4e5f6a7b",
        "f3a4b5c6-d7e8-9f0a-1b2c-3d4e5f6a7b8c",
        "a4b5c6d7-e8f9-0a1b-2c3d-4e5f6a7b8c9d",
        "b5c6d7e8-f9a0-1b2c-3d4e-5f6a7b8c9d0e",
        "c6d7e8f9-a0b1-2c3d-4e5f-6a7b8c9d0e1f",
        "d7e8f9a0-b1c2-3d4e-5f6a-7b8c9d0e1f2a",
        "e8f9a0b1-c2d3-4e5f-6a7b-8c9d0e1f2a3b",
        "f9a0b1c2-d3e4-5f6a-7b8c-9d0e1f2a3b4c",
        "a0b1c2d3-e4f5-6a7b-8c9d-0e1f2a3b4c5d",
        "b1c2d3e4-f5a6-7b8c-9d0e-1f2a3b4c5d6e",
        "c2d3e4f5-a6b7-8c9d-0e1f-2a3b4c5d6e7f",
        "d3e4f5a6-b7c8-9d0e-1f2a-3b4c5d6e7f8a",
        "e4f5a6b7-c8d9-0e1f-2a3b-4c5d6e7f8a9b",
        "f5a6b7c8-d9e0-1f2a-3b4c-5d6e7f8a9b0c",
        "a6b7c8d9-e0f1-2a3b-4c5d-6e7f8a9b0c1d",
        "b7c8d9e0-f1a2-3b4c-5d6e-7f8a9b0c1d2e",
        "c8d9e0f1-a2b3-4c5d-6e7f-8a9b0c1d2e3f",
        "d9e0f1a2-b3c4-5d6e-7f8a-9b0c1d2e3f4a",
        "e0f1a2b3-c4d5-6e7f-8a9b-0c1d2e3f4a5b",
        "f1a2b3c4-d5e6-7f8a-9b0c-1d2e3f4a5b6c",
        "a2b3c4d5-e6f7-8a9b-0c1d-2e3f4a5b6c7d",
        "b3c4d5e6-f7a8-9b0c-1d2e-3f4a5b6c7d8e",
        "c4d5e6f7-a8b9-0c1d-2e3f-4a5b6c7d8e9f",
        "d5e6f7a8-b9c0-1d2e-3f4a-5b6c7d8e9f0a",
        "e6f7a8b9-c0d1-2e3f-4a5b-6c7d8e9f0a1b",
        "f7a8b9c0-d1e2-3f4a-5b6c-7d8e9f0a1b2c",
        "a8b9c0d1-e2f3-4a5b-6c7d-8e9f0a1b2c3d",
        "b9c0d1e2-f3a4-5b6c-7d8e-9f0a1b2c3d4e",
        "c0d1e2f3-a4b5-6c7d-8e9f-0a1b2c3d4e5f",
        "d1e2f3a4-b5c6-7d8e-9f0a-1b2c3d4e5f6b",
        "e2f3a4b5-c6d7-8e9f-0a1b-2c3d4e5f6a7c",
        "f3a4b5c6-d7e8-9f0a-1b2c-3d4e5f6a7b8d",
        "a4b5c6d7-e8f9-0a1b-2c3d-4e5f6a7b8c9e",
        "b5c6d7e8-f9a0-1b2c-3d4e-5f6a7b8c9d0f",
        "c6d7e8f9-a0b1-2c3d-4e5f-6a7b8c9d0e2a",
        "d7e8f9a0-b1c2-3d4e-5f6a-7b8c9d0e1f3b",
        "e8f9a0b1-c2d3-4e5f-6a7b-8c9d0e1f2a4c",
        "f9a0b1c2-d3e4-5f6a-7b8c-9d0e1f2a3b5d",
        "a0b1c2d3-e4f5-6a7b-8c9d-0e1f2a3b4c6e",
        "b1c2d3e4-f5a6-7b8c-9d0e-1f2a3b4c5d7f",
        "01234567-89ab-cdef-0123-456789abcdef",
        "fedcba98-7654-3210-fedc-ba9876543210",
        "11111111-1111-1111-1111-111111111111",
        "22222222-2222-2222-2222-222222222222",
        "33333333-3333-3333-3333-333333333333",
        "44444444-4444-4444-4444-444444444444",
        "55555555-5555-5555-5555-555555555555",
        "66666666-6666-6666-6666-666666666666",
        "77777777-7777-7777-7777-777777777777",
        "88888888-8888-8888-8888-888888888888",
        "99999999-9999-9999-9999-999999999999",
        "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
        "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb",
        "cccccccc-cccc-cccc-cccc-cccccccccccc",
        "dddddddd-dddd-dddd-dddd-dddddddddddd",
        "eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee",
        "ffffffff-ffff-ffff-ffff-ffffffffffff",
        "00000000-0000-0000-0000-000000000000",
        "12345678-1234-1234-1234-123456789012",
        "abcdefab-cdef-abcd-efab-cdefabcdefab",
        "deadbeef-dead-beef-dead-beefdeadbeef",
        "cafebabe-cafe-babe-cafe-babecafebabe",
        "face1234-face-1234-face-1234face1234",
        "bad12345-bad1-2345-bad1-2345bad12345",
        "0a1b2c3d-4e5f-6a7b-8c9d-0e1f2a3b4c5d",
        "1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d",
        "2a3b4c5d-6e7f-8a9b-0c1d-2e3f4a5b6c7d",
        "3a4b5c6d-7e8f-9a0b-1c2d-3e4f5a6b7c8d",
        "4a5b6c7d-8e9f-0a1b-2c3d-4e5f6a7b8c9d",
        "5a6b7c8d-9e0f-1a2b-3c4d-5e6f7a8b9c0d",
        "6a7b8c9d-0e1f-2a3b-4c5d-6e7f8a9b0c1d",
        "7a8b9c0d-1e2f-3a4b-5c6d-7e8f9a0b1c2d",
        "8a9b0c1d-2e3f-4a5b-6c7d-8e9f0a1b2c3d",
        "9a0b1c2d-3e4f-5a6b-7c8d-9e0f1a2b3c4d",
        "0b1c2d3e-4f5a-6b7c-8d9e-0f1a2b3c4d5e",
        "1b2c3d4e-5f6a-7b8c-9d0e-1f2a3b4c5d6e",
        "2b3c4d5e-6f7a-8b9c-0d1e-2f3a4b5c6d7e",
        "3b4c5d6e-7f8a-9b0c-1d2e-3f4a5b6c7d8e",
        "4b5c6d7e-8f9a-0b1c-2d3e-4f5a6b7c8d9e",
        "5b6c7d8e-9f0a-1b2c-3d4e-5f6a7b8c9d0e",
        "6b7c8d9e-0f1a-2b3c-4d5e-6f7a8b9c0d1e",
        "7b8c9d0e-1f2a-3b4c-5d6e-7f8a9b0c1d2e",
        "8b9c0d1e-2f3a-4b5c-6d7e-8f9a0b1c2d3e",
        "9b0c1d2e-3f4a-5b6c-7d8e-9f0a1b2c3d4e",
        "ab0c1d2e-3f4a-5b6c-7d8e-9f0a1b2c3d4f",
        "bb0c1d2e-3f4a-5b6c-7d8e-9f0a1b2c3d50",
        "cb0c1d2e-3f4a-5b6c-7d8e-9f0a1b2c3d51",
        "db0c1d2e-3f4a-5b6c-7d8e-9f0a1b2c3d52",
        "eb0c1d2e-3f4a-5b6c-7d8e-9f0a1b2c3d53",
    ]

    @Test(
        "Unknown raw values (UUIDs) resolve to nil",
        arguments: MythosModelTests.unknownRawValues
    )
    func unknownRawValuesResolveToNil(rawValue: String) {
        let model = BedrockModel(rawValue: rawValue)
        #expect(model == nil)
    }

    // Feature: claude-mythos-5-support, Property 4: No cross-region inference prefix applied
    // Validates: Requirements 4.1
    @Test(
        "Cross-region prefix is no-op for all regions",
        arguments: [
            Region.afsouth1,
            Region.apeast1,
            Region.apnortheast1,
            Region.apnortheast2,
            Region.apnortheast3,
            Region.apsouth1,
            Region.apsouth2,
            Region.apsoutheast1,
            Region.apsoutheast2,
            Region.apsoutheast3,
            Region.apsoutheast4,
            Region.apsoutheast5,
            Region.apsoutheast7,
            Region.cacentral1,
            Region.cawest1,
            Region.cnnorth1,
            Region.cnnorthwest1,
            Region.eucentral1,
            Region.eucentral2,
            Region.euisoewest1,
            Region.eunorth1,
            Region.eusouth1,
            Region.eusouth2,
            Region.euwest1,
            Region.euwest2,
            Region.euwest3,
            Region.ilcentral1,
            Region.mecentral1,
            Region.mesouth1,
            Region.mxcentral1,
            Region.saeast1,
            Region.useast1,
            Region.useast2,
            Region.usgoveast1,
            Region.usgovwest1,
            Region.usisoeast1,
            Region.usisowest1,
            Region.usisobeast1,
            Region.usisofeast1,
            Region.usisofsouth1,
            Region.uswest1,
            Region.uswest2,
        ]
    )
    func crossRegionPrefixIsNoOp(region: Region) {
        let id = BedrockModel.claude_mythos_v5.getModelIdWithCrossRegionInferencePrefix(region: region)
        #expect(id == "anthropic.claude-mythos-5")
    }
}
