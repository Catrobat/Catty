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

import Foundation
import CoreBluetooth
import BluetoothHelper

struct TestFailure {
    static let error = NSError(domain:"BluetoothTests Tests", code:100, userInfo:[NSLocalizedDescriptionKey:"Testing"])
}

class TestCentralManager : CMWrapper {
    
    let helper = CentralManagerHelper<TestCentralManager>()
    
    var state : ManagerState
    
    var isOn : Bool {
        return self.state == ManagerState.poweredOn
    }
    
    var isOff : Bool {
        return self.state == ManagerState.poweredOff
    }
    
    var peripherals : [TestPeripheral] {
        return []
    }
    
    init(state:ManagerState = .poweredOn) {
        self.state = state
    }
    
    func scanForPeripheralsWithServices(_ uuids:[CBUUID]?) {
    }
    
    func stopScan() {
    }
    
    func retrieveConnectedPeripheralsWithServices(_ uuids: [CBUUID]) {
        
    }
    
    func retrievePeripheralsWithIdentifiers(_ uuids: [UUID]) -> [CBPeripheral] {
        return [CBPeripheral]()
    }
    
}

class TestPeripheral : PeripheralWrapper {
    
    let helper = PeripheralHelper<TestPeripheral>()
    
    let state :CBPeripheralState
    let name : String
    
    let services : [TestService]
    
    init(name:String = "Mock Peripheral", state:CBPeripheralState = .disconnected,
        services:[TestService]=[TestService(uuid:CBUUID(string:"2f0a0017-69aa-f316-3e78-4194989a6ccc"), name:"Service Mock-1"),
            TestService(uuid:CBUUID(string:"2f0a0017-69aa-f316-3e78-4194989a6aaa"), name:"Service Mock-2")]) {
                self.state = state
                self.name = name
                self.services = services
    }
    
    func connect() {
    }
    
    func reconnect() {
    }
    
    func cancel() {
        if self.state == .disconnected {
            CentralQueue.async {
                self.helper.didDisconnectPeripheral(self)
            }
        }
    }
    
    func disconnect() {
    }
    
    func discoverServices(_ services:[CBUUID]?) {
    }
    
    func didDiscoverServices() {
    }
    
}

struct TestServiceValues {
    static var error : NSError? = nil
}

struct TestService : ServiceWrapper{
    
    let uuid  : CBUUID
    let name  : String
    let state : CBPeripheralState
    
    let helper = ServiceHelper<TestService>()
    
    init(uuid:CBUUID = CBUUID(string:"2f0a0017-69aa-f316-3e78-4194989a6ccc"),
        name:String = "Mock",
        state:CBPeripheralState = .connected) {
            self.uuid = uuid
            self.name = name
            self.state = state
    }
    
    func discoverCharacteristics(_ characteristics:[CBUUID]?) {
    }
    
    func didDiscoverCharacteristics(_ error:NSError?) {
        CentralQueue.async {
            self.helper.didDiscoverCharacteristics(self, error:TestServiceValues.error)
        }
    }
    
    func initCharacteristics() {
    }
    
    func discoverAllCharacteristics() -> Future<TestService> {
        let future = self.helper.discoverCharacteristicsIfConnected(self, characteristics:nil)
        self.didDiscoverCharacteristics(TestServiceValues.error)
        return future
    }
    
}

final class TestCharacteristic : CharacteristicWrapper{
    
    var _isNotifying             = false
    var _stringValues            = [String]()
    var _propertyEnabled         = true
    var _stringValue             = ["Mock":"1"]
    var _dataFromStringValue     = "01".dataFromHexString()
    var _afterDiscoveredPromise  = StreamPromise<TestCharacteristic>()
    
    let helper = CharacteristicImplementation<TestCharacteristic>()
    
    var uuid : CBUUID {
        return CBUUID(string:"2f0a0017-69aa-f316-3e78-4194989a6c1a")
    }
    
    init (propertyEnabled:Bool = true) {
        self._propertyEnabled = propertyEnabled
    }
    
    var name : String {
        return "Mock"
    }
    
    var isNotifying : Bool {
        return self._isNotifying
    }
    
    var stringValues : [String] {
        return self._stringValues
    }
    
    var afterDiscoveredPromise  : StreamPromise<TestCharacteristic>? {
        return self._afterDiscoveredPromise
    }
    
    func stringValue(_ data:Data?) -> [String:String]? {
        return self._stringValue
    }
    
    func dataFromStringValue(_ stringValue:[String:String]) -> Data? {
        return self._dataFromStringValue
    }
    
    func setNotifyValue(_ state:Bool) {
        self._isNotifying = state
    }
    
    func propertyEnabled(_ property:CBCharacteristicProperties) -> Bool {
        return self._propertyEnabled
    }
    
    func readValueForCharacteristic() {
    }
    
    func writeValue(_ value:Data) {
    }
}


