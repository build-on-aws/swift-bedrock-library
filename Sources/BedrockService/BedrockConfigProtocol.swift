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
import AWSBedrockAgentRuntime
import AWSBedrockRuntime
import ClientRuntime
import SmithyHTTPAuthAPI
import SmithyIdentity

protocol BedrockConfigProtocol {
    // support regular AWS Credentials + Sigv4 authentication
    var awsCredentialIdentityResolver: any SmithyIdentity.AWSCredentialIdentityResolver { get set }

    // support bearer token authentication (for API Keys)
    var bearerTokenIdentityResolver: any SmithyIdentity.BearerTokenIdentityResolver { get set }
    var authSchemePreference: [String]? { get set }

    // not used at the moment, we use the bearer token instead
    //var httpClientConfiguration: ClientRuntime.HttpClientConfiguration { get set }

    // for debugging
    var clientLogMode: ClientRuntime.ClientLogMode { get set }

}
extension BedrockClient.BedrockClientConfiguration: @retroactive @unchecked Sendable, BedrockConfigProtocol {}
extension BedrockRuntimeClient.BedrockRuntimeClientConfiguration: @retroactive @unchecked Sendable,
    BedrockConfigProtocol
{}
extension BedrockAgentRuntimeClient.BedrockAgentRuntimeClientConfiguration: @retroactive @unchecked Sendable,
    BedrockConfigProtocol
{}
