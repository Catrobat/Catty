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

//MARK: Characteristic

public final class Characteristic : CharacteristicWrapper {
    
    internal var implementation = CharacteristicImplementation<Characteristic>()
    
    public let cbCharacteristic : CBCharacteristic
    internal let _service         : Service
    internal let profile          : CharacteristicProfile
    
    //MARK: init
    internal init(cbCharacteristic:CBCharacteristic, service:Service) {
        self.cbCharacteristic = cbCharacteristic
        self._service = service
        guard let serviceProfile = ProfileManager.sharedInstance.serviceProfiles[service.uuid] else {
            self.profile = CharacteristicProfile(uuid:service.uuid.UUIDString)
            return
        }
        guard let characteristicProfile = serviceProfile.characteristicProfiles[cbCharacteristic.UUID] else {
            self.profile = CharacteristicProfile(uuid:service.uuid.UUIDString)
            return
        }
        self.profile = characteristicProfile
    }
    
        //MARK: getter

    public var service : Service {
        return self._service
    }
    
    public var dataValue : NSData? {
        return self.cbCharacteristic.value
    }
    
    public var stringValue :[String:String]? {
        return self.implementation.stringValue(self, data:self.dataValue)
    }
    
    public var properties : CBCharacteristicProperties {
        return self.cbCharacteristic.properties
    }
    
    public func value<T:Deserialize>() -> T? {
        return self.implementation.value(self.dataValue)
    }
    
    public func value<T:RawDeserialize where T.RawType:Deserialize>() -> T? {
        return self.implementation.value(self.dataValue)
    }
    
    public func value<T:RawArrayDeserialize where T.RawType:Deserialize>() -> T? {
        return self.implementation.value(self.dataValue)
    }
    
    public func value<T:RawPairDeserialize where T.RawType1:Deserialize, T.RawType2:Deserialize>() -> T? {
        return self.implementation.value(self.dataValue)
    }
    
    public func value<T:RawArrayPairDeserialize where T.RawType1:Deserialize, T.RawType2:Deserialize>() -> T? {
        return self.implementation.value(self.dataValue)
    }
    
    
    
    
    //MARK: Notification
    
    public func startNotifying() -> Future<Characteristic> {
        return self.implementation.startNotifying(self)
    }
    
    public func stopNotifying() -> Future<Characteristic> {
        return self.implementation.stopNotifying(self)
    }
    
    public func recieveNotificationUpdates(capacity:Int? = nil) -> FutureStream<Characteristic> {
        return self.implementation.recieveNotificationUpdates(capacity)
    }
    
    public func stopNotificationUpdates() {
        self.implementation.stopNotificationUpdates()
    }
    
    //MARK: read
    
    public func read(timeout:Double = 10.0) -> Future<Characteristic> {
        return self.implementation.read(self, timeout:timeout)
    }
    
    //MARK: write
    
    public func writeData(value:NSData, timeout:Double = 10.0) -> Future<Characteristic> {
        return self.implementation.writeData(self, value:value, timeout:timeout)
    }
    
    public func writeString(stringValue:[String:String], timeout:Double = 10.0) -> Future<Characteristic> {
        return self.implementation.writeString(self, stringValue:stringValue, timeout:timeout)
    }
    
    public func write<T:Deserialize>(value:T, timeout:Double = 10.0) -> Future<Characteristic> {
        return self.implementation.write(self, value:value, timeout:timeout)
    }
    
    public func write<T:RawDeserialize>(value:T, timeout:Double = 10.0) -> Future<Characteristic> {
        return self.implementation.write(self, value:value, timeout:timeout)
    }
    
    public func write<T:RawArrayDeserialize>(value:T, timeout:Double = 10.0) -> Future<Characteristic> {
        return self.implementation.write(self, value:value, timeout:timeout)
    }
    
    public func write<T:RawPairDeserialize>(value:T, timeout:Double = 10.0) -> Future<Characteristic> {
        return self.implementation.write(self, value:value, timeout:timeout)
    }
    
    public func write<T:RawArrayPairDeserialize>(value:T, timeout:Double = 10.0) -> Future<Characteristic> {
        return self.implementation.write(self, value:value, timeout:timeout)
    }
    
    
    //MARK: helper
    internal func didDiscover() {
        self.implementation.didDiscover(self)
    }
    
    internal func didUpdateNotificationState(error:NSError?) {
        self.implementation.didUpdateNotificationState(self, error:error)
    }
    
    internal func didUpdate(error:NSError?) {
        self.implementation.didUpdate(self, error:error)
    }
    
