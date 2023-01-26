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

final class RepeatBrickTests: XCTestCase {

    func testCondition() {
        let interpreter = FormulaManager(stageSize: CGSize.zero, landscapeMode: false)
        let repeatBrick = RepeatBrick()
        let script = Script()
        let object = SpriteObject()
        let scene = Scene(name: "testScene")
        object.scene = scene

        script.object = object
        repeatBrick.script = script

        repeatBrick.timesToRepeat = Formula(double: 2)
        XCTAssertEqual(0, repeatBrick.repetitions)

        XCTAssertTrue(repeatBrick.checkCondition(formulaInterpreter: interpreter))
        XCTAssertEqual(1, repeatBrick.repetitions)

        XCTAssertTrue(repeatBrick.checkCondition(formulaInterpreter: interpreter))
        XCTAssertEqual(2, repeatBrick.repetitions)

        XCTAssertFalse(repeatBrick.checkCondition(formulaInterpreter: interpreter))
    }

    func testConditionInterpretOnce() {
        let interpreter = FormulaManager(stageSize: CGSize.zero, landscapeMode: false)
        let repeatBrick = RepeatBrick()
        let script = Script()
        let object = SpriteObject()
        let scene = Scene(name: "testScene")
        object.scene = scene

        script.object = object
        repeatBrick.script = script

        repeatBrick.timesToRepeat = Formula(double: 1)
        XCTAssertTrue(repeatBrick.checkCondition(formulaInterpreter: interpreter))
        XCTAssertEqual(1, repeatBrick.repetitions)

        repeatBrick.timesToRepeat = Formula(double: 10)
        XCTAssertFalse(repeatBrick.checkCondition(formulaInterpreter: interpreter))
    }

    func testResetCondition() {
        let repeatBrick = RepeatBrick()
        repeatBrick.repetitions = 2
        repeatBrick.maxRepetitions = 10

        repeatBrick.resetCondition()
        XCTAssertEqual(0, repeatBrick.repetitions)
        XCTAssertNil(repeatBrick.maxRepetitions)
    }

    func testMutableCopy() {
        let interpreter = FormulaManager(stageSize: CGSize.zero, landscapeMode: false)

        let brick = RepeatBrick()
        let script = Script()
        let object = SpriteObject()
        let scene = Scene(name: "testScene")
        object.scene = scene

        script.object = object
        brick.script = script
        brick.timesToRepeat = Formula(double: 2)

        XCTAssertTrue(brick.checkCondition(formulaInterpreter: interpreter))

        let copiedBrick: RepeatBrick = brick.mutableCopy(with: CBMutableCopyContext()) as! RepeatBrick

        XCTAssertTrue(brick.isEqual(to: copiedBrick))
        XCTAssertFalse(brick === copiedBrick)
        XCTAssertTrue(brick.timesToRepeat.isEqual(to: copiedBrick.timesToRepeat))
        XCTAssertFalse(brick.timesToRepeat === copiedBrick.timesToRepeat)
    }

    func testGetFormulas() {
        let brick = RepeatBrick()
        let script = Script()
        let object = SpriteObject()
        let scene = Scene(name: "testScene")
        object.scene = scene

        script.object = object
        brick.script = script
        brick.timesToRepeat = Formula(double: 1)
        var formulas = brick.getFormulas()

        XCTAssertTrue(brick.timesToRepeat.isEqual(to: formulas?[0]))
        XCTAssertTrue(brick.timesToRepeat.isEqual(to: Formula(float: 1)))
        XCTAssertFalse(brick.timesToRepeat.isEqual(to: Formula(float: 22)))

        brick.timesToRepeat = Formula(float: 22)
        formulas = brick.getFormulas()

        XCTAssertTrue(brick.timesToRepeat.isEqual(to: formulas?[0]))
        XCTAssertTrue(brick.timesToRepeat.isEqual(to: Formula(float: 22)))
        XCTAssertFalse(brick.timesToRepeat.isEqual(to: Formula(float: 1)))
    }

}
