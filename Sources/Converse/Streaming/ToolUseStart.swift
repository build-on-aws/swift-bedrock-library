// //===----------------------------------------------------------------------===//
// //
// // This source file is part of the Swift Bedrock Library open source project
// //
// // Copyright (c) 2025 Amazon.com, Inc. or its affiliates
// //                    and the Swift Bedrock Library project authors
// // Licensed under Apache License v2.0
// //
// // See LICENSE.txt for license information
// // See CONTRIBUTORS.txt for the list of Swift Bedrock Library project authors
// //
// // SPDX-License-Identifier: Apache-2.0
// //
// //===----------------------------------------------------------------------===//

@preconcurrency import AWSBedrockRuntime

package struct ToolUseStart: Sendable {
    var index: Int
    var name: String
    var id: String

    private init(index: Int, sdkToolUseStart: BedrockRuntimeClientTypes.ToolUseBlockStart) throws {
        guard let name = sdkToolUseStart.name else {
            throw BedrockLibraryError.invalidSDKType("No name found in ToolUseBlockStart")
        }
        guard let toolUseId = sdkToolUseStart.toolUseId else {
            throw BedrockLibraryError.invalidSDKType("No toolUseId found in ToolUseBlockStart")
        }
        self.index = index
        self.name = name
        self.id = toolUseId
    }
    package init(index: Int, sdkEventBlockStart: BedrockRuntimeClientTypes.ContentBlockStart?) throws {
        guard let sdkEventBlockStart else {
            throw BedrockLibraryError.invalidSDKType("No ContentBlockStart found in ToolUseStart")
        }
        if case .tooluse(let sdkToolUseStart) = sdkEventBlockStart {
            try self.init(index: index, sdkToolUseStart: sdkToolUseStart)
        } else {
            throw BedrockLibraryError.invalidSDKType("ContentBlockStart is not a ToolUseStart")
        }
    }
}
