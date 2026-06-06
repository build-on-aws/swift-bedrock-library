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

import AsyncHTTPClient
import Logging
import NIOCore
import NIOHTTP1

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

public struct BedrockMantleClient: BedrockMantleClientProtocol {
    private let httpClient: HTTPClient
    private let logger: Logger

    public init(logger: Logger? = nil) {
        self.httpClient = HTTPClient.shared
        self.logger = logger ?? Logger(label: "bedrock.mantle.client")
    }

    public func sendRequest(
        body: Data,
        url: URL,
        authentication: BedrockMantleAuthentication
    ) async throws -> Data {
        let urlString = url.absoluteString

        var request = HTTPClientRequest(url: urlString)
        request.method = .POST
        request.headers.add(name: "Content-Type", value: "application/json")

        switch authentication {
        case .apiKey(let key):
            request.headers.add(name: "Authorization", value: "Bearer \(key)")
        case .sigV4:
            throw BedrockLibraryError.notImplemented(
                "SigV4 authentication for bedrock-mantle is not yet implemented. Use .apiKey() instead."
            )
        }

        request.body = .bytes(ByteBuffer(data: body))

        logger.trace(
            "Sending request to bedrock-mantle",
            metadata: ["url": .string(urlString)]
        )

        let response = try await httpClient.execute(request, timeout: .seconds(120))

        let responseBody = try await response.body.collect(upTo: 10 * 1024 * 1024)
        let responseData = Data(buffer: responseBody)

        guard (200..<300).contains(response.status.code) else {
            let errorMessage = String(data: responseData, encoding: .utf8) ?? "Unknown error"
            throw BedrockLibraryError.invalidSDKResponse(
                "bedrock-mantle returned HTTP \(response.status.code): \(errorMessage)"
            )
        }

        return responseData
    }
}
