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

import BedrockService
import Logging

@main
struct Main {
    static func main() async throws {
        do {
            try await Main.embed()
        } catch {
            print("Error:\n\(error)")
        }
    }
    static func embed() async throws {
        var logger = Logger(label: "Embeddings")
        logger.logLevel = .debug

        let bedrock = try await BedrockService(
            region: .useast1,
            logger: logger,
        )

        // select a model that supports the embeddings modality
        // models must be enabled in your AWS account
        let model: BedrockModel = .titan_embed_text_v2

        guard model.hasEmbeddingsModality() else {
            throw MyError.incorrectModality("\(model.name) does not support embeddings")
        }

        // send the request
        let reply = try await bedrock.embed("Hello, Vector World", with: model)

        print(reply)
    }

    enum MyError: Error {
        case incorrectModality(String)
    }
}
