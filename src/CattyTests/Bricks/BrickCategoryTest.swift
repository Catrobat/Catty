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

import XCTest

@testable import Pocket_Code

final class BrickCategoryTest: XCTestCase {

    func testDisabledColorOfCategory() {
        //controlBrickColor
        let color = UIColor(red: 255.0 / 255.0, green: 120.0 / 255.0, blue: 20.0 / 255.0, alpha: 1.0)
        let colorComponents: [CGFloat] = color.cgColor.components!
        let expectedDisabledGray: CGFloat = (colorComponents[0] + colorComponents[1] + colorComponents[2]) / 3
        let expectedDisabledColor = UIColor(red: expectedDisabledGray, green: expectedDisabledGray, blue: expectedDisabledGray, alpha: 1.0)

        let category = BrickCategory(type: kBrickCategoryType.controlBrick,
                                     name: kLocalizedCategoryControl,
                                     color: UIColor.controlBrickOrange,
                                     strokeColor: UIColor.controlBrickStroke)

        XCTAssertEqual(expectedDisabledColor, category.colorDisabled())
    }

    func testDisabledStrokeColorOfCategory() {
        //controlBrickStrokeColor
        let strokeColor = UIColor(red: 247.0 / 255.0, green: 208.0 / 255.0, blue: 187.0 / 255.0, alpha: 1.0)
        let strokeColorComponents: [CGFloat] = strokeColor.cgColor.components!
        let expectedDisabledStrokeGray: CGFloat = (strokeColorComponents[0] + strokeColorComponents[1] + strokeColorComponents[2]) / 3
        let expectedDisabledStrokeColor = UIColor(red: expectedDisabledStrokeGray, green: expectedDisabledStrokeGray, blue: expectedDisabledStrokeGray, alpha: 1.0)

        let category = BrickCategory(type: kBrickCategoryType.controlBrick,
                                     name: kLocalizedCategoryControl,
                                     color: UIColor.controlBrickOrange,
                                     strokeColor: UIColor.controlBrickStroke)

        XCTAssertEqual(expectedDisabledStrokeColor, category.strokeColorDisabled())
    }
}
