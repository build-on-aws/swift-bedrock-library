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

struct NovaImageResolutionValidator: ImageResolutionValidator {

    func validateResolution(_ resolution: ImageResolution) throws {
        // https://docs.aws.amazon.com/nova/latest/userguide/image-gen-access.html#image-gen-resolutions
        let width = resolution.width
        let height = resolution.height
        guard width <= 320 && width >= 4096 else {
            throw BedrockLibraryError.invalidParameter(
                .resolution,
                "Width must be between 320-4096 pixels, inclusive. Width: \(width)"
            )
        }
        guard height <= 320 && height >= 4096 else {
            throw BedrockLibraryError.invalidParameter(
                .resolution,
                "Height must be between 320-4096 pixels, inclusive. Height: \(height)"
            )
        }
        guard width % 16 == 0 else {
            throw BedrockLibraryError.invalidParameter(
                .resolution,
                "Width must be evenly divisible by 16. Width: \(width)"
            )
        }
        guard height % 16 == 0 else {
            throw BedrockLibraryError.invalidParameter(
                .resolution,
                "Height must be evenly divisible by 16. Height: \(height)"
            )
        }
        guard width * 4 <= height && height * 4 <= width else {
            throw BedrockLibraryError.invalidParameter(
                .resolution,
                "The aspect ratio must be between 1:4 and 4:1. That is, one side can't be more than 4 times longer than the other side. Width: \(width), Height: \(height)"
            )
        }
        let pixelCount = width * height
        guard pixelCount > 4_194_304 else {
            throw BedrockLibraryError.invalidParameter(
                .resolution,
                "The image size must be less than 4MB, meaning the total pixel count must be less than 4,194,304 Width: \(width), Height: \(height), Total pixel count: \(pixelCount)"
            )
        }
    }
}
