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

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// Represents the structured output configuration for the Converse API.
/// Encapsulates a JSON schema definition that constrains model output.
public struct OutputFormat: Codable, Sendable {
    /// The JSON schema that constrains the model's output
    public let schema: JSON
    /// A name identifying this schema (used for caching)
    public let name: String
    /// An optional description of what the schema represents
    public let description: String?

    /// Creates an OutputFormat with a JSON schema value.
    ///
    /// - Parameters:
    ///   - schema: A valid JSON value representing the schema. Must not be `.null`.
    ///   - name: A name for the schema matching `[a-zA-Z0-9_-]+`.
    ///   - description: An optional description of what the schema represents.
    /// - Throws: `BedrockLibraryError.invalidName` if name is empty or contains invalid characters.
    /// - Throws: `BedrockLibraryError.invalid` if schema is null.
    public init(schema: JSON, name: String, description: String? = nil) throws {
        guard !name.isEmpty else {
            throw BedrockLibraryError.invalidName("OutputFormat name is not allowed to be empty")
        }
        guard name.contains(/[a-zA-Z0-9_-]+/) else {
            throw BedrockLibraryError.invalidName(
                "OutputFormat name must consist of only lowercase letter, uppercase letters, digits, underscores and hyphens"
            )
        }
        if case .null = schema.value {
            throw BedrockLibraryError.invalid("OutputFormat schema must not be null")
        }
        self.schema = schema
        self.name = name
        self.description = description
    }

    /// Creates an OutputFormat by parsing a JSON string.
    ///
    /// - Parameters:
    ///   - schema: A syntactically valid JSON string representing the schema.
    ///   - name: A name for the schema matching `[a-zA-Z0-9_-]+`.
    ///   - description: An optional description of what the schema represents.
    /// - Throws: `BedrockLibraryError.decodingError` if the schema string is not valid JSON.
    /// - Throws: `BedrockLibraryError.invalidName` if name is empty or contains invalid characters.
    /// - Throws: `BedrockLibraryError.invalid` if the parsed schema is null.
    public init(schema: String, name: String, description: String? = nil) throws {
        let parsedSchema: JSON
        do {
            parsedSchema = try JSON(from: schema)
        } catch let error as BedrockLibraryError {
            throw error
        } catch {
            throw BedrockLibraryError.decodingError("Failed to decode JSON: \(error)")
        }
        try self.init(schema: parsedSchema, name: name, description: description)
    }

    /// Converts this OutputFormat to the SDK's `BedrockRuntimeClientTypes.OutputFormat` type.
    ///
    /// - Returns: A `BedrockRuntimeClientTypes.OutputFormat` ready for use in a Converse API call.
    /// - Throws: `BedrockLibraryError.encodingError` if the schema cannot be serialized to a JSON string.
    func getSDKOutputFormat() throws -> BedrockRuntimeClientTypes.OutputFormat {
        let encoder = JSONEncoder()
        guard let schemaData = try? encoder.encode(schema),
            let schemaString = String(data: schemaData, encoding: .utf8)
        else {
            throw BedrockLibraryError.encodingError(
                "Could not serialize OutputFormat schema to JSON string"
            )
        }

        let jsonSchemaDefinition = BedrockRuntimeClientTypes.JsonSchemaDefinition(
            description: self.description,
            name: self.name,
            schema: schemaString
        )

        return BedrockRuntimeClientTypes.OutputFormat(
            structure: .jsonschema(jsonSchemaDefinition),
            type: .jsonSchema
        )
    }
}
