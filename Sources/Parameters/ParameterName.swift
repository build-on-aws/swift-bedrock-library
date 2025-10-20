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

public enum ParameterName: Sendable {
    case maxTokens
    case temperature
    case topK
    case topP
    case nrOfImages
    case images
    case similarity
    case cfgScale
    case seed
    case resolution
    case maxReasoningTokens

    // embeddings model
    case maxInputTextToken
    case maxInputTextChar
    case outputVectorSize
}
