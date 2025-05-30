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

// Converse
public protocol ConverseModality: Modality {
    var converseParameters: ConverseParameters { get }
    var converseFeatures: [ConverseFeature] { get }

    func getConverseParameters() -> ConverseParameters
    func getConverseFeatures() -> [ConverseFeature]
}

// Converse Streaming
public protocol ConverseStreamingModality: ConverseModality, StreamingModality {}

// Default implementation
extension ConverseModality {

    func getConverseParameters() -> ConverseParameters {
        converseParameters
    }

    func getConverseFeatures() -> [ConverseFeature] {
        converseFeatures
    }
}
