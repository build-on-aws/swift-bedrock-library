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

import BedrockTypes
import Foundation

public struct ConverseRequestBuilder {

    public private(set) var model: BedrockModel
    private var parameters: ConverseParameters

    public private(set) var history: [Message]
    public private(set) var tools: [Tool]?

    public private(set) var prompt: String?
    public private(set) var image: ImageBlock?
    public private(set) var document: DocumentBlock?
    public private(set) var toolResult: ToolResultBlock?

    public private(set) var maxTokens: Int?
    public private(set) var temperature: Double?
    public private(set) var topP: Double?
    public private(set) var stopSequences: [String]?
    public private(set) var systemPrompts: [String]?
    public private(set) var maxReasoningTokens: Int?
    public private(set) var enableReasoning: Bool = false

    // MARK - Initializers

    public init(with model: BedrockModel) throws {
        self.model = model
        let modality = try model.getConverseModality()
        self.parameters = modality.getConverseParameters()
        self.history = []
    }

    public init(with modelId: String) throws {
        guard let model = BedrockModel(rawValue: modelId) else {
            throw BedrockServiceError.notFound("No model with model id \(modelId) found.")
        }
        self = try .init(with: model)
    }

    /// Creates a ConverseRequestBuilder object based of a ConverseRequestBuilder object
    public init(from builder: ConverseRequestBuilder) throws {
        self = try ConverseRequestBuilder(with: builder.model)
            .withHistory(builder.history)
            .withTemperature(builder.temperature)
            .withTopP(builder.topP)
            .withMaxTokens(builder.maxTokens)
            .withStopSequences(builder.stopSequences)
            .withSystemPrompts(builder.systemPrompts)
            .withTools(builder.tools)
            .withReasoning(enabled: builder.enableReasoning, maxReasoningTokens: builder.maxReasoningTokens)
    }

    /// Creates a ConverseRequestBuilder object based of a ConverseRequestBuilder object
    /// with an updated history and all the user input (prompt, image, document or toolresult) emptied out.
    public init(from builder: ConverseRequestBuilder, with reply: ConverseReply) throws {
        self = try .init(from: builder)
            .withHistory(reply.getHistory())
    }

    /// Creates a ConverseRequestBuilder object based of a ConverseRequestBuilder object
    /// with an updated history and all the user input (prompt, image, document or toolresult) emptied out.
    public init(from builder: ConverseRequestBuilder, with assistantMessage: Message) throws {
        let userMessage = try builder.getUserMessage()
        let history = builder.history + [userMessage, assistantMessage]
        self = try .init(from: builder)
            .withHistory(history)
    }

    // MARK - builder methods

    // MARK - builder methods - history

    public func withHistory(_ history: [Message]) throws -> ConverseRequestBuilder {
        if let lastMessage = history.last {
            guard lastMessage.role == .assistant else {
                throw BedrockServiceError.ConverseRequestBuilder("Last message in history must be from assistant.")
            }
        }
        if toolResult != nil {
            guard case .toolUse(_) = history.last?.content.last else {
                throw BedrockServiceError.invalidPrompt("Tool result is defined but last message is not tool use.")
            }
        }
        var copy = self
        copy.history = history
        return copy
    }

    // MARK - builder methods - tools

    public func withTools(_ tools: [Tool]) throws -> ConverseRequestBuilder {
        try validateFeature(.toolUse)
        guard tools.count > 0 else {
            throw BedrockServiceError.ConverseRequestBuilder("Cannot set tools to empty array.")
        }
        if case .toolUse(let toolUse) = history.last?.content.last {
            guard tools.contains(where: { $0.name == toolUse.name }) else {
                throw BedrockServiceError.ConverseRequestBuilder(
                    "Cannot set tools if last message in history contains toolUse and no matching tool is found."
                )
            }
        }
        let toolNames = tools.map { $0.name }
        guard Set(toolNames).count == tools.count else {
            throw BedrockServiceError.ConverseRequestBuilder("Cannot set tools with duplicate names.")
        }
        var copy = self
        copy.tools = tools
        return copy
    }

