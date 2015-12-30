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

import Foundation
import CoreBluetooth


//MARK: QUEUE
public struct CentralQueue {
  
  public static let queue = dispatch_queue_create("org.Catrobat.Bluetooth.main", DISPATCH_QUEUE_SERIAL)
  
  public static func sync(request:()->()) {
    dispatch_sync(self.queue, request)
  }
  
  public static func async(request:()->()) {
    dispatch_async(self.queue, request)
  }
  
  public static func delay(delay:Double, request:()->()) {
    let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(Float(delay)*Float(NSEC_PER_SEC)))
    dispatch_after(popTime, self.queue, request)
  }
  
}

//MARK: Protocols
public protocol CMWrapper {
    
    typealias PeripheralWrap
    
    var isOn        : Bool                  {get}
    var isOff       : Bool                  {get}
    var peripherals : [PeripheralWrap]      {get}
    var state       : CBCentralManagerState {get}
    
    func scanForPeripheralsWithServices(uuids:[CBUUID]?)
    func retrievePeripheralsWithIdentifiers(uuids:[NSUUID]) -> [CBPeripheral]
    func retrieveConnectedPeripheralsWithServices(uuids:[CBUUID])
    func stopScan()
}



public protocol PeripheralWrapper {
    
    typealias ServiceWrap
    //
    var name            : String                {get}
    var state           : CBPeripheralState     {get}
    var services        : [ServiceWrap]         {get}
    
    func connect()
    func reconnect()
    func disconnect()
    func cancel()
    func discoverServices(services:[CBUUID]?)
    func didDiscoverServices()
}

public protocol ServiceWrapper {
    
    var uuid : CBUUID               {get}
    var name : String               {get}
    var state: CBPeripheralState    {get}
    
    func discoverAllCharacteristics() -> Future<Self>
    func discoverCharacteristics(characteristics:[CBUUID]?)
    func didDiscoverCharacteristics(error:NSError?)
    func initCharacteristics()
}

public protocol CharacteristicWrapper {
    
    var uuid                    : CBUUID                    {get}
    var name                    : String                    {get}
    var isNotifying             : Bool                      {get}
    var stringValues            : [String]                  {get}
    var afterDiscoveredPromise  : StreamPromise<Self>?      {get}
    
    func stringValue(data:NSData?) -> [String:String]?
    func dataFromStringValue(stringValue:[String:String]) -> NSData?
    
    func setNotifyValue(state:Bool)
    func propertyEnabled(property:CBCharacteristicProperties) -> Bool
    func readValueForCharacteristic()
    func writeValue(value:NSData)
    
}

//MARK: enums
enum PeripheralConnectionError {
    case None
    case Timeout
}

public enum ConnectionEvent {
    case Connected, Disconnected, Timeout , ForcedDisconnected, Failed, GiveUp
}


public enum CharacteristicError : Int {
    case ReadTimeout        = 1
    case WriteTimeout       = 2
    case NotSerializable    = 3
    case ReadNotSupported   = 4
    case WriteNotSupported  = 5
}

public enum PeripheralError : Int {
    case DiscoveryTimeout   = 20
    case Disconnected       = 21
    case NoServices         = 22
}

public enum PeripheralManagerError : Int {
    case IsAdvertising      = 40
    case IsNotAdvertising   = 41
    case AddServiceFailed   = 42
}

public enum CentralError : Int {
    case IsScanning         = 50
}

public struct BluetoothError {
    public static let domain = "BluetoothManager"
    
    public static let characteristicReadTimeout = NSError(domain:domain, code:CharacteristicError.ReadTimeout.rawValue, userInfo:[NSLocalizedDescriptionKey:"Characteristic read timeout"])
    public static let characteristicWriteTimeout = NSError(domain:domain, code:CharacteristicError.WriteTimeout.rawValue, userInfo:[NSLocalizedDescriptionKey:"Characteristic write timeout"])
    public static let characteristicNotSerilaizable = NSError(domain:domain, code:CharacteristicError.NotSerializable.rawValue, userInfo:[NSLocalizedDescriptionKey:"Characteristic not serializable"])
    public static let characteristicReadNotSupported = NSError(domain:domain, code:CharacteristicError.ReadNotSupported.rawValue, userInfo:[NSLocalizedDescriptionKey:"Characteristic read not supported"])
    public static let characteristicWriteNotSupported = NSError(domain:domain, code:CharacteristicError.WriteNotSupported.rawValue, userInfo:[NSLocalizedDescriptionKey:"Characteristic write not supported"])
    
    public static let peripheralDisconnected = NSError(domain:domain, code:PeripheralError.Disconnected.rawValue, userInfo:[NSLocalizedDescriptionKey:"Peripheral disconnected timeout"])
    public static let peripheralDiscoveryTimeout = NSError(domain:domain, code:PeripheralError.DiscoveryTimeout.rawValue, userInfo:[NSLocalizedDescriptionKey:"Peripheral discovery Timeout"])
    public static let peripheralNoServices = NSError(domain:domain, code:PeripheralError.NoServices.rawValue, userInfo:[NSLocalizedDescriptionKey:"Peripheral services not found"])
    
    public static let peripheralManagerIsAdvertising = NSError(domain:domain, code:PeripheralManagerError.IsAdvertising.rawValue, userInfo:[NSLocalizedDescriptionKey:"Peripheral Manager is Advertising"])
    public static let peripheralManagerIsNotAdvertising = NSError(domain:domain, code:PeripheralManagerError.IsNotAdvertising.rawValue, userInfo:[NSLocalizedDescriptionKey:"Peripheral Manager is not Advertising"])
    public static let peripheralManagerAddServiceFailed = NSError(domain:domain, code:PeripheralManagerError.AddServiceFailed.rawValue, userInfo:[NSLocalizedDescriptionKey:"Add service failed because service peripheral is advertising"])
    
    public static let centralIsScanning = NSError(domain:domain, code:CentralError.IsScanning.rawValue, userInfo:[NSLocalizedDescriptionKey:"Central is scanning"])
    
}

