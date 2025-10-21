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

/// Implementation of EmbeddingsModality for Amazon Titan embedding models
///
/// TitanEmbeddings provides text embedding generation capabilities using Amazon's Titan models,
/// supporting configurable vector dimensions and normalization options.
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
        try JSONDecoder().decode(TitanEmbeddingsResponseBody.self, from: data)
    }
}
