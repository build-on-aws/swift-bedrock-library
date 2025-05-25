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

import AwsCommonRuntimeKit
import Testing

@testable import BedrockService
@testable import BedrockTypes

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
    //     await #expect(throws: BedrockServiceError.self) {
    //         let auth = BedrockAuthentication.sso()
    //         let bedrock = try await BedrockService(authentication: auth)
    //         let _ = try await bedrock.listModels()
    //     }
    // }
}
