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

import Testing

@testable import BedrockService

@Suite("StabilityAspectRatio nearest mapping")
struct StabilityAspectRatioTests {

    @Test("Square inputs map to 1:1")
    func squareMapsTo1x1() {
        #expect(StabilityAspectRatio.nearest(to: ImageResolution(width: 1024, height: 1024)) == .r1x1)
        #expect(StabilityAspectRatio.nearest(to: ImageResolution(width: 512, height: 512)) == .r1x1)
    }

    @Test("Common landscape resolutions map to 16:9")
    func landscapeMapsTo16x9() {
        #expect(StabilityAspectRatio.nearest(to: ImageResolution(width: 1920, height: 1080)) == .r16x9)
        #expect(StabilityAspectRatio.nearest(to: ImageResolution(width: 1280, height: 720)) == .r16x9)
    }

    @Test("Common portrait resolutions map to 9:16")
    func portraitMapsTo9x16() {
        #expect(StabilityAspectRatio.nearest(to: ImageResolution(width: 1080, height: 1920)) == .r9x16)
        #expect(StabilityAspectRatio.nearest(to: ImageResolution(width: 720, height: 1280)) == .r9x16)
    }

    @Test("Cinematic landscape maps to 21:9")
    func cinematicLandscape() {
        #expect(StabilityAspectRatio.nearest(to: ImageResolution(width: 2520, height: 1080)) == .r21x9)
        #expect(StabilityAspectRatio.nearest(to: ImageResolution(width: 2100, height: 900)) == .r21x9)
    }

    @Test("Cinematic portrait maps to 9:21")
    func cinematicPortrait() {
        #expect(StabilityAspectRatio.nearest(to: ImageResolution(width: 1080, height: 2520)) == .r9x21)
    }

    @Test("3:2 and 2:3 ratios map exactly")
    func r3x2And2x3() {
        #expect(StabilityAspectRatio.nearest(to: ImageResolution(width: 1500, height: 1000)) == .r3x2)
        #expect(StabilityAspectRatio.nearest(to: ImageResolution(width: 1000, height: 1500)) == .r2x3)
    }

    @Test("4:5 and 5:4 ratios map exactly")
    func r4x5And5x4() {
        #expect(StabilityAspectRatio.nearest(to: ImageResolution(width: 1000, height: 1250)) == .r4x5)
        #expect(StabilityAspectRatio.nearest(to: ImageResolution(width: 1250, height: 1000)) == .r5x4)
    }
}

@Suite("StabilityImageResolutionValidator")
struct StabilityImageResolutionValidatorTests {

    private let validator = StabilityImageResolutionValidator()

    @Test("Square resolution passes")
    func squareValid() throws {
        try validator.validateResolution(ImageResolution(width: 1024, height: 1024))
    }

    @Test("21:9 and 9:21 pass at the boundaries")
    func extremeValid() throws {
        try validator.validateResolution(ImageResolution(width: 21, height: 9))
        try validator.validateResolution(ImageResolution(width: 9, height: 21))
    }

    @Test("Zero width is rejected")
    func zeroWidthThrows() {
        #expect(throws: BedrockLibraryError.self) {
            try validator.validateResolution(ImageResolution(width: 0, height: 1024))
        }
    }

    @Test("Zero height is rejected")
    func zeroHeightThrows() {
        #expect(throws: BedrockLibraryError.self) {
            try validator.validateResolution(ImageResolution(width: 1024, height: 0))
        }
    }

    @Test("Ratio more extreme than 21:9 is rejected")
    func tooWideThrows() {
        #expect(throws: BedrockLibraryError.self) {
            try validator.validateResolution(ImageResolution(width: 5000, height: 100))
        }
    }

    @Test("Ratio more extreme than 9:21 is rejected")
    func tooTallThrows() {
        #expect(throws: BedrockLibraryError.self) {
            try validator.validateResolution(ImageResolution(width: 100, height: 5000))
        }
    }
}
