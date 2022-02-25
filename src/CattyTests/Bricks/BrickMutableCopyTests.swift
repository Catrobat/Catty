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

 import XCTest

 @testable import Pocket_Code

 final class BrickMutableCopyTests: XCTestCase {

     func testMutableCopy() {
        let brick = PlaceAtBrick()
        brick.xPosition = Formula(integer: 111)
        brick.yPosition = Formula(integer: 999)
        let copiedBrick = brick.mutableCopy(with: CBMutableCopyContext(), andErrorReporting: true) as AnyObject

        XCTAssertTrue(brick.isEqual(to: copiedBrick as? Brick))
        XCTAssertFalse(brick === (copiedBrick as? Brick))

        XCTAssertFalse(brick.xPosition.isEqual(to: brick.yPosition))
        XCTAssertTrue(brick.xPosition.isEqual(to: copiedBrick.xPosition))
        XCTAssertFalse(brick.xPosition === copiedBrick.xPosition)
        XCTAssertTrue(brick.yPosition.isEqual(to: copiedBrick.yPosition))
        XCTAssertFalse(brick.yPosition === copiedBrick.yPosition)
    }

     func testMutableCopyForBool() {
        let brick = WaitBrick()
        brick.timeToWaitInSeconds = Formula(integer: 1)
        brick.isAnimated = true
        brick.isAnimatedInsertBrick = false
        let copiedBrick = brick.mutableCopy(with: CBMutableCopyContext(), andErrorReporting: true) as AnyObject

        XCTAssertTrue(brick.isEqual(to: copiedBrick as? Brick))

        XCTAssertFalse(brick === copiedBrick as? Brick)
        XCTAssertEqual(brick.isAnimated, copiedBrick.isAnimated)
        XCTAssertEqual(brick.isAnimatedInsertBrick, copiedBrick.isAnimatedInsertBrick)

         brick.isAnimatedInsertBrick = true
        XCTAssertNotEqual(brick.isAnimatedInsertBrick, copiedBrick.isAnimatedInsertBrick)
    }
}
