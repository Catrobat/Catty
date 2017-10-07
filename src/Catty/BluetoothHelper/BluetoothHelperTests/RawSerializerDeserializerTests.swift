/**
 *  Copyright (C) 2010-2017 The Catrobat Team
 *  (http://developer.catrobat.org/credits)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  An additional term exception under section 7 of the GNU Affero
 *  General Public License, version 3, is available at
 *  (http://developer.catrobat.org/license_additional_term)
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see http://www.gnu.org/licenses/.
 */

import XCTest
import CoreBluetooth
import BluetoothHelper


class RawDeserializerTests: XCTestCase {
    
    enum RawTest: UInt8, RawDeserialize {
        case no     = 0
        case yes    = 1
        case maybe  = 2
        static let uuid = "TEST"
    }

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    
    //MARK: RawDeserialize
    func testRawDeserialization() {
        let data = "01".dataFromHexString()
        if let value : RawTest = Deserializer.deserialize(data) {
            XCTAssert(value == .yes, "RawDeserializable deserialization value wrong: \(data)")
        } else {
            XCTFail("RawDeserializable deserialization failed")
        }
    }
    
    func testRawDeserializationFailure() {
        let data = "03".dataFromHexString()
        if let _ : RawTest = Deserializer.deserialize(data) {
            XCTFail("RawDeserializable deserialization succeeded")
        }
    }
    
    //MARK: RawPairDeserialize
    func testRawPairDeserialization() {
        let data = "02ab".dataFromHexString()
        if let value : RawPairTest = Deserializer.deserialize(data) {
            XCTAssert(value.value1 == 2 && value.value2 == 171, "RawPairDeserializableTests deserialization value invalid: \(value.value1), \(value.value2)")
        } else {
            XCTFail("RawPairDeserializableTests deserialization failed")
        }
    }
    
    func testRawPairDeserializationFailure() {
        let data = "0201".dataFromHexString()
        if let _ : RawPairTest = Deserializer.deserialize(data) {
            XCTFail("RawPairDeserializableTests deserialization succeeded")
        }
    }
    
    //MARK: RawArrayDeserialize
    func testRawArrayDeserialization() {
        let data = "02ab05".dataFromHexString()
        if let value : RawArrayTest = Deserializer.deserialize(data) {
            XCTAssert(value.value1 == 2 && value.value2 == -85 && value.value3 == 5, "RawArrayDeserializable deserialization value invalid: \(value.value1), \(value.value2)")
        } else {
            XCTFail("RawArrayDeserializable deserialization failed")
        }
    }
    
    func testRawArrayDeserializationFailure() {
        let data = "02ab0c05".dataFromHexString()
        if let _ : RawArrayTest = Deserializer.deserialize(data) {
            XCTFail("RawArrayDeserializable deserialization succeeded")
        }
    }
    
    //MARK: RawArrayPairDeserialize
    func testRawArrayPairDeserialization() {
        let data = "02ab03ab".dataFromHexString()
        if let value : RawArrayPairTest = Deserializer.deserialize(data) {
            XCTAssert(value.value1 == [Int8]([2, -85]) && value.value2 == [UInt8]([3, 171]), "RawPairDeserializableTests deserialization value invalid: \(value.value1), \(value.value2)")
        } else {
            XCTFail("RawPairDeserializableTests deserialization failed")
        }
    }
    
    func testRawArrayPairDeserializationFailure() {
        let data = "020103".dataFromHexString()
        if let _ : RawArrayPairTest = Deserializer.deserialize(data) {
            XCTFail("RawPairDeserializableTests deserialization succeeded")
        }
    }
    
    //MARK: Raw Serialize
    func testRawSerialization() {
        let value = RawTest.no
        let data = Serializer.serialize(value)
        XCTAssert(data.hexStringValue() == "00", "RawDeserializable serialization failed: \(data)")
    }
    
    //MARK: Raw Pair Serialize
    func testRawPairSerialization() {
        if let value = RawPairTest(rawValue1:5, rawValue2:100) {
            let data = Serializer.serialize(value)
            XCTAssert(data.hexStringValue() == "0564", "RawDeserializable serialization failed: \(data)")
        } else {
            XCTFail("RawPairDeserializableTests RawArray creation failed")
        }
    }
    
    func testRawPairSerializationFailure() {
        if let _ = RawPairTest(rawValue1:5, rawValue2:1) {
            XCTFail("RawPairDeserializableTests RawArray creation succeeded")
        }
    }
    
    //MARK: Raw Array Serialize
    func testRawArraySerialization() {
        if let value = RawArrayTest(rawValue:[5, 100, 5]) {
            let data = Serializer.serialize(value)
            XCTAssert(data.hexStringValue() == "056405", "RawArrayDeserializable serialization value invalid: \(data)")
        } else {
            XCTFail("RawArrayDeserializable RawArray creation failed")
        }
    }
    
    //MARK: Raw Array Pair Serialize
    func testRawArrayPairSerialization() {
        if let value = RawArrayPairTest(rawValue1:[2, -85], rawValue2:[3, 171]) {
            let data = Serializer.serialize(value)
            XCTAssert(data.hexStringValue() == "02ab03ab", "RawDeserializable serialization failed: \(data.hexStringValue())")
        } else {
            XCTFail("RawPairDeserializableTests RawArray creation failed")
        }
    }
    
    func testRawArrayPairSerializationFailure() {
        if let _ = RawArrayPairTest(rawValue1:[5], rawValue2:[1]) {
            XCTFail("RawPairDeserializableTests RawArray creation succeeded")
        }
    }

    
}
