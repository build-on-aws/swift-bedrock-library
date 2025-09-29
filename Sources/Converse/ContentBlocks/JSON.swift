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
        switch value {
        case nil:
            self = .null
        case let v as Int:
            self = .int(v)
        case let v as Double:
            self = .double(v)
        case let v as String:
            self = .string(v)
        case let v as Bool:
            self = .bool(v)
        case let v as [Any]:
            self = .array(v.map { JSONValue($0) })
        case let v as [String: Any]:
            self = .object(v.mapValues { JSONValue($0) })
        case let v as [String: JSON]:
            self = .object(v.mapValues { $0.value })
        case let v as [JSON]:
            self = .array(v.map { $0.value })
        case let v as JSONValue:
            self = v
        case let v as JSON:
            self = v.value
        default:
            fatalError("JSONValue: Unsupported type: \(type(of: value))")
        }
    }
}

public struct JSON: Codable, Sendable {
    public var value: JSONValue

    public subscript<T>(key: String) -> T? {
        get {
            if case let .object(dictionary) = value {
                let jsonValue = dictionary[key]
                switch jsonValue {
                case .int(let v): return v as? T
                case .double(let v): return v as? T
                case .string(let v): return v as? T
                case .bool(let v): return v as? T
                case .array(let v): return v as? T
                case .object(let v): return v as? T
                case .null: return nil
                case .none: return nil
                }
            }
            return nil
        }
    }

    public subscript(key: String) -> JSON? {
        get {
            if case let .object(dictionary) = value {
                if let v = dictionary[key] {
                    return JSON(with: v)
                }
            }
            return nil
        }
    }
    
//    public subscript(key: String) -> JSONValue? {
//        get {
//            if case let .object(dictionary) = value {
//                if let v = dictionary[key] {
//                    return v
//                }
//            }
//            return nil
//        }
//    }

    public func getValue<T>(_ key: String) -> T? {
        if case let .object(dictionary) = value {
            if let v = dictionary[key] {
                switch v {
                case .int(let val): return val as? T
                case .double(let val): return val as? T
                case .string(let val): return val as? T
                case .bool(let val): return val as? T
                case .array(let val): return val as? T
                case .object(let val): return val as? T
                case .null: return nil
                }
            }
        }
        return nil
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

    public init(with value: Any?) {
        self.value = JSONValue(value)
    }

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

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self.value = .null
        } else if let intValue = try? container.decode(Int.self) {
            self.value = .int(intValue)
        } else if let doubleValue = try? container.decode(Double.self) {
            self.value = .double(doubleValue)
        } else if let stringValue = try? container.decode(String.self) {
            self.value = .string(stringValue)
        } else if let boolValue = try? container.decode(Bool.self) {
            self.value = .bool(boolValue)
        } else if let arrayValue = try? container.decode([JSON].self) {
            self.value = .array(arrayValue.map { $0.value })
        } else if let dictionaryValue = try? container.decode([String: JSON].self) {
            self.value = .object(dictionaryValue.mapValues { $0.value })
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported type")
        }
    }

    // MARK: Public Methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
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
            try container.encode(v.map { JSON(with: $0) })
        case .object(let v):
            try container.encode(v.mapValues { JSON(with: $0) })
        }
    }
}
