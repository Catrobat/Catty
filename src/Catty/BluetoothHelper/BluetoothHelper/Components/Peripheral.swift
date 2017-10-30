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
import CoreBluetooth
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
private func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
private func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


//MARK:Peripheral

@objc open class Peripheral : NSObject, CBPeripheralDelegate, PeripheralWrapper {
    
    open var helper = PeripheralHelper<Peripheral>()
    
    open var ownServices          = [CBUUID:Service]()
    open var ownCharacteristics   = [CBCharacteristic:Characteristic]()
    
    open let cbPeripheral   : CBPeripheral
    
    open let advertisements   : [String: String]
    open let rssi             : Int
    
    // MARK: Init
    public init(cbPeripheral:CBPeripheral, advertisements:[String:String], rssi:Int) {
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
    open func reconnect() {
        self.helper.connectPeripheral(self)
    }
    
    open func connect(_ capacity:Int? = nil, timeoutRetries:Int? = nil, disconnectRetries:Int? = nil, connectionTimeout:Double = 10.0) -> FutureStream<(Peripheral, ConnectionEvent)> {
        return self.helper.connect(self, capacity:capacity, timeoutRetries:timeoutRetries, disconnectRetries:disconnectRetries, connectionTimeout:connectionTimeout)
    }
    
    //MARK: Discover Services
    @discardableResult
    open func discoverAllServices() -> Future<Peripheral> {
        return self.helper.discoverServices(self, services: nil)
    }
    
    open func discoverServices(_ services:[CBUUID]?) -> Future<Peripheral> {
        return self.helper.discoverServices(self, services:services)
    }
    
    open func discoverAllPeripheralServices() -> Future<Peripheral> {
        return self.helper.discoverPeripheralServices(self, services: nil)
    }
    
    open func discoverPeripheralServices(_ services:[CBUUID]?) -> Future<Peripheral> {
        return self.helper.discoverPeripheralServices(self, services:services)
    }
    
    //MARK: CBPeripheralDelegate
    open func peripheralDidUpdateName(_:CBPeripheral) {

    }
    
    open func peripheral(_:CBPeripheral, didModifyServices invalidatedServices:[CBService]) {
    }
    
    open func peripheral(_:CBPeripheral, didReadRSSI RSSI:NSNumber, error:Error?) {
        self.helper.didReadRSSI(RSSI, error:error as NSError?)
    }
    
    // service delegates
    open func peripheral(_ peripheral:CBPeripheral, didDiscoverServices error:Error?) {
        self.removeAll()
        self.helper.didDiscoverServices(self, error:error as NSError?)
    }
    
    open func peripheral(_ peri:CBPeripheral, didDiscoverIncludedServicesFor service:CBService, error:Error?) {

    }
    
    // characteristic delegates
    open func peripheral(_ peri:CBPeripheral, didDiscoverCharacteristicsFor service:CBService, error:Error?) {
       self.discoveredCharacteristics(peri, service: service, error: error as NSError?)
    }
    
    
    open func discoveredCharacteristics(_ peri:CBPeripheral, service:CBService,error:NSError?){
        guard let ownService = self.ownServices[service.uuid], let ownCharacteristics = service.characteristics else {
            return
        }
        ownService.didDiscoverCharacteristics(error)
        if error == nil {
            for characteristic : AnyObject in ownCharacteristics {
                if let ownCharacteristic = characteristic as? CBCharacteristic {
                    self.ownCharacteristics[ownCharacteristic] = ownService.ownCharacteristics[characteristic.uuid]
                }
            }
        }

    }
    
    open func peripheral(_ peripheral:CBPeripheral, didUpdateNotificationStateFor characteristic:CBCharacteristic, error:Error?) {
        guard let ownCharacteristic = self.ownCharacteristics[characteristic] else {
            NSLog("Error")
            return
        }
        NSLog("uuid=\(ownCharacteristic.uuid.uuidString), name=\(ownCharacteristic.name)")
        ownCharacteristic.didUpdateNotificationState(error as NSError?)
    }
    
    open func peripheral(_ peripheral:CBPeripheral, didUpdateValueFor characteristic:CBCharacteristic, error:Error?) {
        guard let ownCharacteristic = self.ownCharacteristics[characteristic] else {
            NSLog("Error")
            return
        }
        NSLog("uuid=\(ownCharacteristic.uuid.uuidString), name=\(ownCharacteristic.name)")
        ownCharacteristic.didUpdate(error as NSError?)
    }
    
    
    
    open func peripheral(_:CBPeripheral, didWriteValueFor characteristic:CBCharacteristic, error: Error?) {
        guard let ownCharacteristic = self.ownCharacteristics[characteristic] else {
            NSLog("Error")
            return
        }
        NSLog("uuid=\(ownCharacteristic.uuid.uuidString), name=\(ownCharacteristic.name)")
        ownCharacteristic.didWrite(error as NSError?)
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
    
    internal func didFailToConnectPeripheral(_ error:NSError?) {
        self.helper.didFailToConnectPeripheral(self, error:error)
    }
    // MARK: Wrap
    open var name : String {
        if let name = self.cbPeripheral.name {
            return name
        } else {
            return "Unknown"
        }
    }
    
    @objc open var state : CBPeripheralState {
        return self.cbPeripheral.state
    }
    
    open var services : [Service] {
        let values:[Service] = [Service](self.ownServices.values)
        return values
    }
    
    open func connect() {
        CentralManager.sharedInstance.connectPeripheral(self)
    }
    
    open func cancel() {
        CentralManager.sharedInstance.cancelPeripheralConnection(self)
    }
    
    open func disconnect() {
        CentralManager.sharedInstance.ownPeripherals.removeValue(forKey: self.cbPeripheral)
        self.helper.disconnect(self)
    }
    
    open func discoverServices(_ services:[CBUUID]?) {
        self.cbPeripheral.discoverServices(services)
    }
    
    open func didDiscoverServices() {
        guard let ownServices = self.cbPeripheral.services else {
            return
        }
        for ownService : AnyObject in ownServices {
            guard let ownService = ownService as? CBService else {
                return
            }
            let bcService = Service(ownService:ownService, peripheral:self)
            self.ownServices[bcService.uuid] = bcService
            NSLog("uuid=\(bcService.uuid.uuidString), name=\(bcService.name)")
        }
    }

    
    open var id : UUID {
        return self.cbPeripheral.identifier
    }
    
    
    open func service(_ uuid:CBUUID) -> Service? {
        return self.ownServices[uuid]
    }

    
}

// MARK: Peripheral Helper
open class PeripheralHelper<P> where P:PeripheralWrapper,
                          P.ServiceWrap:ServiceWrapper {
    
    private var connectionPromise : StreamPromise<(P, ConnectionEvent)>?
    private var servicesDiscoveredPromise   = Promise<P>()
    private var readRSSIPromise             = Promise<Int>()
    
    internal var timeoutRetries         : Int?
    internal var disconnectRetries      : Int?
    internal var connectionTimeout      = 5.0
    
    private var connectionSequence      = 0
    private var currentError            = PeripheralConnectionError.none
    private var forcedDisconnect        = false
    
    
    
    public init() {
    }
    
    //MARK: Connection
    open func connectPeripheral(_ peripheral:P) {
        if peripheral.state == .disconnected {
            NSLog("reconnect peripheral \(peripheral.name)")
            peripheral.connect()
            self.forcedDisconnect = false
            self.connectionSequence += 1
            self.timeoutConnection(peripheral, sequence:self.connectionSequence)
        }
    }
    
    open func connect(_ peripheral:P, capacity:Int? = nil, timeoutRetries:Int? = nil, disconnectRetries:Int? = nil, connectionTimeout:Double = 5.0) -> FutureStream<(P, ConnectionEvent)> {
        self.connectionPromise = StreamPromise<(P, ConnectionEvent)>(capacity:capacity)
        self.timeoutRetries = timeoutRetries
        self.disconnectRetries = disconnectRetries
        self.connectionTimeout = connectionTimeout
        NSLog("connect peripheral \(peripheral.name)")
        self.connectPeripheral(peripheral)
        return self.connectionPromise!.future
    }
    
    open func disconnect(_ peripheral:P) {
        self.forcedDisconnect = true
        if peripheral.state == .connected {
            NSLog("disconnect peripheral \(peripheral.name)")
            peripheral.cancel()
        } else {
            self.didDisconnectPeripheral(peripheral)
        }
    }
    
    private func timeoutConnection(_ peripheral:P, sequence:Int) {
        CentralQueue.delay(self.connectionTimeout) {
            if peripheral.state != .connected && sequence == self.connectionSequence && !self.forcedDisconnect {
                self.currentError = .timeout
                peripheral.cancel()
            } else {
            }
        }
    }
    
    //MARK: discover Service
    open func discoverServices(_ peripheral:P, services:[CBUUID]?) -> Future<P> {
        NSLog("peripheral: \(peripheral.name)")
        CentralQueue.sync {
            self.servicesDiscoveredPromise = Promise<P>()
            if peripheral.state == .connected {
                peripheral.discoverServices(services)
            } else {
                self.servicesDiscoveredPromise.failure(BluetoothError.peripheralDisconnected)
            }
        }
        return self.servicesDiscoveredPromise.future
    }
    
    
    open func discoverPeripheralServices(_ peripheral:P, services:[CBUUID]?) -> Future<P> {
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
    internal func discoverService(_ peripheral:P, head:P.ServiceWrap, tail:[P.ServiceWrap], promise:Promise<P>) {
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
    open func readRSSI() -> Future<Int> {
        CentralQueue.sync {
            self.readRSSIPromise = Promise<Int>()
        }
        return self.readRSSIPromise.future
    }
    
    //MARK: CBPeripheralDelegate
    open func didDiscoverServices(_ peripheral:P, error:NSError?) {
        if let error = error {
            self.servicesDiscoveredPromise.failure(error)
        } else {
            peripheral.didDiscoverServices()
            self.servicesDiscoveredPromise.success(peripheral)
        }
    }
    
    open func didReadRSSI(_ RSSI:NSNumber, error:NSError?) {
        if let error = error {
            self.readRSSIPromise.failure(error)
        } else {
            self.readRSSIPromise.success(RSSI.intValue)
        }
    }
    
    //Helper for Central Manager delegates
    open func didDisconnectPeripheral(_ peripheral:P) {
        if (self.forcedDisconnect) {
            self.forcedDisconnect = false
            self.connectionPromise?.success((peripheral, ConnectionEvent.forcedDisconnected))
        } else {
            switch(self.currentError) {
            case .none:
                self.callDidDisconnect(peripheral)
            case .timeout:
                self.callDidTimeout(peripheral)
            }
        }
    }
    
    open func didConnectPeripheral(_ peripheral:P) {
        self.connectionPromise?.success((peripheral, ConnectionEvent.connected))
    }
    
    open func didFailToConnectPeripheral(_ peripheral:P, error:NSError?) {
        if let error = error {
            NSLog("connection failed '\(error.localizedDescription)'")
            self.connectionPromise?.failure(error)
        } else {
            self.connectionPromise?.success((peripheral, ConnectionEvent.failed))
        }
    }
    
    internal func callDidTimeout(_ peripheral:P) {
        
        guard let _ = self.timeoutRetries else {
            self.connectionPromise?.success((peripheral, ConnectionEvent.timeout))
            return
        }
        if self.timeoutRetries > 0 {
            self.connectionPromise?.success((peripheral, ConnectionEvent.timeout))
            self.timeoutRetries! -= 1
        } else {
            self.connectionPromise?.success((peripheral, ConnectionEvent.giveUp))
        }
    }
    
    internal func callDidDisconnect(_ peripheral:P) {
        
        guard let _ = self.disconnectRetries else {
            self.connectionPromise?.success((peripheral, ConnectionEvent.disconnected))
            return
        }
        if self.disconnectRetries > 0 {
            self.disconnectRetries! -= 1
            self.connectionPromise?.success((peripheral, ConnectionEvent.disconnected))
        } else {
            self.connectionPromise?.success((peripheral, ConnectionEvent.giveUp))
        }
    }

}
