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

// MARK: text generation
// https://docs.aws.amazon.com/bedrock/latest/userguide/titan-embedding-models.html

typealias TitanEmbeddingsV2 = TitanEmbeddings

extension BedrockModel {
    public static let titan_embed_text_v2: BedrockModel = BedrockModel(
        id: "amazon.titan-embed-text-v2:0",
        name: "Amazon Titan Text Embeddings V2",
        modality: TitanEmbeddingsV2(
            parameters: EmbeddingsParameters(
                maxInputTokens: Parameter(.maxInputTextToken, defaultValue: 8192),
                maxInputChars: Parameter(.maxInputTextChar, defaultValue: 50000),
                outputVectorSize: Parameter(.outputVectorSize, minValue: 256, maxValue: 1024, defaultValue: 1024),
                maxPromptSize: 50000
            )
        )
    )
}