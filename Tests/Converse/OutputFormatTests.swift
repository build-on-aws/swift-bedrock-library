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

@Suite("OutputFormat Tests")
struct OutputFormatTests {

    // MARK: - Successful creation with valid JSON value and valid name

    @Test("Create OutputFormat with valid JSON schema and valid name")
    func createWithValidJSONAndName() throws {
        let schema = JSON(
            with: .object([
                "type": .string("object"),
                "properties": .object([
                    "name": .object(["type": .string("string")])
                ]),
            ])
        )

        let outputFormat = try OutputFormat(schema: schema, name: "test_schema")

        #expect(outputFormat.name == "test_schema")
        #expect(outputFormat.description == nil)
        #expect(outputFormat.schema["type"] == "object")
    }

    @Test("Create OutputFormat with name containing hyphens and underscores")
    func createWithHyphensAndUnderscores() throws {
        let schema = JSON(with: .object(["type": .string("object")]))

        let outputFormat = try OutputFormat(schema: schema, name: "my-schema_v2")

        #expect(outputFormat.name == "my-schema_v2")
    }

    @Test("Create OutputFormat with alphanumeric name")
    func createWithAlphanumericName() throws {
        let schema = JSON(with: .object(["type": .string("object")]))

        let outputFormat = try OutputFormat(schema: schema, name: "Schema123")

        #expect(outputFormat.name == "Schema123")
    }

    // MARK: - Creation with and without description

    @Test("Create OutputFormat with description")
    func createWithDescription() throws {
        let schema = JSON(with: .object(["type": .string("object")]))

        let outputFormat = try OutputFormat(
            schema: schema,
            name: "person_info",
            description: "A schema for person information"
        )

        #expect(outputFormat.name == "person_info")
        #expect(outputFormat.description == "A schema for person information")
    }

    @Test("Create OutputFormat without description")
    func createWithoutDescription() throws {
        let schema = JSON(with: .object(["type": .string("object")]))

        let outputFormat = try OutputFormat(schema: schema, name: "person_info")

        #expect(outputFormat.description == nil)
    }

    // MARK: - Creation from JSON string

    @Test("Create OutputFormat from valid JSON string")
    func createFromValidJSONString() throws {
        let schemaString = """
            {
                "type": "object",
                "properties": {
                    "name": { "type": "string" },
                    "age": { "type": "integer" }
                },
                "required": ["name", "age"]
            }
            """

        let outputFormat = try OutputFormat(schema: schemaString, name: "person_schema")

        #expect(outputFormat.name == "person_schema")
        #expect(outputFormat.schema["type"] == "object")
    }

    // MARK: - Failure for null JSON schema

