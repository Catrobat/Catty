/**
 *  Copyright (C) 2010-2023 The Catrobat Team
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

import BluetoothHelper
import CoreBluetooth
import XCTest

class CentralManagerTests: XCTestCase {

    func testPowerOnWhenPoweredOn() {
        let testCentralManager = TestCentralManager(state: .poweredOn)
        let expectation = self.expectation(description: "onSuccess fulfilled for future")
        let future = testCentralManager.helper.start(testCentralManager)
        future.onSuccess {
            expectation.fulfill()
        }
        future.onFailure {_ in
            XCTAssert(false, "onFailure called")
        }
        waitForExpectations(timeout: 2) {error in
            XCTAssertNil(error, "\(String(describing: error))")
        }
    }

    func testPowerOnWhenPoweredOff() {
        let testCentralManager = TestCentralManager(state: .poweredOff)
        let expectation = self.expectation(description: "onSuccess fulfilled for future")
        let future = testCentralManager.helper.start(testCentralManager)
        future.onSuccess {
            expectation.fulfill()
        }
        future.onFailure {_ in
            XCTAssert(false, "onFailure called")
        }
        testCentralManager.state = .poweredOn
        testCentralManager.helper.didUpdateState(testCentralManager)
        waitForExpectations(timeout: 2) {error in
            XCTAssertNil(error, "\(String(describing: error))")
        }
    }

    func testPowerOffWhenPoweredOn() {
        let testCentralManager = TestCentralManager(state: .poweredOn)
        let expectation = self.expectation(description: "onSuccess fulfilled for future")
        let future = testCentralManager.helper.stop(testCentralManager)
        future.onSuccess {
            expectation.fulfill()
        }
        future.onFailure {_ in
            XCTAssert(false, "onFailure called")
        }
        testCentralManager.state = .poweredOff
        testCentralManager.helper.didUpdateState(testCentralManager)
        waitForExpectations(timeout: 2) {error in
            XCTAssertNil(error, "\(String(describing: error))")
        }
    }

    func testPowerOffWhenPoweredOff() {
        let testCentralManager = TestCentralManager(state: .poweredOff)
        let expectation = self.expectation(description: "onSuccess fulfilled for future")
        let future = testCentralManager.helper.stop(testCentralManager)
        future.onSuccess {
            expectation.fulfill()
        }
        future.onFailure {_ in
            XCTAssert(false, "onFailure called")
        }
        waitForExpectations(timeout: 2) {error in
            XCTAssertNil(error, "\(String(describing: error))")
        }
    }

    func testServiceScanning() {
        let testCentralManager = TestCentralManager(state: .poweredOff)
        let expectation = self.expectation(description: "onSuccess fulfilled for future")
        let future = testCentralManager.helper.startScanningForServiceUUIDs(testCentralManager, uuids: nil)
        future.onSuccess {_ in
            expectation.fulfill()
        }
        future.onFailure {_ in
            XCTAssert(false, "onFailure called")
        }
        testCentralManager.helper.didDiscoverPeripheral(TestPeripheral(name: "testCentralManager"))
        waitForExpectations(timeout: 2) {error in
            XCTAssertNil(error, "\(String(describing: error))")
        }
    }

}
