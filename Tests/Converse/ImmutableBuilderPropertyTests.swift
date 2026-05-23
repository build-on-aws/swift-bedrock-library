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

/// **Validates: Requirements 4.6, 4.7**
///
/// Property 7: Immutable Builder
/// For any builder and valid OutputFormat, calling `withOutputFormat` returns a new builder
/// with the format set, and the original builder remains unchanged
@Suite("Immutable Builder Property Tests")
struct ImmutableBuilderPropertyTests {

    // MARK: - Custom Generators

    /// Characters allowed in OutputFormat names: [a-zA-Z0-9_-]
    private static let validNameCharacters = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-")

    /// Generates a random valid name matching pattern [a-zA-Z0-9_-]+
    private static func generateValidName() -> String {
        let length = Int.random(in: 1...40)
        return String((0..<length).map { _ in validNameCharacters.randomElement()! })
    }

    /// Generates a random optional description
    private static func generateDescription() -> String? {
        guard Bool.random() else { return nil }
        let words = [
            "extraction", "schema", "output", "format", "data", "result", "response", "model", "test", "config",
        ]
        let wordCount = Int.random(in: 1...5)
        return (0..<wordCount).map { _ in words.randomElement()! }.joined(separator: " ")
    }

    /// Generates a random valid JSON schema as a JSON value
    private static func generateValidJSONSchema() -> JSON {
        let propertyTypes = ["string", "integer", "number", "boolean"]
        let propertyCount = Int.random(in: 0...6)

        var properties: [String: JSONValue] = [:]
        var propertyNames: [String] = []

        for i in 0..<propertyCount {
            let propName = "field_\(i)_\(generateValidName().prefix(6))"
            let propType = propertyTypes.randomElement()!
            properties[propName] = .object(["type": .string(propType)])
            propertyNames.append(propName)
        }

        var schemaObject: [String: JSONValue] = [
            "type": .string("object")
        ]

        if !properties.isEmpty {
            schemaObject["properties"] = .object(properties)

            // Randomly add required fields
            if !propertyNames.isEmpty && Bool.random() {
                let requiredCount = Int.random(in: 1...propertyNames.count)
                let required = Array(propertyNames.shuffled().prefix(requiredCount))
                schemaObject["required"] = .array(required.map { .string($0) })
            }
        }

        // Randomly add additionalProperties: false
        if Bool.random() {
            schemaObject["additionalProperties"] = .bool(false)
        }

        return JSON(with: .object(schemaObject))
    }

    /// Generates a random valid OutputFormat instance
    private static func generateValidOutputFormat() throws -> OutputFormat {
        let schema = generateValidJSONSchema()
        let name = generateValidName()
        let description = generateDescription()
        return try OutputFormat(schema: schema, name: name, description: description)
    }

    // MARK: - Property Tests

    @Test("Property: withOutputFormat returns new builder with format set, original remains unchanged")
    func immutableBuilderProperty() throws {
        let iterations = 100

        for _ in 0..<iterations {
            let outputFormat = try Self.generateValidOutputFormat()

            // Create a builder for a model that supports structured output
            let originalBuilder = try ConverseRequestBuilder(with: .claudev3_5_sonnet)

            // Verify original has no outputFormat
            #expect(
                originalBuilder.outputFormat == nil,
                "Original builder should have nil outputFormat before calling withOutputFormat"
            )

            // Call withOutputFormat
            let newBuilder = try originalBuilder.withOutputFormat(outputFormat)

            // Assert: the returned builder has the outputFormat set
            #expect(
                newBuilder.outputFormat != nil,
                "New builder should have outputFormat set after calling withOutputFormat"
            )
            #expect(
                newBuilder.outputFormat?.name == outputFormat.name,
                "New builder's outputFormat name should match the provided format's name '\(outputFormat.name)'"
            )
            #expect(
                newBuilder.outputFormat?.description == outputFormat.description,
                "New builder's outputFormat description should match the provided format's description"
            )

            // Assert: the original builder's outputFormat remains nil (unchanged)
            #expect(
                originalBuilder.outputFormat == nil,
                "Original builder's outputFormat should remain nil after calling withOutputFormat, but got name: \(originalBuilder.outputFormat?.name ?? "nil")"
            )
        }
    }

    @Test("Property: withOutputFormat preserves immutability when original builder has a prompt set")
    func immutableBuilderWithPromptProperty() throws {
        let iterations = 100

        for _ in 0..<iterations {
            let outputFormat = try Self.generateValidOutputFormat()

            // Create a builder with a prompt already set
            let originalBuilder = try ConverseRequestBuilder(with: .claudev3_5_sonnet)
                .withPrompt("Test prompt for property testing")

            // Verify original state
            #expect(originalBuilder.outputFormat == nil)
            #expect(originalBuilder.prompt == "Test prompt for property testing")

            // Call withOutputFormat
            let newBuilder = try originalBuilder.withOutputFormat(outputFormat)

            // Assert: new builder has the format set and retains the prompt
            #expect(newBuilder.outputFormat != nil)
            #expect(newBuilder.outputFormat?.name == outputFormat.name)
            #expect(newBuilder.prompt == "Test prompt for property testing")

            // Assert: original builder remains unchanged
            #expect(
                originalBuilder.outputFormat == nil,
                "Original builder's outputFormat should remain nil, but got name: \(originalBuilder.outputFormat?.name ?? "nil")"
            )
            #expect(originalBuilder.prompt == "Test prompt for property testing")
        }
    }

    @Test("Property: chaining withOutputFormat multiple times preserves immutability of intermediate builders")
    func immutableBuilderChainingProperty() throws {
        let iterations = 50

        for _ in 0..<iterations {
            let format1 = try Self.generateValidOutputFormat()
            let format2 = try Self.generateValidOutputFormat()

            let baseBuilder = try ConverseRequestBuilder(with: .claudev3_5_sonnet)
            let builder1 = try baseBuilder.withOutputFormat(format1)
            let builder2 = try builder1.withOutputFormat(format2)

            // Assert: base builder remains unchanged
            #expect(
                baseBuilder.outputFormat == nil,
                "Base builder should remain nil after chaining withOutputFormat calls"
            )

            // Assert: builder1 retains format1
            #expect(
                builder1.outputFormat?.name == format1.name,
                "First intermediate builder should retain its own format '\(format1.name)', but got '\(builder1.outputFormat?.name ?? "nil")'"
            )

            // Assert: builder2 has format2
            #expect(
                builder2.outputFormat?.name == format2.name,
                "Final builder should have the last format '\(format2.name)', but got '\(builder2.outputFormat?.name ?? "nil")'"
            )
        }
    }
}
