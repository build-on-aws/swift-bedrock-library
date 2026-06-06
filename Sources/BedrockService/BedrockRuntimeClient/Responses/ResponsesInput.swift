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

struct ResponsesRequestBody: Codable, Sendable {
    let model: BedrockModel
    let input: [ResponsesMessage]
    let store: Bool?

    init(model: BedrockModel, input: [ResponsesMessage], store: Bool? = nil) {
        self.model = model
        self.input = input
        self.store = store
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(model.id, forKey: .model)
        try container.encode(input, forKey: .input)
        try container.encodeIfPresent(store, forKey: .store)
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let modelId = try container.decode(String.self, forKey: .model)
        guard let model = BedrockModel(rawValue: modelId) else {
            throw BedrockLibraryError.notFound("Unknown model: \(modelId)")
        }
        self.model = model
        self.input = try container.decode([ResponsesMessage].self, forKey: .input)
        self.store = try container.decodeIfPresent(Bool.self, forKey: .store)
    }

    private enum CodingKeys: String, CodingKey {
        case model
        case input
        case store
    }
}

public struct ResponsesMessage: Codable, Sendable {
    public let role: Role
    public let content: String

    public init(role: Role, content: String) {
        self.role = role
        self.content = content
    }
}
