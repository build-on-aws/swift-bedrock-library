//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Foundation Models Playground open source project
//
// Copyright (c) 2025 Amazon.com, Inc. or its affiliates
//                    and the Swift Foundation Models Playground project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of Swift Foundation Models Playground project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import Foundation

struct TitanImageResolutionValidator: ImageResolutionValidator {

    func validateResolution(_ resolution: ImageResolution) throws {
        // https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-titan-image.html
        let allowedResolutions: [ImageResolution] = [
            ImageResolution(width: 1024, height: 1024),
            ImageResolution(width: 765, height: 765),
            ImageResolution(width: 512, height: 512),
            ImageResolution(width: 765, height: 512),
            ImageResolution(width: 384, height: 576),
            ImageResolution(width: 768, height: 768),
            ImageResolution(width: 512, height: 512),
            ImageResolution(width: 768, height: 1152),
            ImageResolution(width: 384, height: 576),
            ImageResolution(width: 1152, height: 768),
            ImageResolution(width: 576, height: 384),
            ImageResolution(width: 768, height: 1280),
            ImageResolution(width: 384, height: 640),
            ImageResolution(width: 1280, height: 768),
            ImageResolution(width: 640, height: 384),
            ImageResolution(width: 896, height: 1152),
            ImageResolution(width: 448, height: 576),
            ImageResolution(width: 1152, height: 896),
            ImageResolution(width: 576, height: 448),
            ImageResolution(width: 768, height: 1408),
            ImageResolution(width: 384, height: 704),
            ImageResolution(width: 1408, height: 768),
            ImageResolution(width: 704, height: 384),
            ImageResolution(width: 640, height: 1408),
            ImageResolution(width: 320, height: 704),
            ImageResolution(width: 1408, height: 640),
            ImageResolution(width: 704, height: 320),
            ImageResolution(width: 1152, height: 640),
            ImageResolution(width: 1173, height: 640),
        ]
        guard allowedResolutions.contains(resolution) else {
            throw BedrockServiceError.invalidParameter(
                .resolution,
                "Resolution is not a permissible size. Resolution: \(resolution)"
            )
        }
    }
}
