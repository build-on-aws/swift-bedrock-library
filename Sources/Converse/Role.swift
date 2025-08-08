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

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

public struct Role: Codable, Sendable, Equatable, CustomStringConvertible {
    private enum RoleType: Codable, Sendable, Equatable {
        case user
        case assistant
    }

    private let type: RoleType

    public init(from sdkConversationRole: BedrockRuntimeClientTypes.ConversationRole) throws {
        switch sdkConversationRole {
        case .user: self.type = .user
        case .assistant: self.type = .assistant
        case .sdkUnknown(let unknownRole):
            throw BedrockLibraryError.notImplemented(
                "Role \(unknownRole) is not implemented by BedrockRuntimeClientTypes"
            )
        }
    }

    public func getSDKConversationRole() -> BedrockRuntimeClientTypes.ConversationRole {
        switch self.type {
        case .user: return .user
        case .assistant: return .assistant
        }
    }

    // custom encoding and decoding to handle string value with a "type" field
    //
    //     "message":{
    //     "content":[
    //         {"text":"This is the textcompletion for: This is a test"}
    //     ],
    //     "role":"assistant"
    // }},
    //
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let role = try container.decode(String.self)
        switch role {
        case "user": self.type = .user
        case "assistant": self.type = .assistant
        default:
            throw BedrockLibraryError.decodingError(
                "Role \(role) is not a valid role"
            )
        }
    }
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self.type {
        case .user: try container.encode("user")
        case .assistant: try container.encode("assistant")
        }
    }
    /// Returns the type of the role as a string.
    public var description: String {
        switch self.type {
        case .user: return "user"
        case .assistant: return "assistant"
        }
    }

    // Equatable
    public static func == (lhs: Role, rhs: Role) -> Bool {
        lhs.type == rhs.type
    }

    // convenience static properties for common roles
    private init(_ type: RoleType) {
        self.type = type
    }
    public static let user = Role(.user)
    public static let assistant = Role(.assistant)
}
