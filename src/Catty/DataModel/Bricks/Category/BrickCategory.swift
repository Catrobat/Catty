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

@objc public class BrickCategory: NSObject {

    @objc public let type: kBrickCategoryType
    @objc public let name: String
    @objc public let color: UIColor
    @objc public let strokeColor: UIColor

    init(type: kBrickCategoryType, name: String, color: UIColor, strokeColor: UIColor) {
        self.type = type
        self.name = name
        self.color = color
        self.strokeColor = strokeColor
    }

    @objc public func colorDisabled() -> UIColor {
        getGrayScaleFromColor(color: self.color)
    }

    @objc public func strokeColorDisabled() -> UIColor {
        getGrayScaleFromColor(color: self.strokeColor)
    }

    fileprivate func getGrayScaleFromColor(color: UIColor) -> UIColor {
        let colorComponents: [CGFloat] = color.cgColor.components!
        let gray: CGFloat = (colorComponents[0] + colorComponents[1] + colorComponents[2]) / 3
        return UIColor(red: gray, green: gray, blue: gray, alpha: 1.0)
    }
}
