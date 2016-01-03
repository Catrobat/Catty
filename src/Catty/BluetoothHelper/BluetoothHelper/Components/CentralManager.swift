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
import CoreBluetooth

//MARK: Central Manager
public class CentralManager : NSObject, CBCentralManagerDelegate, CMWrapper {
    
    private static var instance : CentralManager!
    
    internal let helper = CentralManagerHelper<CentralManager>()
    
    private var cbCentralManager : CBCentralManager! = nil
    
    internal var ownPeripherals   = [CBPeripheral: Peripheral]()
    
    public class var sharedInstance : CentralManager {
        self.instance = self.instance ?? CentralManager()
        return self.instance
    }

    public class func sharedInstance(options:[String:AnyObject]) -> CentralManager {
        self.instance = self.instance ?? CentralManager(options:options)
        return self.instance
    }

    public var isScanning : Bool {
        return self.helper.isScanning
    }
    
    //MARK: init
    private override init() {
        super.init()
        self.cbCentralManager = CBCentralManager(delegate:self, queue:CentralQueue.queue)
    }
    
    private init(options:[String:AnyObject]?) {
        super.init()
        self.cbCentralManager = CBCentralManager(delegate:self, queue:CentralQueue.queue, options:options)
    }
    
    
    //MARK: SCAN
    public func getKnownPeripheralsWithIdentifiers(uuids:[NSUUID])-> [CBPeripheral] {
        return self.helper.retrieveKnownPeripheralsWithIdentifiers(self, uuids: uuids)
    }
    
    public func getConnectedPeripheralsWithServices(uuids:[CBUUID])-> FutureStream<[Peripheral]> {
        return self.helper.retrieveConnectedPeripheralsWithServices(self,uuids: uuids)
    }
    
    public func startScan() -> FutureStream<Peripheral> {
        return self.helper.startScanningForServiceUUIDs(self, uuids: nil)
    }
    
    public func startScanningForServiceUUIDs(uuids:[CBUUID]!, capacity:Int? = nil) -> FutureStream<Peripheral> {
        return self.helper.startScanningForServiceUUIDs(self, uuids:uuids, capacity:capacity)
    }
    
    public func stopScanning() {
        self.helper.stopScanning(self)
    }
    
    public func removeAllPeripherals() {
        self.ownPeripherals.removeAll(keepCapacity:false)
    }
    
    //MARK: Connection
    public func disconnectAllPeripherals() {
        self.helper.disconnectAllPeripherals(self)
    }
    
    public func connectPeripheral(peripheral:Peripheral, options:[String:AnyObject]?=nil) {
        self.cbCentralManager.connectPeripheral(peripheral.cbPeripheral, options:options)
    }
    
    internal func cancelPeripheralConnection(peripheral:Peripheral) {
        self.cbCentralManager.cancelPeripheralConnection(peripheral.cbPeripheral)
    }
    
    //MARK: Start/Stop
    public func start() -> Future<Void> {
        return self.helper.start(self)
    }
    
    public func stop() -> Future<Void> {
        return self.helper.stop(self)
    }
    
    //MARK: CBCentralManagerDelegate
    public func centralManager(_:CBCentralManager, didConnectPeripheral peripheral:CBPeripheral) {
        NSLog("peripheral: \(peripheral.name)")
        guard let ownPeripheral = self.ownPeripherals[peripheral] else {
            NSLog("error")
            return
        }
        ownPeripheral.didConnectPeripheral()
    }
    
    public func centralManager(_:CBCentralManager, didDisconnectPeripheral peripheral:CBPeripheral, error:NSError?) {
        NSLog("peripheral: \(peripheral.name)")
        guard let ownPeripheral = self.self.ownPeripherals[peripheral] else {
            NSLog("error")
            return
        }
        ownPeripheral.didDisconnectPeripheral()
    }
    
