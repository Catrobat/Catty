/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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

@testable import Pocket_Code

final class NSDataExtensionTests: XCTestCase {
    func testMD5() {

           guard let data1 = "".data(using: .ascii) else {
               XCTFail("Failed to get string into data using ASCII encoding")
               return
           }
           let testData1 = NSData(data: data1)
           let correctOutput1 = "d41d8cd98f00b204e9800998ecf8427e"

           guard let data2 = "a".data(using: .ascii) else {
               XCTFail("Failed to get string into data using ASCII encoding")
               return
           }
           let testData2 = NSData(data: data2)
           let correctOutput2 = "0cc175b9c0f1b6a831c399e269772661"

           guard let data3 = "abc".data(using: .ascii) else {
               XCTFail("Failed to get string into data using ASCII encoding")
               return
           }
           let testData3 = NSData(data: data3)
           let correctOutput3 = "900150983cd24fb0d6963f7d28e17f72"

           guard let data4 = "message digest".data(using: .ascii) else {
               XCTFail("Failed to get string into data using ASCII encoding")
               return
           }
           let testData4 = NSData(data: data4)
           let correctOutput4 = "f96b697d7cb7938d525a2f31aaf161d0"

           guard let data5 = "abcdefghijklmnopqrstuvwxyz".data(using: .ascii) else {
                XCTFail("Failed to get string into data using ASCII encoding")
               return
           }
           let testData5 = NSData(data: data5)
           let correctOutput5 = "c3fcd3d76192e4007dfb496cca67e13b"

           guard let data6 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789".data(using: .ascii) else {
                XCTFail("Failed to get string into data using ASCII encoding")
               return
           }
           let testData6 = NSData(data: data6)
           let correctOutput6 = "d174ab98d277d9f5a5611c2c9f419d9f"

           guard let data7 = "12345678901234567890123456789012345678901234567890123456789012345678901234567890".data(using: .ascii) else {
                XCTFail("Failed to get string into data using ASCII encoding")
               return
           }
           let testData7 = NSData(data: data7)
           let correctOutput7 = "57edf4a22be3c955ac49da2e2107b67a"

           XCTAssertEqual(testData1.md5(), correctOutput1)
           XCTAssertEqual(testData2.md5(), correctOutput2)
           XCTAssertEqual(testData3.md5(), correctOutput3)
           XCTAssertEqual(testData4.md5(), correctOutput4)
           XCTAssertEqual(testData5.md5(), correctOutput5)
           XCTAssertEqual(testData6.md5(), correctOutput6)
           XCTAssertEqual(testData7.md5(), correctOutput7)

       }
}
