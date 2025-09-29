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

import Testing

@testable import BedrockService

// MARK: JSON
@Suite("JSONTests")
struct JSONTests {

    @Test("JSON getValue 1")
    func jsonGetValue1() async throws {
        let json = JSON(with: [
            "name": JSON(with: "Jane Doe"),
            "age": JSON(with: 30),
            "isMember": JSON(with: true),
        ])
        #expect(json.getValue("name") == "Jane Doe")
        #expect(json.getValue("age") == 30)
        #expect(json.getValue("isMember") == true)
        #expect(json.getValue("nonExistentKey") == nil)
    }
    
    @Test("JSON getValue 2")
    func jsonGetValue2() async throws {
        let json = JSON(with: [
            "name": JSONValue("Jane Doe"),
            "age": JSONValue(30),
            "isMember": JSONValue(true),
        ])
        #expect(json.getValue("name") == "Jane Doe")
        #expect(json.getValue("age") == 30)
        #expect(json.getValue("isMember") == true)
        #expect(json.getValue("nonExistentKey") == nil)
    }

//    @Test("JSON getValue nested")
//    func jsonGetValueNested() async throws {
//        let json = JSON(with: [
//            "name": JSON(with: "Jane Doe"),
//            "age": JSON(with: 30),
//            "isMember": JSON(with: true),
//            "address": JSON(with: [
//                "street": JSON(with: "123 Main St"),
//                "city": JSON(with: "Anytown"),
//                "state": JSON(with: "CA"),
//                "zip": JSON(with: "12345"),
//                "isSomething": JSON(with: true),
//            ]),
//        ])
//        #expect(json.getValue("name") == "Jane Doe")
//        #expect(json.getValue("age") == 30)
//        #expect(json.getValue("isMember") == true)
//        #expect(json.getValue("nonExistentKey") == nil)
//        #expect(json["address"]?.getValue("street") == "123 Main St")
//        #expect(json["address"]?.getValue("city") == "Anytown")
//        #expect(json["address"]?.getValue("state") == "CA")
//        #expect(json["address"]?.getValue("zip") == "12345")
//        #expect(json["address"]?.getValue("isSomething") == true)
//        #expect(json["address"]?.getValue("nonExistentKey") == nil)
//    }
//
//    @Test("JSON Subscript")
//    func jsonSubscript() async throws {
//        let json = JSON(with: [
//            "name": JSON(with: "Jane Doe"),
//            "age": JSON(with: 30),
//            "isMember": JSON(with: true),
//        ])
//        #expect(json["name"] == "Jane Doe")
//        #expect(json["age"] == 30)
//        #expect(json["isMember"] == true)
//        #expect(json["nonExistentKey"] == nil)
//    }
//
//    @Test("JSON Subscript nested")
//    func jsonSubscriptNested() async throws {
//        let json = JSON(with: [
//            "name": JSON(with: "Jane Doe"),
//            "age": JSON(with: 30),
//            "isMember": JSON(with: true),
//            "address": JSON(with: [
//                "street": JSON(with: "123 Main St"),
//                "city": JSON(with: "Anytown"),
//                "state": JSON(with: "CA"),
//                "zip": JSON(with: 12345),
//                "isSomething": JSON(with: true),
//            ]),
//        ])
//        #expect(json["name"] == "Jane Doe")
//        #expect(json["age"] == 30)
//        #expect(json["isMember"] == true)
//        #expect(json["nonExistentKey"] == nil)
//        #expect(json["address"]?["street"] == "123 Main St")
//        #expect(json["address"]?["city"] == "Anytown")
//        #expect(json["address"]?["state"] == "CA")
//        #expect(json["address"]?["zip"] == 12345)
//        #expect(json["address"]?["isSomething"] == true)
//        #expect(json["address"]?.getValue("nonExistentKey") == nil)
//    }
//
//    @Test("JSON String Initializer with Valid String")
//    func jsonStringInitializer() async throws {
//        let validJSONString = """
//            {
//                "name": "Jane Doe",
//                "age": 30,
//                "isMember": true
//            }
//            """
//
//        let json = try JSON(from: validJSONString)
//        #expect(json.getValue("name") == "Jane Doe")
//        #expect(json.getValue("age") == 30)
//        #expect(json.getValue("isMember") == true)
//    }
//
//    @Test("JSON String Initializer with Invalid String")
//    func jsonInvalidStringInitializer() async throws {
//        let invalidJSONString = """
//            {
//                "name": "Jane Doe",
//                "age": 30,
//                "isMember": true,
//            """  // Note: trailing comma, making this invalid
//        #expect(throws: BedrockLibraryError.self) {
//            let _ = try JSON(from: invalidJSONString)
//        }
//    }
//
//    @Test("Empty JSON")
//    func emptyJSON() async throws {
//        #expect(throws: Never.self) {
//            let json = try JSON(from: "")
//            #expect(json.getValue("nonExistentKey") == nil)
//        }
//    }
}
