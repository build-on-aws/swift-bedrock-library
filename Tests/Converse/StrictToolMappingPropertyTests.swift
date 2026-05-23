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

/// **Validates: Requirements 3.3, 3.4**
///
/// Property 6: Strict Tool Mapping
/// For any Tool with `strict == true`, `getSDKToolSpecification().strict == true`;
/// for `strict == false`, `getSDKToolSpecification().strict == nil`
@Suite("Strict Tool Mapping Property Tests")
struct StrictToolMappingPropertyTests {

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

    // MARK: - Property Tests

    @Test("Property: Tool with strict == true maps to SDK strict == true")
    func strictTrueMapsToSDKTrue() throws {
        let iterations = 100

        for _ in 0..<iterations {
            let name = Self.generateValidToolName()
            let schema = Self.generateValidJSONSchema()

            let tool = try Tool(
                name: name,
                inputSchema: schema,
                description: "Auto-generated tool for property testing",
                strict: true
            )

            #expect(tool.strict == true, "Tool created with strict: true should have strict == true for name: \(name)")

            let spec = try tool.getSDKToolSpecification()
            #expect(spec.strict == true, "Tool with strict: true should have SDK strict == true, but got \(String(describing: spec.strict)) for name: \(name)")
        }
    }

    @Test("Property: Tool with strict == false maps to SDK strict == nil")
    func strictFalseMapsToSDKNil() throws {
        let iterations = 100

        for _ in 0..<iterations {
            let name = Self.generateValidToolName()
            let schema = Self.generateValidJSONSchema()

            let tool = try Tool(
                name: name,
                inputSchema: schema,
                description: "Auto-generated tool for property testing",
                strict: false
            )

            #expect(tool.strict == false, "Tool created with strict: false should have strict == false for name: \(name)")

            let spec = try tool.getSDKToolSpecification()
            #expect(spec.strict == nil, "Tool with strict: false should have SDK strict == nil, but got \(String(describing: spec.strict)) for name: \(name)")
        }
    }

    @Test("Property: Strict mapping is consistent for both values on same input")
    func strictMappingConsistentForBothValues() throws {
        let iterations = 100

        for _ in 0..<iterations {
            let name = Self.generateValidToolName()
            let schema = Self.generateValidJSONSchema()

            // Create tool with strict: true
            let strictTool = try Tool(
                name: name,
                inputSchema: schema,
                description: "Tool for consistency check",
                strict: true
            )

            // Create tool with strict: false using same name and schema
            let nonStrictTool = try Tool(
                name: name,
                inputSchema: schema,
                description: "Tool for consistency check",
                strict: false
            )

            let strictSpec = try strictTool.getSDKToolSpecification()
            let nonStrictSpec = try nonStrictTool.getSDKToolSpecification()

            // strict: true -> SDK strict == true
            #expect(strictSpec.strict == true, "strict: true tool should map to SDK strict == true for name: \(name)")

            // strict: false -> SDK strict == nil
            #expect(nonStrictSpec.strict == nil, "strict: false tool should map to SDK strict == nil for name: \(name)")

            // Both tools should have the same name in the SDK spec
            #expect(strictSpec.name == nonStrictSpec.name, "Both tools should have the same name in SDK spec")
        }
    }
}