    public func centralManager(_:CBCentralManager, didDiscoverPeripheral peripheral:CBPeripheral, advertisementData:[String:AnyObject], RSSI:NSNumber) {
        if self.ownPeripherals[peripheral] == nil {

            let ownPeripheral = Peripheral(cbPeripheral:peripheral, advertisements:self.unpackAdvertisements(advertisementData), rssi:RSSI.integerValue)
            NSLog("peripheral: \(ownPeripheral.name)")
            self.ownPeripherals[peripheral] = ownPeripheral
            self.helper.didDiscoverPeripheral(ownPeripheral)
        }
    }
    
    public func centralManager(_:CBCentralManager, didFailToConnectPeripheral peripheral:CBPeripheral, error:NSError?) {
        guard let bcPeripheral = self.ownPeripherals[peripheral] else {
            NSLog("error")
            return
        }
        bcPeripheral.didFailToConnectPeripheral(error)
    }
    
    public func centralManager(_:CBCentralManager!, didRetrieveConnectedPeripherals peripherals:[AnyObject]!) {
        var array:[Peripheral] = Array()
        for peripheral:CBPeripheral in peripherals as! [CBPeripheral] {
            let ownPeripheral:Peripheral = Peripheral(cbPeripheral:peripheral)
            array.append(ownPeripheral)
        }
        self.helper.receivedConnectedPeripheral(array)
    }
    
    public func centralManager(_:CBCentralManager!, didRetrievePeripherals peripherals:[AnyObject]!) {
        var array:[Peripheral] = Array()
        for peripheral:CBPeripheral in peripherals as! [CBPeripheral] {
            let ownPeripheral:Peripheral = Peripheral(cbPeripheral:peripheral)
            array.append(ownPeripheral)
        }
        self.helper.receivedKnownPeripheral(array)

    }
    
    public func centralManager(_:CBCentralManager, willRestoreState dict:[String:AnyObject]) {

    }
    public func centralManagerDidUpdateState(_:CBCentralManager) {
        self.helper.didUpdateState(self)
    }

    internal func unpackAdvertisements(advertDictionary:[String:AnyObject]) -> [String:String] {
        var advertisements = [String:String]()
        func addKey(key:String, andValue value:AnyObject) -> () {
            if value is NSString {
                advertisements[key] = (value as? String)
            } else {
                advertisements[key] = value.stringValue
            }
        }
        for key in advertDictionary.keys {
            if let value : AnyObject = advertDictionary[key] {
                if value is NSArray {
                    for valueItem : AnyObject in (value as! NSArray) {
                        addKey(key, andValue:valueItem)
                    }
                } else {
                    addKey(key, andValue:value)
                }
            }
        }
        return advertisements
    }
    
    //MARK: Wrap
    public var isOn : Bool {
        return self.cbCentralManager.state == CBCentralManagerState.PoweredOn
    }
    
    public var isOff : Bool {
        return self.cbCentralManager.state == CBCentralManagerState.PoweredOff
    }
    
    
    public var peripherals : [Peripheral] {
        
        let values: [Peripheral] = [Peripheral](self.ownPeripherals.values)
        return values
    }

    public var state: CBCentralManagerState {
        return self.cbCentralManager.state
    }
    
    public func scanForPeripheralsWithServices(uuids:[CBUUID]?) {
        self.cbCentralManager.scanForPeripheralsWithServices(uuids,options:nil)
    }
    
    public func retrievePeripheralsWithIdentifiers(uuids:[NSUUID]) -> [CBPeripheral]{
        return self.cbCentralManager.retrievePeripheralsWithIdentifiers(uuids)
    }
    public func retrieveConnectedPeripheralsWithServices(uuids:[CBUUID]){
        self.cbCentralManager.retrieveConnectedPeripheralsWithServices(uuids)
    }
    
    public func stopScan() {
        self.cbCentralManager.stopScan()
    }

}

