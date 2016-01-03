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

func toHostByteOrder<T>(value:T) -> T {
    return value;
}

func fromHostByteOrder<T>(value:T) -> T {
    return value;
}

func byteArrayValue<T>(value:T) -> [UInt8] {
    let values = [value]
    let data = NSData(bytes:values, length:sizeof(T))
    var byteArray = [UInt8](count:sizeof(T), repeatedValue:0)
    data.getBytes(&byteArray, length:sizeof(T))
    return byteArray
}

func reverseBytes<T>(value:T) -> T {
    var result = value
    let swappedBytes = NSData(bytes:byteArrayValue(value).reverse(), length:sizeof(T))
    swappedBytes.getBytes(&result, length:sizeof(T))
    return result
}

public protocol Deserialize {
    static var size : Int {get}
    static func deserialize(data:NSData) -> Self?
    static func deserialize(data:NSData, start:Int) -> Self?
    static func deserialize(data:NSData) -> [Self]
}

public protocol Serialize {
    static func fromString(value:String, encoding:NSStringEncoding) -> NSData?
    static func serialize<T>(value:T) -> NSData
    static func serialize<T>(values:[T]) -> NSData
    static func serialize<T1, T2>(value1:T1, value2:T2) -> NSData
    static func serialize<T1, T2>(value1:[T1], value2:[T2]) -> NSData
}

public protocol CharacteristicConfigurable {
    static var name          : String {get}
    static var uuid          : String {get}
    static var permissions   : CBAttributePermissions {get}
    static var properties    : CBCharacteristicProperties {get}
    static var initialValue  : NSData? {get}
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
    typealias RawType
    static var uuid         : String {get}
    var rawValue            : RawType {get}
    init?(rawValue:RawType)
}

public protocol RawArrayDeserialize {
    typealias RawType
    static var uuid     : String {get}
    static var size     : Int {get}
    var rawValue        : [RawType] {get}
    init?(rawValue:[RawType])
}

public protocol RawPairDeserialize {
    typealias RawType1
    typealias RawType2
    static var uuid     : String {get}
    var rawValue1       : RawType1 {get}
    var rawValue2       : RawType2 {get}
    init?(rawValue1:RawType1, rawValue2:RawType2)
}

public protocol RawArrayPairDeserialize {
    typealias RawType1
    typealias RawType2
    static var uuid     : String {get}
    static var size1    : Int {get}
    static var size2    : Int {get}
    var rawValue1       : [RawType1] {get}
    var rawValue2       : [RawType2] {get}
    init?(rawValue1:[RawType1], rawValue2:[RawType2])
}

public struct Serializer {
    
    public static func serialize(value:String, encoding:NSStringEncoding = NSUTF8StringEncoding) -> NSData? {
        return NSData.fromString(value, encoding:encoding)
    }


    public static func serialize<T:Deserialize>(value:T) -> NSData {
        return NSData.serialize(value)
    }

    public static func serialize<T:Deserialize>(values:[T]) -> NSData {
        return NSData.serializeArray(values)
    }



    public static func serialize<T:RawDeserialize>(value:T) -> NSData {
        return NSData.serialize(value.rawValue)
    }



    public static func serialize<T:RawArrayDeserialize>(value:T) -> NSData {
        return NSData.serializeArray(value.rawValue)
    }



    public static func serialize<T:RawPairDeserialize>(value:T) -> NSData {
        return NSData.serialize(value.rawValue1, value2:value.rawValue2)
    }



    public static func serialize<T:RawArrayPairDeserialize>(value:T) -> NSData {
        return NSData.serializeArrays(value.rawValue1, values2:value.rawValue2)
    }
}

public struct Deserializer {
  
  public static func deserialize(data:NSData, encoding:NSStringEncoding = NSUTF8StringEncoding) -> String? {
    return (NSString(data:data, encoding:encoding) as? String)
  }
  
  public static func deserialize<T:Deserialize>(data:NSData) -> T? {
    return T.deserialize(data)
  }
  
  
  public static func deserialize<T:RawDeserialize where T.RawType:Deserialize>(data:NSData) -> T? {
    return T.RawType.deserialize(data).flatmap{T(rawValue:$0)}
  }
  
  public static func deserialize<T:RawArrayDeserialize where T.RawType:Deserialize>(data:NSData) -> T? {
    if data.length >= T.size {
      return T(rawValue:T.RawType.deserialize(data))
    } else {
      return nil
    }
  }
  
  public static func deserialize<T:RawPairDeserialize where T.RawType1:Deserialize,  T.RawType2:Deserialize>(data:NSData) -> T? {
    if data.length >= (T.RawType1.size + T.RawType2.size) {
      let rawData1 = data.subdataWithRange(NSMakeRange(0, T.RawType1.size))
      let rawData2 = data.subdataWithRange(NSMakeRange(T.RawType1.size, T.RawType2.size))
      return T.RawType1.deserialize(rawData1).flatmap {rawValue1 in
        T.RawType2.deserialize(rawData2).flatmap {rawValue2 in
          T(rawValue1:rawValue1, rawValue2:rawValue2)
        }
      }
    } else {
      return nil
    }
  }
  
  public static func deserialize<T:RawArrayPairDeserialize where T.RawType1:Deserialize,  T.RawType2:Deserialize>(data:NSData) -> T? {
    if data.length >= (T.size1 + T.size2) {
      let rawData1 = data.subdataWithRange(NSMakeRange(0, T.size1))
      let rawData2 = data.subdataWithRange(NSMakeRange(T.size1, T.size2))
      return T(rawValue1:T.RawType1.deserialize(rawData1), rawValue2:T.RawType2.deserialize(rawData2))
    } else {
      return nil
    }
  }
}



