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

final class TurnLeftBrickTests: AbstractBrickTest {

    func testTurnLeftBrick() {
        turnLeft(initialRotation: 90, rotation: 60)
        turnLeft(initialRotation: 0, rotation: 60)
        turnLeft(initialRotation: 90, rotation: 400)
    }

    func futestTurnLeftBrickNegative() {
        turnLeft(initialRotation: 90, rotation: -60)
    }

    func testTurnLeftBrickNegativeOver360() {
        turnLeft(initialRotation: 90, rotation: -400)
    }

    private func turnLeft(initialRotation: Double, rotation: Double) {
        let object = SpriteObject()
        let scene = Scene(name: "testScene")
        object.scene = scene
        object.name = "testname"
        let spriteNode = CBSpriteNode.init(spriteObject: object)
        object.spriteNode = spriteNode

        spriteNode.catrobatRotation = initialRotation

        let script = WhenScript()
        script.object = object

        let brick = TurnLeftBrick()
        brick.script = script

        brick.degrees = Formula(double: rotation)

        let action = brick.actionBlock(self.formulaInterpreter)
        action()

        let expectedRawRotation = RotationSensor.convertToRaw(userInput: initialRotation - rotation, for: object)
        XCTAssertEqual(CGFloat(expectedRawRotation), spriteNode.zRotation, accuracy: 0.0001, "TurnLeftBrick not correct")
    }

    func testGetFormulas() {
        let brick = TurnLeftBrick()
        brick.degrees = Formula(double: 1)
        var formulas = brick.getFormulas()

        XCTAssertEqual(formulas?.count, 1)
        XCTAssertEqual(brick.degrees, formulas?[0])

        brick.degrees = Formula(double: 22)
        formulas = brick.getFormulas()

        XCTAssertEqual(brick.degrees, formulas?[0])
    }

    func testMutableCopy() {
        let brick = TurnLeftBrick()
        brick.degrees = Formula(double: 2)

        let copiedBrick: TurnLeftBrick = brick.mutableCopy(with: CBMutableCopyContext(), andErrorReporting: true) as! TurnLeftBrick

        XCTAssertTrue(brick.isEqual(to: copiedBrick))
        XCTAssertFalse(brick === copiedBrick)
        XCTAssertTrue(brick.degrees.isEqual(to: copiedBrick.degrees))
        XCTAssertFalse(brick.degrees === copiedBrick.degrees)
    }
}
