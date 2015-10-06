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

extension Int8 : Deserialize {
    
    public static var size : Int {
        return sizeof(Int8)
    }
  

    public init?(doubleValue:Double) {
        if doubleValue >= 127.0 || doubleValue <= -128.0 {
            return nil
        } else {
            self = Int8(doubleValue)
        }
    }

    public init?(uintValue:UInt16) {
        if uintValue > 255 {
            return nil
        } else {
            self = Int8(uintValue)
        }
    }
    
    public init?(intValue:Int16) {
        if intValue > 255 || intValue < 0 {
            return nil
        } else {
            self = Int8(intValue)
        }
    }

    public static func deserialize(data:NSData) -> Int8? {
        if data.length >= sizeof(Int8) {
            var value : Int8 = 0
            data.getBytes(&value, length:sizeof(Int8))
            return toHostByteOrder(value)
        } else {
            return nil
        }
    }

    public static func deserialize(data:NSData, start:Int) -> Int8? {
        if data.length >= start + sizeof(Int8) {
            var value : Int8 = 0
            data.getBytes(&value, range: NSMakeRange(start, sizeof(Int8)))
            return toHostByteOrder(value)
        } else {
            return nil
        }
    }

    public static func deserialize(data:NSData) -> [Int8] {
        let count = data.length / sizeof(Int8)
        return [Int](0..<count).reduce([]) {(result, start) in
            if let value = self.deserialize(data, start:start) {
                return result + [value]
            } else {
                return result
            }
        }
    }
    
}

extension Int16 : Deserialize {
  
  public static var size : Int {
    return sizeof(Int16)
  }
  
  public init?(doubleValue:Double) {
    if doubleValue >= 32767.0 || doubleValue <= -32768.0 {
      return nil
    } else {
      self = Int16(doubleValue)
    }
  }
  
  public static func deserialize(data:NSData) -> Int16? {
    if data.length >= sizeof(Int16) {
      var value : Int16 = 0
      data.getBytes(&value , length:sizeof(Int16))
      return toHostByteOrder(value)
    } else {
      return nil
    }
  }
  
  public static func deserialize(data:NSData, start:Int) -> Int16? {
    if data.length >= (sizeof(Int16) + start)  {
      var value : Int16 = 0
      data.getBytes(&value, range:NSMakeRange(start, sizeof(Int16)))
      return toHostByteOrder(value)
    } else {
      return nil
    }
  }
  
  public static func deserialize(data:NSData) -> [Int16] {
    let size = sizeof(Int16)
    let count = data.length / size
    return [Int](0..<count).reduce([]) {(result, idx) in
      if let value = self.deserialize(data, start:idx*size) {
        return result + [value]
      } else {
        return result
      }
    }
  }
  
}

extension UInt8 : Deserialize {
  
  public static var size : Int {
    return sizeof(UInt8)
  }
  
  public init?(doubleValue:Double) {
    if doubleValue > 255.0 || doubleValue < 0.0 {
      return nil
    } else {
      self = UInt8(doubleValue)
    }
  }
  
  public init?(uintValue:UInt16) {
    if uintValue > 255 {
      return nil
    } else {
      self = UInt8(uintValue)
    }
  }
  
  public init?(intValue:Int16) {
    if intValue > 255 || intValue < 0 {
      return nil
    } else {
      self = UInt8(intValue)
    }
  }
  
  public static func deserialize(data:NSData) -> UInt8? {
    if data.length >= sizeof(UInt8) {
      var value : UInt8 = 0
      data.getBytes(&value, length:sizeof(UInt8))
      return toHostByteOrder(value)
    } else {
      return nil
    }
  }
  
  public static func deserialize(data:NSData, start:Int) -> UInt8? {
    if data.length >= start + sizeof(UInt8) {
      var value : UInt8 = 0
      data.getBytes(&value, range: NSMakeRange(start, sizeof(UInt8)))
      return toHostByteOrder(value)
    } else {
      return nil
    }
  }
  
  public static func deserialize(data:NSData) -> [UInt8] {
    let count = data.length / sizeof(UInt8)
    return [Int](0..<count).reduce([]) {(result, start) in
      if let value = self.deserialize(data, start:start) {
        return result + [value]
      } else {
        return result
      }
    }
  }
  
}


extension UInt16 : Deserialize {
  
  public static var size : Int {
    return sizeof(UInt16)
  }
  
  public init?(doubleValue:Double) {
    if doubleValue >= 65535.0 || doubleValue <= 0.0 {
      return nil
    } else {
      self = UInt16(doubleValue)
    }
  }
  
  public static func deserialize(data:NSData) -> UInt16? {
    if data.length >= sizeof(UInt16) {
      var value : UInt16 = 0
      data.getBytes(&value, length:sizeof(UInt16))
      return toHostByteOrder(value)
    } else {
      return nil
    }
  }
  
  public static func deserialize(data:NSData, start:Int) -> UInt16? {
    if data.length >= start + sizeof(UInt16) {
      var value : UInt16 = 0
      data.getBytes(&value, range:NSMakeRange(start, sizeof(UInt16)))
      return toHostByteOrder(value)
    } else {
      return nil
    }
  }
  
  public static func deserialize(data:NSData) -> [UInt16] {
    let size = sizeof(UInt16)
    let count = data.length / size
    return [Int](0..<count).reduce([]) {(result, idx) in
      if let value = self.deserialize(data, start:size*idx) {
        return result + [value]
      } else {
        return result
      }
    }
  }
}