    internal func didWrite(error:NSError?) {
        self.implementation.didWrite(self, error:error)
    }
    
    //MARK: CharacteristicWrapper
    public var uuid : CBUUID {
        return self.cbCharacteristic.UUID
    }
    
    public var name : String {
        return self.profile.name
    }
    
    public var isNotifying : Bool {
        return self.cbCharacteristic.isNotifying
    }
    
    public var stringValues : [String] {
        return self.profile.stringValues
    }
    
    public var afterDiscoveredPromise  : StreamPromise<Characteristic>? {
        return self.profile.afterDiscoveredPromise
    }
    
    public func stringValue(data:NSData?) -> [String:String]? {
        guard let data = data else {
            return nil
        }
        return self.profile.stringValue(data)
    }
    
    public func dataFromStringValue(stringValue:[String:String]) -> NSData? {
        return self.profile.dataFromStringValue(stringValue)
    }
    
    public func setNotifyValue(state:Bool) {
        self.service.peripheral.cbPeripheral.setNotifyValue(state, forCharacteristic:self.cbCharacteristic)
    }
    
    public func propertyEnabled(property:CBCharacteristicProperties) -> Bool {
        return (self.properties.rawValue & property.rawValue) > 0
    }
    
    public func readValueForCharacteristic() {
        self.service.peripheral.cbPeripheral.readValueForCharacteristic(self.cbCharacteristic)
    }
    
    public func writeValue(value:NSData) {
        if(self.propertyEnabled(.WriteWithoutResponse)){
            self.service.peripheral.cbPeripheral.writeValue(value, forCharacteristic:self.cbCharacteristic, type:.WithoutResponse)
        } else if (self.propertyEnabled(.Write)){
            self.service.peripheral.cbPeripheral.writeValue(value, forCharacteristic:self.cbCharacteristic, type:.WithResponse)
        }
        
    }

}

//MARK: Characteristic Implementation
public final class CharacteristicImplementation<C:CharacteristicWrapper> {
    
    public var notificationUpdatePromise          : StreamPromise<C>?
    private var notificationStateChangedPromise    = Promise<C>()
    private var readPromise                        = Promise<C>()
    private var writePromise                       = Promise<C>()
    
    private var reading = false
    private var writing = false
    
    private var readSequence    = 0
    private var writeSequence   = 0
    private let defaultTimeout  = 10.0
    
    public init() {
    }
    
    //MARK: Values
    public func value<T:Deserialize>(data:NSData?) -> T? {
        guard let data = data else {
            return nil
        }
        return T.deserialize(data)
    }
    
    public func value<T:RawDeserialize where T.RawType:Deserialize>(data:NSData?) -> T? {
        guard let data = data else {
            return nil
        }
        return Deserializer.deserialize(data)
    }
    
    public func value<T:RawArrayDeserialize where T.RawType:Deserialize>(data:NSData?) -> T? {
        guard let data = data else {
            return nil
        }
        return Deserializer.deserialize(data)
    }
    
    public func value<T:RawPairDeserialize where T.RawType1:Deserialize, T.RawType2:Deserialize>(data:NSData?) -> T? {
        guard let data = data else {
            return nil
        }
        return Deserializer.deserialize(data)
    }
    
    public func value<T:RawArrayPairDeserialize where T.RawType1:Deserialize, T.RawType2:Deserialize>(data:NSData?) -> T? {
        guard let data = data else {
            return nil
        }
        return Deserializer.deserialize(data)
    }
    
    //MARK: String values
    public func stringValue(characteristic:C, data:NSData?) -> [String:String]? {
        return characteristic.stringValue(data).map{$0}
    }
    
    public func stringValues(characteristic:C) -> [String] {
        return characteristic.stringValues
    }
    
    //MARK: Notification
    public func startNotifying(characteristic:C) -> Future<C> {
        self.notificationStateChangedPromise = Promise<C>()
        if characteristic.propertyEnabled(.Notify) {
            characteristic.setNotifyValue(true)
        }
        return self.notificationStateChangedPromise.future
    }
    
    public func stopNotifying(characteristic:C) -> Future<C> {
        self.notificationStateChangedPromise = Promise<C>()
        if characteristic.propertyEnabled(.Notify) {
            characteristic.setNotifyValue(false)
        }
        return self.notificationStateChangedPromise.future
    }
    
    public func recieveNotificationUpdates(capacity:Int? = nil) -> FutureStream<C> {
        self.notificationUpdatePromise = StreamPromise<C>(capacity:capacity)
        return self.notificationUpdatePromise!.future
    }
    
    public func stopNotificationUpdates() {
        self.notificationUpdatePromise = nil
    }
    
