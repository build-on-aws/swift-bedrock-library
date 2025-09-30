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
    private func toJSONValue() throws -> JSONValue {
        switch self.type {
        case .string:
            return try JSONValue(self.asString())
        case .boolean:
            return try JSONValue(self.asBoolean())
        case .integer:
            return try JSONValue(self.asInteger())
        case .double, .float:
            return try JSONValue(self.asDouble())
        case .list:
            let array = try self.asList().map { try $0.toJSONValue() }
            return JSONValue(array)
        case .map:
            let map = try self.asStringMap()
            let newMap = try map.mapValues({ try $0.toJSONValue() })
            return JSONValue(newMap)
        case .blob:
            let data = try self.asBlob()
            let json = try JSON(from: data)
            return json.value
        default:
            throw DocumentError.typeMismatch("Unsupported type for JSON conversion: \(self.type)")
        }
    }

    public func toJSON() throws -> JSON {
        let value = try self.toJSONValue()
        return JSON(with: value)
    }
}
