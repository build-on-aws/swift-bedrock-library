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
import Foundation

/// # Stability AI Image Generation Example
///
/// Generates a single PNG image with Stable Image Core in `us-west-2` and writes
/// it to `out.png` in the current working directory.
///
/// Stability models on Bedrock differ from Nova Canvas:
/// - exactly one image per call
/// - no `cfgScale`, `quality`, or `negativePrompt` (except `sd3-5-large`)
/// - `resolution` is mapped internally to the closest supported aspect ratio
@main
struct StabilityImageExample {

    static func main() async throws {
        let bedrock = try await BedrockService(region: .uswest2)

        let prompt = "A serene landscape with mountains at sunset, photorealistic"
        print("Generating image for prompt: \(prompt)")

        let output = try await bedrock.generateImage(
            prompt,
            with: .stable_image_core,
            seed: 42,
            resolution: ImageResolution(width: 1920, height: 1080)
        )

        guard let png = output.images.first else {
            print("No image returned by the model")
            return
        }

        let url = URL(fileURLWithPath: "out.png")
        try png.write(to: url)
        print("Wrote \(png.count) bytes to \(url.path)")
    }
}
