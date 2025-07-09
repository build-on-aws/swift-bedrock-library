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

import AWSBedrock
import AWSBedrockRuntime
import ClientRuntime
import SmithyIdentity

protocol BedrockConfigProtocol {
    init() async throws
    var awsCredentialIdentityResolver: any SmithyIdentity.AWSCredentialIdentityResolver { get set }
    var httpClientConfiguration: ClientRuntime.HttpClientConfiguration { get set }
    var region: String? { get set }
}
extension BedrockClient.BedrockClientConfiguration: @retroactive @unchecked Sendable, BedrockConfigProtocol {}
extension BedrockRuntimeClient.BedrockRuntimeClientConfiguration: @retroactive @unchecked Sendable,
    BedrockConfigProtocol
{}
