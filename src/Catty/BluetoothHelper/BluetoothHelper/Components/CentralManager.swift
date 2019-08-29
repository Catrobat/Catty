/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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

import CoreBluetooth
import UIKit

// MARK: Central Manager
@objc open class CentralManager: NSObject, CBCentralManagerDelegate, CMWrapper {

    private static var instance: CentralManager!

    internal let helper = CentralManagerHelper<CentralManager>()

    private let cbCentralManager: CBCentralManager

    internal var ownPeripherals   = [CBPeripheral: Peripheral]()

    @objc open class var sharedInstance: CentralManager {
        self.instance = self.instance ?? CentralManager()
        return self.instance
    }

    @objc open class func sharedInstance(_ options: [String: AnyObject]) -> CentralManager {
        self.instance = self.instance ?? CentralManager(options: options)
        return self.instance
    }

    @objc open var isScanning: Bool {
        return self.helper.isScanning
    }

    // MARK: init

    override private init() {
        self.cbCentralManager = CBCentralManager(delegate: nil, queue: CentralQueue.queue)
        super.init()

        self.cbCentralManager.delegate = self
    }

    private init(options: [String: AnyObject]?) {
        self.cbCentralManager = CBCentralManager(delegate: nil, queue: CentralQueue.queue, options: options)
        super.init()

        self.cbCentralManager.delegate = self
    }

    // MARK: SCAN
    open func getKnownPeripheralsWithIdentifiers(_ uuids: [UUID]) -> [CBPeripheral] {
        return self.helper.retrieveKnownPeripheralsWithIdentifiers(self, uuids: uuids)
    }

    open func getConnectedPeripheralsWithServices(_ uuids: [CBUUID])-> FutureStream<[Peripheral]> {
        return self.helper.retrieveConnectedPeripheralsWithServices(self, uuids: uuids)
    }

    open func startScan() -> FutureStream<Peripheral> {
        return self.helper.startScanningForServiceUUIDs(self, uuids: nil)
    }

    open func startScanningForServiceUUIDs(_ uuids: [CBUUID]!, capacity: Int? = nil) -> FutureStream<Peripheral> {
        return self.helper.startScanningForServiceUUIDs(self, uuids: uuids, capacity: capacity)
    }

    open func stopScanning() {
        self.helper.stopScanning(self)
    }

    open func removeAllPeripherals() {
        self.ownPeripherals.removeAll(keepingCapacity: false)
    }

    // MARK: Connection
    open func disconnectAllPeripherals() {
        self.helper.disconnectAllPeripherals(self)
    }

    open func connectPeripheral(_ peripheral: Peripheral, options: [String: AnyObject]?=nil) {
        self.cbCentralManager.connect(peripheral.cbPeripheral, options: options)
    }

    internal func cancelPeripheralConnection(_ peripheral: Peripheral) {
        self.cbCentralManager.cancelPeripheralConnection(peripheral.cbPeripheral)
    }

    // MARK: Start/Stop
    open func start() -> Future<Void> {
        return self.helper.start(self)
    }

    open func stop() -> Future<Void> {
        return self.helper.stop(self)
    }

