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
import CoreBluetooth

//MARK:Peripheral

public class Peripheral : NSObject, CBPeripheralDelegate, PeripheralWrapper {
    
    public var helper = PeripheralHelper<Peripheral>()
    
    public var ownServices          = [CBUUID:Service]()
    public var ownCharacteristics   = [CBCharacteristic:Characteristic]()
    
    public let cbPeripheral   : CBPeripheral
    
    public let advertisements   : [String: String]
    public let rssi             : Int
    
    // MARK: Init
    internal init(cbPeripheral:CBPeripheral, advertisements:[String:String], rssi:Int) {
        self.cbPeripheral = cbPeripheral
        self.advertisements = advertisements
        self.rssi = rssi
        super.init()
        self.cbPeripheral.delegate = self
    }
    
    internal init(cbPeripheral:CBPeripheral) {
        self.cbPeripheral = cbPeripheral
        self.advertisements = NSDictionary() as! [String : String]
        self.rssi = 0
        super.init()
        self.cbPeripheral.delegate = self
    }

    
    
    
    // rssi
    func readRSSI() -> Future<Int> {
        self.cbPeripheral.readRSSI()
        return self.helper.readRSSI()
    }
    
    //MARK: Connection
    public func reconnect() {
        self.helper.connectPeripheral(self)
    }
    
    public func connect(capacity:Int? = nil, timeoutRetries:Int? = nil, disconnectRetries:Int? = nil, connectionTimeout:Double = 10.0) -> FutureStream<(Peripheral, ConnectionEvent)> {
        return self.helper.connect(self, capacity:capacity, timeoutRetries:timeoutRetries, disconnectRetries:disconnectRetries, connectionTimeout:connectionTimeout)
    }
    
    //MARK: Discover Services
    public func discoverAllServices() -> Future<Peripheral> {
        return self.helper.discoverServices(self, services: nil)
    }
    
    public func discoverServices(services:[CBUUID]?) -> Future<Peripheral> {
        return self.helper.discoverServices(self, services:services)
    }
    
    public func discoverAllPeripheralServices() -> Future<Peripheral> {
        return self.helper.discoverPeripheralServices(self, services: nil)
    }
    
    public func discoverPeripheralServices(services:[CBUUID]?) -> Future<Peripheral> {
        return self.helper.discoverPeripheralServices(self, services:services)
    }
    
    //MARK: CBPeripheralDelegate
    public func peripheralDidUpdateName(_:CBPeripheral) {

    }
    
    public func peripheral(_:CBPeripheral, didModifyServices invalidatedServices:[CBService]) {
    }
    
    public func peripheral(_:CBPeripheral, didReadRSSI RSSI:NSNumber, error:NSError?) {
        self.helper.didReadRSSI(RSSI, error:error)
    }
    
    // service delegates
    public func peripheral(peripheral:CBPeripheral, didDiscoverServices error:NSError?) {
        self.removeAll()
        self.helper.didDiscoverServices(self, error:error)
    }
    
    public func peripheral(_:CBPeripheral, didDiscoverIncludedServicesForService service:CBService, error:NSError?) {

    }
    
    // characteristic delegates
    public func peripheral(_:CBPeripheral, didDiscoverCharacteristicsForService service:CBService, error:NSError?) {
        guard let ownService = self.ownServices[service.UUID], ownCharacteristics = service.characteristics else {
            return
        }
        ownService.didDiscoverCharacteristics(error)
        if error == nil {
            for characteristic : AnyObject in ownCharacteristics {
                if let ownCharacteristic = characteristic as? CBCharacteristic {
                    self.ownCharacteristics[ownCharacteristic] = ownService.ownCharacteristics[characteristic.UUID]
                }
            }
        }

    }
    
    public func peripheral(_:CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic:CBCharacteristic, error:NSError?) {
        guard let ownCharacteristic = self.ownCharacteristics[characteristic] else {
            NSLog("Error")
            return
        }
        NSLog("uuid=\(ownCharacteristic.uuid.UUIDString), name=\(ownCharacteristic.name)")
        ownCharacteristic.didUpdateNotificationState(error)
    }
    
    public func peripheral(_:CBPeripheral, didUpdateValueForCharacteristic characteristic:CBCharacteristic, error:NSError?) {
        guard let ownCharacteristic = self.ownCharacteristics[characteristic] else {
            NSLog("Error")
            return
        }
        NSLog("uuid=\(ownCharacteristic.uuid.UUIDString), name=\(ownCharacteristic.name)")
        ownCharacteristic.didUpdate(error)
    }
    
