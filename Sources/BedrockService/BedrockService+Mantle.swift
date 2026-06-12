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

import Logging

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

extension BedrockService {

    /// Constructs a validated bedrock-mantle URL for the given path.
    /// - Parameter path: The API path (e.g. `/anthropic/v1/messages`)
    /// - Returns: A validated URL pointing to the bedrock-mantle endpoint
    /// - Throws: `BedrockLibraryError.invalidURI` if the constructed URL string is invalid
    package func makeMantleURL(path: String) throws -> URL {
        let urlString = "https://bedrock-mantle.\(region.rawValue).api.aws\(path)"
        guard let url = URL(string: urlString, encodingInvalidCharacters: false) else {
            throw BedrockLibraryError.invalidURI(urlString)
        }
        return url
    }

    /// Returns the provided mantle client override, or creates a default one using the service's region and logger.
    /// - Parameter mantleClient: An optional client override (typically used for testing)
    /// - Returns: The override client if non-nil, otherwise a new `BedrockMantleClient`
    package func makeMantleClient(override mantleClient: BedrockMantleClientProtocol?) -> BedrockMantleClientProtocol {
        mantleClient ?? BedrockMantleClient(region: region.rawValue, logger: self.logger)
    }
}
