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
import CoreBluetooth

public class ServiceProfile {
    
    internal var characteristicProfiles = [CBUUID:CharacteristicProfile]()

    public let uuid : CBUUID
    public let name : String
    public let tag  : String
    
    public var characteristics : [CharacteristicProfile] {
        let values: [CharacteristicProfile] = [CharacteristicProfile](self.characteristicProfiles.values)
        return values
    }
    
    public var characteristic : [CBUUID:CharacteristicProfile] {
        return self.characteristicProfiles
    }
    
    public init(uuid:String, name:String, tag:String = "Miscellaneous") {
        self.name = name
        self.uuid = CBUUID(string:uuid)
        self.tag = tag
    }
    
    public convenience init(uuid:String) {
        self.init(uuid:uuid, name:"Unknown")
    }

    public func addCharacteristic(characteristicProfile:CharacteristicProfile) {
        self.characteristicProfiles[characteristicProfile.uuid] = characteristicProfile
    }
    
}
