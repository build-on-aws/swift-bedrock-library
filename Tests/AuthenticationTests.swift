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
import AwsCommonRuntimeKit
import Logging
import Testing

@testable import BedrockService

// MARK: authentication
extension BedrockServiceTests {

    @Test(
        "Authentication: AuthenticationType struct does not leak credentials",
        arguments: [
            BedrockAuthentication.static(
                accessKey: "MY_ACCESS_KEY",
                secretKey: "MY_SECRET_KEY",
                sessionToken: "MY_SECRET_SESSION_TOKEN"
            ),
            BedrockAuthentication.webIdentity(
                token: "MY_SECRET_JWT_TOKEN",
                roleARN: "MY_ROLE_ARN",
                region: .useast1,
                notification: {}
            ),
            BedrockAuthentication.apiKey(key: "MY_SECRET_API_KEY"),
        ]
    )
    func authNoLeaks(auth: BedrockAuthentication) {
        //given the auth in paramaters

        //when
        let str = String(describing: auth)

        // then
        #expect(!str.contains("SECRET"))

        //when
        let str2 = "\(auth)"  // is it different than String(describing:) ?

        // then
        #expect(!str2.contains("SECRET"))
    }

    // // Only works when SSO is actually expired
    // @Test("Authentication Error: SSO expired")
    // func authErrorSSOExpired() async throws {
    //     await #expect(throws: BedrockLibraryError.self) {
    //         let auth = BedrockAuthentication.sso()
    //         let bedrock = try await BedrockService(authentication: auth)
    //         let _ = try await bedrock.listModels()
    //     }
    // }

    @Test("Authentication: API Key authentication adds HTTP Header to the request")
    func apiKeyAuthentication() async throws {
        // given
        let testApiKey = "test-api-key-12345"
        let auth = BedrockAuthentication.apiKey(key: testApiKey)

        // when
        // create bedrock configuration with API Key authentication
        let config: BedrockClient.BedrockClientConfiguration = try await BedrockService.prepareConfig(
            region: .useast1,
            authentication: auth,
            logger: Logger(label: "test.logger"),
        )

        // then
        #expect(config.region == Region.useast1.rawValue)  // default region
        #expect(
            config.httpClientConfiguration.defaultHeaders.value(for: "Authorization") == "Bearer test-api-key-12345"
        )

    }

    @Test("Authentication: API Key returns nil credential resolver")
    func apiKeyCredentialResolver() async throws {
        // given
        let testApiKey = "test-api-key-12345"
        let auth = BedrockAuthentication.apiKey(key: testApiKey)
        let logger = Logger(label: "test.logger")

        // when
        let resolver = try await auth.getAWSCredentialIdentityResolver(logger: logger)

        // then
        #expect(resolver == nil, "API Key authentication should return nil credential resolver")
    }

    @Test("Authentication: API Key description doesn't leak full key")
    func apiKeyDescription() {
        // given
        let testApiKey = "test-api-key-12345-very-long-key"
        let auth = BedrockAuthentication.apiKey(key: testApiKey)

        // when
        let description = auth.description

        // then
        #expect(description.contains("apiKey:"))
        #expect(description.contains("tes..."))  // should show first 3 characters
        #expect(description.contains("*** shuuut, it's a secret ***"))
        #expect(!description.contains("12345"))  // should not contain the full key
        #expect(!description.contains("very-long-key"))  // should not contain the full key
    }
}
