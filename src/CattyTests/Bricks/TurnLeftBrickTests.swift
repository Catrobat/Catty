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

final class TurnLeftBrickTests: AbstractBrickTests {

    func testTurnLeftBrick() {
        turnLeft(withInitialRotation: 90, andRotation: 60)
        turnLeft(withInitialRotation: 0, andRotation: 60)
        turnLeft(withInitialRotation: 90, andRotation: 400)
    }

    func testTurnLeftBrickNegative() {
        turnLeft(withInitialRotation: 90, andRotation: -60)
    }

    func testTurnLeftBrickNegativeOver360() {
        turnLeft(withInitialRotation: 90, andRotation: -400)
    }

    func turnLeft(withInitialRotation initialRotation: CGFloat, andRotation rotation: CGFloat) {
        let object = SpriteObject()
        let spriteNode = CBSpriteNode(spriteObject: object)
        object.spriteNode = spriteNode

        spriteNode.catrobatRotation = Double(initialRotation)

        let script = WhenScript()
        script.object = object

        let brick = TurnLeftBrick()
        brick.script = script

        brick.degrees = Formula(float: Float(rotation))

        let action: () -> Void = brick.actionBlock(formulaInterpreter!)
        action()

        let expectedRawRotation = RotationSensor.convertToRaw(userInput: Double(initialRotation - rotation), for: object)
        XCTAssertEqual(expectedRawRotation, Double(spriteNode.zRotation), accuracy: 0.0001, "TurnLeftBrick not correct")
    }
}
