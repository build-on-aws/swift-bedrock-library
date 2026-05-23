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

import BedrockService
import Logging

@main
struct Main {
    static func main() async throws {
        do {
            try await Main.structuredOutput()
        } catch {
            print("Error:\n\(error)")
        }
    }

    static func structuredOutput() async throws {
        var logger = Logger(label: "StructuredOutput")
        logger.logLevel = .info

        let bedrock = try await BedrockService(
            region: .useast1,
            logger: logger
        )

        // Select a model that supports structured output
        let model: BedrockModel = .claude_sonnet_v4_5

        // Verify the model supports structured output before making requests
        guard model.hasConverseModality(.structuredOutput) else {
            print("Error: \(model.name) does not support structured output.")
            return
        }

        // --- Part 1: JSON Schema Output Format ---
        print("=== JSON Schema Output Format ===\n")
        try await demonstrateJsonSchemaOutput(bedrock: bedrock, model: model)

        print("\n")

        // --- Part 2: Strict Tool Use ---
        print("=== Strict Tool Use ===\n")
        try await demonstrateStrictToolUse(bedrock: bedrock, model: model)
    }

    /// Demonstrates JSON schema output format with a schema containing 2+ properties and 1+ required field.
    static func demonstrateJsonSchemaOutput(bedrock: BedrockService, model: BedrockModel) async throws {
        // Define a JSON schema with multiple properties and required fields
        let schema = """
        {
            "type": "object",
            "properties": {
                "title": { "type": "string", "description": "The book title" },
                "author": { "type": "string", "description": "The author name" },
                "year": { "type": "integer", "description": "Publication year" },
                "genre": { "type": "string", "description": "The book genre" }
            },
            "required": ["title", "author", "year"],
            "additionalProperties": false
        }
        """

        let builder = try ConverseRequestBuilder(with: model)
            .withPrompt("Give me information about the novel '1984' by George Orwell. Return the data as JSON.")
            .withOutputFormat(schema: schema, name: "book_info", description: "Information about a book")

        let reply = try await bedrock.converse(with: builder)
        let jsonText = try reply.getTextReply()
        print("Structured JSON response:")
        print(jsonText)
    }

    /// Demonstrates strict tool use with a Tool that has strict set to true.
    static func demonstrateStrictToolUse(bedrock: BedrockService, model: BedrockModel) async throws {
        // Define a tool with strict: true for validated input parameters
        let tool = try Tool(
            name: "get_weather",
            inputSchema: try JSON(from: """
            {
                "type": "object",
                "properties": {
                    "location": { "type": "string", "description": "City name" },
                    "unit": { "type": "string", "enum": ["celsius", "fahrenheit"], "description": "Temperature unit" }
                },
                "required": ["location", "unit"],
                "additionalProperties": false
            }
            """),
            description: "Get the current weather for a location",
            strict: true
        )

        let builder = try ConverseRequestBuilder(with: model)
            .withPrompt("What is the weather in Paris in celsius?")
            .withTool(tool)

        let reply = try await bedrock.converse(with: builder)

        // Detect the ToolUseBlock in the response
        let toolUseBlock = try reply.getToolUse()
        print("Tool called: \(toolUseBlock.name)")
        print("Tool input parameters: \(toolUseBlock.input)")
    }
}
