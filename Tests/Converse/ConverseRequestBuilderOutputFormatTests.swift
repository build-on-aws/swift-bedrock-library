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

@Suite("ConverseRequestBuilder OutputFormat Tests")
struct ConverseRequestBuilderOutputFormatTests {

    // MARK: - withOutputFormat stores the format on a supported model

    @Test("withOutputFormat stores the format on a supported model")
    func withOutputFormatStoresFormat() throws {
        let schema = JSON(with: .object([
            "type": .string("object"),
            "properties": .object([
                "name": .object(["type": .string("string")])
            ])
        ]))

        let outputFormat = try OutputFormat(schema: schema, name: "test_schema", description: "A test schema")

        let builder = try ConverseRequestBuilder(with: .claudev3_5_sonnet)
            .withOutputFormat(outputFormat)

        #expect(builder.outputFormat != nil)
        #expect(builder.outputFormat?.name == "test_schema")
        #expect(builder.outputFormat?.description == "A test schema")
    }

    @Test("withOutputFormat convenience with JSON schema stores the format")
    func withOutputFormatConvenienceJSON() throws {
        let schema = JSON(with: .object([
            "type": .string("object"),
            "properties": .object([
                "age": .object(["type": .string("integer")])
            ])
        ]))

        let builder = try ConverseRequestBuilder(with: .claudev3_5_sonnet)
            .withOutputFormat(schema: schema, name: "age_schema", description: "Age extraction")

        #expect(builder.outputFormat != nil)
        #expect(builder.outputFormat?.name == "age_schema")
        #expect(builder.outputFormat?.description == "Age extraction")
    }

    @Test("withOutputFormat convenience with String schema stores the format")
    func withOutputFormatConvenienceString() throws {
        let schemaString = """
            {
                "type": "object",
                "properties": {
                    "name": { "type": "string" }
                }
            }
            """

        let builder = try ConverseRequestBuilder(with: .claudev3_5_sonnet)
            .withOutputFormat(schema: schemaString, name: "name_schema")

        #expect(builder.outputFormat != nil)
        #expect(builder.outputFormat?.name == "name_schema")
        #expect(builder.outputFormat?.description == nil)
    }

    // MARK: - withOutputFormat throws on unsupported model

