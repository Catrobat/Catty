/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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

import UIKit
import XCTest
import CoreBluetooth
import CoreLocation
import BluetoothHelper

class ServiceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testDiscoverCharacteristicsSuccess() {
        let testService = TestService()
        let onSuccessExpectation = expectation(description: "onSuccess fulfilled for future")
        let future = testService.helper.discoverCharacteristicsIfConnected(testService, characteristics:nil)
        future.onSuccess {_ in
            onSuccessExpectation.fulfill()
        }
        future.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        testService.helper.didDiscoverCharacteristics(testService, error:nil)
        waitForExpectations(timeout: 2) {error in
            XCTAssertNil(error, "\(String(describing: error))")
        }
    }

    func testDiscoverCharacteristicsFailure() {
        let testService = TestService()
        let onFailureExpectation = expectation(description: "onFailure fulfilled for future")
        let future = testService.helper.discoverCharacteristicsIfConnected(testService, characteristics:nil)
        future.onSuccess {_ in
            XCTAssert(false, "onSuccess called")
        }
        future.onFailure {error in
            onFailureExpectation.fulfill()
        }
        testService.helper.didDiscoverCharacteristics(testService, error:TestFailure.error)
        waitForExpectations(timeout: 2) {error in
            XCTAssertNil(error, "\(String(describing: error))")
        }
    }

    func testDiscoverCharacteristicsDisconnected() {
        let testService = TestService(state:.disconnected)
        let onFailureExpectation = expectation(description: "onFailure fulfilled for future")
        let future = testService.helper.discoverCharacteristicsIfConnected(testService, characteristics:nil)
        future.onSuccess {_ in
            XCTAssert(false, "onSuccess called")
        }
        future.onFailure {error in
            onFailureExpectation.fulfill()
            XCTAssert(error.code == PeripheralError.disconnected.rawValue, "Error code invalid \(error.code)")
        }
        waitForExpectations(timeout: 2) {error in
            XCTAssertNil(error, "\(String(describing: error))")
        }
    }

}
