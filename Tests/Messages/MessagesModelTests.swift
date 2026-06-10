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

@Suite("Messages Model Tests")
struct MessagesModelTests {

    @Test("Claude Fable 5 has correct model ID")
    func fable5ModelId() {
        #expect(BedrockModel.claude_fable_v5.id == "anthropic.claude-fable-5")
    }

    @Test("Claude Fable 5 has messages modality")
    func fable5HasMessagesModality() {
        #expect(BedrockModel.claude_fable_v5.hasMessagesModality())
    }

    @Test("Claude Fable 5 has converse modality")
    func fable5HasConverseModality() {
        #expect(BedrockModel.claude_fable_v5.hasConverseModality())
    }

    @Test("Claude Fable 5 has text modality")
    func fable5HasTextModality() {
        #expect(BedrockModel.claude_fable_v5.hasTextModality())
    }

    @Test("Claude Fable 5 has converse streaming modality")
    func fable5HasConverseStreamingModality() {
        #expect(BedrockModel.claude_fable_v5.hasConverseStreamingModality())
    }

    @Test("Claude Fable 5 does not have responses modality")
    func fable5NoResponsesModality() {
        #expect(!BedrockModel.claude_fable_v5.hasResponsesModality())
    }

    @Test("Claude Fable 5 uses /anthropic/v1/messages path")
    func fable5MessagesPath() throws {
        let modality = try BedrockModel.claude_fable_v5.getMessagesModality()
        #expect(modality.getMessagesPath() == "/anthropic/v1/messages")
    }

    @Test("Claude Fable 5 is resolvable from rawValue")
    func fable5RawValue() {
        let model = BedrockModel(rawValue: "anthropic.claude-fable-5")
        #expect(model != nil)
        #expect(model?.name == "Claude Fable 5")
    }

    @Test("Claude Fable 5 uses global cross-region inference prefix")
    func fable5CrossRegionInference() {
        let id = BedrockModel.claude_fable_v5.getModelIdWithCrossRegionInferencePrefix(region: .useast1)
        #expect(id == "global.anthropic.claude-fable-5")
    }

    @Test("Claude Fable 5 has reasoning feature")
    func fable5HasReasoning() {
        #expect(BedrockModel.claude_fable_v5.hasConverseModality(.reasoning))
    }

    @Test("Claude Fable 5 has vision feature")
    func fable5HasVision() {
        #expect(BedrockModel.claude_fable_v5.hasConverseModality(.vision))
    }

    @Test("Claude Fable 5 has tool use feature")
    func fable5HasToolUse() {
        #expect(BedrockModel.claude_fable_v5.hasConverseModality(.toolUse))
    }

    @Test("Existing Claude models do not have messages modality")
    func existingModelsNoMessagesModality() {
        #expect(!BedrockModel.claude_opus_v4_8.hasMessagesModality())
        #expect(!BedrockModel.claude_opus_v4_7.hasMessagesModality())
        #expect(!BedrockModel.claudev3_5_haiku.hasMessagesModality())
    }
}
