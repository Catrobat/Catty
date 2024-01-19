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

final class SetTempoToBrickTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func testIsEqual() {
        let brickA = SetTempoToBrick()
        brickA.setFormula(Formula(integer: 50), forLineNumber: 0, andParameterNumber: 0)

        let brickB = SetTempoToBrick()
        brickB.setFormula(Formula(integer: 50), forLineNumber: 0, andParameterNumber: 0)

        XCTAssertTrue(brickA.isEqual(to: brickB))
    }

    func testIsEqualDifferentTempo() {
        let brickA = SetTempoToBrick()
        brickA.setFormula(Formula(integer: 70), forLineNumber: 0, andParameterNumber: 0)

        let brickB = SetTempoToBrick()
        brickB.setFormula(Formula(integer: 80), forLineNumber: 0, andParameterNumber: 0)

        XCTAssertFalse(brickA.isEqual(to: brickB))
    }

    func testMutableCopy() {
        let brick = SetTempoToBrick()
        brick.setFormula(Formula(integer: 80), forLineNumber: 0, andParameterNumber: 0)

        let copiedBrick: SetTempoToBrick = brick.mutableCopy(with: CBMutableCopyContext()) as! SetTempoToBrick

        XCTAssertTrue(brick.isEqual(to: copiedBrick))
        XCTAssertFalse(brick === copiedBrick)
        XCTAssertEqual(brick.getFormulas(), copiedBrick.getFormulas())

    }

    func testDefaultValue() {
        let brick = SetTempoToBrick()
        XCTAssertTrue(brick.formula(forLineNumber: 0, andParameterNumber: 0).isEqual(to: Formula(integer: 60)))
    }
}
