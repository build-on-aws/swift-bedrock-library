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

@preconcurrency import AWSBedrockRuntime
import Foundation

public struct Message: Codable, CustomStringConvertible, Sendable {
    public let role: Role
    public let content: [Content]

    // MARK - initializers

    public init(from role: Role, content: [Content]) {
        self.role = role
        self.content = content
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
            throw BedrockServiceError.decodingError("Could not extract role from BedrockRuntimeClientTypes.Message")
        }
        guard let sdkContent = sdkMessage.content else {
            throw BedrockServiceError.decodingError("Could not extract content from BedrockRuntimeClientTypes.Message")
        }
        let content: [Content] = try sdkContent.map { try Content(from: $0) }
        self = Message(from: try Role(from: sdkRole), content: content)
    }

    public init(_ response: ConverseOutput) throws {
        guard let output = response.output else {
            throw BedrockServiceError.invalidSDKResponse(
                "Something went wrong while extracting ConverseOutput from response."
            )
        }
        guard case .message(let sdkMessage) = output else {
            throw BedrockServiceError.invalidSDKResponse("Could not extract message from ConverseOutput")
        }
        self = try Message(from: sdkMessage)
    }

    // MARK - CustomStringConvertible

    public var description: String {
        let contentDescription = content.map { $0.description }.joined(separator: " - ")
        return "- \(role): [\(contentDescription)]"
    }

    // MARK - public functions

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
}