    //MARK: read
    public func read(characteristic:C, timeout:Double = 10.0) -> Future<C> {
        self.readPromise = Promise<C>()
        if characteristic.propertyEnabled(.Read) {
            characteristic.readValueForCharacteristic()
            self.reading = true
            self.readSequence++
            self.timeoutRead(characteristic, sequence:self.readSequence, timeout:timeout)
        } else {
            self.readPromise.failure(BluetoothError.characteristicReadNotSupported)
        }
        return self.readPromise.future
    }
    private func timeoutRead(characteristic:C, sequence:Int, timeout:Double) {
        CentralQueue.delay(timeout) {
            if sequence == self.readSequence && self.reading {
                self.reading = false
                self.readPromise.failure(BluetoothError.characteristicReadTimeout)
            } else {
            }
        }
    }
    //MARK: write
    public func writeData(characteristic:C, value:NSData, timeout:Double = 10.0) -> Future<C> {
        self.writePromise = Promise<C>()
        if characteristic.propertyEnabled(.Write) {
            characteristic.writeValue(value)
            self.writing = true
            self.writeSequence++
            self.timeoutWrite(characteristic, sequence:self.writeSequence, timeout:timeout)
        } else {
            self.writePromise.failure(BluetoothError.characteristicWriteNotSupported)
        }
        return self.writePromise.future
    }
    
    private func timeoutWrite(characteristic:C, sequence:Int, timeout:Double) {
        CentralQueue.delay(timeout) {
            if sequence == self.writeSequence && self.writing {
                self.writing = false
                self.writePromise.failure(BluetoothError.characteristicWriteTimeout)
            } else {
            }
        }
    }
    
    public func writeString(characteristic:C, stringValue:[String:String], timeout:Double = 10.0) -> Future<C> {
        if let value = characteristic.dataFromStringValue(stringValue) {
            return self.writeData(characteristic, value:value)
        } else {
            self.writePromise = Promise<C>()
            self.writePromise.failure(BluetoothError.characteristicNotSerilaizable)
            return self.writePromise.future
        }
    }
    
    public func write<T:Deserialize>(characteristic:C, value:T, timeout:Double = 10.0) -> Future<C> {
        return self.writeData(characteristic, value:Serializer.serialize(value), timeout:timeout)
    }
    
    public func write<T:RawDeserialize>(characteristic:C, value:T, timeout:Double = 10.0) -> Future<C> {
        return self.writeData(characteristic, value:Serializer.serialize(value), timeout:timeout)
    }
    
    public func write<T:RawArrayDeserialize>(characteristic:C, value:T, timeout:Double = 10.0) -> Future<C> {
        return self.writeData(characteristic, value:Serializer.serialize(value), timeout:timeout)
    }
    
    public func write<T:RawPairDeserialize>(characteristic:C, value:T, timeout:Double = 10.0) -> Future<C> {
        return self.writeData(characteristic, value:Serializer.serialize(value), timeout:timeout)
    }
    
    public func write<T:RawArrayPairDeserialize>(characteristic:C, value:T, timeout:Double = 10.0) -> Future<C> {
        return self.writeData(characteristic, value:Serializer.serialize(value), timeout:timeout)
    }
    
   
    
    public func didDiscover(characteristic:C) {
        guard let afterDiscoveredPromise = characteristic.afterDiscoveredPromise else {
            return
        }
        afterDiscoveredPromise.success(characteristic)
    }
    
    //MARK: Helpers
    public func didUpdateNotificationState(characteristic:C, error:NSError!) {
        guard let error = error else {
            self.notificationStateChangedPromise.success(characteristic)
            return
        }
        self.notificationStateChangedPromise.failure(error)
    }
    
    public func didUpdate(characteristic:C, error:NSError!) {
        self.reading = false
        guard let error = error else {
            if characteristic.isNotifying {
                if let notificationUpdatePromise = self.notificationUpdatePromise {
                    notificationUpdatePromise.success(characteristic)
                }
            } else {
                self.readPromise.success(characteristic)
            }
            return
        }
        if characteristic.isNotifying {
            if let notificationUpdatePromise = self.notificationUpdatePromise {
                notificationUpdatePromise.failure(error)
            }
        } else {
            self.readPromise.failure(error)
        }
    }
    
    public func didWrite(characteristic:C, error:NSError!) {
        self.writing = false
        guard let error = error else {
            if !self.writePromise.completed {
                self.writePromise.success(characteristic)
            }
            return
            
        }
        if !self.writePromise.completed {
            self.writePromise.failure(error)
        }
    }
    
}