    @Test("withOutputFormat throws invalidModality on unsupported model")
    func withOutputFormatThrowsOnUnsupportedModel() throws {
        let schema = JSON(with: .object(["type": .string("object")]))
        let outputFormat = try OutputFormat(schema: schema, name: "test_schema")

        #expect(throws: BedrockLibraryError.self) {
            let _ = try ConverseRequestBuilder(with: .nova_micro)
                .withOutputFormat(outputFormat)
        }
    }

    @Test("withOutputFormat throws specific invalidModality error on unsupported model")
    func withOutputFormatThrowsSpecificError() throws {
        let schema = JSON(with: .object(["type": .string("object")]))
        let outputFormat = try OutputFormat(schema: schema, name: "test_schema")

        #expect {
            try ConverseRequestBuilder(with: .nova_micro)
                .withOutputFormat(outputFormat)
        } throws: { error in
            guard let bedrockError = error as? BedrockLibraryError else { return false }
            if case .invalidModality(_, _, _) = bedrockError {
                return true
            }
            return false
        }
    }

    // MARK: - Builder immutability

    @Test("withOutputFormat does not mutate the original builder")
    func withOutputFormatImmutability() throws {
        let schema = JSON(with: .object(["type": .string("object")]))
        let outputFormat = try OutputFormat(schema: schema, name: "test_schema")

        let originalBuilder = try ConverseRequestBuilder(with: .claudev3_5_sonnet)

        #expect(originalBuilder.outputFormat == nil)

        let newBuilder = try originalBuilder.withOutputFormat(outputFormat)

        // Original builder remains unchanged
        #expect(originalBuilder.outputFormat == nil)
        // New builder has the format set
        #expect(newBuilder.outputFormat != nil)
        #expect(newBuilder.outputFormat?.name == "test_schema")
    }

    @Test("withOutputFormat does not mutate original builder with prompt set")
    func withOutputFormatImmutabilityWithPrompt() throws {
        let schema = JSON(with: .object(["type": .string("object")]))
        let outputFormat = try OutputFormat(schema: schema, name: "test_schema")

        let originalBuilder = try ConverseRequestBuilder(with: .claudev3_5_sonnet)
            .withPrompt("Extract data")

        #expect(originalBuilder.outputFormat == nil)
        #expect(originalBuilder.prompt == "Extract data")

        let newBuilder = try originalBuilder.withOutputFormat(outputFormat)

        // Original builder remains unchanged
        #expect(originalBuilder.outputFormat == nil)
        #expect(originalBuilder.prompt == "Extract data")
        // New builder has both prompt and format
        #expect(newBuilder.outputFormat != nil)
        #expect(newBuilder.prompt == "Extract data")
    }

    // MARK: - init(from:) preserves outputFormat

    @Test("init(from:) preserves outputFormat from source builder")
    func initFromPreservesOutputFormat() throws {
        let schema = JSON(with: .object([
            "type": .string("object"),
            "properties": .object([
                "name": .object(["type": .string("string")])
            ])
        ]))
        let outputFormat = try OutputFormat(schema: schema, name: "preserved_schema", description: "Should be preserved")

        let sourceBuilder = try ConverseRequestBuilder(with: .claudev3_5_sonnet)
            .withPrompt("Test prompt")
            .withOutputFormat(outputFormat)

        let copiedBuilder = try ConverseRequestBuilder(from: sourceBuilder)

        #expect(copiedBuilder.outputFormat != nil)
        #expect(copiedBuilder.outputFormat?.name == "preserved_schema")
        #expect(copiedBuilder.outputFormat?.description == "Should be preserved")
    }

    @Test("init(from:) preserves nil outputFormat from source builder")
    func initFromPreservesNilOutputFormat() throws {
        let sourceBuilder = try ConverseRequestBuilder(with: .claudev3_5_sonnet)
            .withPrompt("Test prompt")

        let copiedBuilder = try ConverseRequestBuilder(from: sourceBuilder)

        #expect(copiedBuilder.outputFormat == nil)
    }

    // MARK: - Multiple withOutputFormat calls use the last one

    @Test("Multiple withOutputFormat calls use the last one")
    func multipleWithOutputFormatUsesLast() throws {
        let schema1 = JSON(with: .object([
            "type": .string("object"),
            "properties": .object([
                "name": .object(["type": .string("string")])
            ])
        ]))
        let schema2 = JSON(with: .object([
            "type": .string("object"),
            "properties": .object([
                "age": .object(["type": .string("integer")])
            ])
        ]))

        let format1 = try OutputFormat(schema: schema1, name: "first_schema", description: "First")
        let format2 = try OutputFormat(schema: schema2, name: "second_schema", description: "Second")

        let builder = try ConverseRequestBuilder(with: .claudev3_5_sonnet)
            .withOutputFormat(format1)
            .withOutputFormat(format2)

        #expect(builder.outputFormat?.name == "second_schema")
        #expect(builder.outputFormat?.description == "Second")
    }

    @Test("Multiple withOutputFormat calls - intermediate builders retain their own format")
    func multipleWithOutputFormatIntermediateBuilders() throws {
        let schema1 = JSON(with: .object(["type": .string("object")]))
        let schema2 = JSON(with: .object(["type": .string("array")]))

        let format1 = try OutputFormat(schema: schema1, name: "first_schema")
        let format2 = try OutputFormat(schema: schema2, name: "second_schema")

        let builder1 = try ConverseRequestBuilder(with: .claudev3_5_sonnet)
            .withOutputFormat(format1)

        let builder2 = try builder1.withOutputFormat(format2)

        // builder1 retains its own format
        #expect(builder1.outputFormat?.name == "first_schema")
        // builder2 has the new format
        #expect(builder2.outputFormat?.name == "second_schema")
    }
}
