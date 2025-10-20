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

struct TitanEmbeddings: EmbeddingsModality {
    func getName() -> String { "Titan Embeddings" }

    let parameters: EmbeddingsParameters

    init(parameters: EmbeddingsParameters) {
        self.parameters = parameters
    }

    func getParameters() -> EmbeddingsParameters {
        parameters
    }

    func getEmbeddingsRequestBody(
        text: String,
        vectorSize: Int,
        normalize: Bool,
    ) throws -> BedrockBodyCodable {
        TitanEmbeddingsBody(
            prompt: text,
            dimensions: vectorSize,
            normalize: normalize
        )
    }

    func getEmbeddingsResponseBody(from data: Data) throws -> ContainsEmbeddings {
        let decoder = JSONDecoder()
        return try decoder.decode(TitanEmbeddingsResponseBody.self, from: data)
    }
}
