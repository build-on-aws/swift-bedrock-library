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

@preconcurrency import AWSBedrockRuntime
import Foundation
import Testing

@testable import BedrockService

/// **Validates: Requirements 1.2, 1.3, 2.2**
///
/// Property 2: Schema Preservation
/// For any valid JSON schema and valid name, `OutputFormat(schema:name:).getSDKOutputFormat()`
/// produces a JsonSchemaDefinition whose schema string, when parsed back, is semantically
/// equivalent to the original.
@Suite("Schema Preservation Property Tests")
struct SchemaPreservationPropertyTests {

    // MARK: - Custom Generators

    /// Characters allowed in OutputFormat names: [a-zA-Z0-9_-]
    private static let validNameCharacters = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-")

    /// Generates a random valid name matching pattern [a-zA-Z0-9_-]+
    private static func generateValidName() -> String {
        let length = Int.random(in: 1...40)
        return String((0..<length).map { _ in validNameCharacters.randomElement()! })
    }

    /// Generates a random valid JSON schema with varying complexity
    private static func generateValidJSONSchema() -> JSON {
        let propertyTypes = ["string", "integer", "number", "boolean"]
        let propertyCount = Int.random(in: 0...8)

        var properties: [String: JSONValue] = [:]
        var propertyNames: [String] = []

        for i in 0..<propertyCount {
            let propName = "prop_\(i)_\(String(generateValidName().prefix(6)))"
            let propType = propertyTypes.randomElement()!

            var propSchema: [String: JSONValue] = ["type": .string(propType)]

            // Randomly add extra constraints
            if propType == "string" && Bool.random() {
                propSchema["minLength"] = .int(Int.random(in: 0...10))
            }
            if propType == "integer" && Bool.random() {
                propSchema["minimum"] = .int(Int.random(in: 0...100))
            }
            if propType == "number" && Bool.random() {
                propSchema["maximum"] = .double(Double.random(in: 0...1000))
            }

            properties[propName] = .object(propSchema)
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

        // Randomly add a description
        if Bool.random() {
            schemaObject["description"] = .string("Generated schema \(Int.random(in: 1...999))")
        }

        // Randomly add a title
        if Bool.random() {
            schemaObject["title"] = .string("Schema_\(Int.random(in: 1...999))")
        }

        return JSON(with: .object(schemaObject))
    }

    /// Generates a schema with nested objects for deeper structure testing
    private static func generateNestedJSONSchema() -> JSON {
        let innerProperties: [String: JSONValue] = [
            "street": .object(["type": .string("string")]),
            "city": .object(["type": .string("string")]),
            "zip": .object(["type": .string("string")])
        ]

        let innerSchema: [String: JSONValue] = [
            "type": .string("object"),
            "properties": .object(innerProperties),
            "required": .array([.string("street"), .string("city")])
        ]

        let outerProperties: [String: JSONValue] = [
            "name": .object(["type": .string("string")]),
            "age": .object(["type": .string("integer")]),
            "address": .object(innerSchema)
        ]

        let schemaObject: [String: JSONValue] = [
            "type": .string("object"),
            "properties": .object(outerProperties),
            "required": .array([.string("name")]),
            "additionalProperties": .bool(false)
        ]

        return JSON(with: .object(schemaObject))
    }

    /// Generates a schema with array types
    private static func generateArrayJSONSchema() -> JSON {
        let itemTypes = ["string", "integer", "number", "boolean"]
        let itemType = itemTypes.randomElement()!

        var itemsSchema: [String: JSONValue] = ["type": .string(itemType)]
        if itemType == "string" && Bool.random() {
            itemsSchema["enum"] = .array([.string("a"), .string("b"), .string("c")])
        }

        let arrayProp: [String: JSONValue] = [
            "type": .string("array"),
            "items": .object(itemsSchema)
        ]

        let schemaObject: [String: JSONValue] = [
            "type": .string("object"),
            "properties": .object([
                "items_list": .object(arrayProp),
                "count": .object(["type": .string("integer")])
            ]),
            "required": .array([.string("items_list")])
        ]

        return JSON(with: .object(schemaObject))
    }

    // MARK: - Semantic Equivalence Helper

    /// Compares two JSONValue instances for semantic equivalence.
    /// Objects are compared regardless of key ordering.
    /// Arrays are compared element-by-element in order.
    private static func isSemanticEqual(_ lhs: JSONValue, _ rhs: JSONValue) -> Bool {
        switch (lhs, rhs) {
        case (.null, .null):
            return true
        case (.int(let a), .int(let b)):
            return a == b
        case (.double(let a), .double(let b)):
            return a == b
        case (.int(let a), .double(let b)):
            return Double(a) == b
        case (.double(let a), .int(let b)):
            return a == Double(b)
        case (.string(let a), .string(let b)):
            return a == b
        case (.bool(let a), .bool(let b)):
            return a == b
        case (.array(let a), .array(let b)):
            guard a.count == b.count else { return false }
            return zip(a, b).allSatisfy { isSemanticEqual($0, $1) }
        case (.object(let a), .object(let b)):
            guard a.count == b.count else { return false }
            for (key, value) in a {
                guard let otherValue = b[key] else { return false }
                if !isSemanticEqual(value, otherValue) { return false }
            }
            return true
        default:
            return false
        }
    }

    // MARK: - Property Tests

    @Test("Property 2: Schema is preserved through OutputFormat -> getSDKOutputFormat() -> parse round-trip")
    func schemaPreservationProperty() throws {
        let iterations = 100

        for _ in 0..<iterations {
            let name = Self.generateValidName()
            let schema = Self.generateValidJSONSchema()

            // Create OutputFormat with the generated schema and name
            let outputFormat = try OutputFormat(schema: schema, name: name)

            // Convert to SDK format
            let sdkFormat = try outputFormat.getSDKOutputFormat()

            // Extract the schema string from the SDK structure
            guard case .jsonschema(let definition) = sdkFormat.structure else {
                Issue.record("Expected .jsonschema structure for name: \(name)")
                continue
            }

            let schemaString = try #require(
                definition.schema,
                "Schema string should not be nil for name: \(name)"
            )

            // Parse the schema string back to JSON
            let parsedBack = try JSON(from: schemaString)

            // Verify semantic equivalence
            #expect(
                Self.isSemanticEqual(schema.value, parsedBack.value),
                "Schema not preserved for name: \(name). Original: \(schema.value), Parsed back: \(parsedBack.value)"
            )
        }
    }

    @Test("Property 2: Nested schemas are preserved through the round-trip")
    func nestedSchemaPreservation() throws {
        let iterations = 50

        for _ in 0..<iterations {
            let name = Self.generateValidName()
            let schema = Self.generateNestedJSONSchema()

            let outputFormat = try OutputFormat(schema: schema, name: name)
            let sdkFormat = try outputFormat.getSDKOutputFormat()

            guard case .jsonschema(let definition) = sdkFormat.structure else {
                Issue.record("Expected .jsonschema structure for nested schema with name: \(name)")
                continue
            }

            let schemaString = try #require(definition.schema)
            let parsedBack = try JSON(from: schemaString)

            #expect(
                Self.isSemanticEqual(schema.value, parsedBack.value),
                "Nested schema not preserved for name: \(name)"
            )
        }
    }

    @Test("Property 2: Array schemas are preserved through the round-trip")
    func arraySchemaPreservation() throws {
        let iterations = 50

        for _ in 0..<iterations {
            let name = Self.generateValidName()
            let schema = Self.generateArrayJSONSchema()

            let outputFormat = try OutputFormat(schema: schema, name: name)
            let sdkFormat = try outputFormat.getSDKOutputFormat()

            guard case .jsonschema(let definition) = sdkFormat.structure else {
                Issue.record("Expected .jsonschema structure for array schema with name: \(name)")
                continue
            }

            let schemaString = try #require(definition.schema)
            let parsedBack = try JSON(from: schemaString)

            #expect(
                Self.isSemanticEqual(schema.value, parsedBack.value),
                "Array schema not preserved for name: \(name)"
            )
        }
    }

    @Test("Property 2: Name is preserved in the SDK output format")
    func namePreservation() throws {
        let iterations = 100

        for _ in 0..<iterations {
            let name = Self.generateValidName()
            let schema = Self.generateValidJSONSchema()

            let outputFormat = try OutputFormat(schema: schema, name: name)
            let sdkFormat = try outputFormat.getSDKOutputFormat()

            guard case .jsonschema(let definition) = sdkFormat.structure else {
                Issue.record("Expected .jsonschema structure for name: \(name)")
                continue
            }

            #expect(
                definition.name == name,
                "Name not preserved. Expected: \(name), Got: \(String(describing: definition.name))"
            )
        }
    }

    @Test("Property 2: Schema preservation works with string-initialized OutputFormat")
    func schemaPreservationFromString() throws {
        let iterations = 50

        for _ in 0..<iterations {
            let name = Self.generateValidName()
            let schema = Self.generateValidJSONSchema()

            // Serialize the schema to a JSON string first
            let encoder = JSONEncoder()
            let schemaData = try encoder.encode(schema)
            let schemaString = try #require(String(data: schemaData, encoding: .utf8))

            // Create OutputFormat from the string
            let outputFormat = try OutputFormat(schema: schemaString, name: name)

            // Convert to SDK format
            let sdkFormat = try outputFormat.getSDKOutputFormat()

            guard case .jsonschema(let definition) = sdkFormat.structure else {
                Issue.record("Expected .jsonschema structure for string-initialized schema with name: \(name)")
                continue
            }

            let resultSchemaString = try #require(definition.schema)
            let parsedBack = try JSON(from: resultSchemaString)

            // Verify semantic equivalence with the original schema
            #expect(
                Self.isSemanticEqual(schema.value, parsedBack.value),
                "Schema not preserved through string initialization for name: \(name)"
            )
        }
    }
}
