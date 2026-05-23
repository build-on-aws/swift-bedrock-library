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

@Suite("Stability response body decoding")
struct StabilityResponseBodyTests {

    private static let onePixelPNGBase64 =
        "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII="

    @Test("Decodes images, seeds, and finish_reasons")
    func decodesValidPayload() throws {
        let json = """
            {
                "seeds": [42],
                "finish_reasons": [null],
                "images": ["\(Self.onePixelPNGBase64)"]
            }
            """.data(using: .utf8)!

        let body = try JSONDecoder().decode(StabilityImageResponseBody.self, from: json)
        let output = body.getGeneratedImage()

        #expect(output.images.count == 1)
        let original = Data(base64Encoded: Self.onePixelPNGBase64)!
        #expect(output.images.first == original)
    }

    @Test("Malformed base64 yields no decoded images")
    func malformedBase64() throws {
        let json = """
            {
                "seeds": [0],
                "finish_reasons": [null],
                "images": ["@@@not-valid-base64@@@"]
            }
            """.data(using: .utf8)!

        let body = try JSONDecoder().decode(StabilityImageResponseBody.self, from: json)
        let output = body.getGeneratedImage()
        #expect(output.images.isEmpty)
    }

    @Test("Missing optional fields decode to nil")
    func missingOptionals() throws {
        let json = """
            { "images": ["\(Self.onePixelPNGBase64)"] }
            """.data(using: .utf8)!

        let body = try JSONDecoder().decode(StabilityImageResponseBody.self, from: json)
        #expect(body.seeds == nil)
        #expect(body.finishReasons == nil)
        #expect(body.images.count == 1)
    }
}
