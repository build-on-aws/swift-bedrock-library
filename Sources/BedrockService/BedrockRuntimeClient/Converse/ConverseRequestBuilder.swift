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

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// A builder for constructing Amazon Bedrock Converse API requests.
///
/// `ConverseRequestBuilder` provides a fluent interface for building conversational AI requests
/// with support for multi-turn conversations, tool use, vision, documents, and reasoning capabilities.
///
/// ## Usage
///
/// ```swift
/// let builder = try ConverseRequestBuilder(with: .claude3Sonnet)
///     .withPrompt("What is the weather?")
///     .withMaxTokens(1000)
///     .withTemperature(0.7)
/// ```
public struct ConverseRequestBuilder: Sendable {

    /// The Bedrock model to use for the conversation.
    public private(set) var model: BedrockModel
    private var parameters: ConverseParameters

    /// The conversation history containing previous messages.
    public private(set) var history: History
    /// The tools available for the model to use, if any.
    public private(set) var tools: [Tool]?

    /// The text prompt for the current user message, if any.
    public private(set) var prompt: String?
    /// The image content for the current user message, if any.
    public private(set) var image: ImageBlock?
    /// The document content for the current user message, if any.
    public private(set) var document: DocumentBlock?
    /// The tool result for the current user message, if any.
    public private(set) var toolResult: ToolResultBlock?

    /// The maximum number of tokens to generate in the response, if specified.
    public private(set) var maxTokens: Int?
    /// The temperature parameter controlling randomness in generation, if specified.
    public private(set) var temperature: Double?
    /// The top-p parameter for nucleus sampling, if specified.
    public private(set) var topP: Double?
    /// The stop sequences that halt generation, if any.
    public private(set) var stopSequences: [String]?
    /// The system prompts that guide model behavior, if any.
    public private(set) var systemPrompts: [String]?
    /// The maximum number of reasoning tokens for extended thinking models, if specified.
    public private(set) var maxReasoningTokens: Int?
    /// Indicates whether reasoning mode is enabled for extended thinking models.
    public private(set) var enableReasoning: Bool = false

    /// The service tier for the inference request.
    public private(set) var serviceTier: ServiceTier = .default

    // MARK - Initializers

    /// Creates a new builder for the specified Bedrock model.
    ///
    /// - Parameter model: The Bedrock model to use for conversation.
    /// - Throws: `BedrockLibraryError` if the model doesn't support the Converse API.
    public init(with model: BedrockModel) throws {
        self.model = model
        let modality = try model.getConverseModality()
        self.parameters = modality.getConverseParameters()
        self.history = []
    }

    /// Creates a new builder for the specified model ID.
    ///
    /// - Parameter modelId: The string identifier of the Bedrock model.
    /// - Throws: `BedrockLibraryError.notFound` if the model ID is invalid,
    ///           or other errors if the model doesn't support the Converse API.
    public init(with modelId: String) throws {
        guard let model = BedrockModel(rawValue: modelId) else {
            throw BedrockLibraryError.notFound("No model with model id \(modelId) found.")
        }
        self = try .init(with: model)
    }

