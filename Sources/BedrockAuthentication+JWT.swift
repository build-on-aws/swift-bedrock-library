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

import AWSSDKIdentity
import Logging

// for setenv and unsetenv functions
#if os(Linux)
import Glibc
#else
import Darwin.C
#endif

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

extension BedrockAuthentication {
    /// Convert the given JWT identity token string into temporary AWS credentials
    /// using the STSWebIdentityAWSCredentialIdentityResolver
    ///
    /// - Parameters:
    ///   - tokenString: The string version of the JWT identity token
    ///     returned by Sign In With Apple.
    ///   - roleARN: The ARN of the IAM role to assume.
    ///   - region: An optional string specifying the AWS Region to
    ///     access. If not specified, "us-east-1" is assumed.
    ///   - notify: A closure to be called on the main thread when the credentials are retrieved.
    func webIdentityCredentialResolver(
        withWebIdentity tokenString: String,
        logger: Logger,
        roleARN: String,
        region: Region = .useast1,
        notify: @Sendable @escaping () -> Void
    ) async throws -> STSWebIdentityAWSCredentialIdentityResolver {
        // Write the token to a temporary file so it can be used by the resolver
        let tokenFilename = "apple-identity-token.jwt"
        let tokenFileURL = FileManager.default.temporaryDirectory.appendingPathComponent(
            tokenFilename,
            isDirectory: false
        )
        let tokenFilePath = tokenFileURL.path
        defer {
            // silently ignore an error if the file does not exist
            try? FileManager.default.removeItem(at: tokenFileURL)
        }

        guard (try? tokenString.write(to: tokenFileURL, atomically: true, encoding: .utf8)) != nil else {
            throw BedrockLibraryError.authenticationFailed("Failed to write token to file")
        }

        // Create an identity resolver that uses the JWT token received from an Identity Provider
        // to create AWS credentials
        do {
            logger.trace("Creating identity resolver using web identity token")
            setenv("AWS_REGION", region.rawValue, 1)
            setenv("AWS_ROLE_ARN", roleARN, 1)
            setenv("AWS_ROLE_SESSION_NAME", "SwiftBedrockService-\(UUID().uuidString)", 1)
            setenv("AWS_WEB_IDENTITY_TOKEN_FILE", tokenFilePath, 1)
            let identityResolver = try STSWebIdentityAWSCredentialIdentityResolver(source: .env)

            // Test the resolver by retrieving credentials to ensure it works
            logger.trace("Retrieving credentials using web identity token")
            _ = try await identityResolver.getIdentity(identityProperties: nil)
            logger.trace("Successfully retrieved credentials using web identity token")

            unsetenv("AWS_REGION")
            unsetenv("AWS_ROLE_ARN")
            unsetenv("AWS_ROLE_SESSION_NAME")
            unsetenv("AWS_WEB_IDENTITY_TOKEN_FILE")

            // Notify observers, if any
            logger.trace("Notifying observers of credentials update")
            await MainActor.run {
                notify()
            }

            return identityResolver

        } catch {
            logger.error("Failed to assume role using web identity token: \(error)")
            throw BedrockLibraryError.authenticationFailed(
                "Failed to assume role using web identity token: \(error.localizedDescription)"
            )
        }
    }
}