    private func withTools(_ tools: [Tool]?) throws -> ConverseRequestBuilder {
        let copy = self
        if let tools {
            return try copy.withTools(tools)
        }
        return copy
    }

    public func withTool(_ tool: Tool) throws -> ConverseRequestBuilder {
        try self.withTools([tool])
    }

    public func withTool(name: String, inputSchema: JSON, description: String?) throws -> ConverseRequestBuilder {
        try self.withTools([try Tool(name: name, inputSchema: inputSchema, description: description)])
    }

    // MARK - builder methods - user prompt

    public func withPrompt(_ prompt: String) throws -> ConverseRequestBuilder {
        guard toolResult == nil else {
            throw BedrockServiceError.ConverseRequestBuilder("Cannot set prompt when tool result is set")
        }
        try parameters.prompt.validateValue(prompt)
        var copy = self
        copy.prompt = prompt
        return copy
    }

    public func withImage(_ image: ImageBlock) throws -> ConverseRequestBuilder {
        try validateFeature(.vision)
        guard toolResult == nil else {
            throw BedrockServiceError.ConverseRequestBuilder("Cannot set image when tool result is set")
        }
        var copy = self
        copy.image = image
        return copy
    }

    public func withImage(format: ImageBlock.Format, source: String) throws -> ConverseRequestBuilder {
        try self.withImage(try ImageBlock(format: format, source: source))
    }

    public func withDocument(_ document: DocumentBlock) throws -> ConverseRequestBuilder {
        try validateFeature(.document)
        guard toolResult == nil else {
            throw BedrockServiceError.ConverseRequestBuilder("Cannot set document when tool result is set")
        }
        var copy = self
        copy.document = document
        return copy
    }

    public func withDocument(
        name: String,
        format: DocumentBlock.Format,
        source: String
    ) throws -> ConverseRequestBuilder {
        try self.withDocument(try DocumentBlock(name: name, format: format, source: source))
    }

    public func withToolResult(_ toolResult: ToolResultBlock) throws -> ConverseRequestBuilder {
        guard prompt == nil && image == nil && document == nil else {
            throw BedrockServiceError.ConverseRequestBuilder(
                "Cannot set tool result when prompt, image, or document is set"
            )
        }
        guard let _ = tools else {
            throw BedrockServiceError.ConverseRequestBuilder("Cannot set tool result when tools are not set")
        }
        guard let lastMessage = history.last else {
            throw BedrockServiceError.ConverseRequestBuilder("Cannot set tool result when history is empty")
        }
        guard case .toolUse(let toolUse) = lastMessage.content.last else {
            throw BedrockServiceError.invalidPrompt("Cannot set tool result when last message is not tool use.")
        }
        guard toolUse.id == toolResult.id else {
            throw BedrockServiceError.invalidPrompt("Tool result name does not match tool use name.")
        }
        try validateFeature(.toolUse)
        var copy = self
        copy.toolResult = toolResult
        return copy
    }

    public func withToolResult(
        id: String? = nil,
        content: [ToolResultBlock.Content],
        status: ToolResultBlock.Status? = nil
    ) throws -> ConverseRequestBuilder {
        let id = try id ?? getToolResultId()
        let toolResult = ToolResultBlock(id: id, content: content, status: status)
        return try self.withToolResult(toolResult)
    }

    public func withToolResult(
        _ text: String,
        id: String? = nil,
        status: ToolResultBlock.Status? = nil
    ) throws -> ConverseRequestBuilder {
        let id = try id ?? getToolResultId()
        let toolResult = ToolResultBlock(text, id: id, status: status)
        return try self.withToolResult(toolResult)
    }

