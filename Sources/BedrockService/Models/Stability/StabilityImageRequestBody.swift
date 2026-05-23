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

/// Request body for Stability AI text-to-image models on Amazon Bedrock.
///
/// The Stability InvokeModel schema accepts a flat JSON object with a required
/// `prompt`. Optional fields (`negative_prompt`, `aspect_ratio`, `seed`, `mode`)
/// are omitted from the encoded JSON when they are not set or not supported by
/// the target model — Bedrock rejects unknown or unsupported keys for
/// `stable-image-core` and `stable-image-ultra`.
public struct StabilityImageRequestBody: BedrockBodyCodable {
    let prompt: String
    let negativePrompt: String?
    let aspectRatio: String?
    let seed: Int?
    let outputFormat: String
    let mode: String?

    private enum CodingKeys: String, CodingKey {
        case prompt
        case negativePrompt = "negative_prompt"
        case aspectRatio = "aspect_ratio"
        case seed
        case outputFormat = "output_format"
        case mode
    }

    /// Creates a text-to-image request body for a Stability model.
    ///
    /// - Parameters:
    ///   - prompt: The text description of the image to generate.
    ///   - negativePrompt: Text describing what to avoid. Pass `nil` for models that do not
    ///     support this field (`stable-image-core`, `stable-image-ultra`).
    ///   - aspectRatio: The closest supported aspect ratio for the desired resolution.
    ///   - seed: A seed for reproducible generation in the range `0...4_294_967_295`.
    ///   - mode: Generation mode for `sd3-5-large` (`text-to-image` / `image-to-image`).
    ///     Pass `nil` for models that do not support this field.
    public static func textToImage(
        prompt: String,
        negativePrompt: String?,
        aspectRatio: StabilityAspectRatio?,
        seed: Int?,
        mode: String?
    ) -> Self {
        StabilityImageRequestBody(
            prompt: prompt,
            negativePrompt: negativePrompt,
            aspectRatio: aspectRatio?.rawValue,
            seed: seed,
            outputFormat: "png",
            mode: mode
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(prompt, forKey: .prompt)
        try container.encode(outputFormat, forKey: .outputFormat)
        if let negativePrompt {
            try container.encode(negativePrompt, forKey: .negativePrompt)
        }
        if let aspectRatio {
            try container.encode(aspectRatio, forKey: .aspectRatio)
        }
        if let seed {
            try container.encode(seed, forKey: .seed)
        }
        if let mode {
            try container.encode(mode, forKey: .mode)
        }
    }
}
