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

import Foundation
import Testing

@testable import BedrockService

// MARK: JSON
@Suite("JSONTests")
struct JSONTests {

    @Test("JSON getValue from valid JSON string")
    func jsonGetValueFromValidJSONString() async throws {

        let json = try jsonFromString()
        #expect(json["name"] == "Jane Doe")
        #expect(json["age"] == 30)
        #expect(json["isMember"] == true)
        #expect(json["nonExistentKey"] == nil)
    }

    @Test("JSON getValue from [String:JSONValue]")
    func jsonGetValueFromDictionary() async throws {
        let json = try jsonFromDictionary()

        #expect(json["name"] == "Jane Doe")
        #expect(json["age"] == 30)
        #expect(json["isMember"] == true)
        #expect(json["nonExistentKey"] == nil)
    }

    @Test("JSON getValue nested")
    func jsonGetValueNested() async throws {

        let json = try jsonFromDictionaryWithNested()
        #expect(json["name"] == "Jane Doe")
        #expect(json["age"] == 30)
        #expect(json["isMember"] == true)
        #expect(json["nonExistentKey"] == nil)
        #expect(json["address"]?["street"] == "123 Main St")
        #expect(json["address"]?["city"] == "Anytown")
        #expect(json["address"]?["state"] == "CA")
        #expect(json["address"]?["zip"] == 12345)
        #expect(json["address"]?["isSomething"] == true)
        #expect(json["nonExistentKey"] == nil)
    }

    @Test("JSON Subscript")
    func jsonSubscript() async throws {
        let json = try JSON(
            from: """
                {
                    "name": "Jane Doe",
                    "age": 30,
                    "isMember": true
                }
                """
        )
        #expect(json["name"] == "Jane Doe")
        #expect(json["age"] == 30)
        #expect(json["isMember"] == true)
        let t: String? = json["nonExistentKey"]
        #expect(t == nil)
    }

    @Test("JSON Subscript nested")
    func jsonSubscriptNested() async throws {
        let json = try jsonFromDictionaryWithNested()
        #expect(json["name"] == "Jane Doe")
        #expect(json["age"] == 30)
        #expect(json["isMember"] == true)
        let t: String? = json["nonExistentKey"]
        #expect(t == nil)
        #expect(json["address"]?["street"] == "123 Main St")
        #expect(json["address"]?["city"] == "Anytown")
        #expect(json["address"]?["state"] == "CA")
        #expect(json["address"]?["zip"] == 12345)
        #expect(json["address"]?["isSomething"] == true)
        #expect(json["nonExistentKey"] == nil)
    }

    @Test("JSON String Initializer with Invalid String")
    func jsonInvalidStringInitializer() async throws {
        let invalidJSONString = """
            {
                "name": "Jane Doe",
                "age": 30,
                "isMember": true,
            """  // Note: trailing comma and no closing brace, making this invalid
        #expect(throws: BedrockLibraryError.self) {
            let _ = try JSON(from: invalidJSONString)
        }
    }

    @Test("Empty JSON")
    func emptyJSON() async throws {
        #expect(throws: Never.self) {
            let json = try JSON(from: "")
            #expect(json["nonExistentKey"] == nil)
        }
    }

    @Test("Nested JSONValue")
    func nestedJSONValue() {
        let json = JSON(
            with: JSONValue([
                "name": JSONValue("Jane Doe"),
                "age": JSONValue(30),
                "isMember": JSONValue(true),
            ])
        )
        #expect(json["name"] == "Jane Doe")
        #expect(json["age"] == 30)
        #expect(json["isMember"] == true)
    }

    @Test("JSON encoding skips value wrapper")
    func jsonEncodingSkipsValueWrapper() throws {
        let json = JSON(with: .object(["test": .string("my_test")]))
        let encoded = try JSONEncoder().encode(json)
        let jsonString = String(data: encoded, encoding: .utf8)!
        #expect(jsonString == "{\"test\":\"my_test\"}")
        #expect(!jsonString.contains("\"value\":"))
    }

    @Test("JSON decoding skips value wrapper")
    func jsonDecodingSkipsValueWrapper() throws {
        let jsonString = "{\"test\":\"my_test\"}"
        let data = jsonString.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(JSON.self, from: data)
        #expect(decoded["test"] == "my_test")
    }
}

// Fixtures
extension JSONTests {
    private func jsonFromString() throws -> JSON {
        try JSON(
            from: """
                {
                    "name": "Jane Doe",
                    "age": 30,
                    "isMember": true
                }
                """
        )
    }

    private func jsonFromDictionary() throws -> JSON {
        let value: [String: JSONValue] = ["name": .string("Jane Doe"), "age": .int(30), "isMember": .bool(true)]
        return JSON(with: .object(value))
    }

    private func jsonFromDictionaryWithNested() throws -> JSON {
        JSON(
            with: JSONValue([
                "name": JSONValue("Jane Doe"),
                "age": JSONValue(30),
                "isMember": JSONValue(true),
                "address": JSONValue([
                    "street": JSONValue("123 Main St"),
                    "city": JSONValue("Anytown"),
                    "state": JSONValue("CA"),
                    "zip": JSONValue(12345),
                    "isSomething": JSONValue(true),
                ]),
            ])
        )
    }
}