    public func peripheral(_:CBPeripheral, didWriteValueForCharacteristic characteristic:CBCharacteristic, error: NSError?) {
        guard let ownCharacteristic = self.ownCharacteristics[characteristic] else {
            NSLog("Error")
            return
        }
        NSLog("uuid=\(ownCharacteristic.uuid.UUIDString), name=\(ownCharacteristic.name)")
        ownCharacteristic.didWrite(error)
    }
    
    
    //MARK: Helper
    private func removeAll() {
        self.ownServices.removeAll()
        self.ownCharacteristics.removeAll()
    }
    
    internal func didDisconnectPeripheral() {
        self.helper.didDisconnectPeripheral(self)
    }
    
    internal func didConnectPeripheral() {
        self.helper.didConnectPeripheral(self)
    }
    
    internal func didFailToConnectPeripheral(error:NSError?) {
        self.helper.didFailToConnectPeripheral(self, error:error)
    }
    // MARK: Wrap
    public var name : String {
        if let name = self.cbPeripheral.name {
            return name
        } else {
            return "Unknown"
        }
    }
    
    public var state : CBPeripheralState {
        return self.cbPeripheral.state
    }
    
    public var services : [Service] {
        let values:[Service] = [Service](self.ownServices.values)
        return values
    }
    
    public func connect() {
        CentralManager.sharedInstance.connectPeripheral(self)
    }
    
    public func cancel() {
        CentralManager.sharedInstance.cancelPeripheralConnection(self)
    }
    
    public func disconnect() {
        CentralManager.sharedInstance.ownPeripherals.removeValueForKey(self.cbPeripheral)
        self.helper.disconnect(self)
    }
    
    public func discoverServices(services:[CBUUID]?) {
        self.cbPeripheral.discoverServices(services)
    }
    
    public func didDiscoverServices() {
        guard let ownServices = self.cbPeripheral.services else {
            return
        }
        for ownService : AnyObject in ownServices {
            guard let ownService = ownService as? CBService else {
                return
            }
            let bcService = Service(ownService:ownService, peripheral:self)
            self.ownServices[bcService.uuid] = bcService
            NSLog("uuid=\(bcService.uuid.UUIDString), name=\(bcService.name)")
        }
    }
    
    public var id : NSUUID {
        return self.cbPeripheral.identifier
    }
    
    
    public func service(uuid:CBUUID) -> Service? {
        return self.ownServices[uuid]
    }

    
}

