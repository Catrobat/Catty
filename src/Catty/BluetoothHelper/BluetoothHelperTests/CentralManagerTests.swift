/**
 *  Copyright (C) 2010-2016 The Catrobat Team
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

class CentralManagerTests: XCTestCase {

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
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
    
    func testPowerOnWhenPoweredOn() {
        let testCentralManager = TestCentralManager(state:.PoweredOn)
        let expectation = expectationWithDescription("onSuccess fulfilled for future")
        let future = testCentralManager.helper.start(testCentralManager)
        future.onSuccess {
            expectation.fulfill()
        }
        future.onFailure{error in
            XCTAssert(false, "onFailure called")
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testPowerOnWhenPoweredOff() {
        let testCentralManager = TestCentralManager(state:.PoweredOff)
        let expectation = expectationWithDescription("onSuccess fulfilled for future")
        let future = testCentralManager.helper.start(testCentralManager)
        future.onSuccess {
            expectation.fulfill()
        }
        future.onFailure{error in
            XCTAssert(false, "onFailure called")
        }
        testCentralManager.state = .PoweredOn
        testCentralManager.helper.didUpdateState(testCentralManager)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testPowerOffWhenPoweredOn() {
        let testCentralManager = TestCentralManager(state:.PoweredOn)
        let expectation = expectationWithDescription("onSuccess fulfilled for future")
        let future = testCentralManager.helper.stop(testCentralManager)
        future.onSuccess {
            expectation.fulfill()
        }
        future.onFailure{error in
            XCTAssert(false, "onFailure called")
        }
        testCentralManager.state = .PoweredOff
        testCentralManager.helper.didUpdateState(testCentralManager)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testPowerOffWhenPoweredOff() {
        let testCentralManager = TestCentralManager(state:.PoweredOff)
        let expectation = expectationWithDescription("onSuccess fulfilled for future")
        let future = testCentralManager.helper.stop(testCentralManager)
        future.onSuccess {
            expectation.fulfill()
        }
        future.onFailure{error in
            XCTAssert(false, "onFailure called")
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testServiceScanning() {
        let testCentralManager = TestCentralManager(state:.PoweredOff)
        let expectation = expectationWithDescription("onSuccess fulfilled for future")
        let future = testCentralManager.helper.startScanningForServiceUUIDs(testCentralManager, uuids: nil)
        future.onSuccess {_ in
            expectation.fulfill()
        }
        future.onFailure{error in
            XCTAssert(false, "onFailure called")
        }
        testCentralManager.helper.didDiscoverPeripheral(TestPeripheral(name:"testCentralManager"))
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }


}
