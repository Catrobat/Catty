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

class PeripheralTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testDiscoverServicesSuccess() {
        let testPeripheral = TestPeripheral(state:.connected)
        let onSuccessExpectation = expectation(description: "onSuccess fulfilled for future")
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
        waitForExpectations(timeout: 2) {error in
            XCTAssertNil(error, "\(String(describing: error))")
        }
    }

    func testDiscoverServicesFailure() {
        let testPeripheral = TestPeripheral(state:.connected)
        let onFailureExpectation = expectation(description: "onFailure fulfilled for future")
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
        waitForExpectations(timeout: 2) {error in
            XCTAssertNil(error, "\(String(describing: error))")
        }
    }

    func testDiscoverPeripheralServicesSuccess() {
        let testPeripheral = TestPeripheral(state:.connected)
        let onSuccessExpectation = expectation(description: "onSuccess fulfilled for future")
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
        waitForExpectations(timeout: 20) {error in
            XCTAssertNil(error, "\(String(describing: error))")
        }
    }
    
    func testDiscoverPeripheralServicesPeripheralFailure() {
        let testPeripheral = TestPeripheral(state:.connected)
        let onFailureExpectation = expectation(description: "onFailure fulfilled for future")
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
        waitForExpectations(timeout: 20) {error in
            XCTAssertNil(error, "\(String(describing: error))")
        }
    }

    func testDiscoverPeripheralServicesServiceFailure() {
        let testPeripheral = TestPeripheral(state:.connected)
        TestServiceValues.error = TestFailure.error
        let onFailureExpectation = expectation(description: "onFailure fulfilled for future")
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
        waitForExpectations(timeout: 20) {error in
            XCTAssertNil(error, "\(String(describing: error))")
        }
        TestServiceValues.error = nil
    }

    func testDiscoverPeripheralServicesNoNersicesFoundFailure() {
        let testPeripheral = TestPeripheral(state:.connected, services:[TestService]())
        let onFailureExpectation = expectation(description: "onFailure fulfilled for future")
        let future = testPeripheral.helper.discoverPeripheralServices(testPeripheral, services:nil)
        future.onSuccess {_ in
            XCTAssert(false, "onSuccess called")
        }
        future.onFailure {error in
            onFailureExpectation.fulfill()
            XCTAssert(error.domain == BluetoothError.domain, "message domain invalid")
            XCTAssert(error.code == PeripheralError.noServices.rawValue, "message code invalid")
        }
        CentralQueue.sync {
            testPeripheral.helper.didDiscoverServices(testPeripheral, error:nil)
        }
        waitForExpectations(timeout: 20) {error in
            XCTAssertNil(error, "\(String(describing: error))")
        }
        TestServiceValues.error = nil
    }

    func testConnect() {
        let testPeripheral = TestPeripheral()
        let onConnectionExpectation = expectation(description: "onSuccess fulfilled for future")
        let future = testPeripheral.helper.connect(testPeripheral, connectionTimeout:100.0)
        future.onSuccess{(peripheral, connectionEvent) in
            switch connectionEvent {
            case .connected:
                onConnectionExpectation.fulfill()
            case .timeout:
                XCTAssert(false, "onSuccess Timeout invalid")
            case .disconnected:
                XCTAssert(false, "onSuccess Disconnect invalid")
            case .forcedDisconnected:
                XCTAssert(false, "onSuccess ForceDisconnect invalid")
            case .failed:
                XCTAssert(false, "onSuccess Failed invalid")
            case .giveUp:
                XCTAssert(false, "onSuccess GiveUp invalid")
            }
        }
        future.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        CentralQueue.sync {
            testPeripheral.helper.didConnectPeripheral(testPeripheral)
        }
        waitForExpectations(timeout: 120) {error in
            XCTAssertNil(error, "\(String(describing: error))")
        }
    }
    
    func testFailedConnect() {
        let testPeripheral = TestPeripheral()
        let onFailureExpectation = expectation(description: "onFailure fulfilled for future")
        let future = testPeripheral.helper.connect(testPeripheral, connectionTimeout:100.0)
        future.onSuccess{(peripheral, connectionEvent) in
            switch connectionEvent {
            case .connected:
                XCTAssert(false, "onSuccess Connect invalid")
            case .timeout:
                XCTAssert(false, "onSuccess Timeout invalid")
            case .disconnected:
                XCTAssert(false, "onSuccess Disconnect invalid")
            case .forcedDisconnected:
                XCTAssert(false, "onSuccess ForceDisconnect invalid")
            case .failed:
                onFailureExpectation.fulfill()
            case .giveUp:
                XCTAssert(false, "onSuccess GiveUp invalid")
            }
        }
        future.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        CentralQueue.sync {
            testPeripheral.helper.didFailToConnectPeripheral(testPeripheral, error:nil)
        }
        waitForExpectations(timeout: 120) {error in
            XCTAssertNil(error, "\(String(describing: error))")
        }
    }

    func testFailedConnectWithError() {
        let testPeripheral = TestPeripheral(state:.connected)
        let onFailureExpectation = expectation(description: "onFailure fulfilled for future")
        let future = testPeripheral.helper.connect(testPeripheral)
        future.onSuccess{(peripheral, connectionEvent) in
            switch connectionEvent {
            case .connected:
                XCTAssert(false, "onSuccess Connect invalid")
            case .timeout:
                XCTAssert(false, "onSuccess Timeout invalid")
            case .disconnected:
                XCTAssert(false, "onSuccess Disconnect invalid")
            case .forcedDisconnected:
                XCTAssert(false, "onSuccess ForceDisconnect invalid")
            case .failed:
                XCTAssert(false, "onSuccess Failed invalid")
            case .giveUp:
                XCTAssert(false, "onSuccess GiveUp invalid")
            }
        }
        future.onFailure {error in
            onFailureExpectation.fulfill()
        }
        CentralQueue.sync {
            testPeripheral.helper.didFailToConnectPeripheral(testPeripheral, error:TestFailure.error)
        }
        waitForExpectations(timeout: 20) {error in
            XCTAssertNil(error, "\(String(describing: error))")
        }
    }

    func testForcedDisconnectWhenDisconnected() {
        let testPeripheral = TestPeripheral(state:.disconnected)
        let onFailureExpectation = expectation(description: "onFailure fulfilled for future")
        let future = testPeripheral.helper.connect(testPeripheral, connectionTimeout:100.0)
        future.onSuccess{(peripheral, connectionEvent) in
            switch connectionEvent {
            case .connected:
                XCTAssert(false, "onSuccess Connect invalid")
            case .timeout:
                XCTAssert(false, "onSuccess Timeout invalid")
            case .disconnected:
                XCTAssert(false, "onSuccess Disconnect invalid")
            case .forcedDisconnected:
                onFailureExpectation.fulfill()
            case .failed:
                XCTAssert(false, "onSuccess Failed invalid")
            case .giveUp:
                XCTAssert(false, "onSuccess GiveUp invalid")
            }
        }
        future.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        testPeripheral.helper.disconnect(testPeripheral)
        waitForExpectations(timeout: 120) {error in
            XCTAssertNil(error, "\(String(describing: error))")
        }
    }
    
    func testForcedDisconnectWhenConnected() {
        let testPeripheral = TestPeripheral(state:.connected)
        let onFailureExpectation = expectation(description: "onFailure fulfilled for future")
        let future = testPeripheral.helper.connect(testPeripheral)
        future.onSuccess{(peripheral, connectionEvent) in
            switch connectionEvent {
            case .connected:
                XCTAssert(false, "onSuccess Connect invalid")
            case .timeout:
                XCTAssert(false, "onSuccess Timeout invalid")
            case .disconnected:
                XCTAssert(false, "onSuccess Disconnect invalid")
            case .forcedDisconnected:
                onFailureExpectation.fulfill()
            case .failed:
                XCTAssert(false, "onSuccess Failed invalid")
            case .giveUp:
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
        waitForExpectations(timeout: 20) {error in
            XCTAssertNil(error, "\(String(describing: error))")
        }
    }

    func testDisconnect() {
        let testPeripheral = TestPeripheral()
        let onFailureExpectation = expectation(description: "onFailure fulfilled for future")
        let future = testPeripheral.helper.connect(testPeripheral, connectionTimeout:100.0)
        future.onSuccess{(peripheral, connectionEvent) in
            switch connectionEvent {
            case .connected:
                XCTAssert(false, "onSuccess Connect invalid")
            case .timeout:
                XCTAssert(false, "onSuccess Timeout invalid")
            case .disconnected:
                onFailureExpectation.fulfill()
            case .forcedDisconnected:
                XCTAssert(false, "onSuccess ForceDisconnect invalid")
            case .failed:
                XCTAssert(false, "onSuccess Failed invalid")
            case .giveUp:
                XCTAssert(false, "onSuccess GiveUp invalid")
            }
        }
        future.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        CentralQueue.sync {
            testPeripheral.helper.didDisconnectPeripheral(testPeripheral)
        }
        waitForExpectations(timeout: 120) {error in
            XCTAssertNil(error, "\(String(describing: error))")
        }
    }
    
    func testTimeout() {
        let testPeripheral = TestPeripheral(state:.disconnected)
        let onFailureExpectation = expectation(description: "onFailure fulfilled for future")
        let future = testPeripheral.helper.connect(testPeripheral, connectionTimeout:1.0)
        future.onSuccess{(peripheral, connectionEvent) in
            switch connectionEvent {
            case .connected:
                XCTAssert(false, "onSuccess Connect invalid")
            case .timeout:
                onFailureExpectation.fulfill()
            case .disconnected:
                XCTAssert(false, "onSuccess Disconnect invalid")
            case .forcedDisconnected:
                XCTAssert(false, "onSuccess ForceDisconnect invalid")
            case .failed:
                XCTAssert(false, "onSuccess Failed invalid")
            case .giveUp:
                XCTAssert(false, "onSuccess GiveUp invalid")
            }
        }
        future.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        waitForExpectations(timeout: 20) {error in
            XCTAssertNil(error, "\(String(describing: error))")
        }
    }
    
    func testGiveUp() {
        let testPeripheral = TestPeripheral(state:.disconnected)
        let timeoutExpectation = expectation(description: "onFailure fulfilled for Timeout")
        let giveUpExpectation = expectation(description: "onFailure fulfilled for GiveUp")
        let future = testPeripheral.helper.connect(testPeripheral, timeoutRetries:1, connectionTimeout:1.0)
        future.onSuccess{(peripheral, connectionEvent) in
            switch connectionEvent {
            case .connected:
                XCTAssert(false, "onSuccess Connect invalid")
            case .timeout:
                timeoutExpectation.fulfill()
                testPeripheral.helper.connectPeripheral(testPeripheral)
            case .disconnected:
                XCTAssert(false, "onSuccess Disconnect invalid")
            case .forcedDisconnected:
                XCTAssert(false, "onSuccess ForceDisconnect invalid")
            case .failed:
                XCTAssert(false, "onSuccess Failed invalid")
            case .giveUp:
                giveUpExpectation.fulfill()
            }
        }
        future.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        waitForExpectations(timeout: 20) {error in
            XCTAssertNil(error, "\(String(describing: error))")
        }
    }

    func testReconectOnTimeout() {
        let testPeripheral = TestPeripheral(state:.disconnected)
        let timeoutExpectation = expectation(description: "onFailure fulfilled for Timeout")
        let onConnectionExpectation = expectation(description: "onSuccess fulfilled for future")
        let future = testPeripheral.helper.connect(testPeripheral, timeoutRetries:2, connectionTimeout:5.0)
        future.onSuccess{(peripheral, connectionEvent) in
            switch connectionEvent {
            case .connected:
                onConnectionExpectation.fulfill()
            case .timeout:
                timeoutExpectation.fulfill()
//                testPeripheral.helper.connectPeripheral(testPeripheral)
                testPeripheral.helper.didConnectPeripheral(testPeripheral)
            case .disconnected:
                XCTAssert(false, "onSuccess Disconnect invalid")
            case .forcedDisconnected:
                XCTAssert(false, "onSuccess ForceDisconnect invalid")
            case .failed:
                XCTAssert(false, "onSuccess Failed invalid")
            case .giveUp:
                XCTAssert(false, "onFailure GiveUp invalid")
            }
        }
        future.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        waitForExpectations(timeout: 120) {error in
            XCTAssertNil(error, "\(String(describing: error))")
        }
    }
    
    func testReconnectOnDisconnect() {
        let testPeripheral = TestPeripheral(state:.disconnected)
        let disconnectExpectation = expectation(description: "onFailure fulfilled for Disconnect")
        let onConnectionExpectation = expectation(description: "onSuccess fulfilled for future")
        let future = testPeripheral.helper.connect(testPeripheral, connectionTimeout:100.0)
        future.onSuccess{(peripheral, connectionEvent) in
            switch connectionEvent {
            case .connected:
                onConnectionExpectation.fulfill()
            case .timeout:
                XCTAssert(false, "onSuccess Timeout invalid")
            case .disconnected:
                disconnectExpectation.fulfill()
                testPeripheral.helper.connectPeripheral(testPeripheral)
                testPeripheral.helper.didConnectPeripheral(testPeripheral)
            case .forcedDisconnected:
                XCTAssert(false, "onSuccess ForceDisconnect invalid")
            case .failed:
                XCTAssert(false, "onSuccess Failed invalid")
            case .giveUp:
                XCTAssert(false, "onFailure GiveUp invalid")
            }
        }
        future.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        CentralQueue.sync {
            testPeripheral.helper.didDisconnectPeripheral(testPeripheral)
        }
        waitForExpectations(timeout: 120) {error in
            XCTAssertNil(error, "\(String(describing: error))")
        }
    }
}
