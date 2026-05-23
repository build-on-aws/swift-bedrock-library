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

/// The aspect ratios supported by Stability AI image generation models on Amazon Bedrock.
///
/// Stability models do not accept explicit width/height — they accept an `aspect_ratio`
/// string. The library maps an `ImageResolution` to the closest supported ratio.
public enum StabilityAspectRatio: String, Codable, Sendable, CaseIterable {
    case r16x9 = "16:9"
    case r1x1 = "1:1"
    case r21x9 = "21:9"
    case r2x3 = "2:3"
    case r3x2 = "3:2"
    case r4x5 = "4:5"
    case r5x4 = "5:4"
    case r9x16 = "9:16"
    case r9x21 = "9:21"

    /// The numeric ratio (width / height) for this aspect ratio.
    var ratio: Double {
        switch self {
        case .r16x9: return 16.0 / 9.0
        case .r1x1: return 1.0
        case .r21x9: return 21.0 / 9.0
        case .r2x3: return 2.0 / 3.0
        case .r3x2: return 3.0 / 2.0
        case .r4x5: return 4.0 / 5.0
        case .r5x4: return 5.0 / 4.0
        case .r9x16: return 9.0 / 16.0
        case .r9x21: return 9.0 / 21.0
        }
    }

    /// Returns the supported aspect ratio whose numeric ratio is closest to the
    /// given resolution.
    ///
    /// - Parameter resolution: The desired image resolution.
    /// - Returns: The closest supported `StabilityAspectRatio`.
    public static func nearest(to resolution: ImageResolution) -> StabilityAspectRatio {
        let target = Double(resolution.width) / Double(resolution.height)
        var best: StabilityAspectRatio = .r1x1
        var bestDistance = Double.greatestFiniteMagnitude
        for candidate in StabilityAspectRatio.allCases {
            let distance = abs(candidate.ratio - target)
            if distance < bestDistance {
                bestDistance = distance
                best = candidate
            }
        }
        return best
    }
}
