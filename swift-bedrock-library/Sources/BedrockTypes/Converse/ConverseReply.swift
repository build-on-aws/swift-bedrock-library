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

public struct ConverseReply: Codable, CustomStringConvertible {
    let history: History
    let textReply: String?
    let toolUse: ToolUseBlock?
    let imageBlock: ImageBlock?
    let videoBlock: VideoBlock?
    let reasoningBlock: Reasoning?
    let encryptedReasoning: EncryptedReasoning?

    public var description: String {
        if let textReply {
            return textReply
        } else {
            let lastMessage = getLastMessage()
            return lastMessage.content.description
        }
    }

    // MARK: Initializers

    public init(_ history: History) throws {
        guard let lastMessage = history.last else {
            throw BedrockServiceError.invalidConverseReply("The provided history is not allowed to be empty.")
        }
        guard lastMessage.role == .assistant else {
            throw BedrockServiceError.invalidConverseReply("The last message in the history is not from the assistant.")
        }
        self.history = history
        self.textReply = try? ConverseReply.getTextReply(lastMessage)
        self.toolUse = try? ConverseReply.getToolUse(lastMessage)
        self.imageBlock = try? ConverseReply.getImageBlock(lastMessage)
        self.videoBlock = try? ConverseReply.getVideoBlock(lastMessage)
        self.reasoningBlock = try? ConverseReply.getReasoningBlock(lastMessage)
        self.encryptedReasoning = try? ConverseReply.getEncryptedReasoning(lastMessage)
    }

    // MARK: Public functions

    /// Returns the conversation history
    public func getHistory() -> History { history }

    /// Returns the latest message
    public func getLastMessage() -> Message { history.last! }

    /// Returns the latest text reply or throws if the latest message does not contain a text reply
    public func getTextReply() throws -> String {
        guard let textReply else {
            throw BedrockServiceError.invalidConverseReply("No text block found in last message.")
        }
        return textReply
    }

    /// Returns the latest tool use request or throws if the latest message does not contain a tool use request
    public func getToolUse() throws -> ToolUseBlock {
        guard let toolUse else {
            throw BedrockServiceError.invalidConverseReply("No ToolUse block found in last message.")
        }
        return toolUse
    }

    /// Returns the latest image block or throws if the latest message does not contain an image block
    public func getImageBlock() throws -> ImageBlock {
        guard let imageBlock else {
            throw BedrockServiceError.invalidConverseReply("No Image block found in last message.")
        }
        return imageBlock
    }

    /// Returns the latest video block or throws if the latest message does not contain a video block
    public func getVideoBlock() throws -> VideoBlock {
        guard let videoBlock else {
            throw BedrockServiceError.invalidConverseReply("No Video block found in last message.")
        }
        return videoBlock
    }

    /// Returns the latest reasoning block or throws if the latest message does not contain a reasoning block
    public func getReasoningBlock() throws -> Reasoning {
        guard let reasoningBlock else {
            throw BedrockServiceError.invalidConverseReply("No Reasoning block found in last message.")
        }
        return reasoningBlock
    }

    // MARK: Private functions

    static private func getTextReply(_ reply: Message) throws -> String {
        for content in reply.content {
            if case .text(let text) = content {
                return text
            }
        }
        throw BedrockServiceError.invalidConverseReply("No text block found in last message.")
    }

    static private func getToolUse(_ reply: Message) throws -> ToolUseBlock {
        for content in reply.content {
            if case .toolUse(let block) = content {
                return block
            }
        }
        throw BedrockServiceError.invalidConverseReply("No ToolUse block found in last message.")
    }

    static private func getImageBlock(_ reply: Message) throws -> ImageBlock {
        for content in reply.content {
            if case .image(let block) = content {
                return block
            }
        }
        throw BedrockServiceError.invalidConverseReply("No Image block found in last message.")
    }

    static private func getVideoBlock(_ reply: Message) throws -> VideoBlock {
        for content in reply.content {
            if case .video(let block) = content {
                return block
            }
        }
        throw BedrockServiceError.invalidConverseReply("No Video block found in last message.")
    }

    static private func getReasoningBlock(_ reply: Message) throws -> Reasoning {
        for content in reply.content {
            if case .reasoning(let block) = content {
                return block
            }
        }
        throw BedrockServiceError.invalidConverseReply("No Reasoning block found in last message.")
    }

    static private func getEncryptedReasoning(_ reply: Message) throws -> EncryptedReasoning {
        for content in reply.content {
            if case .encryptedReasoning(let block) = content {
                return block
            }
        }
        throw BedrockServiceError.invalidConverseReply("No EncryptedReasoning found in last message.")
    }
}

/// StringInterpolation for ConverseReply, returns textReply if not nil, throws if textReply is nil
extension String.StringInterpolation {
    mutating func appendInterpolation(_ reply: ConverseReply) throws {
        guard let text = reply.textReply else {
            throw BedrockServiceError.invalidConverseReply("No text block found in last message.")
        }
        appendLiteral(text)
    }
}
