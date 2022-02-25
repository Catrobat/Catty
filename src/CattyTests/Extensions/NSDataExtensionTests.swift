/**
 *  Copyright (C) 2010-2022 The Catrobat Team
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

        XCTAssertEqual(testData1.md5(), correctOutput1)
        XCTAssertEqual(testData2.md5(), correctOutput2)
    }

    func testMD5WithLargeData() {
        let fiveHundredMegabyteData = NSData(data: Data(count: 524288000))
        let expectation = self.expectation(description: "md5 calculated")

        DispatchQueue.global(qos: .userInitiated).async {
            let md5 = fiveHundredMegabyteData.md5()
            XCTAssertNotNil(md5)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10) { error in
             XCTAssertNil(error)
        }
    }
}
