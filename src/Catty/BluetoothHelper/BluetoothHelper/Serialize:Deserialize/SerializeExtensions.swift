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

extension Data : Serialize {
    
    public static func fromString(_ value:String, encoding:String.Encoding = String.Encoding.utf8) -> Data? {
        return value.data(using: encoding).map{(NSData(data:$0) as Data)}
    }
    
    public static func serialize<T>(_ value:T) -> Data {
        let values = [fromHostByteOrder(value)]
        let bytes = UnsafeRawPointer(values).assumingMemoryBound(to: UInt8.self)
        return Data(bytes: bytes, count:MemoryLayout<T>.size)
    }
    
    public static func serializeArray<T>(_ values:[T]) -> Data {
        let littleValues = values.map{fromHostByteOrder($0)}
        let bytes = UnsafeRawPointer(littleValues).assumingMemoryBound(to: UInt8.self)
        return Data(bytes: bytes, count:MemoryLayout<T>.size*littleValues.count)
    }

    public static func serialize<T1, T2>(_ value1:T1, value2:T2) -> Data {
        let data = NSMutableData()
        data.setData(Data.serialize(value1))
        data.append(Data.serialize(value2))
        return data as Data
    }

    public static func serializeArrays<T1, T2>(_ values1:[T1], values2:[T2]) -> Data {
        let data = NSMutableData()
        data.setData(Data.serializeArray(values1))
        data.append(Data.serializeArray(values2))
        return data as Data
    }

    public func hexStringValue() -> String {
        var dataBytes = [UInt8](repeating: 0x0, count: self.count)
        (self as NSData).getBytes(&dataBytes, length:self.count)
        let hexString = dataBytes.reduce(""){(out:String, dataByte:UInt8) in
            return out + (NSString(format:"%02lx", dataByte) as String)
        }
        return hexString
    }
    
}
