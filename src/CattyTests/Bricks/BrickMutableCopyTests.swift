/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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

final class BrickMutableCopyTests: XCTestCase {
    func testMutableCopy() {
        let brick = PlaceAtBrick()
        brick.xPosition = Formula(integer: 111)
        brick.yPosition = Formula(integer: 999)
        let copiedBrick: PlaceAtBrick? = (brick.mutableCopy(with: CBMutableCopyContext(), andErrorReporting: true) as! PlaceAtBrick)

        XCTAssertTrue(brick.isEqual(to: copiedBrick), "Bricks are not equal")
        XCTAssertFalse(brick.xPosition.isEqual(to: brick.yPosition), "Formulas for xPosition and xPosition are equal")
        XCTAssertTrue(brick.xPosition.isEqual(to: copiedBrick?.xPosition), "Formulas for xPosition are not equal")
        XCTAssertTrue(brick.yPosition.isEqual(to: copiedBrick?.yPosition), "Formulas for xPosition are not equal")
    }

    func testMutableCopyForBool() {
        let brick = WaitBrick()
        brick.timeToWaitInSeconds = Formula(integer: 1)
        brick.isAnimated = true
        brick.isAnimatedInsertBrick = false
        let copiedBrick: WaitBrick? = (brick.mutableCopy(with: CBMutableCopyContext(), andErrorReporting: true) as! WaitBrick)

        XCTAssertTrue(brick.isEqual(to: copiedBrick), "Bricks are not equal")
        XCTAssertEqual(brick.isAnimated, copiedBrick?.isAnimated, "BOOL animate is not equal")
        XCTAssertEqual(brick.isAnimatedInsertBrick, copiedBrick?.isAnimatedInsertBrick, "BOOL animateInsertBrick are not equal")

        brick.isAnimatedInsertBrick = true
        XCTAssertNotEqual(brick.isAnimatedInsertBrick, copiedBrick?.isAnimatedInsertBrick, "BOOL animateInsertBrick should not be equal")
    }
}