//MARK:Helper
public class CentralManagerHelper<CM where CM:CMWrapper,
                                           CM.PeripheralWrap:PeripheralWrapper> {
    
    private var afterStartingPromise                 = Promise<Void>()
    private var afterStoppingPromise                = Promise<Void>()
    internal var afterPeripheralDiscoveredPromise   = StreamPromise<CM.PeripheralWrap>()
    internal var afterKnownPeripheralDiscoveredPromise   = StreamPromise<[CM.PeripheralWrap]>()
    internal var afterConnectedPeripheralDiscoveredPromise   = StreamPromise<[CM.PeripheralWrap]>()
    
    private var _isScanning      = false
    
    public var isScanning : Bool {
        return self._isScanning
    }
    
    public init() {
    }
    
    //MARK: Scan
    
    public func startScanningForServiceUUIDs(central:CM, uuids:[CBUUID]!, capacity:Int? = nil) -> FutureStream<CM.PeripheralWrap> {
        if !self._isScanning {
            NSLog("UUIDs \(uuids)")
            if let capacity = capacity {
                self.afterPeripheralDiscoveredPromise = StreamPromise<CM.PeripheralWrap>(capacity:capacity)
            } else {
                self.afterPeripheralDiscoveredPromise = StreamPromise<CM.PeripheralWrap>()
            }
            self._isScanning = true
            central.scanForPeripheralsWithServices(uuids)
        }
        return self.afterPeripheralDiscoveredPromise.future
    }
    
    public func retrieveKnownPeripheralsWithIdentifiers(central:CM,uuids:[NSUUID])-> [CBPeripheral] {
        return central.retrievePeripheralsWithIdentifiers(uuids)
    }
    
    public func retrieveConnectedPeripheralsWithServices(central:CM,uuids:[CBUUID])-> FutureStream<[CM.PeripheralWrap]> {
        central.retrieveConnectedPeripheralsWithServices(uuids)
        self.afterConnectedPeripheralDiscoveredPromise = StreamPromise<[CM.PeripheralWrap]>()
        return self.afterConnectedPeripheralDiscoveredPromise.future
    }
    
    public func stopScanning(central:CM) {
        if self._isScanning {
            self._isScanning = false
            central.stopScan()
        }
    }
    
    //MARK: Connection
    public func disconnectAllPeripherals(central:CentralManager) {
        for peripheral in central.peripherals {
            peripheral.disconnect()
        }
    }
    
    
    //MARK: Power
    public func start(central:CM) -> Future<Void> {
        CentralQueue.sync {
            self.afterStartingPromise = Promise<Void>()
            if central.isOn {
                self.afterStartingPromise.success()
            }
        }
        return self.afterStartingPromise.future
    }
    
    public func stop(central:CM) -> Future<Void> {
        CentralQueue.sync {
            self.afterStoppingPromise = Promise<Void>()
            if central.isOff {
                self.afterStoppingPromise.success()
            }
        }
        return self.afterStoppingPromise.future
    }
    
    //MARK: State
    public func didUpdateState(central:CM) {
        switch(central.state) {
        case .Unauthorized:
            NSLog("Unauthorized")
            break
        case .Unknown:
            NSLog("Unknown")
            break
        case .Unsupported:
            NSLog("Unsupported")
            break
        case .Resetting:
            NSLog("Resetting")
            break
        case .PoweredOff:
            NSLog("PoweredOff")
            if !self.afterStoppingPromise.completed {
                self.afterStoppingPromise.success()
            }
            break
        case .PoweredOn:
            NSLog("PoweredOn")
            if !self.afterStartingPromise.completed {
                self.afterStartingPromise.success()
            }
            break
        }
    }
    
    //MARK: did discover Peripheral
    public func didDiscoverPeripheral(peripheral:CM.PeripheralWrap) {
        self.afterPeripheralDiscoveredPromise.success(peripheral)
    }
    
    public func receivedKnownPeripheral(peripherals:[CM.PeripheralWrap]) {
        self.afterKnownPeripheralDiscoveredPromise.success(peripherals)
    }
    
    public func receivedConnectedPeripheral(peripherals:[CM.PeripheralWrap]) {
        self.afterConnectedPeripheralDiscoveredPromise.success(peripherals)
    }
    
    
}
