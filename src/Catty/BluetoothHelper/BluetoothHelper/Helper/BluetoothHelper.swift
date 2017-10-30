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


//MARK: QUEUE
public struct CentralQueue {
  
  public static let queue = DispatchQueue(label: "org.Catrobat.Bluetooth.main", attributes: [])
  
  public static func sync(_ request:()->()) {
    self.queue.sync(execute: request)
  }
  
  public static func async(_ request:@escaping ()->()) {
    self.queue.async(execute: request)
  }
  
  public static func delay(_ delay:Double, request:@escaping ()->()) {
    let popTime = DispatchTime.now() + delay
    self.queue.asyncAfter(deadline: popTime, execute: request)
  }
  
}

//MARK: Protocols
public protocol CMWrapper {
    
    associatedtype PeripheralWrap
    
    var isOn        : Bool                  {get}
    var isOff       : Bool                  {get}
    var peripherals : [PeripheralWrap]      {get}
    var state       : ManagerState {get}
    
    func scanForPeripheralsWithServices(_ uuids:[CBUUID]?)
    func retrievePeripheralsWithIdentifiers(_ uuids:[UUID]) -> [CBPeripheral]
    func retrieveConnectedPeripheralsWithServices(_ uuids:[CBUUID])
    func stopScan()
}



public protocol PeripheralWrapper {
    
    associatedtype ServiceWrap
    //
    var name            : String                {get}
    var state           : CBPeripheralState     {get}
    var services        : [ServiceWrap]         {get}
    
    func connect()
    func reconnect()
    func disconnect()
    func cancel()
    func discoverServices(_ services:[CBUUID]?)
    func didDiscoverServices()
}

public protocol ServiceWrapper {
    
    var uuid : CBUUID               {get}
    var name : String               {get}
    var state: CBPeripheralState    {get}
    
    func discoverAllCharacteristics() -> Future<Self>
    func discoverCharacteristics(_ characteristics:[CBUUID]?)
    func didDiscoverCharacteristics(_ error:NSError?)
    func initCharacteristics()
}

public protocol CharacteristicWrapper {
    
    var uuid                    : CBUUID                    {get}
    var name                    : String                    {get}
    var isNotifying             : Bool                      {get}
    var stringValues            : [String]                  {get}
    var afterDiscoveredPromise  : StreamPromise<Self>?      {get}
    
    func stringValue(_ data:Data?) -> [String:String]?
    func dataFromStringValue(_ stringValue:[String:String]) -> Data?
    
    func setNotifyValue(_ state:Bool)
    func propertyEnabled(_ property:CBCharacteristicProperties) -> Bool
    func readValueForCharacteristic()
    func writeValue(_ value:Data)
    
}

//MARK: enums
enum PeripheralConnectionError {
    case none
    case timeout
}

public enum ConnectionEvent {
    case connected, disconnected, timeout , forcedDisconnected, failed, giveUp
}


public enum CharacteristicError : Int {
    case readTimeout        = 1
    case writeTimeout       = 2
    case notSerializable    = 3
    case readNotSupported   = 4
    case writeNotSupported  = 5
}

public enum PeripheralError : Int {
    case discoveryTimeout   = 20
    case disconnected       = 21
    case noServices         = 22
}

public enum PeripheralManagerError : Int {
    case isAdvertising      = 40
    case isNotAdvertising   = 41
    case addServiceFailed   = 42
}

public enum CentralError : Int {
    case isScanning         = 50
}

@objc public enum ManagerState : Int {
    case unknown
    case resetting
    case unsupported
    case unauthorized
    case poweredOff
    case poweredOn
}

public struct BluetoothError {
    public static let domain = "BluetoothManager"
    
    public static let characteristicReadTimeout = NSError(domain:domain, code:CharacteristicError.readTimeout.rawValue, userInfo:[NSLocalizedDescriptionKey:"Characteristic read timeout"])
    public static let characteristicWriteTimeout = NSError(domain:domain, code:CharacteristicError.writeTimeout.rawValue, userInfo:[NSLocalizedDescriptionKey:"Characteristic write timeout"])
    public static let characteristicNotSerilaizable = NSError(domain:domain, code:CharacteristicError.notSerializable.rawValue, userInfo:[NSLocalizedDescriptionKey:"Characteristic not serializable"])
    public static let characteristicReadNotSupported = NSError(domain:domain, code:CharacteristicError.readNotSupported.rawValue, userInfo:[NSLocalizedDescriptionKey:"Characteristic read not supported"])
    public static let characteristicWriteNotSupported = NSError(domain:domain, code:CharacteristicError.writeNotSupported.rawValue, userInfo:[NSLocalizedDescriptionKey:"Characteristic write not supported"])
    
    public static let peripheralDisconnected = NSError(domain:domain, code:PeripheralError.disconnected.rawValue, userInfo:[NSLocalizedDescriptionKey:"Peripheral disconnected timeout"])
    public static let peripheralDiscoveryTimeout = NSError(domain:domain, code:PeripheralError.discoveryTimeout.rawValue, userInfo:[NSLocalizedDescriptionKey:"Peripheral discovery Timeout"])
    public static let peripheralNoServices = NSError(domain:domain, code:PeripheralError.noServices.rawValue, userInfo:[NSLocalizedDescriptionKey:"Peripheral services not found"])
    
    public static let peripheralManagerIsAdvertising = NSError(domain:domain, code:PeripheralManagerError.isAdvertising.rawValue, userInfo:[NSLocalizedDescriptionKey:"Peripheral Manager is Advertising"])
    public static let peripheralManagerIsNotAdvertising = NSError(domain:domain, code:PeripheralManagerError.isNotAdvertising.rawValue, userInfo:[NSLocalizedDescriptionKey:"Peripheral Manager is not Advertising"])
    public static let peripheralManagerAddServiceFailed = NSError(domain:domain, code:PeripheralManagerError.addServiceFailed.rawValue, userInfo:[NSLocalizedDescriptionKey:"Add service failed because service peripheral is advertising"])
    
    public static let centralIsScanning = NSError(domain:domain, code:CentralError.isScanning.rawValue, userInfo:[NSLocalizedDescriptionKey:"Central is scanning"])
    
}

