/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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
    var boundingBox: CGRect

    let mx: Int = 0
    let my: Int = 0
    let pd: String = "*****"

    init(withName name: String) {
        self.name = String(name.prefix(16))
        self.pointAmount = 0
        self.colorChangeCount = 1

        self.delta = CGVector.zero
        self.boundingBox = CGRect.zero
    }

    func update(relativeX: Int, relativeY: Int, isColorChange: Bool = false) {
        delta += CGVector(dx: relativeX, dy: relativeY)

        if !boundingBox.contains(delta.toCGPoint()) {
            boundingBox = boundingBox.union(CGRect(x: 0, y: 0, width: delta.dx, height: delta.dy))
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
                                             Int(boundingBox.maxX),
                                             Int(boundingBox.minX),
                                             Int(boundingBox.maxY),
                                             Int(boundingBox.minY),
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