    public func withToolResult(
        _ image: ImageBlock,
        id: String? = nil,
        status: ToolResultBlock.Status? = nil
    ) throws -> ConverseRequestBuilder {
        let id = try id ?? getToolResultId()
        let toolResult = ToolResultBlock(image, id: id, status: status)
        return try self.withToolResult(toolResult)
    }

    public func withToolResult(
        _ document: DocumentBlock,
        id: String? = nil,
        status: ToolResultBlock.Status? = nil
    ) throws -> ConverseRequestBuilder {
        let id = try id ?? getToolResultId()
        let toolResult = ToolResultBlock(document, id: id, status: status)
        return try self.withToolResult(toolResult)
    }

    public func withToolResult(
        _ json: JSON,
        id: String? = nil,
        status: ToolResultBlock.Status? = nil
    ) throws -> ConverseRequestBuilder {
        let id = try id ?? getToolResultId()
        let toolResult = ToolResultBlock(json, id: id, status: status)
        return try self.withToolResult(toolResult)
    }

    public func withToolResult(
        _ video: VideoBlock,
        id: String? = nil,
        status: ToolResultBlock.Status? = nil
    ) throws -> ConverseRequestBuilder {
        let id = try id ?? getToolResultId()
        let toolResult = ToolResultBlock(video, id: id, status: status)
        return try self.withToolResult(toolResult)
    }

    public func withToolResult(
        _ data: Data,
        id: String? = nil,
        status: ToolResultBlock.Status? = nil
    ) throws -> ConverseRequestBuilder {
        let id = try id ?? getToolResultId()
        let toolResult = try ToolResultBlock(data, id: id, status: status)
        return try self.withToolResult(toolResult)
    }

    public func withToolResult<C: Codable>(
        _ object: C,
        id: String? = nil,
        status: ToolResultBlock.Status? = nil
    ) throws -> ConverseRequestBuilder {
        let id = try id ?? getToolResultId()
        let toolResult = try ToolResultBlock(object, id: id, status: status)
        return try self.withToolResult(toolResult)
    }

    public func withFailedToolResult(id: String?) throws -> ConverseRequestBuilder {
        let id = try id ?? getToolResultId()
        let toolResult = ToolResultBlock(id: id, content: [], status: .error)
        return try self.withToolResult(toolResult)
    }

    // MARK - builder methods - inference parameters

    public func withMaxTokens(_ maxTokens: Int?) throws -> ConverseRequestBuilder {
        var copy = self
        if let maxTokens {
            try copy.parameters.maxTokens.validateValue(maxTokens)
            if let maxReasoningTokens {
                guard maxReasoningTokens < maxTokens else {
                    throw BedrockServiceError.ConverseRequestBuilder(
                        "maxTokens must be greater than maxReasoningTokens"
                    )
                }
            }
            copy.maxTokens = maxTokens
        }
        return copy
    }

    public func withTemperature(_ temperature: Double?) throws -> ConverseRequestBuilder {
        var copy = self
        if let temperature {
            try copy.parameters.temperature.validateValue(temperature)
            copy.temperature = temperature
        }
        return copy
    }

    public func withTopP(_ topP: Double?) throws -> ConverseRequestBuilder {
        var copy = self
        if let topP {
            try copy.parameters.topP.validateValue(topP)
            copy.topP = topP
        }
        return copy
    }

    public func withStopSequences(_ stopSequences: [String]?) throws -> ConverseRequestBuilder {
        var copy = self
        if let stopSequences {
            guard stopSequences != [] else {
                throw BedrockServiceError.ConverseRequestBuilder("Cannot set stop sequences to empty array.")
            }
            try copy.parameters.stopSequences.validateValue(stopSequences)
            copy.stopSequences = stopSequences
        }
        return copy
    }

    public func withStopSequence(_ stopSequence: String?) throws -> ConverseRequestBuilder {
        var stopSequences: [String]? = nil
        if let stopSequence {
            stopSequences = [stopSequence]
        }
        return try self.withStopSequences(stopSequences)
    }

