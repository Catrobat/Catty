/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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

class SpriteKitDefines: NSObject {

    static let defaultFont = "Helvetica"
    static let defaultLabelFontSize = Float(45.0)

    static let bubbleBrickNodeName = "textBubble"

    static let defaultCatrobatPenSize = CGFloat(3.15)
    static let defaultPenZPosition = CGFloat(0)
    static let defaultPenColor = UIColor(red: 0, green: 0, blue: 255)
    static let penShapeNodeName = "penShapeNode"
    static let stampedSpriteNodeName = "stampedSpriteNode"

    static let defaultValueShowVariable = "0"

    static let defaultRotationStyle = RotationStyle.allAround
    @objc static let avCaptureDeviceType = AVCaptureDevice.DeviceType.builtInWideAngleCamera
}
