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

/// Response body for Stability AI text-to-image models on Amazon Bedrock.
///
/// Stability returns exactly one image per call as a base64-encoded string.
/// The library decodes those strings into `Data` so the public
/// `ImageGenerationOutput` shape matches other providers.
public struct StabilityImageResponseBody: ContainsImageGeneration {
    let images: [String]
    let seeds: [Int]?
    let finishReasons: [String?]?

    private enum CodingKeys: String, CodingKey {
        case images
        case seeds
        case finishReasons = "finish_reasons"
    }

    public func getGeneratedImage() -> ImageGenerationOutput {
        let datas: [Data] = images.compactMap { Data(base64Encoded: $0) }
        return ImageGenerationOutput(images: datas)
    }
}
