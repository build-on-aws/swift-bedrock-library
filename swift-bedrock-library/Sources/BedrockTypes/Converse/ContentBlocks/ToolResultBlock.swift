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

public struct ToolResultBlock: Codable, Sendable {
    public let id: String
    public let content: [Content]
    public let status: Status?  // currently only supported by Anthropic Claude 3 models

    public init(id: String, content: [Content], status: Status? = nil) {
        self.id = id
        self.content = content
        self.status = status
    }

    /// convenience initializer for ToolResultBlock with only an id and a String
    public init(_ prompt: String, id: String, status: Status? = .success) {
        self.init(id: id, content: [.text(prompt)], status: status)
    }

    /// convenience initializer for ToolResultBlock with only an id and a JSON
    public init(_ json: JSON, id: String, status: Status? = .success) {
        self.init(id: id, content: [.json(json)], status: status)
    }

    /// convenience initializer for ToolResultBlock with only an id and a ImageBlock
    public init(_ image: ImageBlock, id: String, status: Status? = .success) {
        self.init(id: id, content: [.image(image)], status: status)
    }

    /// convenience initializer for ToolResultBlock with only an id and a DocumentBlock
    public init(_ document: DocumentBlock, id: String, status: Status? = .success) {
        self.init(id: id, content: [.document(document)], status: status)
    }

    /// convenience initializer for ToolResultBlock with only an id and a VideoBlock
    public init(_ video: VideoBlock, id: String, status: Status? = .success) {
        self.init(id: id, content: [.video(video)], status: status)
    }

    /// convenience initializer for ToolResultBlock with failed request
    public static func failed(_ id: String) -> Self {
        self.init(id: id, content: [], status: .error)
    }

    /// convenience initializer for ToolResultBlock for Data
    public init(_ data: Data, id: String, status: Status? = .success) throws {
        guard let json = try? JSON(from: data) else {
            throw BedrockServiceError.decodingError("Could not decode JSON from Data")
        }
        self.init(json, id: id, status: status)
    }

    /// convenience initializer for ToolResultBlock for any Codable
    public init<T: Codable>(_ object: T, id: String, status: Status? = .success) throws {
        guard let data = try? JSONEncoder().encode(object) else {
            throw BedrockServiceError.encodingError("Could not encode object to JSON")
        }
        try self.init(data, id: id, status: status)
    }

    public init(from sdkToolResultBlock: BedrockRuntimeClientTypes.ToolResultBlock) throws {
        guard let sdkToolResultContent = sdkToolResultBlock.content else {
            throw BedrockServiceError.decodingError(
                "Could not extract content from BedrockRuntimeClientTypes.ToolResultBlock"
            )
        }
        guard let id = sdkToolResultBlock.toolUseId else {
            throw BedrockServiceError.decodingError(
                "Could not extract toolUseId from BedrockRuntimeClientTypes.ToolResultBlock"
            )
        }
        let sdkToolStatus: BedrockRuntimeClientTypes.ToolResultStatus? = sdkToolResultBlock.status
        var status: Status? = nil
        if let sdkToolStatus = sdkToolStatus {
            status = try Status(from: sdkToolStatus)
        }
        let toolContents = try sdkToolResultContent.map { try Content(from: $0) }
        self = ToolResultBlock(id: id, content: toolContents, status: status)
    }

    public func getSDKToolResultBlock() throws -> BedrockRuntimeClientTypes.ToolResultBlock {
        BedrockRuntimeClientTypes.ToolResultBlock(
            content: try content.map { try $0.getSDKToolResultContentBlock() },
            status: status?.getSDKToolStatus(),
            toolUseId: id
        )
    }

    public enum Status: Codable, Sendable {
        case success
        case error

        init(from sdkToolStatus: BedrockRuntimeClientTypes.ToolResultStatus) throws {
            switch sdkToolStatus {
            case .success: self = .success
            case .error: self = .error
            default:
                throw BedrockServiceError.notImplemented(
                    "ToolStatus \(sdkToolStatus) is not implemented by BedrockService or not implemented by BedrockRuntimeClientTypes in case of `sdkUnknown`"
                )
            }
        }

        func getSDKToolStatus() -> BedrockRuntimeClientTypes.ToolResultStatus {
            switch self {
            case .success: .success
            case .error: .error
            }
        }
    }

    public enum Content: Sendable {
        case json(JSON)
        case text(String)
        case image(ImageBlock)  // currently only supported by Anthropic Claude 3 models
        case document(DocumentBlock)
        case video(VideoBlock)

        init(from sdkToolResultContent: BedrockRuntimeClientTypes.ToolResultContentBlock) throws {
            switch sdkToolResultContent {
            case .document(let sdkDocumentBlock):
                self = .document(try DocumentBlock(from: sdkDocumentBlock))
            case .image(let sdkImageBlock):
                self = .image(try ImageBlock(from: sdkImageBlock))
            case .text(let text):
                self = .text(text)
            case .video(let sdkVideoBlock):
                self = .video(try VideoBlock(from: sdkVideoBlock))
            case .json(let document):
                self = .json(try document.toJSON())
            default:
                throw BedrockServiceError.notImplemented(
                    "ToolResultContent \(sdkToolResultContent) is not implemented by BedrockService or not implemented by BedrockRuntimeClientTypes in case of `sdkUnknown`"
                )
            }
        }

        func getSDKToolResultContentBlock() throws -> BedrockRuntimeClientTypes.ToolResultContentBlock {
            switch self {
            case .json(let json):
                .json(try json.toDocument())
            case .document(let documentBlock):
                .document(try documentBlock.getSDKDocumentBlock())
            case .image(let imageBlock):
                .image(try imageBlock.getSDKImageBlock())
            case .text(let text):
                .text(text)
            case .video(let videoBlock):
                .video(try videoBlock.getSDKVideoBlock())
            }
        }
    }
}

extension ToolResultBlock.Content: Codable {
    private enum CodingKeys: String, CodingKey {
        case json, text, image, document, video
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .json(let json):
            try container.encode(json, forKey: .json)
        case .text(let text):
            try container.encode(text, forKey: .text)
        case .image(let image):
            try container.encode(image, forKey: .image)
        case .document(let doc):
            try container.encode(doc, forKey: .document)
        case .video(let video):
            try container.encode(video, forKey: .video)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let json = try container.decodeIfPresent(JSON.self, forKey: .json) {
            self = .json(json)
        } else if let text = try container.decodeIfPresent(String.self, forKey: .text) {
            self = .text(text)
        } else if let image = try container.decodeIfPresent(ImageBlock.self, forKey: .image) {
            self = .image(image)
        } else if let doc = try container.decodeIfPresent(DocumentBlock.self, forKey: .document) {
            self = .document(doc)
        } else if let video = try container.decodeIfPresent(VideoBlock.self, forKey: .video) {
            self = .video(video)
        } else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Invalid tool result content"
                )
            )
        }
    }
}
