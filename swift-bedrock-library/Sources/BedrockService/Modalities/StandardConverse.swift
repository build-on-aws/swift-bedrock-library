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
