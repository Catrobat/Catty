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

import Foundation
import CoreBluetooth

func toHostByteOrder<T>(_ value:T) -> T {
    return value;
}

func fromHostByteOrder<T>(_ value:T) -> T {
    return value;
}

func byteArrayValue<T>(_ value:T) -> [UInt8] {
    let values = [value]
    let bytes = UnsafeRawPointer(values).assumingMemoryBound(to: UInt8.self)
    let data = Data(bytes: bytes, count:MemoryLayout<T>.size)
    var byteArray = [UInt8](repeating: 0, count: MemoryLayout<T>.size)
    (data as NSData).getBytes(&byteArray, length:MemoryLayout<T>.size)
    return byteArray
}

func reverseBytes<T>(_ value:T) -> T {
    var result = value
    let swappedBytes = Data(bytes: UnsafePointer<UInt8>(byteArrayValue(value).reversed()), count:MemoryLayout<T>.size)
    (swappedBytes as NSData).getBytes(&result, length:MemoryLayout<T>.size)
    return result
}

public protocol Deserialize {
    static var size : Int {get}
    static func deserialize(_ data:Data) -> Self?
    static func deserialize(_ data:Data, start:Int) -> Self?
    static func deserialize(_ data:Data) -> [Self]
}

public protocol Serialize {
    static func fromString(_ value:String, encoding:String.Encoding) -> Data?
    static func serialize<T>(_ value:T) -> Data
    static func serialize<T>(_ values:[T]) -> Data
    static func serialize<T1, T2>(_ value1:T1, value2:T2) -> Data
    static func serialize<T1, T2>(_ value1:[T1], value2:[T2]) -> Data
}

public protocol CharacteristicConfigurable {
    static var name          : String {get}
    static var uuid          : String {get}
    static var permissions   : CBAttributePermissions {get}
    static var properties    : CBCharacteristicProperties {get}
    static var initialValue  : Data? {get}
}

public protocol ServiceConfigurable {
    static var name  : String {get}
    static var uuid  : String {get}
    static var tag   : String {get}
}

public protocol StringDeserialize {
    static var stringValues : [String] {get}
    var stringValue         : [String:String] {get}
    init?(stringValue:[String:String])
}

public protocol RawDeserialize {
    associatedtype RawType
    static var uuid         : String {get}
    var rawValue            : RawType {get}
    init?(rawValue:RawType)
}

public protocol RawArrayDeserialize {
    associatedtype RawType
    static var uuid     : String {get}
    static var size     : Int {get}
    var rawValue        : [RawType] {get}
    init?(rawValue:[RawType])
}

public protocol RawPairDeserialize {
    associatedtype RawType1
    associatedtype RawType2
    static var uuid     : String {get}
    var rawValue1       : RawType1 {get}
    var rawValue2       : RawType2 {get}
    init?(rawValue1:RawType1, rawValue2:RawType2)
}

public protocol RawArrayPairDeserialize {
    associatedtype RawType1
    associatedtype RawType2
    static var uuid     : String {get}
    static var size1    : Int {get}
    static var size2    : Int {get}
    var rawValue1       : [RawType1] {get}
    var rawValue2       : [RawType2] {get}
    init?(rawValue1:[RawType1], rawValue2:[RawType2])
}

public struct Serializer {
    
    public static func serialize(_ value:String, encoding:String.Encoding = String.Encoding.utf8) -> Data? {
        return Data.fromString(value, encoding:encoding)
    }


    public static func serialize<T:Deserialize>(_ value:T) -> Data {
        return Data.serialize(value)
    }

    public static func serialize<T:Deserialize>(_ values:[T]) -> Data {
        return Data.serializeArray(values)
    }



    public static func serialize<T:RawDeserialize>(_ value:T) -> Data {
        return Data.serialize(value.rawValue)
    }



    public static func serialize<T:RawArrayDeserialize>(_ value:T) -> Data {
        return Data.serializeArray(value.rawValue)
    }



    public static func serialize<T:RawPairDeserialize>(_ value:T) -> Data {
        return Data.serialize(value.rawValue1, value2:value.rawValue2)
    }



    public static func serialize<T:RawArrayPairDeserialize>(_ value:T) -> Data {
        return Data.serializeArrays(value.rawValue1, values2:value.rawValue2)
    }
}

public struct Deserializer {
  
  public static func deserialize(_ data:Data, encoding:String.Encoding = String.Encoding.utf8) -> String? {
    return (NSString(data:data, encoding:encoding.rawValue) as String?)
  }
  
  public static func deserialize<T:Deserialize>(_ data:Data) -> T? {
    return T.deserialize(data)
  }
  
  
  public static func deserialize<T:RawDeserialize>(_ data:Data) -> T? where T.RawType:Deserialize {
    return T.RawType.deserialize(data).flatmap{T(rawValue:$0)}
  }
  
  public static func deserialize<T:RawArrayDeserialize>(_ data:Data) -> T? where T.RawType:Deserialize {
    if data.count >= T.size {
      return T(rawValue:T.RawType.deserialize(data))
    } else {
      return nil
    }
  }

    public static func deserialize<T: RawPairDeserialize>(_ data: Data) -> T? where T.RawType1: Deserialize, T.RawType2: Deserialize {
        guard data.count >= T.RawType1.size + T.RawType2.size else { return nil }

        let rawData1 = data[0..<T.RawType1.size]
        let rawData2 = data[T.RawType1.size..<T.RawType1.size + T.RawType2.size]
        return T.RawType1.deserialize(rawData1).flatmap { rawValue1 in
            T.RawType2.deserialize(rawData2).flatmap { rawValue2 in
                T(rawValue1:rawValue1, rawValue2:rawValue2)
            }
        }
    }

    public static func deserialize<T: RawArrayPairDeserialize>(_ data: Data) -> T? where T.RawType1: Deserialize, T.RawType2: Deserialize {
        guard data.count >= T.size1 + T.size2 else { return nil }

        let rawData1 = data[0..<T.size1]
        let rawData2 = data[T.size1..<T.size1 + T.size2]
        return T(rawValue1: T.RawType1.deserialize(rawData1), rawValue2: T.RawType2.deserialize(rawData2))
    }
}