    public func withSystemPrompts(_ systemPrompts: [String]?) throws -> ConverseRequestBuilder {
        var copy = self
        if let systemPrompts {
            guard systemPrompts != [] else {
                throw BedrockServiceError.ConverseRequestBuilder("Cannot set system prompts to empty array.")
            }
            copy.systemPrompts = systemPrompts
        }
        return copy
    }

    public func withSystemPrompt(_ systemPrompt: String?) throws -> ConverseRequestBuilder {
        var systemPrompts: [String]? = nil
        if let systemPrompt {
            systemPrompts = [systemPrompt]
        }
        return try self.withSystemPrompts(systemPrompts)
    }

    public func withReasoning(_ enabled: Bool = true) throws -> ConverseRequestBuilder {
        var copy = self
        if enabled {
            try validateFeature(.reasoning)
            copy.enableReasoning = true
            copy = try copy.withMaxReasoningTokens(
                self.maxReasoningTokens ?? parameters.maxReasoningTokens.defaultValue
            )
        } else {
            copy.enableReasoning = false
            copy.maxReasoningTokens = nil
        }
        return copy
    }

    public func withMaxReasoningTokens(_ maxReasoningTokens: Int?) throws -> ConverseRequestBuilder {
        var copy = self
        if let maxReasoningTokens {
            try validateFeature(.reasoning)
            guard enableReasoning else {
                throw BedrockServiceError.ConverseRequestBuilder(
                    "Cannot set maxReasoningTokens when reasoning is disabled"
                )
            }
            if let maxTokens {
                guard maxReasoningTokens < maxTokens else {
                    throw BedrockServiceError.ConverseRequestBuilder(
                        "maxReasoningTokens must be less than maxTokens"
                    )
                }
            }
            try copy.parameters.maxReasoningTokens.validateValue(maxReasoningTokens)
            copy.maxReasoningTokens = maxReasoningTokens
        }
        return copy
    }

    /// convenience method to enable reasoning and set maxReasoningTokens at the same time
    public func withReasoning(maxReasoningTokens: Int) throws -> ConverseRequestBuilder {
        try self.withReasoning(true).withMaxReasoningTokens(maxReasoningTokens)
    }

    /// private convenience method
    private func withReasoning(enabled: Bool, maxReasoningTokens: Int? = nil) throws -> ConverseRequestBuilder {
        let copy = self
        if let maxReasoningTokens {
            return try copy.withReasoning(true)
                .withMaxReasoningTokens(maxReasoningTokens)
        }
        return try copy.withReasoning(enabled)
    }

    // MARK - public methods

    /// Returns the user Message made up of the user input in the builder
    package func getUserMessage() throws -> Message {
        var content: [Content] = []
        if let prompt {
            content.append(.text(prompt))
        }
        if let image {
            content.append(.image(image))
        }
        if let document {
            content.append(.document(document))
        }
        if let toolResult {
            content.append(.toolResult(toolResult))
        }
        guard !content.isEmpty else {
            throw BedrockServiceError.ConverseRequestBuilder("No content defined.")
        }
        return Message(from: .user, content: content)
    }

    private func getToolResultId() throws -> String {
        guard let lastMessage = history.last else {
            throw BedrockServiceError.ConverseRequestBuilder("Cannot set tool result when history is empty")
        }
        guard case .toolUse(let toolUse) = lastMessage.content.last else {
            throw BedrockServiceError.invalidPrompt("Cannot set tool result when last message is not tool use.")
        }
        return toolUse.id
    }

    private func validateFeature(_ feature: ConverseFeature) throws {
        guard model.hasConverseModality(feature) else {
            throw BedrockServiceError.invalidModality(
                model,
                try model.getConverseModality(),
                "This model does not support converse feature \(feature)."
            )
        }
    }
}
