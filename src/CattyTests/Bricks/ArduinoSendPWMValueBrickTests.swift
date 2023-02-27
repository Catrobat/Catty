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

import XCTest

@testable import Pocket_Code

final class ArduinoSendPWMValueBrickTests: XCTestCase {

    override func tearDown() {
        UserDefaults.standard.set(false, forKey: kUseArduinoBricks)
    }

    func testGetFormulas() {
        let brick = ArduinoSendPWMValueBrick()

        brick.pin = Formula(float: 1)
        brick.value = Formula(float: 0)
        var formulas = brick.getFormulas()

        let pinIndex = 0
        let valueIndex = 1

        XCTAssertTrue(brick.pin.isEqual(to: formulas?[pinIndex]))
        XCTAssertTrue(brick.value.isEqual(to: formulas?[valueIndex]))
        XCTAssertTrue(brick.pin.isEqual(to: Formula(float: 1)))
        XCTAssertTrue(brick.value.isEqual(to: Formula(float: 0)))
        XCTAssertFalse(brick.pin.isEqual(to: Formula(float: 5)))
        XCTAssertFalse(brick.value.isEqual(to: Formula(float: 1)))

        brick.pin = Formula(float: 5)
        formulas = brick.getFormulas()

        XCTAssertTrue(brick.pin.isEqual(to: formulas?[pinIndex]))
        XCTAssertTrue(brick.value.isEqual(to: formulas?[valueIndex]))
        XCTAssertTrue(brick.pin.isEqual(to: Formula(float: 5)))
        XCTAssertTrue(brick.value.isEqual(to: Formula(float: 0)))
        XCTAssertFalse(brick.pin.isEqual(to: Formula(float: 1)))
        XCTAssertFalse(brick.value.isEqual(to: Formula(float: 1)))

        brick.value = Formula(float: 1)
        formulas = brick.getFormulas()

        XCTAssertTrue(brick.pin.isEqual(to: formulas?[pinIndex]))
        XCTAssertTrue(brick.value.isEqual(to: formulas?[valueIndex]))
        XCTAssertTrue(brick.pin.isEqual(to: Formula(float: 5)))
        XCTAssertTrue(brick.value.isEqual(to: Formula(float: 1)))
        XCTAssertFalse(brick.pin.isEqual(to: Formula(float: 1)))
        XCTAssertFalse(brick.value.isEqual(to: Formula(float: 0)))
    }
}
