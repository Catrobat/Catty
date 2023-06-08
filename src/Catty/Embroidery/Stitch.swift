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

class Stitch: Equatable {
    let x: CGFloat
    let y: CGFloat
    let isJump: Bool
    var isColorChange = false
    var isInterpolated = false
    var isDrawn = false
    var color: UIColor

    init<T: BinaryInteger>(x: T, y: T, asJump isJump: Bool = false, isInterpolated: Bool = false) {
        self.x = CGFloat(x)
        self.y = CGFloat(y)
        self.isJump = isJump
        self.isInterpolated = isInterpolated
        self.color = SpriteKitDefines.defaultStitchingColor
    }

    init<T: BinaryFloatingPoint>(x: T, y: T, withColor: UIColor = SpriteKitDefines.defaultStitchingColor, asJump isJump: Bool = false, isInterpolated: Bool = false) {
        self.x = CGFloat(x)
        self.y = CGFloat(y)
        self.isJump = isJump
        self.isInterpolated = isInterpolated
        self.color = withColor
    }

    convenience init(atPosition pos: CGPoint, withColor: UIColor = SpriteKitDefines.defaultStitchingColor, asJump isJump: Bool = false, isInterpolated: Bool = false) {
        self.init(x: pos.x, y: pos.y, withColor: withColor, asJump: isJump, isInterpolated: isInterpolated)
    }

    static func == (lhs: Stitch, rhs: Stitch) -> Bool {
        lhs.x == rhs.x && lhs.y == rhs.y && lhs.isJump == rhs.isJump
        && lhs.isColorChange == rhs.isColorChange
    }

    func embroideryDimensions() -> CGPoint {
        CGPoint(x: (x * 2).rounded(), y: (y * 2).rounded())
    }

    func maxDistanceInEmbroideryDimensions(stitch: Stitch) -> Int {
        let delta_x = abs(stitch.embroideryDimensions().x - self.embroideryDimensions().x)
        let delta_y = abs(stitch.embroideryDimensions().y - self.embroideryDimensions().y)
        return Int(max(delta_x, delta_y))
    }

    func getPosition() -> CGPoint {
        CGPoint(x: self.x, y: self.y)
    }

    func setColor(color: UIColor) {
        self.color = color
    }

    func getColor() -> UIColor {
        self.color
    }
}
