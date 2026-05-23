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

import Foundation
import Testing

@testable import BedrockService

@Suite("Stability request body encoding")
struct StabilityRequestBodyTests {

    private func encodeToDictionary(_ body: StabilityImageRequestBody) throws -> [String: Any] {
        let data = try JSONEncoder().encode(body)
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        return try #require(json as? [String: Any])
    }

    @Test("Core/Ultra body: only prompt and output_format are present")
    func minimalCoreBody() throws {
        let body = StabilityImageRequestBody.textToImage(
            prompt: "hello",
            negativePrompt: nil,
            aspectRatio: nil,
            seed: nil,
            mode: nil
        )
        let dict = try encodeToDictionary(body)

        #expect(dict["prompt"] as? String == "hello")
        #expect(dict["output_format"] as? String == "png")
        #expect(dict["negative_prompt"] == nil)
        #expect(dict["aspect_ratio"] == nil)
        #expect(dict["seed"] == nil)
        #expect(dict["mode"] == nil)
    }

    @Test("Aspect ratio is encoded when set")
    func encodesAspectRatio() throws {
        let body = StabilityImageRequestBody.textToImage(
            prompt: "hello",
            negativePrompt: nil,
            aspectRatio: .r16x9,
            seed: nil,
            mode: nil
        )
        let dict = try encodeToDictionary(body)
        #expect(dict["aspect_ratio"] as? String == "16:9")
    }

    @Test("Seed is encoded when set")
    func encodesSeed() throws {
        let body = StabilityImageRequestBody.textToImage(
            prompt: "hello",
            negativePrompt: nil,
            aspectRatio: nil,
            seed: 42,
            mode: nil
        )
        let dict = try encodeToDictionary(body)
        #expect(dict["seed"] as? Int == 42)
    }

    @Test("SD 3.5 body includes negative_prompt and mode")
    func sd35Body() throws {
        let body = StabilityImageRequestBody.textToImage(
            prompt: "hello",
            negativePrompt: "blurry",
            aspectRatio: .r1x1,
            seed: 7,
            mode: "text-to-image"
        )
        let dict = try encodeToDictionary(body)

        #expect(dict["prompt"] as? String == "hello")
        #expect(dict["negative_prompt"] as? String == "blurry")
        #expect(dict["mode"] as? String == "text-to-image")
        #expect(dict["aspect_ratio"] as? String == "1:1")
        #expect(dict["seed"] as? Int == 7)
        #expect(dict["output_format"] as? String == "png")
    }

    @Test("output_format is always present and equal to png")
    func outputFormatIsAlwaysPng() throws {
        let body = StabilityImageRequestBody.textToImage(
            prompt: "x",
            negativePrompt: nil,
            aspectRatio: nil,
            seed: nil,
            mode: nil
        )
        let dict = try encodeToDictionary(body)
        #expect(dict["output_format"] as? String == "png")
    }
}
