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

import BedrockTypes
import Foundation
import Hummingbird

extension ImageGenerationOutput: @retroactive ResponseCodable {}

struct ImageGenerationInput: Codable {
    let prompt: String
    let nrOfImages: Int?
    let referenceImage: Data?
    let similarity: Double?

    init(
        prompt: String,
        nrOfImages: Int? = 1,
        referenceImage: Data? = nil,
        similarity: Double? = nil,
        stylePreset: String? = ""
    ) {
        self.prompt = prompt
        self.referenceImage = referenceImage
        self.nrOfImages = nrOfImages
        self.similarity = similarity
    }
}

// struct ImageVariationInput: Codable {
//     let prompt: String
//     let nrOfImages: Int?
//     let referenceImage: Data
//     let similarity: Double?

//     init(
//         prompt: String,
//         nrOfImages: Int? = 1,
//         referenceImage: Data,
//         similarity: Double? = nil
//     ) {
//         self.prompt = prompt
//         self.referenceImage = referenceImage
//         self.nrOfImages = nrOfImages
//         self.similarity = similarity
//     }
// }
