//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Foundation Models Playground open source project
//
// Copyright (c) 2025 Amazon.com, Inc. or its affiliates
//                    and the Swift Foundation Models Playground project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of Swift Foundation Models Playground project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import Testing

@testable import BedrockService
@testable import BedrockTypes

// Converse tools

extension BedrockServiceTests {

    @Test("Request tool usage")
    func converseRequestTool() async throws {
        let tool = try Tool(
            name: "toolName",
            inputSchema: JSON(with: ["code": "string"]),
            description: "toolDescription"
        )
        let builder = try ConverseRequestBuilder(with: .nova_lite)
            .withPrompt("Use tool")
            .withTool(tool)
        let reply = try await bedrock.converse(with: builder)
        #expect(reply.textReply == nil)
        let id: String
        let name: String
        let input: JSON
        if let toolUse = reply.toolUse {
            id = toolUse.id
            name = toolUse.name
            input = toolUse.input
        } else {
            id = ""
            name = ""
            input = JSON(with: ["code": "wrong"])
        }
        #expect(id == "toolId")
        #expect(name == "toolName")
        #expect(input.getValue("code") == "abc")
    }

    @Test("Request tool usage with reused builder")
    func converseToolWithReusedBuilder() async throws {
        var builder = try ConverseRequestBuilder(with: .nova_lite)
            .withPrompt("Use tool")
            .withTool(name: "toolName", inputSchema: JSON(with: ["code": "string"]), description: "toolDescription")

        #expect(builder.prompt != nil)
        #expect(builder.prompt! == "Use tool")
        #expect(builder.history.count == 0)

        var reply = try await bedrock.converse(with: builder)

        #expect(reply.textReply == nil)

        let id: String
        let name: String
        let input: JSON
        if let toolUse = reply.toolUse {
            id = toolUse.id
            name = toolUse.name
            input = toolUse.input
        } else {
            id = ""
            name = ""
            input = JSON(with: ["code": "wrong"])
        }

        #expect(id == "toolId")
        #expect(name == "toolName")
        #expect(input.getValue("code") == "abc")

        builder = try ConverseRequestBuilder(from: builder, with: reply)
            .withToolResult("Information from Tool")

        #expect(builder.prompt == nil)
        #expect(builder.toolResult != nil)
        #expect(builder.history.count == 2)

        reply = try await bedrock.converse(with: builder)
        #expect(reply.textReply == "Tool result received")
        #expect(reply.toolUse == nil)

        builder = try ConverseRequestBuilder(from: builder, with: reply)
            .withPrompt("Some prompt")

        #expect(builder.prompt != nil)
        #expect(builder.prompt! == "Some prompt")
        #expect(builder.toolResult == nil)
        #expect(builder.history.count == 4)

        reply = try await bedrock.converse(with: builder)
        #expect(reply.textReply != nil)
        #expect(reply.textReply! == "Your prompt was: Some prompt")
    }

    @Test("Add tool with invalid model")
    func converseToolWrongModel() async throws {
        #expect(throws: BedrockServiceError.self) {
            let tool = try Tool(
                name: "toolName",
                inputSchema: JSON(with: ["code": "string"]),
                description: "toolDescription"
            )
            let _ = try ConverseRequestBuilder(with: .titan_text_g1_express)
                .withTool(tool)
        }
    }

    @Test("No tool request without tools")
    func converseToolWithoutTools() async throws {
        let builder = try ConverseRequestBuilder(with: .nova_lite)
            .withPrompt("Use tool")
        let reply = try await bedrock.converse(with: builder)
        #expect(reply.textReply != nil)
        #expect(reply.toolUse == nil)
    }

    @Test("Tool result")
    func converseToolResult() async throws {
        let tool = try Tool(
            name: "toolName",
            inputSchema: JSON(with: ["code": "string"]),
            description: "toolDescription"
        )
        let id = "toolId"
        let toolUse = ToolUseBlock(id: id, name: "toolName", input: JSON(with: ["code": "abc"]))
        let history = [Message("Use tool"), Message(toolUse)]

        let builder = try ConverseRequestBuilder(with: .nova_lite)
            .withHistory(history)
            .withTool(tool)
            .withToolResult("Information from tool")

        let reply = try await bedrock.converse(with: builder)
        #expect(reply.toolUse == nil)
        #expect(reply.textReply == "Tool result received")
    }

    @Test("Tool result without toolUse")
    func converseToolResultWithoutToolUse() async throws {
        let tool = try Tool(
            name: "toolName",
            inputSchema: JSON(with: ["code": "string"]),
            description: "toolDescription"
        )
        let id = "toolId"
        let history = [Message("Use tool"), Message(from: .assistant, content: [.text("No need for a tool")])]
        #expect(throws: BedrockServiceError.self) {
            let _ = try ConverseRequestBuilder(with: .nova_lite)
                .withHistory(history)
                .withTool(tool)
                .withToolResult("Information from tool", id: id)
        }
    }

    @Test("Tool result without tools")
    func converseToolResultWithoutTools() async throws {
        let id = "toolId"
        let toolUse = ToolUseBlock(id: id, name: "toolName", input: JSON(with: ["code": "abc"]))
        let history = [Message("Use tool"), Message(toolUse)]
        #expect(throws: BedrockServiceError.self) {
            let _ = try ConverseRequestBuilder(with: .nova_lite)
                .withHistory(history)
                .withToolResult("Information from tool")
        }
    }

    @Test("Tool result with invalid model")
    func converseToolResultInvalidModel() async throws {
        let tool = try Tool(
            name: "toolName",
            inputSchema: JSON(with: ["code": "string"]),
            description: "toolDescription"
        )
        let id = "toolId"
        let toolUse = ToolUseBlock(id: id, name: "toolName", input: JSON(with: ["code": "abc"]))
        let history = [Message("Use tool"), Message(toolUse)]
        #expect(throws: BedrockServiceError.self) {
            let _ = try ConverseRequestBuilder(with: .titan_text_g1_express)
                .withHistory(history)
                .withTool(tool)
                .withToolResult("Information from tool")
        }
    }

    @Test("Tool result with invalid model without tools")
    func converseToolResultInvalidModelWithoutTools() async throws {
        let id = "toolId"
        let toolUse = ToolUseBlock(id: id, name: "toolName", input: JSON(with: ["code": "abc"]))
        let history = [Message("Use tool"), Message(toolUse)]

        #expect(throws: BedrockServiceError.self) {
            let _ = try ConverseRequestBuilder(with: .titan_text_g1_express)
                .withHistory(history)
                .withToolResult("Information from tool")
        }
    }

    @Test("Tool result with invalid model without toolUse")
    func converseToolResultInvalidModelWithoutToolUse() async throws {
        let tool = try Tool(
            name: "toolName",
            inputSchema: JSON(with: ["code": "string"]),
            description: "toolDescription"
        )
        let history = [Message("Use tool"), Message(from: .assistant, content: [.text("No need for a tool")])]

        #expect(throws: BedrockServiceError.self) {
            let _ = try ConverseRequestBuilder(with: .titan_text_g1_express)
                .withHistory(history)
                .withTool(tool)
                .withToolResult("Information from tool")
        }
    }

    @Test("Tool result with invalid model without toolUse and without tools")
    func converseToolResultInvalidModelWithoutToolUseAndTools() async throws {
        let history = [Message("Use tool"), Message(from: .assistant, content: [.text("No need for a tool")])]
        #expect(throws: BedrockServiceError.self) {
            let _ = try ConverseRequestBuilder(with: .titan_text_g1_express)
                .withHistory(history)
                .withToolResult("Information from tool")
        }
    }
}