    // MARK: CBCentralManagerDelegate
    open func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        NSLog("peripheral: \(String(describing: peripheral.name))")
        guard let ownPeripheral = self.ownPeripherals[peripheral] else {
            NSLog("error")
            return
        }
        ownPeripheral.didConnectPeripheral()
    }

    open func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        NSLog("peripheral: \(String(describing: peripheral.name))")
        guard let ownPeripheral = self.self.ownPeripherals[peripheral] else {
            NSLog("error")
            return
        }
        ownPeripheral.didDisconnectPeripheral()
    }

    open func centralManager(_:CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        if self.ownPeripherals[peripheral] == nil {

            let ownPeripheral = Peripheral(cbPeripheral: peripheral, advertisements: self.unpackAdvertisements(advertisementData as [String : AnyObject]), rssi: RSSI.intValue)
            NSLog("peripheral: \(ownPeripheral.name)")
            self.ownPeripherals[peripheral] = ownPeripheral
            self.helper.didDiscoverPeripheral(ownPeripheral)
        }
    }

    open func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        guard let bcPeripheral = self.ownPeripherals[peripheral] else {
            NSLog("error")
            return
        }
        bcPeripheral.didFailToConnectPeripheral(error as NSError?)
    }

    open func centralManager(_:CBCentralManager!, didRetrieveConnectedPeripherals peripherals: [AnyObject]!) {
        let peripherals = peripherals.compactMap { cbPeripheral -> Peripheral? in
            guard let peripheral = cbPeripheral as? CBPeripheral else { return nil }
            return Peripheral(cbPeripheral: peripheral)
        }
        self.helper.receivedConnectedPeripheral(peripherals)
    }

    open func centralManager(_:CBCentralManager!, didRetrievePeripherals peripherals: [AnyObject]!) {
        let peripherals = peripherals.compactMap { cbPeripheral -> Peripheral? in
            guard let peripheral = cbPeripheral as? CBPeripheral else { return nil }
            return Peripheral(cbPeripheral: peripheral)
        }
        self.helper.receivedKnownPeripheral(peripherals)

    }

    open func centralManagerDidUpdateState(_ central: CBCentralManager) {
        self.helper.didUpdateState(self)
    }

    internal func unpackAdvertisements(_ advertDictionary: [String: AnyObject]) -> [String: String] {
        var advertisements = [String: String]()
        func addKey(_ key: String, andValue value: AnyObject) {
            if value is NSString {
                advertisements[key] = (value as? String)
            } else {
                advertisements[key] = value.stringValue
            }
        }
        for key in advertDictionary.keys {
            if let value: AnyObject = advertDictionary[key] {
                if let value = value as? NSArray {
                    for valueItem in value {
                        addKey(key, andValue: valueItem as AnyObject)
                    }
                } else {
                    addKey(key, andValue: value)
                }
            }
        }
        return advertisements
    }

    // MARK: Wrap
    open var isOn: Bool {
        switch self.cbCentralManager.state {
        case .poweredOn:
            return true
        default:
            return false
        }
    }

    // MARK: Wrap
    open var isOff: Bool {
        switch self.cbCentralManager.state {
        case .poweredOff:
            return true
        default:
            return false
        }
    }

    open var peripherals: [Peripheral] {

        let values: [Peripheral] = [Peripheral](self.ownPeripherals.values)
        return values
    }

    @objc open var state: ManagerState {
        switch self.cbCentralManager.state {
        case .unknown:
            return .unknown
        case .resetting:
            return .resetting
        case .unsupported:
            return .unsupported
        case .unauthorized:
            return .unauthorized
        case .poweredOff:
            return .poweredOff
        case .poweredOn:
            return .poweredOn
        @unknown default:
            print("ERROR: case not handled by switch statement")
            return .unknown
        }
    }

    open func scanForPeripheralsWithServices(_ uuids: [CBUUID]?) {
        self.cbCentralManager.scanForPeripherals(withServices: uuids, options: nil)
    }

    open func retrievePeripheralsWithIdentifiers(_ uuids: [UUID]) -> [CBPeripheral] {
        return self.cbCentralManager.retrievePeripherals(withIdentifiers: uuids)
    }
    open func retrieveConnectedPeripheralsWithServices(_ uuids: [CBUUID]) {
        self.cbCentralManager.retrieveConnectedPeripherals(withServices: uuids)
    }

    open func stopScan() {
        self.cbCentralManager.stopScan()
    }

}

