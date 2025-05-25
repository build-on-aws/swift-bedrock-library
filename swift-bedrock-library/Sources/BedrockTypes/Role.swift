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

public enum Role: String, Codable, Sendable {
    case user
    case assistant

    public init(from sdkConversationRole: BedrockRuntimeClientTypes.ConversationRole) throws {
        switch sdkConversationRole {
        case .user: self = .user
        case .assistant: self = .assistant
        case .sdkUnknown(let unknownRole):
            throw BedrockServiceError.notImplemented(
                "Role \(unknownRole) is not implemented by BedrockRuntimeClientTypes"
            )
        }
    }

    public func getSDKConversationRole() -> BedrockRuntimeClientTypes.ConversationRole {
        switch self {
        case .user: return .user
        case .assistant: return .assistant
        }
    }
}
