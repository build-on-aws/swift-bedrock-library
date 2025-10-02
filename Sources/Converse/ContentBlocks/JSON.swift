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

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

public enum JSONValue: Codable, Sendable {
    case null
    case int(Int)
    case double(Double)
    case string(String)
    case bool(Bool)
    case array([JSONValue])
    case object([String: JSONValue])

    public init(_ value: Any?) {

        guard let value else {
            self = .null
            return
        }
        switch value {
        case let v as Int:
            self = .int(v)
            break
        case let v as Double:
            self = .double(v)
            break
        case let v as String:
            self = .string(v)
            break
        case let v as Bool:
            self = .bool(v)
            break
        case let v as [Any]:
            self = .array(v.map { JSONValue($0) })
            break
        case let v as [String: JSONValue]:
            self = .object(v)
            break
        case let v as [JSONValue]:
            self = .array(v)
            break
        case let v as JSONValue:
            self = v
            break
        default:
            fatalError("JSONValue: Unsupported type: \(type(of: value))")
        }
    }

    public subscript<T>(key: String) -> T? {
        get {
            if case let .object(dictionary) = self {
                guard let jsonValue = dictionary[key] else {
                    return nil
                }
                switch jsonValue {
                case .int(let v): return v as? T
                case .double(let v): return v as? T
                case .string(let v): return v as? T
                case .bool(let v): return v as? T
                case .array(let v): return v as? T
                case .object(let v): return v as? T
                case .null: return nil
                }
            }
            return nil
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else if let intValue = try? container.decode(Int.self) {
            self = .int(intValue)
        } else if let doubleValue = try? container.decode(Double.self) {
            self = .double(doubleValue)
        } else if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else if let boolValue = try? container.decode(Bool.self) {
            self = .bool(boolValue)
        } else if let arrayValue = try? container.decode([JSONValue].self) {
            self = .array(arrayValue)
        } else if let dictionaryValue = try? container.decode([String: JSONValue].self) {
            self = .object(dictionaryValue)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported type")
        }
    }

    // MARK: Public Methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .null:
            try container.encodeNil()
        case .int(let v):
            try container.encode(v)
        case .double(let v):
            try container.encode(v)
        case .string(let v):
            try container.encode(v)
        case .bool(let v):
            try container.encode(v)
        case .array(let v):
            try container.encode(v)
        case .object(let v):
            try container.encode(v)
        }
    }

}

public struct JSON: Codable, Sendable {
    public let value: JSONValue

    public subscript<T>(key: String) -> T? {
        get {
            value[key]
        }
    }

    public subscript(key: String) -> JSONValue? {
        get {
            if case let .object(dictionary) = value {
                if let v = dictionary[key] {
                    return v
                }
            }
            return nil
        }
    }

    public func getValue<T>() -> T? {
        switch value {
        case .int(let v): return v as? T
        case .double(let v): return v as? T
        case .string(let v): return v as? T
        case .bool(let v): return v as? T
        case .array(let v): return v as? T
        case .object(let v): return v as? T
        case .null: return nil
        }
    }

    // MARK: Initializers

    public init(with value: JSONValue) {
        self.value = value
    }

    public init(from string: String) throws {
        let s = string.isEmpty ? "{}" : string
        guard let data = s.data(using: .utf8) else {
            throw BedrockLibraryError.encodingError("Could not encode String to Data")
        }
        try self.init(from: data)
    }

    public init(from data: Data) throws {
        do {
            self = try JSONDecoder().decode(JSON.self, from: data)
        } catch {
            throw BedrockLibraryError.decodingError("Failed to decode JSON: \(error)")
        }
    }

    // Codable

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        value = try container.decode(JSONValue.self)
    }

}
