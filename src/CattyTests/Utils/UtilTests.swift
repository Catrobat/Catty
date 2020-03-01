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

final class UtilTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func testScreenSize() {
        let screenSizeInPoints = UIScreen.main.bounds.size
        let screenSizeInPixel = mainScreenSizeInPixel()

        XCTAssertEqual(screenSizeInPoints, Util.screenSize(false))
        XCTAssertEqual(screenSizeInPixel, Util.screenSize(true))
        XCTAssertNotEqual(screenSizeInPixel, screenSizeInPoints)
    }

    func testScreenWidth() {
        let screenWidthInPoints = UIScreen.main.bounds.size.width
        let screenSizeInPixel = mainScreenSizeInPixel()

        XCTAssertEqual(screenWidthInPoints, Util.screenWidth())
        XCTAssertEqual(screenWidthInPoints, Util.screenWidth(false))
        XCTAssertEqual(screenSizeInPixel.width, Util.screenWidth(true))
        XCTAssertNotEqual(screenSizeInPixel.width, screenWidthInPoints)
    }

    func testScreenHeight() {
        let screenHeightInPoints = UIScreen.main.bounds.size.height
        let screenSizeInPixel = mainScreenSizeInPixel()

        XCTAssertEqual(screenHeightInPoints, Util.screenHeight())
        XCTAssertEqual(screenHeightInPoints, Util.screenHeight(false))
        XCTAssertEqual(screenSizeInPixel.height, Util.screenHeight(true))
        XCTAssertNotEqual(screenSizeInPixel.height, screenHeightInPoints)
    }

    private func mainScreenSizeInPixel() -> CGSize {
        var screenSizeInPixel = UIScreen.main.nativeBounds.size

        if UIScreen.main.bounds.height == CGFloat(kIphone6PScreenHeight) {
            let iPhonePlusDownsamplingFactor = CGFloat(1.15)
            screenSizeInPixel.height /= iPhonePlusDownsamplingFactor
            screenSizeInPixel.width /= iPhonePlusDownsamplingFactor
        }
        return screenSizeInPixel
    }
}
