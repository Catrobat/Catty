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
import UIKit
import XCTest
import CoreBluetooth
import CoreLocation
import BluetoothHelper

class CharacteristicTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testDiscovered() {
        let testCharacteristic = TestCharacteristic()
        let onSuccessExpectation = expectationWithDescription("onSuccess fulfilled for future")
        let future = testCharacteristic.afterDiscoveredPromise?.future
        future!.onSuccess {_ in
            onSuccessExpectation.fulfill()
        }
        future!.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        CentralQueue.async {
            testCharacteristic.helper.didDiscover(testCharacteristic)
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testWriteDataSuccess() {
        let testCharacteristic = TestCharacteristic()
        let onSuccessExpectation = expectationWithDescription("onSuccess fulfilled for future")
        let future = testCharacteristic.helper.writeData(testCharacteristic, value:"aa".dataFromHexString())
        future.onSuccess {_ in
            onSuccessExpectation.fulfill()
        }
        future.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        CentralQueue.async {
            testCharacteristic.helper.didWrite(testCharacteristic, error:nil)
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testWriteDataFailed() {
        let testCharacteristic = TestCharacteristic()
        let onFailureExpectation = expectationWithDescription("onFailure fulfilled for future")
        let future = testCharacteristic.helper.writeData(testCharacteristic, value:"aa".dataFromHexString())
        future.onSuccess {_ in
            XCTAssert(false, "onSuccess called")
        }
        future.onFailure {error in
            onFailureExpectation.fulfill()
        }
        CentralQueue.async {
            testCharacteristic.helper.didWrite(testCharacteristic, error:TestFailure.error)
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testWriteDataTimeOut() {
        let testCharacteristic = TestCharacteristic()
        let onFailureExpectation = expectationWithDescription("onFailure fulfilled for future")
        let future = testCharacteristic.helper.writeData(testCharacteristic, value:"aa".dataFromHexString())
        future.onSuccess {_ in
            XCTAssert(false, "onFailure called")
        }
        future.onFailure {error in
            onFailureExpectation.fulfill()
            XCTAssert(error.code == CharacteristicError.WriteTimeout.rawValue, "Error code invalid")
        }
        waitForExpectationsWithTimeout(20) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testWriteDataNotWrteable() {
        let testCharacteristic = TestCharacteristic(propertyEnabled:false)
        let onFailureExpectation = expectationWithDescription("onFailure fulfilled for future")
        let future = testCharacteristic.helper.writeData(testCharacteristic, value:"aa".dataFromHexString())
        future.onSuccess {_ in
            XCTAssert(false, "onSuccess called")
        }
        future.onFailure {error in
            onFailureExpectation.fulfill()
            XCTAssert(error.code == CharacteristicError.WriteNotSupported.rawValue, "Error code invalid")
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testWriteStringSuccess() {
        let testCharacteristic = TestCharacteristic()
        let onSuccessExpectation = expectationWithDescription("onSuccess fulfilled for future")
        let future = testCharacteristic.helper.writeString(testCharacteristic, stringValue:["testCharacteristic":"1"])
        future.onSuccess {_ in
            onSuccessExpectation.fulfill()
        }
        future.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        CentralQueue.async {
            testCharacteristic.helper.didWrite(testCharacteristic, error:nil)
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testWriteStringFailed() {
        let testCharacteristic = TestCharacteristic()
        let onFailureExpectation = expectationWithDescription("onFailure fulfilled for future")
        let future = testCharacteristic.helper.writeString(testCharacteristic, stringValue:["testCharacteristic":"1"])
        future.onSuccess {_ in
            XCTAssert(false, "onSuccess called")
        }
        future.onFailure {error in
            onFailureExpectation.fulfill()
        }
        CentralQueue.async {
            testCharacteristic.helper.didWrite(testCharacteristic, error:TestFailure.error)
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testWriteStringTimeOut() {
        let testCharacteristic = TestCharacteristic()
        let onFailureExpectation = expectationWithDescription("onFailure fulfilled for future")
        let future = testCharacteristic.helper.writeString(testCharacteristic, stringValue:["testCharacteristic":"1"])
        future.onSuccess {_ in
            XCTAssert(false, "onFailure called")
        }
        future.onFailure {error in
            onFailureExpectation.fulfill()
            XCTAssert(error.code == CharacteristicError.WriteTimeout.rawValue, "Error code invalid")
        }
        waitForExpectationsWithTimeout(20) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testWriteStringNotWrteable() {
        let testCharacteristic = TestCharacteristic(propertyEnabled:false)
        let onFailureExpectation = expectationWithDescription("onFailure fulfilled for future")
        let future = testCharacteristic.helper.writeString(testCharacteristic, stringValue:["testCharacteristic":"1"])
        future.onSuccess {_ in
            XCTAssert(false, "onSuccess called")
        }
        future.onFailure {error in
            onFailureExpectation.fulfill()
            XCTAssert(error.code == CharacteristicError.WriteNotSupported.rawValue, "Error code invalid")
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testReadSuccess() {
        let testCharacteristic = TestCharacteristic()
        let onSuccessExpectation = expectationWithDescription("onSuccess fulfilled for future")
        let future = testCharacteristic.helper.read(testCharacteristic)
        future.onSuccess {_ in
            onSuccessExpectation.fulfill()
        }
        future.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        CentralQueue.async {
            testCharacteristic.helper.didUpdate(testCharacteristic, error:nil)
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testReadFailure() {
        let testCharacteristic = TestCharacteristic()
        let onFailureExpectation = expectationWithDescription("onFailure fulfilled for future")
        let future = testCharacteristic.helper.read(testCharacteristic)
        future.onSuccess {_ in
            XCTAssert(false, "onSuccess called")
        }
        future.onFailure {error in
            onFailureExpectation.fulfill()
        }
        CentralQueue.async {
            testCharacteristic.helper.didUpdate(testCharacteristic, error:TestFailure.error)
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testReadTimeout() {
        let testCharacteristic = TestCharacteristic()
        let onFailureExpectation = expectationWithDescription("onFailure fulfilled for future")
        let future = testCharacteristic.helper.read(testCharacteristic)
        future.onSuccess {_ in
            XCTAssert(false, "onFailure called")
        }
        future.onFailure {error in
            onFailureExpectation.fulfill()
            XCTAssert(error.code == CharacteristicError.ReadTimeout.rawValue, "Error code invalid")
        }
        waitForExpectationsWithTimeout(120) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testReadNotReadable() {
        let testCharacteristic = TestCharacteristic(propertyEnabled:false)
        let onFailureExpectation = expectationWithDescription("onFailure fulfilled for future")
        let future = testCharacteristic.helper.read(testCharacteristic)
        future.onSuccess {_ in
            XCTAssert(false, "onSuccess called")
        }
        future.onFailure {error in
            onFailureExpectation.fulfill()
            XCTAssert(error.code == CharacteristicError.ReadNotSupported.rawValue, "Error code invalid")
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testStartNotifyingSucceess() {
        let testCharacteristic = TestCharacteristic()
        let onSuccessExpectation = expectationWithDescription("onSuccess fulfilled for future")
        let future = testCharacteristic.helper.startNotifying(testCharacteristic)
        future.onSuccess {_ in
            onSuccessExpectation.fulfill()
        }
        future.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        CentralQueue.async {
            testCharacteristic.helper.didUpdateNotificationState(testCharacteristic, error:nil)
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testStartNotifyingFailure() {
        let testCharacteristic = TestCharacteristic()
        let onFailureExpectation = expectationWithDescription("onFailure fulfilled for future")
        let future = testCharacteristic.helper.startNotifying(testCharacteristic)
        future.onSuccess {_ in
            XCTAssert(false, "onSuccess called")
        }
        future.onFailure {error in
            onFailureExpectation.fulfill()
        }
        CentralQueue.async {
            testCharacteristic.helper.didUpdateNotificationState(testCharacteristic, error:TestFailure.error)
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testReceiveNotificationUpdateSuccess() {
        let testCharacteristic = TestCharacteristic()
        let startNotifyingOnSuccessExpectation = expectationWithDescription("onSuccess fulfilled for future start notifying")
        let updateOnSuccessExpectation = expectationWithDescription("onSuccess fulfilled for future on update")

        let startNotifyingFuture = testCharacteristic.helper.startNotifying(testCharacteristic)
        testCharacteristic.helper.didUpdateNotificationState(testCharacteristic, error:nil)
        
        startNotifyingFuture.onSuccess{_ in
            startNotifyingOnSuccessExpectation.fulfill()
        }
        startNotifyingFuture.onFailure{_ in
            XCTAssert(false, "start notifying onFailure called")
        }
        let updateFuture = startNotifyingFuture.flatmap{_ -> FutureStream<TestCharacteristic> in
            let future = testCharacteristic.helper.recieveNotificationUpdates()
            CentralQueue.async {
                testCharacteristic.helper.didUpdate(testCharacteristic, error:nil)
            }
            return future
        }
        updateFuture.onSuccess {characteristic in
            updateOnSuccessExpectation.fulfill()
        }
        updateFuture.onFailure {error in
            XCTAssert(false, "update onFailure called")
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testReceiveNotificationUpdateFailure() {
        let testCharacteristic = TestCharacteristic()
        let startNotifyingOnSuccessExpectation = expectationWithDescription("onSuccess fulfilled for future start notifying")
        let updateOnFailureExpectation = expectationWithDescription("onSuccess fulfilled for future on update")
        
        let startNotifyingFuture = testCharacteristic.helper.startNotifying(testCharacteristic)
        testCharacteristic.helper.didUpdateNotificationState(testCharacteristic, error:nil)
        
        startNotifyingFuture.onSuccess{_ in
            startNotifyingOnSuccessExpectation.fulfill()
        }
        startNotifyingFuture.onFailure{_ in
            XCTAssert(false, "start notifying onFailure called")
        }
        let updateFuture = startNotifyingFuture.flatmap{_ -> FutureStream<TestCharacteristic> in
            let future = testCharacteristic.helper.recieveNotificationUpdates()
            CentralQueue.async {
                testCharacteristic.helper.didUpdate(testCharacteristic, error:TestFailure.error)
            }
            return future
        }
        updateFuture.onSuccess {characteristic in
            XCTAssert(false, "update onSuccess called")
        }
        updateFuture.onFailure {error in
            updateOnFailureExpectation.fulfill()
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testStopNotifyingSuccess() {
        let testCharacteristic = TestCharacteristic()
        let onSuccessExpectation = expectationWithDescription("onSuccess fulfilled for future")
        let future = testCharacteristic.helper.stopNotifying(testCharacteristic)
        future.onSuccess {_ in
            onSuccessExpectation.fulfill()
        }
        future.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        CentralQueue.async {
            testCharacteristic.helper.didUpdateNotificationState(testCharacteristic, error:nil)
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testStopNotifyingFailure() {
        let testCharacteristic = TestCharacteristic()
        let onFailureExpectation = expectationWithDescription("onSuccess fulfilled for future")
        let future = testCharacteristic.helper.stopNotifying(testCharacteristic)
        future.onSuccess {_ in
            XCTAssert(false, "onSuccess called")
        }
        future.onFailure {error in
            onFailureExpectation.fulfill()
        }
        CentralQueue.async {
            testCharacteristic.helper.didUpdateNotificationState(testCharacteristic, error:TestFailure.error)
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testStopNotificationUpdates() {
        let testCharacteristic = TestCharacteristic()
        let startNotifyingOnSuccessExpectation = expectationWithDescription("onSuccess fulfilled for future start notifying")
        let updateOnSuccessExpectation = expectationWithDescription("onSuccess fulfilled for future on update")

        var updates = 0
        let startNotifyingFuture = testCharacteristic.helper.startNotifying(testCharacteristic)
        testCharacteristic.helper.didUpdateNotificationState(testCharacteristic, error:nil)
        
        startNotifyingFuture.onSuccess{_ in
            startNotifyingOnSuccessExpectation.fulfill()
        }
        startNotifyingFuture.onFailure{_ in
            XCTAssert(false, "start notifying onFailure called")
        }
        let updateFuture = startNotifyingFuture.flatmap{_ -> FutureStream<TestCharacteristic> in
            let future = testCharacteristic.helper.recieveNotificationUpdates()
            CentralQueue.sync {
                testCharacteristic.helper.didUpdate(testCharacteristic, error:nil)
            }
            testCharacteristic.helper.stopNotificationUpdates()
            CentralQueue.sync {
                testCharacteristic.helper.didUpdate(testCharacteristic, error:nil)
            }
            return future
        }
        updateFuture.onSuccess {characteristic in
            if updates == 0 {
                updateOnSuccessExpectation.fulfill()
                updates += 1
            } else {
                XCTAssert(false, "update onSuccess called more than once")
            }
        }
        updateFuture.onFailure {error in
            XCTAssert(false, "update onFailure called")
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

}
