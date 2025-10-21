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

/// A protocol defining the interface for models that support embeddings generation
/// 
/// Embeddings modalities can convert text into numerical vector representations
/// that capture semantic meaning for use in machine learning tasks.
public protocol EmbeddingsModality: Modality {

    /// Returns the parameters configuration for embeddings generation
    /// - Returns: EmbeddingsParameters containing model-specific parameter constraints
    func getParameters() -> EmbeddingsParameters

    /// Creates a request body for embeddings generation
    /// - Parameters:
    ///   - text: The input text to generate embeddings for
    ///   - vectorSize: The desired size of the output embedding vector
    ///   - normalize: Whether to normalize the embedding vector
    /// - Returns: A BedrockBodyCodable request body for the embeddings API
    /// - Throws: BedrockLibraryError if the parameters are invalid
    func getEmbeddingsRequestBody(
        text: String,
        vectorSize: Int,
        normalize: Bool
    ) throws -> BedrockBodyCodable

    /// Parses the response data from an embeddings API call
    /// - Parameter data: The raw response data from the embeddings API
    /// - Returns: A ContainsEmbeddings object containing the generated embeddings
    /// - Throws: DecodingError if the response cannot be parsed
    func getEmbeddingsResponseBody(from data: Data) throws -> ContainsEmbeddings
}
