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

public struct StandardConverse: ConverseModality, StreamingModality {
    public func getName() -> String { "Standard Converse Modality" }

    public let converseParameters: ConverseParameters
    public let converseFeatures: [ConverseFeature]

    public init(parameters: ConverseParameters, features: [ConverseFeature]) {
        self.converseParameters = parameters
        self.converseFeatures = features
    }

    public func getConverseParameters() -> ConverseParameters { converseParameters }
    public func getConverseFeatures() -> [ConverseFeature] { converseFeatures }
}
