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

import Foundation
import CoreBluetooth

// CharacteristicProfile
public class CharacteristicProfile {
    
    public let uuid                     : CBUUID
    public let name                     : String
    public let permissions              : CBAttributePermissions
    public let properties               : CBCharacteristicProperties
    public let initialValue             : NSData?

    internal var afterDiscoveredPromise : StreamPromise<Characteristic>!

    public var stringValues : [String] {
        return []
    }
    
    public init(uuid:String,
                name:String,
                permissions:CBAttributePermissions = [CBAttributePermissions.Readable, CBAttributePermissions.Writeable],
                properties:CBCharacteristicProperties = [CBCharacteristicProperties.Read, CBCharacteristicProperties.Write, CBCharacteristicProperties.Notify],
                initialValue:NSData? = nil) {
        self.uuid = CBUUID(string:uuid)
        self.name = name
        self.permissions = permissions
        self.properties = properties
        self.initialValue = initialValue
    }
    
    public convenience init(uuid:String) {
        self.init(uuid:uuid, name:"Unknown")
    }
    
    public func afterDiscovered(capacity:Int?) -> FutureStream<Characteristic> {
        if let capacity = capacity {
            self.afterDiscoveredPromise = StreamPromise<Characteristic>(capacity:capacity)
        } else {
            self.afterDiscoveredPromise = StreamPromise<Characteristic>()
        }
        return self.afterDiscoveredPromise.future
    }

    public func propertyEnabled(property:CBCharacteristicProperties) -> Bool {
        return (self.properties.rawValue & property.rawValue) > 0
    }
    
    public func permissionEnabled(permission:CBAttributePermissions) -> Bool {
        return (self.permissions.rawValue & permission.rawValue) > 0
    }
        
    public func stringValue(data:NSData) -> [String:String]? {
        return [self.name:data.hexStringValue()]
    }
    
    public func dataFromStringValue(data:[String:String]) -> NSData? {
        return data[self.name].map{$0.dataFromHexString()}
    }
    
}

// RawCharacteristicProfile
public final class RawCharacteristicProfile<DeserializedType where
                                              DeserializedType:RawDeserialize,
                                              DeserializedType:StringDeserialize,
                                              DeserializedType:CharacteristicConfigurable,
                                              DeserializedType.RawType:Deserialize> : CharacteristicProfile {
    
    public init() {
        super.init(uuid:DeserializedType.uuid,
            name:DeserializedType.name,
            permissions:DeserializedType.permissions,
            properties:DeserializedType.properties,
            initialValue:DeserializedType.initialValue)
    }
    
    public override var stringValues : [String] {
        return DeserializedType.stringValues
    }
    
    public override func stringValue(data:NSData) -> [String:String]? {
        let value : DeserializedType? = Deserializer.deserialize(data)
        return value.map{$0.stringValue}
    }
    
    public override func dataFromStringValue(data:Dictionary<String, String>) -> NSData? {
        return DeserializedType(stringValue:data).flatmap{Serializer.serialize($0)}
    }
    
}

// RawArrayCharacteristicProfile
public final class RawArrayCharacteristicProfile<DeserializedType where
                                                   DeserializedType:RawArrayDeserialize,
                                                   DeserializedType:StringDeserialize,
                                                   DeserializedType:CharacteristicConfigurable,
                                                   DeserializedType.RawType:Deserialize> : CharacteristicProfile {
    
    public init() {
        super.init(uuid:DeserializedType.uuid,
                   name:DeserializedType.name,
                   permissions:DeserializedType.permissions,
                   properties:DeserializedType.properties,
                   initialValue:DeserializedType.initialValue)
    }
    
    public override var stringValues : [String] {
        return DeserializedType.stringValues
    }
    
    public override func stringValue(data:NSData) -> [String:String]? {
        let value : DeserializedType? = Deserializer.deserialize(data)
        return value.map{$0.stringValue}
    }
    
    public override func dataFromStringValue(data:[String:String]) -> NSData? {
        return DeserializedType(stringValue:data).flatmap{Serializer.serialize($0)}
    }
    
}

// RawPairCharacteristicProfile
public final class RawPairCharacteristicProfile<DeserializedType where
                                                  DeserializedType:RawPairDeserialize,
                                                  DeserializedType:StringDeserialize,
                                                  DeserializedType:CharacteristicConfigurable,
                                                  DeserializedType.RawType1:Deserialize,
                                                  DeserializedType.RawType2:Deserialize> : CharacteristicProfile {
    
    public init() {
        super.init(uuid:DeserializedType.uuid,
            name:DeserializedType.name,
            permissions:DeserializedType.permissions,
            properties:DeserializedType.properties,
            initialValue:DeserializedType.initialValue)
    }
    
    public override var stringValues : [String] {
        return DeserializedType.stringValues
    }
    
    public override func stringValue(data:NSData) -> [String:String]? {
        let value : DeserializedType? = Deserializer.deserialize(data)
        return value.map{$0.stringValue}
    }
    
    public override func dataFromStringValue(data:[String:String]) -> NSData? {
        return DeserializedType(stringValue:data).flatmap{Serializer.serialize($0)}
    }
    
}


// RawArrayPairCharacteristicProfile
public final class RawArrayPairCharacteristicProfile<DeserializedType where
                                                       DeserializedType:RawArrayPairDeserialize,
                                                       DeserializedType:StringDeserialize,
                                                       DeserializedType:CharacteristicConfigurable,
                                                       DeserializedType.RawType1:Deserialize,
                                                       DeserializedType.RawType2:Deserialize> : CharacteristicProfile {
    
    public init() {
        super.init(uuid:DeserializedType.uuid,
            name:DeserializedType.name,
            permissions:DeserializedType.permissions,
            properties:DeserializedType.properties,
            initialValue:DeserializedType.initialValue)
    }
    
    public override var stringValues : [String] {
        return DeserializedType.stringValues
    }
    
    public override func stringValue(data:NSData) -> [String:String]? {
        let value : DeserializedType? = Deserializer.deserialize(data)
        return value.map{$0.stringValue}
    }
    
    public override func dataFromStringValue(data:[String:String]) -> NSData? {
        return DeserializedType(stringValue:data).flatmap{Serializer.serialize($0)}
    }
    
}

// StringCharacteristicProfile
public final class StringCharacteristicProfile<T:CharacteristicConfigurable> : CharacteristicProfile {
    
    public var encoding : NSStringEncoding
    
    public convenience init(encoding:NSStringEncoding = NSUTF8StringEncoding) {
        self.init(uuid:T.uuid, name:T.name, permissions:T.permissions, properties:T.properties, initialValue:T.initialValue, encoding:encoding)
    }
    
    public init(uuid:String,
                name:String,
                permissions:CBAttributePermissions = [CBAttributePermissions.Readable, CBAttributePermissions.Writeable],
                properties:CBCharacteristicProperties = [CBCharacteristicProperties.Read, CBCharacteristicProperties.Write, CBCharacteristicProperties.Notify],
                initialValue:NSData? = nil,
                encoding:NSStringEncoding = NSUTF8StringEncoding) {
        self.encoding = encoding
        super.init(uuid:uuid, name:name, permissions:permissions, properties:properties)
    }
    
    public override func stringValue(data:NSData) -> [String:String]? {
        let value : String? = Deserializer.deserialize(data, encoding:self.encoding)
        return value.map{[self.name:$0]}
    }
    
    public override func dataFromStringValue(data:[String:String]) -> NSData? {
        return data[self.name].flatmap{Serializer.serialize($0, encoding:self.encoding)}
    }

}