// MARK: Helper
open class CentralManagerHelper<CM> where CM: CMWrapper,
CM.PeripheralWrap: PeripheralWrapper {

    private var afterStartingPromise = Promise<Void>()
    private var afterStoppingPromise = Promise<Void>()
    internal var afterPeripheralDiscoveredPromise = StreamPromise<CM.PeripheralWrap>()
    internal var afterKnownPeripheralDiscoveredPromise = StreamPromise<[CM.PeripheralWrap]>()
    internal var afterConnectedPeripheralDiscoveredPromise = StreamPromise<[CM.PeripheralWrap]>()

    private var _isScanning = false

    open var isScanning: Bool {
        return self._isScanning
    }

    public init() {
    }

    // MARK: Scan

    open func startScanningForServiceUUIDs(_ central: CM, uuids: [CBUUID]!, capacity: Int? = nil) -> FutureStream<CM.PeripheralWrap> {
        if !self._isScanning {
            NSLog("UUIDs \(String(describing: uuids))")
            if let capacity = capacity {
                self.afterPeripheralDiscoveredPromise = StreamPromise<CM.PeripheralWrap>(capacity: capacity)
            } else {
                self.afterPeripheralDiscoveredPromise = StreamPromise<CM.PeripheralWrap>()
            }
            self._isScanning = true
            central.scanForPeripheralsWithServices(uuids)
        }
        return self.afterPeripheralDiscoveredPromise.future
    }

    open func retrieveKnownPeripheralsWithIdentifiers(_ central: CM, uuids: [UUID]) -> [CBPeripheral] {
        return central.retrievePeripheralsWithIdentifiers(uuids)
    }

    open func retrieveConnectedPeripheralsWithServices(_ central: CM, uuids: [CBUUID])-> FutureStream<[CM.PeripheralWrap]> {
        central.retrieveConnectedPeripheralsWithServices(uuids)
        self.afterConnectedPeripheralDiscoveredPromise = StreamPromise<[CM.PeripheralWrap]>()
        return self.afterConnectedPeripheralDiscoveredPromise.future
    }

    open func stopScanning(_ central: CM) {
        if self._isScanning {
            self._isScanning = false
            central.stopScan()
        }
    }

    // MARK: Connection
    open func disconnectAllPeripherals(_ central: CentralManager) {
        for peripheral in central.peripherals {
            peripheral.disconnect()
        }
    }

    // MARK: Power
    open func start(_ central: CM) -> Future<Void> {
        CentralQueue.sync {
            self.afterStartingPromise = Promise<Void>()
            if central.isOn {
                self.afterStartingPromise.success(())
            }
        }
        return self.afterStartingPromise.future
    }

    open func stop(_ central: CM) -> Future<Void> {
        CentralQueue.sync {
            self.afterStoppingPromise = Promise<Void>()
            if central.isOff {
                self.afterStoppingPromise.success(())
            }
        }
        return self.afterStoppingPromise.future
    }

    // MARK: State
    open func didUpdateState(_ central: CM) {
        switch central.state {
        case .unauthorized:
            NSLog("Unauthorized")
        case .unknown:
            NSLog("Unknown")
        case .unsupported:
            NSLog("Unsupported")
        case .resetting:
            NSLog("Resetting")
        case .poweredOff:
            NSLog("PoweredOff")
            if !self.afterStoppingPromise.completed {
                self.afterStoppingPromise.success(())
            }
        case .poweredOn:
            NSLog("PoweredOn")
            if !self.afterStartingPromise.completed {
                self.afterStartingPromise.success(())
            }
        }
    }

    // MARK: did discover Peripheral
    open func didDiscoverPeripheral(_ peripheral: CM.PeripheralWrap) {
        self.afterPeripheralDiscoveredPromise.success(peripheral)
    }

    open func receivedKnownPeripheral(_ peripherals: [CM.PeripheralWrap]) {
        self.afterKnownPeripheralDiscoveredPromise.success(peripherals)
    }

    open func receivedConnectedPeripheral(_ peripherals: [CM.PeripheralWrap]) {
        self.afterConnectedPeripheralDiscoveredPromise.success(peripherals)
    }

}
