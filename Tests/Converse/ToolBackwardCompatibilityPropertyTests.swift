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

/// **Validates: Requirements 3.2, 3.4, 3.5**
///
/// Property 1: Backward Compatibility
/// For any valid tool name and schema, creating a Tool without the strict parameter
/// results in `strict == false` and `getSDKToolSpecification().strict == nil`
@Suite("Tool Backward Compatibility Property Tests")
struct ToolBackwardCompatibilityPropertyTests {

    // MARK: - Custom Generators

    /// Characters allowed in tool names: [a-zA-Z0-9_-]
    private static let validNameCharacters = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-")

    /// Generates a random valid tool name matching pattern [a-zA-Z0-9_-]+
    private static func generateValidToolName() -> String {
        let length = Int.random(in: 1...50)
        return String((0..<length).map { _ in validNameCharacters.randomElement()! })
    }

    /// Generates a random valid JSON schema as a JSON value
    private static func generateValidJSONSchema() -> JSON {
        let propertyTypes = ["string", "integer", "number", "boolean"]
        let propertyCount = Int.random(in: 0...5)

        var properties: [String: JSONValue] = [:]
        var propertyNames: [String] = []

        for i in 0..<propertyCount {
            let propName = "prop_\(i)_\(generateValidToolName().prefix(8))"
            let propType = propertyTypes.randomElement()!
            properties[propName] = .object(["type": .string(propType)])
            propertyNames.append(propName)
        }

        var schemaObject: [String: JSONValue] = [
            "type": .string("object")
        ]

        if !properties.isEmpty {
            schemaObject["properties"] = .object(properties)

            // Randomly add some required fields
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

    // MARK: - Property Test

    @Test("Property: Tool without strict parameter has strict == false and SDK strict == nil")
    func backwardCompatibilityProperty() throws {
        // Run the property across many random inputs
        let iterations = 100

        for _ in 0..<iterations {
            let name = Self.generateValidToolName()
            let schema = Self.generateValidJSONSchema()

            // Create a Tool WITHOUT the strict parameter (backward-compatible usage)
            let tool = try Tool(
                name: name,
                inputSchema: schema,
                description: "Auto-generated tool for property testing"
            )

            // Assert: strict defaults to false
            #expect(
                tool.strict == false,
                "Tool created without strict parameter should have strict == false, but got true for name: \(name)"
            )

            // Assert: SDK specification has strict == nil
            let spec = try tool.getSDKToolSpecification()
            #expect(
                spec.strict == nil,
                "Tool created without strict parameter should have SDK strict == nil, but got \(String(describing: spec.strict)) for name: \(name)"
            )
        }
    }

    @Test("Property: Tool without strict parameter preserves name and description")
    func backwardCompatibilityPreservesFields() throws {
        let iterations = 100

        for _ in 0..<iterations {
            let name = Self.generateValidToolName()
            let schema = Self.generateValidJSONSchema()
            let description = Bool.random() ? "Description for \(name)" : nil

            let tool = try Tool(
                name: name,
                inputSchema: schema,
                description: description
            )

            // Verify backward-compatible behavior: fields are preserved correctly
            #expect(tool.name == name)
            #expect(tool.toolDescription == description)
            #expect(tool.strict == false)

            let spec = try tool.getSDKToolSpecification()
            #expect(spec.name == name)
            #expect(spec.description == description)
            #expect(spec.strict == nil)
        }
    }
}
