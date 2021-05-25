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

import XCTest

@testable import Pocket_Code

final class ThinkForBubbleBrickTests: XCTestCase {

    var brick: ThinkForBubbleBrick!

    override func setUp() {
        super.setUp()
        brick = ThinkForBubbleBrick()
    }

    func testGetFormulas() {
        brick.intFormula = Formula(integer: 1)
        brick.stringFormula = Formula(string: "Hello World")
        var formulas = brick.getFormulas()

        XCTAssertEqual(formulas?.count, 2)
        XCTAssertEqual(brick.intFormula, formulas?[1])
        XCTAssertEqual(brick.stringFormula, formulas?[0])

        brick.intFormula = Formula(integer: 22)
        brick.stringFormula = Formula(string: "World Hello")
        formulas = brick.getFormulas()

        XCTAssertEqual(brick.intFormula, formulas?[1])
        XCTAssertEqual(brick.stringFormula, formulas?[0])
    }
}
