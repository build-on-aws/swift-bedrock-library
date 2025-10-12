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

@preconcurrency import AWSBedrock
@preconcurrency import AWSBedrockRuntime
import AWSClientRuntime
import AwsCommonRuntimeKit
import Logging

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

// for setenv and unsetenv functions
#if os(Linux)
import Glibc
#else
import Darwin.C
#endif

public struct BedrockService: Sendable {
    package let region: Region
    package let logger: Logging.Logger
    package let bedrockClient: BedrockClientProtocol
    package let bedrockRuntimeClient: BedrockRuntimeClientProtocol

    // MARK: - Initialization

    /// Initializes a new SwiftBedrock instance
    /// - Parameters:
    ///   - region: The AWS region to use (defaults to .useast1)
    ///   - logger: Optional custom logger instance
    ///   - bedrockClient: Optional custom Bedrock client
    ///   - bedrockRuntimeClient: Optional custom Bedrock Runtime client
    ///   - authentication: The authentication type to use (defaults to .default)
    /// - Throws: Error if client initialization fails
    public init(
        region: Region = .useast1,
        logger: Logging.Logger? = nil,
        bedrockClient: BedrockClientProtocol? = nil,
        bedrockRuntimeClient: BedrockRuntimeClientProtocol? = nil,
        authentication: BedrockAuthentication = .default
    ) async throws {
        self.logger = logger ?? BedrockService.createLogger("bedrock.service")
        self.logger.trace(
            "Initializing BedrockService",
            metadata: ["region": .string(region.rawValue)]
        )
        self.region = region

        if bedrockClient != nil {
            self.logger.trace("Using supplied bedrockClient")
            self.bedrockClient = bedrockClient!
        } else {
            self.logger.trace("Creating bedrockClient")
            self.bedrockClient = try await BedrockService.createBedrockClient(
                region: region,
                authentication: authentication,
                logger: self.logger
            )
            self.logger.trace(
                "Created bedrockClient",
                metadata: ["authentication type": "\(authentication)"]
            )
        }
        if bedrockRuntimeClient != nil {
            self.logger.trace("Using supplied bedrockRuntimeClient")
            self.bedrockRuntimeClient = bedrockRuntimeClient!
        } else {
            self.logger.trace("Creating bedrockRuntimeClient")
            self.bedrockRuntimeClient = try await BedrockService.createBedrockRuntimeClient(
                region: region,
                authentication: authentication,
                logger: self.logger
            )
            self.logger.trace(
                "Created bedrockRuntimeClient",
                metadata: ["authentication type": "\(authentication)"]
            )
        }
        self.logger.trace(
            "Initialized SwiftBedrock",
            metadata: ["region": .string(region.rawValue)]
        )
    }

    // MARK: - Private Helpers

    /// Creates Logger using either the loglevel saved as environment variable `BEDROCK_SERVICE_LOG_LEVEL` or with default `.info`
    /// - Parameter name: The name/label for the logger
    /// - Returns: Configured Logger instance
    static private func createLogger(_ name: String) -> Logging.Logger {
        var logger: Logging.Logger = Logger(label: name)
        logger.logLevel =
            ProcessInfo.processInfo.environment["BEDROCK_SERVICE_LOG_LEVEL"].flatMap {
                Logger.Level(rawValue: $0.lowercased())
            } ?? .info
        return logger
    }

    /// Creates a BedrockClient
    /// - Parameters:
    ///   - region: The AWS region to configure the client for
    ///   - authentication: The authentication type to use
    /// - Returns: Configured BedrockClientProtocol instance
    /// - Throws: Error if client creation fails
    internal static func createBedrockClient(
        region: Region,
        authentication: BedrockAuthentication,
        logger: Logging.Logger
    ) async throws
        -> BedrockClient
    {
        let config: BedrockClient.BedrockClientConfiguration = try await prepareConfig(
            initialConfig: BedrockClient.BedrockClientConfiguration(region: region.rawValue),
            authentication: authentication,
            logger: logger
        )
        return BedrockClient(config: config)
    }

    /// Creates a BedrockRuntimeClient
    /// - Parameters:
    ///   - region: The AWS region to configure the client for
    ///   - authentication: The authentication type to use
    /// - Returns: Configured BedrockRuntimeClientProtocol instance
    /// - Throws: Error if client creation fails
    internal static func createBedrockRuntimeClient(
        region: Region,
        authentication: BedrockAuthentication,
        logger: Logging.Logger
    )
        async throws
        -> BedrockRuntimeClient
    {
        let config: BedrockRuntimeClient.BedrockRuntimeClientConfiguration = try await prepareConfig(
            initialConfig: BedrockRuntimeClient.BedrockRuntimeClientConfiguration(
                region: region.rawValue
            ),
            authentication: authentication,
            logger: logger
        )
        return BedrockRuntimeClient(config: config)
    }

