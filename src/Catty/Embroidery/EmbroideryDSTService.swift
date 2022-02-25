/**
 *  Copyright (C) 2010-2022 The Catrobat Team
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

class EmbroideryDSTService: EmbroideryProtocol {
    func generateOutput(embroideryStream: EmbroideryStream) -> Data {

        let DSTHeader = EmbroideryDSTHeader(withName: embroideryStream.name ?? "")
        var DSTStitches = Data.init()

        guard var previousStitch = embroideryStream.first else {

            var emptyFile = DSTHeader.toDSTData()
            emptyFile.append(contentsOf: EmbroideryDefines.END_OF_FILE)
            return emptyFile
        }

        for currentStitch in embroideryStream {
            let relativeX = Int(currentStitch.embroideryDimensions().x - previousStitch.embroideryDimensions().x)
            let relativeY = Int(currentStitch.embroideryDimensions().y - previousStitch.embroideryDimensions().y)

            DSTHeader.update(relativeX: relativeX,
                             relativeY: relativeY,
                             isColorChange: currentStitch.isColorChange)

            DSTStitches.append(contentsOf: StichDTSBytes(
                relativeX: relativeX,
                relativeY: relativeY,
                isJump: currentStitch.isJump,
                isColorChange: currentStitch.isColorChange))

            if currentStitch.isColorChange {
                DSTHeader.update(relativeX: 0, relativeY: 0, isColorChange: false)
                DSTStitches.append(contentsOf: StichDTSBytes(relativeX: 0, relativeY: 0, isJump: true))
                DSTHeader.update(relativeX: 0, relativeY: 0, isColorChange: false)
                DSTStitches.append(contentsOf: StichDTSBytes(relativeX: 0, relativeY: 0, isJump: true))
            }

            previousStitch = currentStitch
        }

        var DSTData = DSTHeader.toDSTData()
        DSTData.append(DSTStitches)
        DSTData.append(contentsOf: EmbroideryDefines.END_OF_FILE)

        return DSTData
    }

    func StichDTSBytes(relativeX: Int, relativeY: Int,
                       isJump: Bool = false, isColorChange: Bool = false) -> [UInt8] {

        var bytes: [UInt8] = [0x00, 0x00, 0x03]
        let xValue = byteFromConversionTable(position: relativeX)
        let yValue = byteFromConversionTable(position: relativeY)

        var yPart: UInt = 0
        var xPart: UInt = 0

        yPart |= ((yValue & 0x1) << 3)
        yPart |= ((yValue & 0x2) << 1)
        yPart |= ((yValue & 0x10) >> 3)
        yPart |= ((yValue & 0x20) >> 5)
        bytes[0] |= UInt8(yPart << 4)

        xPart |= ((xValue >> 2) & 0xC)
        xPart |= (xValue & 0x3)
        bytes[0] |= UInt8(xPart)

        yPart = 0
        xPart = 0

        yPart |= ((yValue & 0x4) << 1)
        yPart |= ((yValue & 0x8) >> 1)
        yPart |= ((yValue & 0x40) >> 5)
        yPart |= ((yValue & 0x80) >> 7)
        bytes[1] |= UInt8(yPart << 4)

        xPart |= ((xValue >> 4) & 0xC)
        xPart |= ((xValue >> 2) & 0x3)
        bytes[1] |= UInt8(xPart)

        yPart = 0
        xPart = 0

        yPart |= ((yValue >> 5) & 0x10)
        yPart |= ((yValue >> 3) & 0x20)
        bytes[2] |= UInt8(yPart)

        bytes[2] |= UInt8((xValue >> 6) & 0xC)

        if isColorChange {
            bytes[2] |= (0x3 << 6)
        } else if isJump {
            bytes[2] |= (0x1 << 7)
        }
        return bytes
    }

    func byteFromConversionTable(position: Int) -> UInt {
        guard position > -EmbroideryDefines.MAX_STITCHING_DISTANCE
                && position < EmbroideryDefines.MAX_STITCHING_DISTANCE
        else {
            fatalError("Embroidery Stream cannot be represented as DST")
        }
        return position < 0 ?
            EmbroideryDefines.CONVERSION_TABLE[(position * (-1)) + 121] :
            EmbroideryDefines.CONVERSION_TABLE[position]
    }
}
