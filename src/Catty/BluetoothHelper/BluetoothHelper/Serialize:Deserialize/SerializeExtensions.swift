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

extension NSData : Serialize {
    
    public class func fromString(value:String, encoding:NSStringEncoding = NSUTF8StringEncoding) -> NSData? {
        return value.dataUsingEncoding(encoding).map{NSData(data:$0)}
    }
    
    public class func serialize<T>(value:T) -> NSData {
        let values = [fromHostByteOrder(value)]
        return NSData(bytes:values, length:sizeof(T))
    }
    
    public class func serializeArray<T>(values:[T]) -> NSData {
        let littleValues = values.map{fromHostByteOrder($0)}
        return NSData(bytes:littleValues, length:sizeof(T)*littleValues.count)
    }

    public class func serialize<T1, T2>(value1:T1, value2:T2) -> NSData {
        let data = NSMutableData()
        data.setData(NSData.serialize(value1))
        data.appendData(NSData.serialize(value2))
        return data
    }

    public class func serializeArrays<T1, T2>(values1:[T1], values2:[T2]) -> NSData {
        let data = NSMutableData()
        data.setData(NSData.serializeArray(values1))
        data.appendData(NSData.serializeArray(values2))
        return data
    }

    public func hexStringValue() -> String {
        var dataBytes = [UInt8](count:self.length, repeatedValue:0x0)
        self.getBytes(&dataBytes, length:self.length)
        let hexString = dataBytes.reduce(""){(out:String, dataByte:UInt8) in
            return out + (NSString(format:"%02lx", dataByte) as String)
        }
        return hexString
    }
    
}
