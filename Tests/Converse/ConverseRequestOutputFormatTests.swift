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

@preconcurrency import AWSBedrockRuntime
@testable import BedrockService

@Suite("ConverseRequest OutputFormat Propagation Tests")
struct ConverseRequestOutputFormatTests {

    // MARK: - getConverseInput includes outputFormat when set

    @Test("getConverseInput includes outputConfig when outputFormat is set")
    func getConverseInputIncludesOutputFormat() throws {
        let schema = JSON(with: .object([
            "type": .string("object"),
            "properties": .object([
                "name": .object(["type": .string("string")])
            ])
        ]))
        let outputFormat = try OutputFormat(schema: schema, name: "test_schema", description: "A test")

        let message = Message("Hello")
        let history = History(message)

        let request = ConverseRequest(
            model: .claudev3_5_sonnet,
            messages: history,
            maxTokens: nil,
            temperature: nil,
            topP: nil,
            stopSequences: nil,
            systemPrompts: nil,
            tools: nil,
            maxReasoningTokens: nil,
            serviceTier: .default,
            outputFormat: outputFormat
        )

        let input = try request.getConverseInput(forRegion: .useast1)

        #expect(input.outputConfig != nil)
        #expect(input.outputConfig?.textFormat != nil)
        #expect(input.outputConfig?.textFormat?.type == .jsonSchema)
    }

    @Test("getConverseInput outputConfig contains correct schema name and description")
    func getConverseInputOutputFormatDetails() throws {
        let schema = JSON(with: .object([
            "type": .string("object"),
            "properties": .object([
                "age": .object(["type": .string("integer")])
            ])
        ]))
        let outputFormat = try OutputFormat(schema: schema, name: "age_schema", description: "Age extraction")

        let message = Message("Extract age")
        let history = History(message)

        let request = ConverseRequest(
            model: .claudev3_5_sonnet,
            messages: history,
            maxTokens: nil,
            temperature: nil,
            topP: nil,
            stopSequences: nil,
            systemPrompts: nil,
            tools: nil,
            maxReasoningTokens: nil,
            serviceTier: .default,
            outputFormat: outputFormat
        )

        let input = try request.getConverseInput(forRegion: .useast1)

        let sdkOutputFormat = input.outputConfig?.textFormat
        #expect(sdkOutputFormat != nil)

        if case .jsonschema(let definition) = sdkOutputFormat?.structure {
            #expect(definition.name == "age_schema")
            #expect(definition.description == "Age extraction")
            #expect(definition.schema != nil)
        } else {
            Issue.record("Expected .jsonschema structure")
        }
    }

    // MARK: - getConverseInput has nil outputFormat when not set

    @Test("getConverseInput has nil outputConfig when outputFormat is not set")
    func getConverseInputNilOutputFormat() throws {
        let message = Message("Hello")
        let history = History(message)

        let request = ConverseRequest(
            model: .claudev3_5_sonnet,
            messages: history,
            maxTokens: nil,
            temperature: nil,
            topP: nil,
            stopSequences: nil,
            systemPrompts: nil,
            tools: nil,
            maxReasoningTokens: nil,
            serviceTier: .default,
            outputFormat: nil
        )

        let input = try request.getConverseInput(forRegion: .useast1)

        #expect(input.outputConfig == nil)
    }

    @Test("getConverseInput has nil outputConfig when outputFormat defaults to nil")
    func getConverseInputDefaultNilOutputFormat() throws {
        let message = Message("Hello")
        let history = History(message)

        let request = ConverseRequest(
            model: .claudev3_5_sonnet,
            messages: history,
            maxTokens: nil,
            temperature: nil,
            topP: nil,
            stopSequences: nil,
            systemPrompts: nil,
            tools: nil,
            maxReasoningTokens: nil,
            serviceTier: .default
        )

        let input = try request.getConverseInput(forRegion: .useast1)

        #expect(input.outputConfig == nil)
    }

    // MARK: - Streaming input includes outputFormat when set

    @Test("getConverseStreamingInput includes outputConfig when outputFormat is set")
    func getConverseStreamingInputIncludesOutputFormat() throws {
        let schema = JSON(with: .object([
            "type": .string("object"),
            "properties": .object([
                "items": .object(["type": .string("array")])
            ])
        ]))
        let outputFormat = try OutputFormat(schema: schema, name: "items_schema")

        let message = Message("List items")
        let history = History(message)

        let request = ConverseRequest(
            model: .claudev3_5_sonnet,
            messages: history,
            maxTokens: nil,
            temperature: nil,
            topP: nil,
            stopSequences: nil,
            systemPrompts: nil,
            tools: nil,
            maxReasoningTokens: nil,
            serviceTier: .default,
            outputFormat: outputFormat
        )

        let streamInput = try request.getConverseStreamingInput(forRegion: .useast1)

        #expect(streamInput.outputConfig != nil)
        #expect(streamInput.outputConfig?.textFormat != nil)
        #expect(streamInput.outputConfig?.textFormat?.type == .jsonSchema)
    }

    @Test("getConverseStreamingInput outputConfig contains correct schema details")
    func getConverseStreamingInputOutputFormatDetails() throws {
        let schema = JSON(with: .object([
            "type": .string("object"),
            "properties": .object([
                "result": .object(["type": .string("string")])
            ])
        ]))
        let outputFormat = try OutputFormat(schema: schema, name: "stream_schema", description: "Streaming test")

        let message = Message("Stream this")
        let history = History(message)

        let request = ConverseRequest(
            model: .claudev3_5_sonnet,
            messages: history,
            maxTokens: nil,
            temperature: nil,
            topP: nil,
            stopSequences: nil,
            systemPrompts: nil,
            tools: nil,
            maxReasoningTokens: nil,
            serviceTier: .default,
            outputFormat: outputFormat
        )

        let streamInput = try request.getConverseStreamingInput(forRegion: .useast1)

        let sdkOutputFormat = streamInput.outputConfig?.textFormat
        #expect(sdkOutputFormat != nil)

        if case .jsonschema(let definition) = sdkOutputFormat?.structure {
            #expect(definition.name == "stream_schema")
            #expect(definition.description == "Streaming test")
            #expect(definition.schema != nil)
        } else {
            Issue.record("Expected .jsonschema structure")
        }
    }

    @Test("getConverseStreamingInput has nil outputConfig when outputFormat is not set")
    func getConverseStreamingInputNilOutputFormat() throws {
        let message = Message("Hello")
        let history = History(message)

        let request = ConverseRequest(
            model: .claudev3_5_sonnet,
            messages: history,
            maxTokens: nil,
            temperature: nil,
            topP: nil,
            stopSequences: nil,
            systemPrompts: nil,
            tools: nil,
            maxReasoningTokens: nil,
            serviceTier: .default,
            outputFormat: nil
        )

        let streamInput = try request.getConverseStreamingInput(forRegion: .useast1)

        #expect(streamInput.outputConfig == nil)
    }
}