// MARK: Peripheral Helper
public class PeripheralHelper<P where P:PeripheralWrapper,
                          P.ServiceWrap:ServiceWrapper> {
    
    private var connectionPromise : StreamPromise<(P, ConnectionEvent)>?
    private var servicesDiscoveredPromise   = Promise<P>()
    private var readRSSIPromise             = Promise<Int>()
    
    internal var timeoutRetries         : Int?
    internal var disconnectRetries      : Int?
    internal var connectionTimeout      = 5.0
    
    private var connectionSequence      = 0
    private var currentError            = PeripheralConnectionError.None
    private var forcedDisconnect        = false
    
    
    
    public init() {
    }
    
    //MARK: Connection
    public func connectPeripheral(peripheral:P) {
        if peripheral.state == .Disconnected {
            NSLog("reconnect peripheral \(peripheral.name)")
            peripheral.connect()
            self.forcedDisconnect = false
            self.connectionSequence++
            self.timeoutConnection(peripheral, sequence:self.connectionSequence)
        }
    }
    
    public func connect(peripheral:P, capacity:Int? = nil, timeoutRetries:Int? = nil, disconnectRetries:Int? = nil, connectionTimeout:Double = 5.0) -> FutureStream<(P, ConnectionEvent)> {
        self.connectionPromise = StreamPromise<(P, ConnectionEvent)>(capacity:capacity)
        self.timeoutRetries = timeoutRetries
        self.disconnectRetries = disconnectRetries
        self.connectionTimeout = connectionTimeout
        NSLog("connect peripheral \(peripheral.name)")
        self.connectPeripheral(peripheral)
        return self.connectionPromise!.future
    }
    
    public func disconnect(peripheral:P) {
        self.forcedDisconnect = true
        if peripheral.state == .Connected {
            NSLog("disconnect peripheral \(peripheral.name)")
            peripheral.cancel()
        } else {
            self.didDisconnectPeripheral(peripheral)
        }
    }
    
    private func timeoutConnection(peripheral:P, sequence:Int) {
        CentralQueue.delay(self.connectionTimeout) {
            if peripheral.state != .Connected && sequence == self.connectionSequence && !self.forcedDisconnect {
                self.currentError = .Timeout
                peripheral.cancel()
            } else {
            }
        }
    }
    
    //MARK: discover Service
    public func discoverServices(peripheral:P, services:[CBUUID]?) -> Future<P> {
        NSLog("peripheral: \(peripheral.name)")
        CentralQueue.sync {
            self.servicesDiscoveredPromise = Promise<P>()
            if peripheral.state == .Connected {
                peripheral.discoverServices(services)
            } else {
                self.servicesDiscoveredPromise.failure(BluetoothError.peripheralDisconnected)
            }
        }
        return self.servicesDiscoveredPromise.future
    }
    
    
    public func discoverPeripheralServices(peripheral:P, services:[CBUUID]?) -> Future<P> {
        let peripheralDiscoveredPromise = Promise<P>()
        NSLog("peripheral: \(peripheral.name)")
        let servicesDiscoveredFuture = self.discoverServices(peripheral, services:services)
        servicesDiscoveredFuture.onSuccess {_ in
            if peripheral.services.count > 1 {
                self.discoverService(peripheral,
                    head:peripheral.services[0],
                    tail:Array(peripheral.services[1..<peripheral.services.count]),
                    promise:peripheralDiscoveredPromise)
            } else {
                if peripheral.services.count > 0 {
                    let discoveryFuture = peripheral.services[0].discoverAllCharacteristics()
                    discoveryFuture.onSuccess {_ in
                        peripheralDiscoveredPromise.success(peripheral)
                    }
                    discoveryFuture.onFailure {error in
                        peripheralDiscoveredPromise.failure(error)
                    }
                } else {
                    peripheralDiscoveredPromise.failure(BluetoothError.peripheralNoServices)
                }
            }
        }
        servicesDiscoveredFuture.onFailure{(error) in
            peripheralDiscoveredPromise.failure(error)
        }
        return peripheralDiscoveredPromise.future
    }
    internal func discoverService(peripheral:P, head:P.ServiceWrap, tail:[P.ServiceWrap], promise:Promise<P>) {
        let discoveryFuture = head.discoverAllCharacteristics()
        NSLog("service name \(head.name) count \(tail.count + 1)")
        if tail.count > 0 {
            discoveryFuture.onSuccess {_ in
                self.discoverService(peripheral, head:tail[0], tail:Array(tail[1..<tail.count]), promise:promise)
            }
        } else {
            discoveryFuture.onSuccess {_ in
                promise.success(peripheral)
            }
        }
        discoveryFuture.onFailure {error in
            promise.failure(error)
        }
    }
    
    //MARK: RSSI
    public func readRSSI() -> Future<Int> {
        CentralQueue.sync {
            self.readRSSIPromise = Promise<Int>()
        }
        return self.readRSSIPromise.future
    }
    
    //MARK: CBPeripheralDelegate
    public func didDiscoverServices(peripheral:P, error:NSError?) {
        if let error = error {
            self.servicesDiscoveredPromise.failure(error)
        } else {
            peripheral.didDiscoverServices()
            self.servicesDiscoveredPromise.success(peripheral)
        }
    }
    
    public func didReadRSSI(RSSI:NSNumber, error:NSError?) {
        if let error = error {
            self.readRSSIPromise.failure(error)
        } else {
            self.readRSSIPromise.success(RSSI.integerValue)
        }
    }

    
    //Helper for Central Manager delegates
    public func didDisconnectPeripheral(peripheral:P) {
        if (self.forcedDisconnect) {
            self.forcedDisconnect = false
            self.connectionPromise?.success((peripheral, ConnectionEvent.ForcedDisconnected))
        } else {
            switch(self.currentError) {
            case .None:
                self.callDidDisconnect(peripheral)
            case .Timeout:
                self.callDidTimeout(peripheral)
            }
        }
    }
    
    public func didConnectPeripheral(peripheral:P) {
        self.connectionPromise?.success((peripheral, ConnectionEvent.Connected))
    }
    
    public func didFailToConnectPeripheral(peripheral:P, error:NSError?) {
        if let error = error {
            NSLog("connection failed '\(error.localizedDescription)'")
            self.connectionPromise?.failure(error)
        } else {
            self.connectionPromise?.success((peripheral, ConnectionEvent.Failed))
        }
    }
    
    internal func callDidTimeout(peripheral:P) {
        
        guard let _ = self.timeoutRetries else {
            self.connectionPromise?.success((peripheral, ConnectionEvent.Timeout))
            return
        }
        if self.timeoutRetries > 0 {
            self.connectionPromise?.success((peripheral, ConnectionEvent.Timeout))
            self.timeoutRetries!--
        } else {
            self.connectionPromise?.success((peripheral, ConnectionEvent.GiveUp))
        }
    }
    
    internal func callDidDisconnect(peripheral:P) {
        
        guard let _ = self.disconnectRetries else {
            self.connectionPromise?.success((peripheral, ConnectionEvent.Disconnected))
            return
        }
        if self.disconnectRetries > 0 {
            self.disconnectRetries!--
            self.connectionPromise?.success((peripheral, ConnectionEvent.Disconnected))
        } else {
            self.connectionPromise?.success((peripheral, ConnectionEvent.GiveUp))
        }
    }

}
