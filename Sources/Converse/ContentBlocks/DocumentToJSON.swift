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

import Smithy

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

// FIXME: avoid extensions on structs you do not control
extension SmithyDocument {
    public func toJSON() throws -> JSON {
        switch self.type {
        case .string:
            return JSON(with: try self.asString())
        case .boolean:
            return JSON(with: try self.asBoolean())
        case .integer:
            return JSON(with: try self.asInteger())
        case .double, .float:
            return JSON(with: try self.asDouble())
        case .list:
            let array = try self.asList().map { try $0.toJSON() }
            return JSON(with: array)
        case .map:
            let map = try self.asStringMap()
            var result: [String: JSON] = [:]
            for (key, value) in map {
                result[key] = try value.toJSON()
            }
            return JSON(with: result)
        case .blob:
            let data = try self.asBlob()
            return JSON(with: data)
        default:
            throw DocumentError.typeMismatch("Unsupported type for JSON conversion: \(self.type)")
        }
    }
}