    @Test("Fail creation with null JSON schema")
    func failWithNullSchema() throws {
        let nullSchema = JSON(with: .null)

        #expect(throws: BedrockLibraryError.self) {
            let _ = try OutputFormat(schema: nullSchema, name: "test_schema")
        }
    }

    @Test("Fail creation with null JSON schema throws .invalid error")
    func failWithNullSchemaThrowsInvalid() throws {
        let nullSchema = JSON(with: .null)

        #expect {
            try OutputFormat(schema: nullSchema, name: "test_schema")
        } throws: { error in
            guard let bedrockError = error as? BedrockLibraryError else { return false }
            return bedrockError == BedrockLibraryError.invalid("OutputFormat schema must not be null")
        }
    }

    // MARK: - Failure for invalid JSON string

    @Test("Fail creation with invalid JSON string")
    func failWithInvalidJSONString() throws {
        let invalidJSON = "{ this is not valid json }"

        #expect(throws: BedrockLibraryError.self) {
            let _ = try OutputFormat(schema: invalidJSON, name: "test_schema")
        }
    }

    @Test("Fail creation with invalid JSON string throws decodingError")
    func failWithInvalidJSONStringThrowsDecodingError() throws {
        let invalidJSON = "{ not valid json"

        #expect {
            try OutputFormat(schema: invalidJSON, name: "test_schema")
        } throws: { error in
            guard let bedrockError = error as? BedrockLibraryError else { return false }
            return bedrockError == BedrockLibraryError.decodingError("")
        }
    }

    // MARK: - Failure for empty name

    @Test("Fail creation with empty name")
    func failWithEmptyName() throws {
        let schema = JSON(with: .object(["type": .string("object")]))

        #expect(throws: BedrockLibraryError.self) {
            let _ = try OutputFormat(schema: schema, name: "")
        }
    }

    @Test("Fail creation with empty name throws invalidName error")
    func failWithEmptyNameThrowsInvalidName() throws {
        let schema = JSON(with: .object(["type": .string("object")]))

        #expect {
            try OutputFormat(schema: schema, name: "")
        } throws: { error in
            guard let bedrockError = error as? BedrockLibraryError else { return false }
            return bedrockError == BedrockLibraryError.invalidName("")
        }
    }

    // MARK: - Failure for name with invalid characters

    @Test("Fail creation with name containing only special characters")
    func failWithSpecialCharsOnlyName() throws {
        let schema = JSON(with: .object(["type": .string("object")]))

        #expect(throws: BedrockLibraryError.self) {
            let _ = try OutputFormat(schema: schema, name: "!!!")
        }
    }

    @Test("Fail creation with name containing only dots")
    func failWithDotsOnlyName() throws {
        let schema = JSON(with: .object(["type": .string("object")]))

        #expect(throws: BedrockLibraryError.self) {
            let _ = try OutputFormat(schema: schema, name: "...")
        }
    }

    @Test("Fail creation with name containing only spaces")
    func failWithSpacesOnlyName() throws {
        let schema = JSON(with: .object(["type": .string("object")]))

        #expect(throws: BedrockLibraryError.self) {
            let _ = try OutputFormat(schema: schema, name: "   ")
        }
    }

    // MARK: - getSDKOutputFormat() tests

    @Test("getSDKOutputFormat returns SDK type with .jsonSchema type")
    func sdkOutputFormatHasJsonSchemaType() throws {
        let schema = JSON(
            with: .object([
                "type": .string("object"),
                "properties": .object([
                    "name": .object(["type": .string("string")])
                ]),
            ])
        )

        let outputFormat = try OutputFormat(schema: schema, name: "test_schema")
        let sdkFormat = try outputFormat.getSDKOutputFormat()

        #expect(sdkFormat.type == .jsonSchema)
    }

    @Test("getSDKOutputFormat schema string round-trips correctly")
    func sdkOutputFormatSchemaRoundTrips() throws {
        let schema = JSON(
            with: .object([
                "type": .string("object"),
                "properties": .object([
                    "name": .object(["type": .string("string")]),
                    "age": .object(["type": .string("integer")]),
                ]),
                "required": .array([.string("name"), .string("age")]),
            ])
        )

        let outputFormat = try OutputFormat(schema: schema, name: "person_schema")
        let sdkFormat = try outputFormat.getSDKOutputFormat()

        // Extract the schema string from the SDK structure
        guard case .jsonschema(let definition) = sdkFormat.structure else {
            Issue.record("Expected .jsonschema structure")
            return
        }

        let schemaString = try #require(definition.schema)

        // Parse the schema string back to JSON and verify it matches the original
        let parsedBack = try JSON(from: schemaString)
        #expect(parsedBack["type"] == "object")
        #expect(parsedBack["required"] != nil)
    }

    @Test("getSDKOutputFormat sets name correctly")
    func sdkOutputFormatSetsName() throws {
        let schema = JSON(with: .object(["type": .string("object")]))

        let outputFormat = try OutputFormat(schema: schema, name: "my-schema_v2")
        let sdkFormat = try outputFormat.getSDKOutputFormat()

        guard case .jsonschema(let definition) = sdkFormat.structure else {
            Issue.record("Expected .jsonschema structure")
            return
        }

        #expect(definition.name == "my-schema_v2")
    }

    @Test("getSDKOutputFormat sets description correctly")
    func sdkOutputFormatSetsDescription() throws {
        let schema = JSON(with: .object(["type": .string("object")]))

        let outputFormat = try OutputFormat(
            schema: schema,
            name: "test_schema",
            description: "A test schema description"
        )
        let sdkFormat = try outputFormat.getSDKOutputFormat()

        guard case .jsonschema(let definition) = sdkFormat.structure else {
            Issue.record("Expected .jsonschema structure")
            return
        }

        #expect(definition.description == "A test schema description")
    }

    @Test("getSDKOutputFormat sets nil description when not provided")
    func sdkOutputFormatNilDescription() throws {
        let schema = JSON(with: .object(["type": .string("object")]))

        let outputFormat = try OutputFormat(schema: schema, name: "test_schema")
        let sdkFormat = try outputFormat.getSDKOutputFormat()

        guard case .jsonschema(let definition) = sdkFormat.structure else {
            Issue.record("Expected .jsonschema structure")
            return
        }

        #expect(definition.description == nil)
    }
}
