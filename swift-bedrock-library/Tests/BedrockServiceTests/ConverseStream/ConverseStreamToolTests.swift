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

// MARK - Streaming conversetooluse

extension BedrockServiceTests {
    @Test("Continue conversation with tool use")
    func converseStreamWithToolUse() async throws {
        let tool = try Tool(
            name: "toolName",
            inputSchema: JSON(with: ["code": "string"]),
            description: "toolDescription"
        )
        var builder = try ConverseRequestBuilder(with: .nova_lite)
            .withPrompt("Use tool")
            .withMaxTokens(100)
            .withTemperature(0.5)
            .withTopP(0.5)
            .withStopSequence("\n\nHuman:")
            .withSystemPrompt("You are a helpful assistant.")
            .withTool(tool)

        #expect(builder.prompt == "Use tool")
        #expect(builder.maxTokens == 100)
        #expect(builder.temperature == 0.5)
        #expect(builder.topP == 0.5)
        #expect(builder.stopSequences == ["\n\nHuman:"])
        #expect(builder.systemPrompts == ["You are a helpful assistant."])
        #expect(builder.tools != nil)

        var stream = try await bedrock.converseStream(with: builder)

        // Collect all the stream elements
        var streamElements: [ConverseStreamElement] = []
        for try await element in stream {
            streamElements.append(element)
        }

        // Verify the stream elements
        #expect(streamElements.count == 3)

        var message: Message = Message("")
        if case .messageComplete(let msg) = streamElements.last {
            message = msg
        } else {
            Issue.record("Expected message")
        }
        var toolUse: ToolUseBlock? = nil
        if case .toolUse(let tu) = message.content.last {
            toolUse = tu
        } else {
            Issue.record("Expected message")
        }
        let toolUseId = toolUse?.id ?? "WRONG"

        #expect(message.content.count == 1)
        #expect(message.role == .assistant)
        #expect(toolUse != nil)
        #expect(toolUse?.name == "toolname")
        #expect(toolUseId == "tooluseid")

        builder = try ConverseRequestBuilder(from: builder, with: message)
            .withToolResult(ToolResultBlock("tool result", id: toolUseId))

        #expect(builder.prompt == nil)
        #expect(builder.toolResult != nil)
        #expect(builder.maxTokens == 100)
        #expect(builder.temperature == 0.5)
        #expect(builder.topP == 0.5)
        #expect(builder.stopSequences == ["\n\nHuman:"])
        #expect(builder.systemPrompts == ["You are a helpful assistant."])
        #expect(builder.history.count == 2)
        #expect(builder.tools != nil)

        stream = try await bedrock.converseStream(with: builder)
        // Collect all the stream elements
        streamElements = []
        for try await element in stream {
            streamElements.append(element)
        }

        // Verify the stream elements
        #expect(streamElements.count == 6)

        message = Message("")
        if case .messageComplete(let msg) = streamElements.last {
            message = msg
        } else {
            Issue.record("Expected message")
        }

        #expect(message.content.count == 1)
        #expect(message.role == .assistant)

        if case .text(let text) = message.content.last {
            #expect(text == "Hello, your prompt was: Tool result received for toolUseId: \(toolUseId)")
        }
    }
}
