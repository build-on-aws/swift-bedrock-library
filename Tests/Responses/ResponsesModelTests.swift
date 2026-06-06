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

@Suite("Responses Model Tests")
struct ResponsesModelTests {

    @Test("GPT 5.5 has correct model ID")
    func gpt55ModelId() {
        #expect(BedrockModel.openai_gpt_5_5.id == "openai.gpt-5.5")
    }

    @Test("GPT 5.4 has correct model ID")
    func gpt54ModelId() {
        #expect(BedrockModel.openai_gpt_5_4.id == "openai.gpt-5.4")
    }

    @Test("GPT 5.5 has responses modality")
    func gpt55HasResponsesModality() {
        #expect(BedrockModel.openai_gpt_5_5.hasResponsesModality())
    }

    @Test("GPT 5.4 has responses modality")
    func gpt54HasResponsesModality() {
        #expect(BedrockModel.openai_gpt_5_4.hasResponsesModality())
    }

    @Test("GPT 5.5 does not have converse modality")
    func gpt55NoConverseModality() {
        #expect(!BedrockModel.openai_gpt_5_5.hasConverseModality())
    }

    @Test("GPT 5.4 does not have text modality")
    func gpt54NoTextModality() {
        #expect(!BedrockModel.openai_gpt_5_4.hasTextModality())
    }

    @Test("GPT 5.5 uses /openai/v1/responses path")
    func gpt55ResponsesPath() throws {
        let modality = try BedrockModel.openai_gpt_5_5.getResponsesModality()
        #expect(modality.getResponsesPath() == "/openai/v1/responses")
    }

    @Test("GPT 5.4 uses /openai/v1/responses path")
    func gpt54ResponsesPath() throws {
        let modality = try BedrockModel.openai_gpt_5_4.getResponsesModality()
        #expect(modality.getResponsesPath() == "/openai/v1/responses")
    }

    @Test("gpt-oss-20b has responses modality")
    func gptOss20bHasResponsesModality() {
        #expect(BedrockModel.openai_gpt_oss_20b.hasResponsesModality())
    }

    @Test("gpt-oss-120b has responses modality")
    func gptOss120bHasResponsesModality() {
        #expect(BedrockModel.openai_gpt_oss_120b.hasResponsesModality())
    }

    @Test("gpt-oss-20b uses /v1/responses path")
    func gptOss20bResponsesPath() throws {
        let modality = try BedrockModel.openai_gpt_oss_20b.getResponsesModality()
        #expect(modality.getResponsesPath() == "/v1/responses")
    }

    @Test("gpt-oss-20b still has converse modality")
    func gptOss20bStillHasConverse() {
        #expect(BedrockModel.openai_gpt_oss_20b.hasConverseModality())
    }

    @Test("GPT 5.5 is resolvable from rawValue")
    func gpt55RawValue() {
        let model = BedrockModel(rawValue: "openai.gpt-5.5")
        #expect(model != nil)
        #expect(model?.name == "OpenAI GPT 5.5")
    }

    @Test("GPT 5.4 is resolvable from rawValue")
    func gpt54RawValue() {
        let model = BedrockModel(rawValue: "openai.gpt-5.4")
        #expect(model != nil)
        #expect(model?.name == "OpenAI GPT 5.4")
    }
}