    /// Generic function to create client configuration and avoid duplication code.
    internal static func prepareConfig<C: BedrockConfigProtocol>(
        initialConfig: C,
        authentication: BedrockAuthentication,
        logger: Logging.Logger
    ) async throws -> C {

        var config = initialConfig

        if logger.logLevel == .trace {
            // enable trace HTTP requests and responses for the SDK
            // see https://github.com/smithy-lang/smithy-swift/blob/main/Sources/ClientRuntime/Telemetry/Logging/ClientLogMode.swift
            config.clientLogMode = .requestAndResponse
        }

        // support profile, SSO, web identity and static authentication
        if let awsCredentialIdentityResolver = try? await authentication.getAWSCredentialIdentityResolver(
            logger: logger
        ) {
            config.awsCredentialIdentityResolver = awsCredentialIdentityResolver
        }

        // support API keys
        if case .apiKey(_) = authentication {
            if let bearerTokenIdentityresolver = authentication.getBearerTokenIdentityResolver(logger: logger) {
                config.bearerTokenIdentityResolver = bearerTokenIdentityresolver
                config.authSchemePreference = ["httpBearerAuth"]
            } else {
                // TODO: should we throw an error here ?
                logger.error(
                    "API Key authentication is used but no BearerTokenIdentityResolver is provided. This will lead to issues."
                )
            }
            logger.trace("Using API Key for authentication")
        } else {
            logger.trace("Using AWS credentials for authentication")
        }

        //We uncheck AWS_BEARER_TOKEN_BEDROCK to avoid conflict with future AWS SDK version
        //see https://docs.aws.amazon.com/bedrock/latest/userguide/getting-started-api-keys.html
        //FIXME: there is a risk of side effect here - what other ways we have to ignore this variable ?
        unsetenv("AWS_BEARER_TOKEN_BEDROCK")

        return config
    }

    func handleCommonError(_ error: Error, context: String) throws -> Never {
        if let commonError = error as? CommonRunTimeError {
            logger.trace("CommonRunTimeError while \(context)", metadata: ["error": "\(error)"])
            switch commonError {
            case .crtError(let crtError):
                switch crtError.code {
                case 6153:
                    throw BedrockLibraryError.authenticationFailed(
                        "No valid credentials found: \(crtError.message)"
                    )
                case 6170:
                    throw BedrockLibraryError.authenticationFailed(
                        "AWS SSO token expired: \(crtError.message)"
                    )
                default:
                    throw BedrockLibraryError.authenticationFailed(
                        "Authentication failed: \(crtError.message)"
                    )
                }
            }
        } else if let validationError = error as? AWSBedrockRuntime.ValidationException {
            logger.trace("ValidationException while \(context)", metadata: ["error": "\(error)"])
            let message = validationError.properties.message ?? "Validation error occurred"
            if message.contains("Input is too long") {
                throw BedrockLibraryError.inputTooLong(message)
            } else {
                throw BedrockLibraryError.invalid(message)
            }
        } else {
            logger.trace("Error while \(context)", metadata: ["error": "\(error)"])
            throw error
        }
    }

    // MARK: Public Methods

    /// Lists all available foundation models from Amazon Bedrock
    /// - Throws: BedrockLibraryError.invalidResponse
    /// - Returns: An array of ModelSummary objects containing details about each available model
    public func listModels() async throws -> [ModelSummary] {
        logger.trace("Fetching foundation models")
        do {
            let response = try await bedrockClient.listFoundationModels(
                input: ListFoundationModelsInput()
            )
            guard let models = response.modelSummaries else {
                logger.trace("Failed to extract modelSummaries from response")
                throw BedrockLibraryError.invalidSDKResponse(
                    "Something went wrong while extracting the modelSummaries from the response."
                )
            }
            var modelsInfo: [ModelSummary] = []
            modelsInfo = try models.compactMap { (sdkModelSummary) -> ModelSummary? in
                try ModelSummary.getModelSummary(from: sdkModelSummary)
            }
            logger.trace(
                "Fetched foundation models",
                metadata: [
                    "models.count": "\(modelsInfo.count)",
                    "models.content": .string(String(describing: modelsInfo)),
                ]
            )
            return modelsInfo
        } catch {
            try handleCommonError(error, context: "listing foundation models")
        }
    }
}
