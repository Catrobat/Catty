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

final class TurnRightBrickTests: AbstractBrickTest {

    var brick: TurnRightBrick!
    var spriteNode: CBSpriteNode!
    var object: SpriteObject!
    var script: WhenScript!

    func testTurnRightBrick() {
        turnRight(initialRotation: 200.0, rotation: 80.0)
    }

    func testTurnRightBrickOver360() {
        turnRight(initialRotation: 0, rotation: 400.0)
        turnRight(initialRotation: -80, rotation: 400.0)
    }

    func testTurnRightBrickNegative() {
        turnRight(initialRotation: 0, rotation: -20.0)
        turnRight(initialRotation: -80, rotation: -20.0)
        turnRight(initialRotation: -20, rotation: -20.0)
    }

    func testTurnRightBrickNegativeOver360() {
        turnRight(initialRotation: 0, rotation: -400.0)
        turnRight(initialRotation: -80, rotation: -560.0)
        turnRight(initialRotation: -20, rotation: -400.0)
    }

    func testTurnRightBrickWithoutRotation() {
        turnRight(initialRotation: -190, rotation: 0.0)
    }

    func testTurnRightBrickWrongInput() {
        initialiseTestData()
        spriteNode.catrobatRotation = 0.0
        brick.degrees = Formula(string: "a")

        let action = brick.actionBlock(self.formulaInterpreter)
        action()

        XCTAssertEqual(0.0, spriteNode.catrobatRotation, accuracy: 0.0001, "TurnRightBrick not correct")
    }

    private func turnRight(initialRotation: Double, rotation: Double) {
        initialiseTestData()
        spriteNode.catrobatRotation = initialRotation
        brick.degrees = Formula(double: rotation)

        let action = brick.actionBlock(self.formulaInterpreter)
        action()

        var initial = initialRotation
        if initial > 180.0 {
            initial -= 360.0
        } else if initial < -180.0 {
            initial += 360.0
        }

        let expectedRawRotation = RotationSensor.convertToRaw(userInput: initial + rotation, for: object)
        XCTAssertEqual(CGFloat(expectedRawRotation), spriteNode.zRotation, accuracy: 0.0001, "TurnRightBrick not correct")
    }

    private func initialiseTestData() {
        object = SpriteObject()
        let scene = Scene(name: "testScene")
        object.scene = scene
        object.name = "testname"
        spriteNode = CBSpriteNode.init(spriteObject: object)
        object.spriteNode = spriteNode

        script = WhenScript()
        script.object = object

        brick = TurnRightBrick()
        brick.script = script
    }

    func testGetFormulas() {
        initialiseTestData()
        brick.degrees = Formula(double: 1)
        var formulas = brick.getFormulas()

        XCTAssertEqual(formulas?.count, 1)
        XCTAssertEqual(brick.degrees, formulas?[0])

        brick.degrees = Formula(double: 22)
        formulas = brick.getFormulas()

        XCTAssertEqual(brick.degrees, formulas?[0])
    }

    func testMutableCopy() {
        initialiseTestData()
        brick.degrees = Formula(double: 2.0)

        let copiedBrick: TurnRightBrick = brick.mutableCopy(with: CBMutableCopyContext(), andErrorReporting: true) as! TurnRightBrick

        XCTAssertTrue(brick.isEqual(to: copiedBrick))
        XCTAssertFalse(brick === copiedBrick)
        XCTAssertTrue(brick.degrees.isEqual(to: copiedBrick.degrees))
        XCTAssertFalse(brick.degrees === copiedBrick.degrees)
    }
}
