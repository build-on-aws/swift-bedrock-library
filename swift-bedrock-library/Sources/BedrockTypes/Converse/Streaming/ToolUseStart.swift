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

package struct ToolUseStart: Sendable {
    var index: Int
    var name: String
    var toolUseId: String

    init(index: Int, sdkToolUseStart: BedrockRuntimeClientTypes.ToolUseBlockStart) throws {
        guard let name = sdkToolUseStart.name else {
            throw BedrockServiceError.invalidSDKType("No name found in ToolUseBlockStart")
        }
        guard let toolUseId = sdkToolUseStart.toolUseId else {
            throw BedrockServiceError.invalidSDKType("No toolUseId found in ToolUseBlockStart")
        }
        self.index = index
        self.name = name
        self.toolUseId = toolUseId
    }
}

public struct ToolUsePart: Sendable {
    var index: Int
    var name: String
    var toolUseId: String
    var inputPart: String

    // init(index: Int, sdkToolUseStart: BedrockRuntimeClientTypes.ToolUseBlockStart) throws {
    //     guard let name = sdkToolUseStart.name else {
    //         throw BedrockServiceError.invalidSDKType("No name found in ToolUseBlockStart")
    //     }
    //     guard let toolUseId = sdkToolUseStart.toolUseId else {
    //         throw BedrockServiceError.invalidSDKType("No toolUseId found in ToolUseBlockStart")
    //     }
    //     self.index = index
    //     self.name = name
    //     self.toolUseId = toolUseId
    // }
}
