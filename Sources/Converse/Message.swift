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

public struct Message: Codable, CustomStringConvertible, Sendable {

    // https://docs.aws.amazon.com/bedrock/latest/APIReference/API_runtime_MessageStopEvent.html
    // end_turn | tool_use | max_tokens | stop_sequence | guardrail_intervened | content_filtered
    public enum StopReason: Codable, Sendable {
        case endTurn
        case toolUse
        case maxTokens
        case stopSequence
        case guardrailIntervened
        case contentFiltered
    }
    public let role: Role
    public let content: [Content]
    public let stopReason: StopReason?

    // MARK - initializers

    public init(from role: Role, content: [Content], stopReason: StopReason? = nil) {
        self.role = role
        self.content = content
        self.stopReason = stopReason
    }

    /// convenience initializer for message with only a user prompt
    public init(_ prompt: String) {
        self.init(from: .user, content: [.text(prompt)])
    }

    /// convenience initializer for message from the user with only a ToolResultBlock
    public init(_ toolResult: ToolResultBlock) {
        self.init(from: .user, content: [.toolResult(toolResult)])
    }

    /// convenience initializer for message from the assistant with only a ToolUseBlock
    public init(_ toolUse: ToolUseBlock) {
        self.init(from: .assistant, content: [.toolUse(toolUse)])
    }

    /// convenience initializer for message with only an ImageBlock
    public init(_ imageBlock: ImageBlock) {
        self.init(from: .user, content: [.image(imageBlock)])
    }

    /// convenience initializer for message with an ImageBlock.Format and imageBytes
    public init(imageFormat: ImageBlock.Format, imageBytes: String) throws {
        self.init(from: .user, content: [.image(try ImageBlock(format: imageFormat, source: imageBytes))])
    }

    /// convenience initializer for message with an ImageBlock and a user prompt
    public init(_ prompt: String, imageBlock: ImageBlock) {
        self.init(from: .user, content: [.text(prompt), .image(imageBlock)])
    }

    /// convenience initializer for message with a user prompt, an ImageBlock.Format and imageBytes
    public init(_ prompt: String, imageFormat: ImageBlock.Format, imageBytes: String) throws {
        self.init(
            from: .user,
            content: [.text(prompt), .image(try ImageBlock(format: imageFormat, source: imageBytes))]
        )
    }

    public init(from sdkMessage: BedrockRuntimeClientTypes.Message) throws {
        guard let sdkRole = sdkMessage.role else {
            throw BedrockLibraryError.decodingError("Could not extract role from BedrockRuntimeClientTypes.Message")
        }
        guard let sdkContent = sdkMessage.content else {
            throw BedrockLibraryError.decodingError("Could not extract content from BedrockRuntimeClientTypes.Message")
        }
        let content: [Content] = try sdkContent.map { try Content(from: $0) }
        self = Message(from: try Role(from: sdkRole), content: content)
    }

    public init(_ response: ConverseOutput) throws {
        guard let output = response.output else {
            throw BedrockLibraryError.invalidSDKResponse(
                "Something went wrong while extracting ConverseOutput from response."
            )
        }
        guard case .message(let sdkMessage) = output else {
            throw BedrockLibraryError.invalidSDKResponse("Could not extract message from ConverseOutput")
        }
        self = try Message(from: sdkMessage)
    }

    // MARK - CustomStringConvertible

    public var description: String {
        let contentDescription = content.map { $0.description }.joined(separator: " - ")
        return "- \(role): [\(contentDescription)]"
    }

    // MARK - public functions

    public func hasToolUse() -> Bool {
        content.contains { $0.isToolUse() }
    }
    public func getToolUse() -> ToolUseBlock? {
        let content = content.first(where: { $0.isToolUse() })
        if case .toolUse(let block) = content {
            return block
        } else {
            return nil
        }
    }
    public func hasTextContent() -> Bool {
        content.contains { $0.isText() }
    }
    public func hasImageContent() -> Bool {
        content.contains { $0.isImage() }
    }
    public func hasVideoContent() -> Bool {
        content.contains { $0.isVideo() }
    }
    public func hasReasoningContent() -> Bool {
        content.contains { $0.isReasoning() }
    }
    public func hasEncryptedReasoningContent() -> Bool {
        content.contains { $0.isEncryptedReasoning() }
    }
    public func hasToolResult() -> Bool {
        content.contains { $0.isToolResult() }
    }

    public func getSDKMessage() throws -> BedrockRuntimeClientTypes.Message {
        let contentBlocks: [BedrockRuntimeClientTypes.ContentBlock] = try content.map {
            content -> BedrockRuntimeClientTypes.ContentBlock in
            try content.getSDKContentBlock()
        }
        return BedrockRuntimeClientTypes.Message(
            content: contentBlocks,
            role: role.getSDKConversationRole()
        )
    }

    public static func stopReason(fromSDK sdkStopReason: BedrockRuntimeClientTypes.StopReason?) -> StopReason? {
        switch sdkStopReason {
        case .endTurn:
            return .endTurn
        case .toolUse:
            return .toolUse
        case .maxTokens:
            return .maxTokens
        case .stopSequence:
            return .stopSequence
        case .guardrailIntervened:
            return .guardrailIntervened
        case .contentFiltered:
            return .contentFiltered
        default:
            return nil
        }
    }

}
