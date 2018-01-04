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
import BluetoothHelper


struct RawPairTest : RawPairDeserialize {
    
    let value1:Int8
    let value2:UInt8
    
    static let uuid = "TEST"
    
    var rawValue1 : Int8  {
        return self.value1
    }
    
    var rawValue2 : UInt8 {
        return self.value2
    }
    
    init?(rawValue1:Int8, rawValue2:UInt8) {
        if rawValue2 > 10 {
            self.value1 = rawValue1
            self.value2 = rawValue2
        } else {
            return nil
        }
    }
    
}

struct RawArrayTest : RawArrayDeserialize {
    
    let value1:Int8
    let value2:Int8
    let value3:Int8
    
    static let uuid = "TEST"
    static let size = 3
    
    init?(rawValue:[Int8]) {
        if rawValue.count == 3 {
            self.value1 = rawValue[0]
            self.value2 = rawValue[1]
            self.value3 = rawValue[2]
        } else {
            return nil
        }
    }
    
    var rawValue : [Int8] {
        return [self.value1, self.value2,self.value3]
    }
    
}

struct RawArrayPairTest : RawArrayPairDeserialize {
    
    let value1:[Int8]
    let value2:[UInt8]
    static let size1 : Int = 2
    static let size2 : Int = 2
    
    static let uuid = "TEST"
    
    var rawValue1 : [Int8]  {
        return self.value1
    }
    
    var rawValue2 : [UInt8] {
        return self.value2
    }
    
    init?(rawValue1:[Int8], rawValue2:[UInt8]) {
        if rawValue1.count == RawArrayPairTest.size1 &&
            rawValue2.count == RawArrayPairTest.size2 {
                self.value1 = rawValue1
                self.value2 = rawValue2
        } else {
            return nil
        }
    }
    
}
