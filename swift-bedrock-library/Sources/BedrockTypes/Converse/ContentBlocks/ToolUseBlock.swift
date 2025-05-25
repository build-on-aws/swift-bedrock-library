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

public struct ToolUseBlock: Codable, Sendable {
    public let id: String
    public let name: String
    public let input: JSON

    public init(id: String, name: String, input: JSON) {
        self.id = id
        self.name = name
        self.input = input
    }

    public init(from sdkToolUseBlock: BedrockRuntimeClientTypes.ToolUseBlock) throws {
        guard let sdkId = sdkToolUseBlock.toolUseId else {
            throw BedrockServiceError.decodingError(
                "Could not extract toolUseId from BedrockRuntimeClientTypes.ToolUseBlock"
            )
        }
        guard let sdkName = sdkToolUseBlock.name else {
            throw BedrockServiceError.decodingError(
                "Could not extract name from BedrockRuntimeClientTypes.ToolUseBlock"
            )
        }
        guard let sdkInput = sdkToolUseBlock.input else {
            throw BedrockServiceError.decodingError(
                "Could not extract input from BedrockRuntimeClientTypes.ToolUseBlock"
            )
        }
        self = ToolUseBlock(
            id: sdkId,
            name: sdkName,
            input: try sdkInput.toJSON()
        )
    }

    public func getSDKToolUseBlock() throws -> BedrockRuntimeClientTypes.ToolUseBlock {
        .init(
            input: try input.toDocument(),
            name: name,
            toolUseId: id
        )
    }
}
