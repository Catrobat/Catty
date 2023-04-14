/**
 *  Copyright (C) 2010-2023 The Catrobat Team
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

class EmbroideryDSTHeader {
    var name: String
    var pointAmount: Int
    var colorChangeCount: Int

    var delta: CGVector
    var minX: Float
    var maxX: Float
    var minY: Float
    var maxY: Float

    let mx: Int = 0
    let my: Int = 0
    let pd: String = "*****"

    init(withName name: String) {
        self.name = String(name.prefix(16))
        self.pointAmount = 0
        self.colorChangeCount = 1

        self.delta = CGVector.zero
        self.minX = 0
        self.maxX = 0
        self.minY = 0
        self.maxY = 0
    }

    func update(relativeX: Float, relativeY: Float, delta: CGVector, isColorChange: Bool = false) {
        self.delta += delta
        let xCoord = relativeX * 2
        let yCoord = relativeY * 2

        if xCoord < minX {
            minX = xCoord
        }

        if xCoord > maxX {
            maxX = xCoord
        }

        if yCoord < minY {
            minY = yCoord
        }

        if yCoord > maxY {
            maxY = yCoord
        }

        if isColorChange {
            colorChangeCount += 1
        }
        pointAmount += 1
    }

    func toDSTData() -> Data {
        var headerContent = String.init()
        name.withCString {
            headerContent.append(String.init(format: EmbroideryDefines.HEADER_FORMAT_STRINGS[0], $0))
        }
        pd.withCString {
            headerContent.append(String.init(format: EmbroideryDefines.HEADER_FORMAT_STRINGS[1],
                                             pointAmount,
                                             colorChangeCount,
                                             Int(maxX),
                                             Int(minX),
                                             Int(maxY),
                                             Int(minY),
                                             Int(delta.dx),
                                             Int(delta.dy),
                                             mx,
                                             my,
                                             $0).replacingOccurrences(of: " ", with: "\0"))
        }
        let headerFiller: [UInt8] = Array.init(repeating: 0x20, count: 388)
        var DSTData = Data(headerContent.utf8)
        DSTData.append(contentsOf: headerFiller)
        return DSTData
    }
}
