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

final class GlideToBrickTests: XCTestCase {

    func testFormulaForLineNumber() {
        let brick = GlideToBrick()

        brick.durationInSeconds = Formula(double: 1)
        brick.xDestination = Formula(double: 1)
        brick.yDestination = Formula(double: 1)

        XCTAssertEqual(brick.durationInSeconds, brick.formula(forLineNumber: 0, andParameterNumber: 0))
        XCTAssertEqual(brick.xDestination, brick.formula(forLineNumber: 1, andParameterNumber: 0))
        XCTAssertEqual(brick.yDestination, brick.formula(forLineNumber: 1, andParameterNumber: 1))
    }

    func testMutableCopy() {
        let brick = GlideToBrick()

        brick.durationInSeconds = Formula(double: 1)
        brick.xDestination = Formula(double: 1)
        brick.yDestination = Formula(double: 1)

        let copiedBrick: GlideToBrick = brick.mutableCopy(with: CBMutableCopyContext(), andErrorReporting: true) as! GlideToBrick

        XCTAssertTrue(brick.isEqual(to: copiedBrick))
        XCTAssertFalse(brick === copiedBrick)

        XCTAssertTrue(brick.durationInSeconds.isEqual(to: copiedBrick.durationInSeconds))
        XCTAssertFalse(brick.durationInSeconds === copiedBrick.durationInSeconds)

        XCTAssertTrue(brick.xDestination.isEqual(to: copiedBrick.xDestination))
        XCTAssertFalse(brick.xDestination === copiedBrick.xDestination)

        XCTAssertTrue(brick.yDestination.isEqual(to: copiedBrick.yDestination))
        XCTAssertFalse(brick.yDestination === copiedBrick.yDestination)
    }

    func testGetFormulas() {
        let brick = GlideToBrick()
        let durationIndex = 0
        let xDestinationIndex = 1
        let yDestinationIndex = 2
        brick.durationInSeconds = Formula(double: 3)
        brick.xDestination = Formula(double: 2)
        brick.yDestination = Formula(double: 1)
        var formulas = brick.getFormulas()

        XCTAssertEqual(formulas?.count, 3)
        XCTAssertEqual(brick.durationInSeconds, formulas?[durationIndex])
        XCTAssertEqual(brick.xDestination, formulas?[xDestinationIndex])
        XCTAssertEqual(brick.yDestination, formulas?[yDestinationIndex])

        brick.durationInSeconds = Formula(double: 1)
        brick.xDestination = Formula(double: 2)
        brick.yDestination = Formula(double: 3)
        formulas = brick.getFormulas()

        XCTAssertEqual(brick.durationInSeconds, formulas?[durationIndex])
        XCTAssertEqual(brick.xDestination, formulas?[xDestinationIndex])
        XCTAssertEqual(brick.yDestination, formulas?[yDestinationIndex])
    }
}
