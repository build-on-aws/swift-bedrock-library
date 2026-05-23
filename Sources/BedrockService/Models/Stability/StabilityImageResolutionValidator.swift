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

/// Validates resolutions for Stability AI image generation models.
///
/// Stability models do not enforce explicit pixel dimensions on input — the model
/// picks dimensions from a closest-matching `aspect_ratio` string. This validator
/// rejects only obviously invalid inputs (zero or negative dimensions, or
/// degenerate aspect ratios outside the supported set).
struct StabilityImageResolutionValidator: ImageResolutionValidator {

    func validateResolution(_ resolution: ImageResolution) throws {
        let width = resolution.width
        let height = resolution.height

        guard width > 0 else {
            throw BedrockLibraryError.invalidParameter(
                .resolution,
                "Width must be a positive integer. Width: \(width)"
            )
        }
        guard height > 0 else {
            throw BedrockLibraryError.invalidParameter(
                .resolution,
                "Height must be a positive integer. Height: \(height)"
            )
        }

        // Stability supports up to 21:9 in landscape and 9:21 in portrait.
        // Reject ratios more extreme than that — they cannot be approximated faithfully.
        let ratio = Double(width) / Double(height)
        let maxRatio = 21.0 / 9.0
        let minRatio = 9.0 / 21.0
        guard ratio <= maxRatio && ratio >= minRatio else {
            throw BedrockLibraryError.invalidParameter(
                .resolution,
                "Aspect ratio must be between 9:21 and 21:9. Width: \(width), Height: \(height)"
            )
        }
    }
}
