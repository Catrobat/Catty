/**
 *  Copyright (C) 2010-2024 The Catrobat Team
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

class UIColorExtensionTests: XCTestCase {

    func testRGBComponentProperties() {

        let testColor1 = UIColor(red: 123, green: 0, blue: 102)
        let testColor2 = UIColor(red: 0.3, green: 0.1, blue: 0.7, alpha: 1.0)
        let testColor3 = UIColor(red: 500, green: 750, blue: 1000)
        let testColor4 = UIColor(red: -150, green: -200, blue: -102)

        let largeNumber = CGFloat.greatestFiniteMagnitude
        let testColor5 = UIColor(red: largeNumber, green: largeNumber, blue: largeNumber, alpha: 1.0)

        let smallNumber = -1 * CGFloat.greatestFiniteMagnitude
        let testColor6 = UIColor(red: smallNumber, green: smallNumber, blue: smallNumber, alpha: 1.0)

        XCTAssertEqual(testColor1.redComponent, 123)
        XCTAssertEqual(testColor1.greenComponent, 0)
        XCTAssertEqual(testColor1.blueComponent, 102)

        XCTAssertEqual(testColor2.redComponent, 76)
        XCTAssertEqual(testColor2.greenComponent, 25)
        XCTAssertEqual(testColor2.blueComponent, 178)

        XCTAssertEqual(testColor3.redComponent, 500)
        XCTAssertEqual(testColor3.greenComponent, 750)
        XCTAssertEqual(testColor3.blueComponent, 1000)

        XCTAssertEqual(testColor4.redComponent, -150)
        XCTAssertEqual(testColor4.greenComponent, -200)
        XCTAssertEqual(testColor4.blueComponent, -102)

        XCTAssertEqual(testColor5.redComponent, Int.max)
        XCTAssertEqual(testColor5.greenComponent, Int.max)
        XCTAssertEqual(testColor5.blueComponent, Int.max)

        XCTAssertEqual(testColor6.redComponent, Int.min)
        XCTAssertEqual(testColor6.greenComponent, Int.min)
        XCTAssertEqual(testColor6.blueComponent, Int.min)
    }

}
