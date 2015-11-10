/**
 *  Copyright (C) 2010-2015 The Catrobat Team
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

class PeripheralTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testDiscoverServicesSuccess() {
        let testPeripheral = TestPeripheral(state:.Connected)
        let onSuccessExpectation = expectationWithDescription("onSuccess fulfilled for future")
        let future = testPeripheral.helper.discoverServices(testPeripheral, services:nil)
        future.onSuccess {_ in
            onSuccessExpectation.fulfill()
        }
        future.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        CentralQueue.sync {
            testPeripheral.helper.didDiscoverServices(testPeripheral, error:nil)
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testDiscoverServicesFailure() {
        let testPeripheral = TestPeripheral(state:.Connected)
        let onFailureExpectation = expectationWithDescription("onFailure fulfilled for future")
        let future = testPeripheral.helper.discoverServices(testPeripheral, services:nil)
        future.onSuccess {_ in
            XCTAssert(false, "onSuccess called")
        }
        future.onFailure {error in
            onFailureExpectation.fulfill()
        }
        CentralQueue.sync {
            testPeripheral.helper.didDiscoverServices(testPeripheral, error:TestFailure.error)
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testDiscoverPeripheralServicesSuccess() {
        let testPeripheral = TestPeripheral(state:.Connected)
        let onSuccessExpectation = expectationWithDescription("onSuccess fulfilled for future")
        let future = testPeripheral.helper.discoverPeripheralServices(testPeripheral, services:nil)
        future.onSuccess {_ in
            onSuccessExpectation.fulfill()
        }
        future.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        CentralQueue.sync {
            testPeripheral.helper.didDiscoverServices(testPeripheral, error:nil)
        }
        waitForExpectationsWithTimeout(20) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testDiscoverPeripheralServicesPeripheralFailure() {
        let testPeripheral = TestPeripheral(state:.Connected)
        let onFailureExpectation = expectationWithDescription("onFailure fulfilled for future")
        let future = testPeripheral.helper.discoverPeripheralServices(testPeripheral, services:nil)
        future.onSuccess {_ in
            XCTAssert(false, "onSuccess called")
        }
        future.onFailure {error in
            onFailureExpectation.fulfill()
        }
        CentralQueue.sync {
            testPeripheral.helper.didDiscoverServices(testPeripheral, error:TestFailure.error)
        }
        waitForExpectationsWithTimeout(20) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testDiscoverPeripheralServicesServiceFailure() {
        let testPeripheral = TestPeripheral(state:.Connected)
        TestServiceValues.error = TestFailure.error
        let onFailureExpectation = expectationWithDescription("onFailure fulfilled for future")
        let future = testPeripheral.helper.discoverPeripheralServices(testPeripheral, services:nil)
        future.onSuccess {_ in
            XCTAssert(false, "onSuccess called")
        }
        future.onFailure {error in
            onFailureExpectation.fulfill()
        }
        CentralQueue.sync {
            testPeripheral.helper.didDiscoverServices(testPeripheral, error:nil)
        }
        waitForExpectationsWithTimeout(20) {error in
            XCTAssertNil(error, "\(error)")
        }
        TestServiceValues.error = nil
    }

    func testDiscoverPeripheralServicesNoNersicesFoundFailure() {
        let testPeripheral = TestPeripheral(state:.Connected, services:[TestService]())
        let onFailureExpectation = expectationWithDescription("onFailure fulfilled for future")
        let future = testPeripheral.helper.discoverPeripheralServices(testPeripheral, services:nil)
        future.onSuccess {_ in
            XCTAssert(false, "onSuccess called")
        }
        future.onFailure {error in
            onFailureExpectation.fulfill()
            XCTAssert(error.domain == BluetoothError.domain, "message domain invalid")
            XCTAssert(error.code == PeripheralError.NoServices.rawValue, "message code invalid")
        }
        CentralQueue.sync {
            testPeripheral.helper.didDiscoverServices(testPeripheral, error:nil)
        }
        waitForExpectationsWithTimeout(20) {error in
            XCTAssertNil(error, "\(error)")
        }
        TestServiceValues.error = nil
    }

    func testConnect() {
        let testPeripheral = TestPeripheral()
        let onConnectionExpectation = expectationWithDescription("onSuccess fulfilled for future")
        let future = testPeripheral.helper.connect(testPeripheral, connectionTimeout:100.0)
        future.onSuccess{(peripheral, connectionEvent) in
            switch connectionEvent {
            case .Connected:
                onConnectionExpectation.fulfill()
            case .Timeout:
                XCTAssert(false, "onSuccess Timeout invalid")
            case .Disconnected:
                XCTAssert(false, "onSuccess Disconnect invalid")
            case .ForcedDisconnected:
                XCTAssert(false, "onSuccess ForceDisconnect invalid")
            case .Failed:
                XCTAssert(false, "onSuccess Failed invalid")
            case .GiveUp:
                XCTAssert(false, "onSuccess GiveUp invalid")
            }
        }
        future.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        CentralQueue.sync {
            testPeripheral.helper.didConnectPeripheral(testPeripheral)
        }
        waitForExpectationsWithTimeout(120) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testFailedConnect() {
        let testPeripheral = TestPeripheral()
        let onFailureExpectation = expectationWithDescription("onFailure fulfilled for future")
        let future = testPeripheral.helper.connect(testPeripheral, connectionTimeout:100.0)
        future.onSuccess{(peripheral, connectionEvent) in
            switch connectionEvent {
            case .Connected:
                XCTAssert(false, "onSuccess Connect invalid")
            case .Timeout:
                XCTAssert(false, "onSuccess Timeout invalid")
            case .Disconnected:
                XCTAssert(false, "onSuccess Disconnect invalid")
            case .ForcedDisconnected:
                XCTAssert(false, "onSuccess ForceDisconnect invalid")
            case .Failed:
                onFailureExpectation.fulfill()
            case .GiveUp:
                XCTAssert(false, "onSuccess GiveUp invalid")
            }
        }
        future.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        CentralQueue.sync {
            testPeripheral.helper.didFailToConnectPeripheral(testPeripheral, error:nil)
        }
        waitForExpectationsWithTimeout(120) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testFailedConnectWithError() {
        let testPeripheral = TestPeripheral(state:.Connected)
        let onFailureExpectation = expectationWithDescription("onFailure fulfilled for future")
        let future = testPeripheral.helper.connect(testPeripheral)
        future.onSuccess{(peripheral, connectionEvent) in
            switch connectionEvent {
            case .Connected:
                XCTAssert(false, "onSuccess Connect invalid")
            case .Timeout:
                XCTAssert(false, "onSuccess Timeout invalid")
            case .Disconnected:
                XCTAssert(false, "onSuccess Disconnect invalid")
            case .ForcedDisconnected:
                XCTAssert(false, "onSuccess ForceDisconnect invalid")
            case .Failed:
                XCTAssert(false, "onSuccess Failed invalid")
            case .GiveUp:
                XCTAssert(false, "onSuccess GiveUp invalid")
            }
        }
        future.onFailure {error in
            onFailureExpectation.fulfill()
        }
        CentralQueue.sync {
            testPeripheral.helper.didFailToConnectPeripheral(testPeripheral, error:TestFailure.error)
        }
        waitForExpectationsWithTimeout(20) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testForcedDisconnectWhenDisconnected() {
        let testPeripheral = TestPeripheral(state:.Disconnected)
        let onFailureExpectation = expectationWithDescription("onFailure fulfilled for future")
        let future = testPeripheral.helper.connect(testPeripheral, connectionTimeout:100.0)
        future.onSuccess{(peripheral, connectionEvent) in
            switch connectionEvent {
            case .Connected:
                XCTAssert(false, "onSuccess Connect invalid")
            case .Timeout:
                XCTAssert(false, "onSuccess Timeout invalid")
            case .Disconnected:
                XCTAssert(false, "onSuccess Disconnect invalid")
            case .ForcedDisconnected:
                onFailureExpectation.fulfill()
            case .Failed:
                XCTAssert(false, "onSuccess Failed invalid")
            case .GiveUp:
                XCTAssert(false, "onSuccess GiveUp invalid")
            }
        }
        future.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        testPeripheral.helper.disconnect(testPeripheral)
        waitForExpectationsWithTimeout(120) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testForcedDisconnectWhenConnected() {
        let testPeripheral = TestPeripheral(state:.Connected)
        let onFailureExpectation = expectationWithDescription("onFailure fulfilled for future")
        let future = testPeripheral.helper.connect(testPeripheral)
        future.onSuccess{(peripheral, connectionEvent) in
            switch connectionEvent {
            case .Connected:
                XCTAssert(false, "onSuccess Connect invalid")
            case .Timeout:
                XCTAssert(false, "onSuccess Timeout invalid")
            case .Disconnected:
                XCTAssert(false, "onSuccess Disconnect invalid")
            case .ForcedDisconnected:
                onFailureExpectation.fulfill()
            case .Failed:
                XCTAssert(false, "onSuccess Failed invalid")
            case .GiveUp:
                XCTAssert(false, "onSuccess GiveUp invalid")
            }
        }
        future.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        testPeripheral.helper.disconnect(testPeripheral)
        CentralQueue.sync {
            testPeripheral.helper.didDisconnectPeripheral(testPeripheral)
        }
        waitForExpectationsWithTimeout(20) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testDisconnect() {
        let testPeripheral = TestPeripheral()
        let onFailureExpectation = expectationWithDescription("onFailure fulfilled for future")
        let future = testPeripheral.helper.connect(testPeripheral, connectionTimeout:100.0)
        future.onSuccess{(peripheral, connectionEvent) in
            switch connectionEvent {
            case .Connected:
                XCTAssert(false, "onSuccess Connect invalid")
            case .Timeout:
                XCTAssert(false, "onSuccess Timeout invalid")
            case .Disconnected:
                onFailureExpectation.fulfill()
            case .ForcedDisconnected:
                XCTAssert(false, "onSuccess ForceDisconnect invalid")
            case .Failed:
                XCTAssert(false, "onSuccess Failed invalid")
            case .GiveUp:
                XCTAssert(false, "onSuccess GiveUp invalid")
            }
        }
        future.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        CentralQueue.sync {
            testPeripheral.helper.didDisconnectPeripheral(testPeripheral)
        }
        waitForExpectationsWithTimeout(120) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testTimeout() {
        let testPeripheral = TestPeripheral(state:.Disconnected)
        let onFailureExpectation = expectationWithDescription("onFailure fulfilled for future")
        let future = testPeripheral.helper.connect(testPeripheral, connectionTimeout:1.0)
        future.onSuccess{(peripheral, connectionEvent) in
            switch connectionEvent {
            case .Connected:
                XCTAssert(false, "onSuccess Connect invalid")
            case .Timeout:
                onFailureExpectation.fulfill()
            case .Disconnected:
                XCTAssert(false, "onSuccess Disconnect invalid")
            case .ForcedDisconnected:
                XCTAssert(false, "onSuccess ForceDisconnect invalid")
            case .Failed:
                XCTAssert(false, "onSuccess Failed invalid")
            case .GiveUp:
                XCTAssert(false, "onSuccess GiveUp invalid")
            }
        }
        future.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        waitForExpectationsWithTimeout(20) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testGiveUp() {
        let testPeripheral = TestPeripheral(state:.Disconnected)
        let timeoutExpectation = expectationWithDescription("onFailure fulfilled for Timeout")
        let giveUpExpectation = expectationWithDescription("onFailure fulfilled for GiveUp")
        let future = testPeripheral.helper.connect(testPeripheral, connectionTimeout:1.0, timeoutRetries:1)
        future.onSuccess{(peripheral, connectionEvent) in
            switch connectionEvent {
            case .Connected:
                XCTAssert(false, "onSuccess Connect invalid")
            case .Timeout:
                timeoutExpectation.fulfill()
                testPeripheral.helper.connectPeripheral(testPeripheral)
            case .Disconnected:
                XCTAssert(false, "onSuccess Disconnect invalid")
            case .ForcedDisconnected:
                XCTAssert(false, "onSuccess ForceDisconnect invalid")
            case .Failed:
                XCTAssert(false, "onSuccess Failed invalid")
            case .GiveUp:
                giveUpExpectation.fulfill()
            }
        }
        future.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        waitForExpectationsWithTimeout(20) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testReconectOnTimeout() {
        let testPeripheral = TestPeripheral(state:.Disconnected)
        let timeoutExpectation = expectationWithDescription("onFailure fulfilled for Timeout")
        let onConnectionExpectation = expectationWithDescription("onSuccess fulfilled for future")
        let future = testPeripheral.helper.connect(testPeripheral, connectionTimeout:5.0, timeoutRetries:2)
        future.onSuccess{(peripheral, connectionEvent) in
            switch connectionEvent {
            case .Connected:
                onConnectionExpectation.fulfill()
            case .Timeout:
                timeoutExpectation.fulfill()
//                testPeripheral.helper.connectPeripheral(testPeripheral)
                testPeripheral.helper.didConnectPeripheral(testPeripheral)
            case .Disconnected:
                XCTAssert(false, "onSuccess Disconnect invalid")
            case .ForcedDisconnected:
                XCTAssert(false, "onSuccess ForceDisconnect invalid")
            case .Failed:
                XCTAssert(false, "onSuccess Failed invalid")
            case .GiveUp:
                XCTAssert(false, "onFailure GiveUp invalid")
            }
        }
        future.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        waitForExpectationsWithTimeout(120) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testReconnectOnDisconnect() {
        let testPeripheral = TestPeripheral(state:.Disconnected)
        let disconnectExpectation = expectationWithDescription("onFailure fulfilled for Disconnect")
        let onConnectionExpectation = expectationWithDescription("onSuccess fulfilled for future")
        let future = testPeripheral.helper.connect(testPeripheral, connectionTimeout:100.0)
        future.onSuccess{(peripheral, connectionEvent) in
            switch connectionEvent {
            case .Connected:
                onConnectionExpectation.fulfill()
            case .Timeout:
                XCTAssert(false, "onSuccess Timeout invalid")
            case .Disconnected:
                disconnectExpectation.fulfill()
                testPeripheral.helper.connectPeripheral(testPeripheral)
                testPeripheral.helper.didConnectPeripheral(testPeripheral)
            case .ForcedDisconnected:
                XCTAssert(false, "onSuccess ForceDisconnect invalid")
            case .Failed:
                XCTAssert(false, "onSuccess Failed invalid")
            case .GiveUp:
                XCTAssert(false, "onFailure GiveUp invalid")
            }
        }
        future.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        CentralQueue.sync {
            testPeripheral.helper.didDisconnectPeripheral(testPeripheral)
        }
        waitForExpectationsWithTimeout(120) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
}