    /// Creates a new builder by copying configuration from an existing builder.
    ///
    /// - Parameter builder: The builder to copy configuration from.
    /// - Throws: `BedrockLibraryError` if validation fails during configuration copy.
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
            .withServiceTier(builder.serviceTier)
    }

    /// Creates a new builder from an existing builder with updated conversation history from a reply.
    ///
    /// This initializer clears all user input (prompt, image, document, tool result) and updates
    /// the history with the conversation from the reply.
    ///
    /// - Parameters:
    ///   - builder: The builder to copy configuration from.
    ///   - reply: The reply containing the updated conversation history.
    /// - Throws: `BedrockLibraryError` if validation fails.
    public init(from builder: ConverseRequestBuilder, with reply: ConverseReply) throws {
        self = try .init(from: builder)
            .withHistory(reply.getHistory())
    }

    /// Creates a new builder from an existing builder with an assistant message added to history.
    ///
    /// This initializer clears all user input (prompt, image, document, tool result) and appends
    /// both the user message and assistant message to the conversation history.
    ///
    /// - Parameters:
    ///   - builder: The builder to copy configuration from.
    ///   - assistantMessage: The assistant's message to add to history.
    /// - Throws: `BedrockLibraryError` if validation fails.
    public init(from builder: ConverseRequestBuilder, with assistantMessage: Message) throws {
        let userMessage = try builder.getUserMessage()
        let history = builder.history + [userMessage, assistantMessage]
        self = try .init(from: builder)
            .withHistory(history)
    }

    // MARK - builder methods

    // MARK - builder methods - history
    /// Sets the conversation history from a message array.
    ///
    /// - Parameter history: The array of messages representing the conversation history.
    /// - Returns: A new builder with the updated history.
    /// - Throws: `BedrockLibraryError` if validation fails.
    @available(
        *,
        deprecated,
        message: "Use withHistory(_: [History])instead. This func will be removed in the next major version."
    )
    public func withHistory(_ history: [Message]) throws -> ConverseRequestBuilder {
        try withHistory(History(history))
    }
    /// Sets the conversation history.
    ///
    /// The history must end with an assistant message if non-empty. If a tool result is set,
    /// the last message must contain a tool use.
    ///
    /// - Parameter history: The conversation history to set.
    /// - Returns: A new builder with the updated history.
    /// - Throws: `BedrockLibraryError.ConverseRequestBuilder` if validation fails.
    public func withHistory(_ history: History) throws -> ConverseRequestBuilder {

        if history.count > 0,
            let lastMessage = history.last
        {
            guard lastMessage.role == .assistant else {
                throw BedrockLibraryError.ConverseRequestBuilder("Last message in history must be from assistant.")
            }
        }
        if history.count > 0,
            toolResult != nil
        {
            guard case .toolUse(_) = history.last?.content.last else {
                throw BedrockLibraryError.ConverseRequestBuilder(
                    "Tool result is defined but last message is not tool use."
                )
            }
        }
        var copy = self
        copy.history = history
        return copy
    }

    // MARK - builder methods - tools

    /// Sets the tools available for the model to use.
    ///
    /// Tool names must be unique. If the last message in history contains a tool use,
    /// a matching tool must be present in the tools array.
    ///
    /// - Parameter tools: The array of tools to make available. Must not be empty.
    /// - Returns: A new builder with the updated tools.
    /// - Throws: `BedrockLibraryError.ConverseRequestBuilder` if validation fails,
    ///           or if the model doesn't support tool use.
    public func withTools(_ tools: [Tool]) throws -> ConverseRequestBuilder {
        try validateFeature(.toolUse)
        guard tools.count > 0 else {
            throw BedrockLibraryError.ConverseRequestBuilder("Cannot set tools to empty array.")
        }
        if case .toolUse(let toolUse) = history.last?.content.last {
            guard tools.contains(where: { $0.name == toolUse.name }) else {
                throw BedrockLibraryError.ConverseRequestBuilder(
                    "Cannot set tools if last message in history contains toolUse and no matching tool is found."
                )
            }
        }
        let toolNames = tools.map { $0.name }
        guard Set(toolNames).count == tools.count else {
            throw BedrockLibraryError.ConverseRequestBuilder("Cannot set tools with duplicate names.")
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

    /// Sets a single tool for the model to use.
    ///
    /// - Parameter tool: The tool to make available.
    /// - Returns: A new builder with the tool set.
    /// - Throws: `BedrockLibraryError` if validation fails or the model doesn't support tool use.
    public func withTool(_ tool: Tool) throws -> ConverseRequestBuilder {
        try self.withTools([tool])
    }

    /// Creates and sets a single tool from its components.
    ///
    /// - Parameters:
    ///   - name: The name of the tool.
    ///   - inputSchema: The JSON schema defining the tool's input parameters.
    ///   - description: An optional description of what the tool does.
    /// - Returns: A new builder with the tool set.
    /// - Throws: `BedrockLibraryError` if validation fails or the model doesn't support tool use.
    public func withTool(name: String, inputSchema: JSON, description: String?) throws -> ConverseRequestBuilder {
        try self.withTools([try Tool(name: name, inputSchema: inputSchema, description: description)])
    }

    // MARK - builder methods - user prompt

    /// Sets the text prompt for the user message.
    ///
    /// Cannot be set when a tool result is already set.
    ///
    /// - Parameter prompt: The text prompt to send.
    /// - Returns: A new builder with the prompt set.
    /// - Throws: `BedrockLibraryError` if validation fails or a tool result is already set.
    public func withPrompt(_ prompt: String) throws -> ConverseRequestBuilder {
        guard toolResult == nil else {
            throw BedrockLibraryError.ConverseRequestBuilder("Cannot set prompt when tool result is set")
        }
        try parameters.prompt.validateValue(prompt)
        var copy = self
        copy.prompt = prompt
        return copy
    }

    /// Sets an image for the user message.
    ///
    /// Cannot be set when a tool result is already set.
    ///
    /// - Parameter image: The image block to include.
    /// - Returns: A new builder with the image set.
    /// - Throws: `BedrockLibraryError` if validation fails, the model doesn't support vision,
    ///           or a tool result is already set.
    public func withImage(_ image: ImageBlock) throws -> ConverseRequestBuilder {
        try validateFeature(.vision)
        guard toolResult == nil else {
            throw BedrockLibraryError.ConverseRequestBuilder("Cannot set image when tool result is set")
        }
        var copy = self
        copy.image = image
        return copy
    }

    /// Sets an image for the user message from binary data.
    ///
    /// - Parameters:
    ///   - format: The image format (e.g., PNG, JPEG).
    ///   - source: The image data.
    /// - Returns: A new builder with the image set.
    /// - Throws: `BedrockLibraryError` if validation fails or the model doesn't support vision.
    public func withImage(format: ImageBlock.Format, source: Data) throws -> ConverseRequestBuilder {
        try self.withImage(try ImageBlock(format: format, source: source.base64EncodedString()))
    }

    /// Sets an image for the user message from a base64-encoded string.
    ///
    /// - Parameters:
    ///   - format: The image format (e.g., PNG, JPEG).
    ///   - source: The base64-encoded image data.
    /// - Returns: A new builder with the image set.
    /// - Throws: `BedrockLibraryError` if validation fails or the model doesn't support vision.
    public func withImage(format: ImageBlock.Format, source: String) throws -> ConverseRequestBuilder {
        try self.withImage(try ImageBlock(format: format, source: source))
    }

    /// Sets a document for the user message.
    ///
    /// Cannot be set when a tool result is already set.
    ///
    /// - Parameter document: The document block to include.
    /// - Returns: A new builder with the document set.
    /// - Throws: `BedrockLibraryError` if validation fails, the model doesn't support documents,
    ///           or a tool result is already set.
    public func withDocument(_ document: DocumentBlock) throws -> ConverseRequestBuilder {
        try validateFeature(.document)
        guard toolResult == nil else {
            throw BedrockLibraryError.ConverseRequestBuilder("Cannot set document when tool result is set")
        }
        var copy = self
        copy.document = document
        return copy
    }

    /// Sets a document for the user message from its components.
    ///
    /// - Parameters:
    ///   - name: The name of the document.
    ///   - format: The document format (e.g., PDF, TXT).
    ///   - source: The base64-encoded document data.
    /// - Returns: A new builder with the document set.
    /// - Throws: `BedrockLibraryError` if validation fails or the model doesn't support documents.
    public func withDocument(
        name: String,
        format: DocumentBlock.Format,
        source: String
    ) throws -> ConverseRequestBuilder {
        try self.withDocument(try DocumentBlock(name: name, format: format, source: source))
    }

    /// Sets a tool result for the user message.
    ///
    /// Tool results can only be set when tools are configured, the history is non-empty,
    /// and the last message contains a tool use. Cannot be set when prompt, image, or document is set.
    ///
    /// - Parameter toolResult: The tool result block to include.
    /// - Returns: A new builder with the tool result set.
    /// - Throws: `BedrockLibraryError` if validation fails or preconditions aren't met.
    public func withToolResult(_ toolResult: ToolResultBlock) throws -> ConverseRequestBuilder {
        guard prompt == nil && image == nil && document == nil else {
            throw BedrockLibraryError.ConverseRequestBuilder(
                "Cannot set tool result when prompt, image, or document is set"
            )
        }
        guard let _ = tools else {
            throw BedrockLibraryError.ConverseRequestBuilder("Cannot set tool result when tools are not set")
        }
        guard let lastMessage = history.last else {
            throw BedrockLibraryError.ConverseRequestBuilder("Cannot set tool result when history is empty")
        }
        guard case .toolUse(let toolUse) = lastMessage.content.last else {
            throw BedrockLibraryError.invalidPrompt("Cannot set tool result when last message is not tool use.")
        }
        guard toolUse.id == toolResult.id else {
            throw BedrockLibraryError.invalidPrompt("Tool result name does not match tool use name.")
        }
        try validateFeature(.toolUse)
        var copy = self
        copy.toolResult = toolResult
        return copy
    }

    /// Sets a tool result with custom content.
    ///
    /// - Parameters:
    ///   - id: The tool use ID. If `nil`, uses the ID from the last tool use in history.
    ///   - content: The result content.
    ///   - status: The result status. Defaults to success if `nil`.
    /// - Returns: A new builder with the tool result set.
    /// - Throws: `BedrockLibraryError` if validation fails or preconditions aren't met.
    public func withToolResult(
        id: String? = nil,
        content: [ToolResultBlock.Content],
        status: ToolResultBlock.Status? = nil
    ) throws -> ConverseRequestBuilder {
        let id = try id ?? getToolResultId()
        let toolResult = ToolResultBlock(id: id, content: content, status: status)
        return try self.withToolResult(toolResult)
    }

    /// Sets a tool result with text content.
    ///
    /// - Parameters:
    ///   - text: The text result.
    ///   - id: The tool use ID. If `nil`, uses the ID from the last tool use in history.
    ///   - status: The result status. Defaults to success if `nil`.
    /// - Returns: A new builder with the tool result set.
    /// - Throws: `BedrockLibraryError` if validation fails.
    public func withToolResult(
        _ text: String,
        id: String? = nil,
        status: ToolResultBlock.Status? = nil
    ) throws -> ConverseRequestBuilder {
        let id = try id ?? getToolResultId()
        let toolResult = ToolResultBlock(text, id: id, status: status)
        return try self.withToolResult(toolResult)
    }

    /// Sets a tool result with image content.
    ///
    /// - Parameters:
    ///   - image: The image result.
    ///   - id: The tool use ID. If `nil`, uses the ID from the last tool use in history.
    ///   - status: The result status. Defaults to success if `nil`.
    /// - Returns: A new builder with the tool result set.
    /// - Throws: `BedrockLibraryError` if validation fails.
    public func withToolResult(
        _ image: ImageBlock,
        id: String? = nil,
        status: ToolResultBlock.Status? = nil
    ) throws -> ConverseRequestBuilder {
        let id = try id ?? getToolResultId()
        let toolResult = ToolResultBlock(image, id: id, status: status)
        return try self.withToolResult(toolResult)
    }

    /// Sets a tool result with document content.
    ///
    /// - Parameters:
    ///   - document: The document result.
    ///   - id: The tool use ID. If `nil`, uses the ID from the last tool use in history.
    ///   - status: The result status. Defaults to success if `nil`.
    /// - Returns: A new builder with the tool result set.
    /// - Throws: `BedrockLibraryError` if validation fails.
    public func withToolResult(
        _ document: DocumentBlock,
        id: String? = nil,
        status: ToolResultBlock.Status? = nil
    ) throws -> ConverseRequestBuilder {
        let id = try id ?? getToolResultId()
        let toolResult = ToolResultBlock(document, id: id, status: status)
        return try self.withToolResult(toolResult)
    }

    /// Sets a tool result with JSON content.
    ///
    /// - Parameters:
    ///   - json: The JSON result.
    ///   - id: The tool use ID. If `nil`, uses the ID from the last tool use in history.
    ///   - status: The result status. Defaults to success if `nil`.
    /// - Returns: A new builder with the tool result set.
    /// - Throws: `BedrockLibraryError` if validation fails.
    public func withToolResult(
        _ json: JSON,
        id: String? = nil,
        status: ToolResultBlock.Status? = nil
    ) throws -> ConverseRequestBuilder {
        let id = try id ?? getToolResultId()
        let toolResult = ToolResultBlock(json, id: id, status: status)
        return try self.withToolResult(toolResult)
    }

    /// Sets a tool result with video content.
    ///
    /// - Parameters:
    ///   - video: The video result.
    ///   - id: The tool use ID. If `nil`, uses the ID from the last tool use in history.
    ///   - status: The result status. Defaults to success if `nil`.
    /// - Returns: A new builder with the tool result set.
    /// - Throws: `BedrockLibraryError` if validation fails.
    public func withToolResult(
        _ video: VideoBlock,
        id: String? = nil,
        status: ToolResultBlock.Status? = nil
    ) throws -> ConverseRequestBuilder {
        let id = try id ?? getToolResultId()
        let toolResult = ToolResultBlock(video, id: id, status: status)
        return try self.withToolResult(toolResult)
    }

    /// Sets a tool result with raw data content.
    ///
    /// - Parameters:
    ///   - data: The raw data result.
    ///   - id: The tool use ID. If `nil`, uses the ID from the last tool use in history.
    ///   - status: The result status. Defaults to success if `nil`.
    /// - Returns: A new builder with the tool result set.
    /// - Throws: `BedrockLibraryError` if validation fails.
    public func withToolResult(
        _ data: Data,
        id: String? = nil,
        status: ToolResultBlock.Status? = nil
    ) throws -> ConverseRequestBuilder {
        let id = try id ?? getToolResultId()
        let toolResult = try ToolResultBlock(data, id: id, status: status)
        return try self.withToolResult(toolResult)
    }

    /// Sets a tool result with an encodable object.
    ///
    /// - Parameters:
    ///   - object: The encodable object to use as the result.
    ///   - id: The tool use ID. If `nil`, uses the ID from the last tool use in history.
    ///   - status: The result status. Defaults to success if `nil`.
    /// - Returns: A new builder with the tool result set.
    /// - Throws: `BedrockLibraryError` if validation or encoding fails.
    public func withToolResult<C: Encodable>(
        _ object: C,
        id: String? = nil,
        status: ToolResultBlock.Status? = nil
    ) throws -> ConverseRequestBuilder {
        let id = try id ?? getToolResultId()
        let toolResult = try ToolResultBlock(object, id: id, status: status)
        return try self.withToolResult(toolResult)
    }

    /// Sets a failed tool result with error status.
    ///
    /// - Parameter id: The tool use ID. If `nil`, uses the ID from the last tool use in history.
    /// - Returns: A new builder with the failed tool result set.
    /// - Throws: `BedrockLibraryError` if validation fails.
    public func withFailedToolResult(id: String?) throws -> ConverseRequestBuilder {
        let id = try id ?? getToolResultId()
        let toolResult = ToolResultBlock(id: id, content: [], status: .error)
        return try self.withToolResult(toolResult)
    }

    // MARK - builder methods - inference parameters

    /// Sets the maximum number of tokens to generate.
    ///
    /// Must be greater than `maxReasoningTokens` if reasoning is enabled.
    ///
    /// - Parameter maxTokens: The maximum token count, or `nil` to use the model's default.
    /// - Returns: A new builder with the max tokens set.
    /// - Throws: `BedrockLibraryError` if the value is invalid or conflicts with reasoning tokens.
    public func withMaxTokens(_ maxTokens: Int?) throws -> ConverseRequestBuilder {
        var copy = self
        if let maxTokens {
            try copy.parameters.maxTokens.validateValue(maxTokens)
            if let maxReasoningTokens {
                guard maxReasoningTokens < maxTokens else {
                    throw BedrockLibraryError.ConverseRequestBuilder(
                        "maxTokens must be greater than maxReasoningTokens"
                    )
                }
            }
            copy.maxTokens = maxTokens
        }
        return copy
    }

    /// Sets the temperature parameter controlling randomness in generation.
    ///
    /// Higher values (e.g., 1.0) make output more random, lower values (e.g., 0.0) make it more deterministic.
    ///
    /// - Parameter temperature: The temperature value, or `nil` to use the model's default.
    /// - Returns: A new builder with the temperature set.
    /// - Throws: `BedrockLibraryError` if the value is outside the model's supported range.
    public func withTemperature(_ temperature: Double?) throws -> ConverseRequestBuilder {
        var copy = self
        if let temperature {
            try copy.parameters.temperature.validateValue(temperature)
            copy.temperature = temperature
        }
        return copy
    }

    /// Sets the top-p parameter for nucleus sampling.
    ///
    /// Controls diversity by limiting the cumulative probability of tokens considered.
    /// Values closer to 0 make output more focused, closer to 1 more diverse.
    ///
    /// - Parameter topP: The top-p value, or `nil` to use the model's default.
    /// - Returns: A new builder with the top-p set.
    /// - Throws: `BedrockLibraryError` if the value is outside the model's supported range.
    public func withTopP(_ topP: Double?) throws -> ConverseRequestBuilder {
        var copy = self
        if let topP {
            try copy.parameters.topP.validateValue(topP)
            copy.topP = topP
        }
        return copy
    }

    /// Sets the stop sequences that halt generation when encountered.
    ///
    /// - Parameter stopSequences: The array of stop sequences, or `nil` to use defaults. Must not be empty if provided.
    /// - Returns: A new builder with the stop sequences set.
    /// - Throws: `BedrockLibraryError` if validation fails or the array is empty.
    public func withStopSequences(_ stopSequences: [String]?) throws -> ConverseRequestBuilder {
        var copy = self
        if let stopSequences {
            guard stopSequences != [] else {
                throw BedrockLibraryError.ConverseRequestBuilder("Cannot set stop sequences to empty array.")
            }
            try copy.parameters.stopSequences.validateValue(stopSequences)
            copy.stopSequences = stopSequences
        }
        return copy
    }

    /// Sets a single stop sequence that halts generation when encountered.
    ///
    /// - Parameter stopSequence: The stop sequence, or `nil` to clear stop sequences.
    /// - Returns: A new builder with the stop sequence set.
    /// - Throws: `BedrockLibraryError` if validation fails.
    public func withStopSequence(_ stopSequence: String?) throws -> ConverseRequestBuilder {
        var stopSequences: [String]? = nil
        if let stopSequence {
            stopSequences = [stopSequence]
        }
        return try self.withStopSequences(stopSequences)
    }

    /// Sets the system prompts that guide model behavior.
    ///
    /// System prompts provide instructions or context that influence how the model responds.
    ///
    /// - Parameter systemPrompts: The array of system prompts, or `nil` to clear. Must not be empty if provided.
    /// - Returns: A new builder with the system prompts set.
    /// - Throws: `BedrockLibraryError.ConverseRequestBuilder` if the array is empty.
    public func withSystemPrompts(_ systemPrompts: [String]?) throws -> ConverseRequestBuilder {
        var copy = self
        if let systemPrompts {
            guard systemPrompts != [] else {
                throw BedrockLibraryError.ConverseRequestBuilder("Cannot set system prompts to empty array.")
            }
            copy.systemPrompts = systemPrompts
        }
        return copy
    }

    /// Sets a single system prompt that guides model behavior.
    ///
    /// - Parameter systemPrompt: The system prompt, or `nil` to clear system prompts.
    /// - Returns: A new builder with the system prompt set.
    /// - Throws: `BedrockLibraryError` if validation fails.
    public func withSystemPrompt(_ systemPrompt: String?) throws -> ConverseRequestBuilder {
        var systemPrompts: [String]? = nil
        if let systemPrompt {
            systemPrompts = [systemPrompt]
        }
        return try self.withSystemPrompts(systemPrompts)
    }

    /// Enables or disables extended thinking mode for reasoning-capable models.
    ///
    /// When enabled, the model uses additional tokens for internal reasoning before generating output.
    ///
    /// - Parameter enabled: Whether to enable reasoning mode. Defaults to `true`.
    /// - Returns: A new builder with reasoning configured.
    /// - Throws: `BedrockLibraryError` if the model doesn't support reasoning.
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

    /// Sets the maximum number of tokens for internal reasoning.
    ///
    /// Must be less than `maxTokens` and can only be set when reasoning is enabled.
    ///
    /// - Parameter maxReasoningTokens: The maximum reasoning token count, or `nil` to use defaults.
    /// - Returns: A new builder with the max reasoning tokens set.
    /// - Throws: `BedrockLibraryError` if reasoning is disabled, the value is invalid,
    ///           or it exceeds `maxTokens`.
    public func withMaxReasoningTokens(_ maxReasoningTokens: Int?) throws -> ConverseRequestBuilder {
        var copy = self
        if let maxReasoningTokens {
            try validateFeature(.reasoning)
            guard enableReasoning else {
                throw BedrockLibraryError.ConverseRequestBuilder(
                    "Cannot set maxReasoningTokens when reasoning is disabled"
                )
            }
            if let maxTokens {
                guard maxReasoningTokens < maxTokens else {
                    throw BedrockLibraryError.ConverseRequestBuilder(
                        "maxReasoningTokens must be less than maxTokens"
                    )
                }
            }
            try copy.parameters.maxReasoningTokens.validateValue(maxReasoningTokens)
            copy.maxReasoningTokens = maxReasoningTokens
        }
        return copy
    }

    /// Enables reasoning mode and sets the maximum reasoning tokens in one call.
    ///
    /// - Parameter maxReasoningTokens: The maximum number of tokens for internal reasoning.
    /// - Returns: A new builder with reasoning enabled and max reasoning tokens set.
    /// - Throws: `BedrockLibraryError` if the model doesn't support reasoning or validation fails.
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

    /// Sets the service tier for the inference request.
    ///
    /// Service tiers control the priority and cost of inference requests.
    /// For more information, see [Service Tiers](https://docs.aws.amazon.com/bedrock/latest/userguide/service-tiers-inference.html).
    ///
    /// - Parameter serviceTier: The service tier to use.
    /// - Returns: A new builder with the service tier set.
    public func withServiceTier(_ serviceTier: ServiceTier) throws -> ConverseRequestBuilder {
        var copy = self
        copy.serviceTier = serviceTier
        return copy
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
            throw BedrockLibraryError.ConverseRequestBuilder("No content defined.")
        }
        return Message(from: .user, content: content)
    }

    private func getToolResultId() throws -> String {
        guard let lastMessage = history.last else {
            throw BedrockLibraryError.ConverseRequestBuilder("Cannot set tool result when history is empty")
        }
        guard case .toolUse(let toolUse) = lastMessage.content.last else {
            throw BedrockLibraryError.invalidPrompt("Cannot set tool result when last message is not tool use.")
        }
        return toolUse.id
    }

    private func validateFeature(_ feature: ConverseFeature) throws {
        guard model.hasConverseModality(feature) else {
            throw BedrockLibraryError.invalidModality(
                model,
                try model.getConverseModality(),
                "This model does not support converse feature \(feature)."
            )
        }
    }
}
