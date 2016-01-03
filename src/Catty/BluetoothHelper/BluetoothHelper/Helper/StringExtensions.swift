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

public extension String {
    
//    public var floatValue : Float {
//        return (self as NSString).floatValue
//    }
  
    public func dataFromHexString() -> NSData {
        var bytes = [UInt8]()
        for i in 0..<(self.characters.count/2) {
            let stringBytes = self.substringWithRange(Range(start:self.startIndex.advancedBy(2*i), end:self.startIndex.advancedBy(2*i+2)))
            let byte = strtol((stringBytes as NSString).UTF8String, nil, 16)
            bytes.append(UInt8(byte))
        }
        return NSData(bytes:bytes, length:bytes.count)
    }
    
}