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


class SerializerDeserializerTests: XCTestCase {
    
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
    // MARK: Deserialize UINT8
    
    func testDeserializeUInt8Sucess() {
        let data = Serializer.serialize(UInt8(10))
        if let value : UInt8 = Deserializer.deserialize(data) {
            XCTAssert(value == 10, "UInt8 deserialization value invalid: \(value)")
        } else {
            XCTFail("UInt8 deserialization failed")
        }
    }
    
    func testDeserializeUInt8Failure() {
        let data = Data()
        if let value : UInt8 = Deserializer.deserialize(data) {
            XCTFail("UInt8 deserialization succeded: \(value)")
        }
    }
    // MARK: Deserialize INT8
    
    func testDeserializeInt8Sucess() {
        let data = Serializer.serialize(Int8(-50))
        if let value : Int8 = Deserializer.deserialize(data) {
            XCTAssert(value == -50, "Int8 deserialization value invalid: \(value)")
        } else {
            XCTFail("Int8 deserialization failed")
        }
    }
    
    func testDeserializeInt8Failure() {
        let data = Data()
        if let value : Int16 = Deserializer.deserialize(data) {
            XCTFail("Int16 deserialization succeded: \(value)")
        }
    }
    
    // MARK: Deserialize UINT16
    
    func testDeserializeUInt16Sucess() {
        let data = Serializer.serialize(UInt16(20000))
        if let value : UInt16 = Deserializer.deserialize(data) {
            XCTAssert(value == 20000, "UInt16 deserialization value invalid: \(value)")
        } else {
            XCTFail("UInt16 deserialization failed")
        }
    }
    
    func testDeserializeUInt16Failure() {
        let data = Data()
        if let value : UInt16 = Deserializer.deserialize(data) {
            XCTFail("UInt16 deserialization succeded: \(value)")
        }
    }
    // MARK: Deserialize INT16
    
    func testDeserializeInt16Sucess() {
        let data = Serializer.serialize(Int16(-10000))
        if let value : Int16 = Deserializer.deserialize(data) {
            XCTAssert(value == -10000, "Int16 deserialization value invalid: \(value)")
        } else {
            XCTFail("Int16 deserialization failed")
        }
    }
    
    func testDeserializeInt16Failure() {
        let data = Data()
        if let value : Int16 = Deserializer.deserialize(data) {
            XCTFail("Int16 deserialization succeded: \(value)")
        }
    }
    
     // MARK: Deserialize UINT8 Array
    func testDeserializeUInt8Array() {
        let value : [UInt8] = [10, 20]
        let data = Serializer.serialize(value)
        let des : [UInt8] = UInt8.deserialize(data)
        XCTAssert(des == [10, 20], "UInt8 array deserialization value invalid: \(des)")
    }
    
    // MARK: Deserialize UINT8 Array
    func testDeserializeInt8Array() {
        let value : [Int8] = [-10, 10]
        let data = Serializer.serialize(value)
        let des : [Int8] = Int8.deserialize(data)
        XCTAssert(des == [-10, 10], "Int8 array deserialization value invalid: \(des)")
    }
    // MARK: Deserialize UINT8 Array
    func testDeserializeUInt16Array() {
        let value : [UInt16] = [20000, 1000]
        let data = Serializer.serialize(value)
        let des : [UInt16] = UInt16.deserialize(data)
        XCTAssert(des == [20000, 1000], "UInt16 array deserialization value invalid: \(des)")
    }
    // MARK: Deserialize UINT8 Array
    func testDeserializeInt16Array() {
        let value : [Int16] = [-10000, 1000]
        let data = Serializer.serialize(value)
        let des : [Int16] = Int16.deserialize(data)
        XCTAssert(des == [-10000, 1000], "Int16 array deserialization value invalid: \(des)")
    }

    // MARK: Serialize UINT8
    func testSerializeUInt8() {
        let data = Serializer.serialize(UInt8(10))
        XCTAssert(data.hexStringValue() == "0a", "UInt8 serialization value invalid: \(data.hexStringValue())")
    }
     // MARK: Serialize INT8
    func testSerializeInt8() {
        let data = Serializer.serialize(Int8(-50))
        XCTAssert(data.hexStringValue() == "ce", "Int8 serialization value invalid: \(data.hexStringValue())")
    }
     // MARK: Serialize UINT16
    func testSerializeUInt16() {
        let data = Serializer.serialize(UInt16(1000))
        XCTAssert(data.hexStringValue() == "e803", "UInt16 serialization value invalid: \(data.hexStringValue())")
    }
     // MARK: Serialize INT16
    func testSerializeInt16() {
        let data = Serializer.serialize(Int16(-1100))
        XCTAssert(data.hexStringValue() == "b4fb", "Int16 serialization value invalid: \(data.hexStringValue())")
    }
     // MARK: Serialize UINT8 Array
    func testSerializeUInt8Array() {
        let value : [UInt8] = [100, 10]
        let data = Serializer.serialize(value)
        XCTAssert(data.hexStringValue() == "640a", "UInt8 array serialization value invalid: \(data.hexStringValue())")
    }
     // MARK: Serialize INT8 Array
    func testSerializeInt8Array() {
        let value : [Int8] = [-50, 10]
        let data = Serializer.serialize(value)
        XCTAssert(data.hexStringValue() == "ce0a", "Int8 array serialization value invalid: \(data.hexStringValue())")
    }
     // MARK: Serialize UINT16 Array
    func testSerializeUInt16Array() {
        let value : [UInt16] = [1000, 10]
        let data = Serializer.serialize(value)
        XCTAssert(data.hexStringValue() == "e8030a00", "UInt16 array serialization value invalid: \(data.hexStringValue())")
    }
     // MARK: Serialize INT16 Array
    func testSerializeInt16Array() {
        let value : [Int16] = [-1100, 10]
        let data = Serializer.serialize(value)
        XCTAssert(data.hexStringValue() == "b4fb0a00", "Int16 array serialization value invalid: \(data.hexStringValue())")
    }
    
    
    // MARK: Serialize Pair
    func testSerializePair() {
        let data = Data.serialize(Int16(-1100),  value2:UInt8(100))
        XCTAssert(data.hexStringValue() == "b4fb64", "Pair serialization value invalid: \(data.hexStringValue())")
    }
    
    // MARK: Serialize Pair Array
    func testSerializeArrayPair() {
        let value1 = [Int16(-1100), Int16(1000)]
        let value2 = [UInt8(100), UInt8(75)]
        let data = Data.serializeArrays(value1, values2:value2)
        XCTAssert(data.hexStringValue() == "b4fbe803644b", "Pair serialization value invalid: \(data.hexStringValue())")
    }

    
}
