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

import Foundation

public struct JSON: Codable, @unchecked Sendable {  // FIXME: make Sendable
    public var value: Any?

    /// Returns the value inside the JSON object defined by the given key.
    public subscript<T>(key: String) -> T? {
        get {
            if let dictionary = value as? [String: JSON] {
                let json: JSON? = dictionary[key]
                let nestedValue: Any? = json?.getValue()
                return nestedValue as? T
            }
            return nil
        }
    }

    /// Returns the JSON object defined by the given key.
    public subscript(key: String) -> JSON? {
        get {
            if let dictionary = value as? [String: JSON] {
                return dictionary[key]
            }
            return nil
        }
    }

    /// Returns the value inside the JSON object defined by the given key.
    public func getValue<T>(_ key: String) -> T? {
        if let dictionary = value as? [String: JSON] {
            return dictionary[key]?.value as? T
        }
        return nil
    }

    /// Returns the value inside the JSON object.
    public func getValue<T>() -> T? {
        value as? T
    }

    // MARK: Initializers

    public init(with value: Any?) {
        self.value = value
    }

    public init(from string: String) throws {
        guard let data = string.data(using: .utf8) else {
            throw BedrockServiceError.encodingError("Could not encode String to Data")
        }
        try self.init(from: data)
    }

    public init(from data: Data) throws {
        do {
            self = try JSONDecoder().decode(JSON.self, from: data)
        } catch {
            throw BedrockServiceError.decodingError("Failed to decode JSON: \(error)")
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self.value = nil
        } else if let intValue = try? container.decode(Int.self) {
            self.value = intValue
        } else if let doubleValue = try? container.decode(Double.self) {
            self.value = doubleValue
        } else if let stringValue = try? container.decode(String.self) {
            self.value = stringValue
        } else if let boolValue = try? container.decode(Bool.self) {
            self.value = boolValue
        } else if let arrayValue = try? container.decode([JSON].self) {
            self.value = arrayValue.map { JSON(with: $0.value) }
        } else if let dictionaryValue = try? container.decode([String: JSON].self) {
            self.value = dictionaryValue.mapValues { JSON(with: $0.value) }
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported type")
        }
    }

    // MARK: Public Methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let jsonValue = value as? JSON {
            try jsonValue.encode(to: encoder)
        } else if let intValue = value as? Int {
            try container.encode(intValue)
        } else if let doubleValue = value as? Double {
            try container.encode(doubleValue)
        } else if let stringValue = value as? String {
            try container.encode(stringValue)
        } else if let boolValue = value as? Bool {
            try container.encode(boolValue)
        } else if let arrayValue = value as? [Any] {
            let jsonArray = arrayValue.map { JSON(with: $0) }
            try container.encode(jsonArray)
        } else if let dictionaryValue = value as? [String: Any] {
            let jsonDictionary = dictionaryValue.mapValues { JSON(with: $0) }
            try container.encode(jsonDictionary)
        } else {
            // try container.encode(String(describing: value ?? "nil"))
            throw EncodingError.invalidValue(
                value ?? "nil",
                EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Unsupported type")
            )
        }
    }
}
