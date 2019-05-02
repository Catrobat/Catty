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
import Foundation

// CharacteristicProfile
open class CharacteristicProfile {

    public let uuid: CBUUID
    public let name: String
    public let permissions: CBAttributePermissions
    public let properties: CBCharacteristicProperties
    public let initialValue: Data?

    internal var afterDiscoveredPromise: StreamPromise<Characteristic>!

    open var stringValues: [String] {
        return []
    }

    public init(uuid: String,
                name: String,
                permissions: CBAttributePermissions = [CBAttributePermissions.readable, CBAttributePermissions.writeable],
                properties: CBCharacteristicProperties = [CBCharacteristicProperties.read, CBCharacteristicProperties.write, CBCharacteristicProperties.notify],
                initialValue: Data? = nil) {
        self.uuid = CBUUID(string: uuid)
        self.name = name
        self.permissions = permissions
        self.properties = properties
        self.initialValue = initialValue
    }

    public convenience init(uuid: String) {
        self.init(uuid: uuid, name: "Unknown")
    }

    open func afterDiscovered(_ capacity: Int?) -> FutureStream<Characteristic> {
        if let capacity = capacity {
            self.afterDiscoveredPromise = StreamPromise<Characteristic>(capacity: capacity)
        } else {
            self.afterDiscoveredPromise = StreamPromise<Characteristic>()
        }
        return self.afterDiscoveredPromise.future
    }

    open func propertyEnabled(_ property: CBCharacteristicProperties) -> Bool {
        return (self.properties.rawValue & property.rawValue) > 0
    }

    open func permissionEnabled(_ permission: CBAttributePermissions) -> Bool {
        return (self.permissions.rawValue & permission.rawValue) > 0
    }

    open func stringValue(_ data: Data) -> [String: String]? {
        return [self.name: data.hexStringValue()]
    }

    open func dataFromStringValue(_ data: [String: String]) -> Data? {
        return data[self.name].map { ($0.dataFromHexString() as Data) }
    }
}

// RawCharacteristicProfile
public final class RawCharacteristicProfile<DeserializedType>: CharacteristicProfile where
    DeserializedType: RawDeserialize, DeserializedType: StringDeserialize, DeserializedType: CharacteristicConfigurable, DeserializedType.RawType: Deserialize {

    public init() {
        super.init(uuid: DeserializedType.uuid,
                   name: DeserializedType.name,
                   permissions: DeserializedType.permissions,
                   properties: DeserializedType.properties,
                   initialValue: DeserializedType.initialValue)
    }

    override public var stringValues: [String] {
        return DeserializedType.stringValues
    }

    override public func stringValue(_ data: Data) -> [String: String]? {
        let value: DeserializedType? = Deserializer.deserialize(data)
        return value.map { $0.stringValue }
    }

    override public func dataFromStringValue(_ data: [String: String]) -> Data? {
        return DeserializedType(stringValue: data).flatmap { Serializer.serialize($0) }
    }
}

// RawArrayCharacteristicProfile
public final class RawArrayCharacteristicProfile<DeserializedType>: CharacteristicProfile where
    DeserializedType: RawArrayDeserialize, DeserializedType: StringDeserialize, DeserializedType: CharacteristicConfigurable, DeserializedType.RawType: Deserialize {

    public init() {
        super.init(uuid: DeserializedType.uuid,
                   name: DeserializedType.name,
                   permissions: DeserializedType.permissions,
                   properties: DeserializedType.properties,
                   initialValue: DeserializedType.initialValue)
    }

    override public var stringValues: [String] {
        return DeserializedType.stringValues
    }

    override public func stringValue(_ data: Data) -> [String: String]? {
        let value: DeserializedType? = Deserializer.deserialize(data)
        return value.map { $0.stringValue }
    }

    override public func dataFromStringValue(_ data: [String: String]) -> Data? {
        return DeserializedType(stringValue: data).flatmap { Serializer.serialize($0) }
    }
}

// RawPairCharacteristicProfile
public final class RawPairCharacteristicProfile<DeserializedType>: CharacteristicProfile where
    DeserializedType: RawPairDeserialize,
    DeserializedType: StringDeserialize,
    DeserializedType: CharacteristicConfigurable,
    DeserializedType.RawType1: Deserialize,
    DeserializedType.RawType2: Deserialize {

    public init() {
        super.init(uuid: DeserializedType.uuid,
                   name: DeserializedType.name,
                   permissions: DeserializedType.permissions,
                   properties: DeserializedType.properties,
                   initialValue: DeserializedType.initialValue)
    }

    override public var stringValues: [String] {
        return DeserializedType.stringValues
    }

    override public func stringValue(_ data: Data) -> [String: String]? {
        let value: DeserializedType? = Deserializer.deserialize(data)
        return value.map { $0.stringValue }
    }

    override public func dataFromStringValue(_ data: [String: String]) -> Data? {
        return DeserializedType(stringValue: data).flatmap { Serializer.serialize($0) }
    }
}

// RawArrayPairCharacteristicProfile
public final class RawArrayPairCharacteristicProfile<DeserializedType>: CharacteristicProfile where
    DeserializedType: RawArrayPairDeserialize,
    DeserializedType: StringDeserialize,
    DeserializedType: CharacteristicConfigurable,
    DeserializedType.RawType1: Deserialize,
    DeserializedType.RawType2: Deserialize {

    public init() {
        super.init(uuid: DeserializedType.uuid,
                   name: DeserializedType.name,
                   permissions: DeserializedType.permissions,
                   properties: DeserializedType.properties,
                   initialValue: DeserializedType.initialValue)
    }

    override public var stringValues: [String] {
        return DeserializedType.stringValues
    }

    override public func stringValue(_ data: Data) -> [String: String]? {
        let value: DeserializedType? = Deserializer.deserialize(data)
        return value.map { $0.stringValue }
    }

    override public func dataFromStringValue(_ data: [String: String]) -> Data? {
        return DeserializedType(stringValue: data).flatmap { Serializer.serialize($0) }
    }
}

// StringCharacteristicProfile
public final class StringCharacteristicProfile<T: CharacteristicConfigurable>: CharacteristicProfile {

    public var encoding: String.Encoding

    public convenience init(encoding: String.Encoding = String.Encoding.utf8) {
        self.init(uuid: T.uuid, name: T.name, permissions: T.permissions, properties: T.properties, initialValue: T.initialValue, encoding: encoding)
    }

    public init(uuid: String,
                name: String,
                permissions: CBAttributePermissions = [CBAttributePermissions.readable, CBAttributePermissions.writeable],
                properties: CBCharacteristicProperties = [CBCharacteristicProperties.read, CBCharacteristicProperties.write, CBCharacteristicProperties.notify],
                initialValue: Data? = nil,
                encoding: String.Encoding = String.Encoding.utf8) {
        self.encoding = encoding
        super.init(uuid: uuid, name: name, permissions: permissions, properties: properties)
    }

    override public func stringValue(_ data: Data) -> [String: String]? {
        let value: String? = Deserializer.deserialize(data, encoding: self.encoding)
        return value.map { [self.name: $0] }
    }

    override public func dataFromStringValue(_ data: [String: String]) -> Data? {
        return data[self.name].flatmap { Serializer.serialize($0, encoding: self.encoding) }
    }
}
