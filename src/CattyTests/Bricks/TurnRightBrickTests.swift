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

final class TurnRightBrickTests: AbstractBrickTests {

    func testTurnRightBrick() {
        //[self turnRightWithInitialRotation:0 andRotation:20.0f];
        //[self turnRightWithInitialRotation:40 andRotation:60.0f];
        turnRight(withInitialRotation: 200, andRotation: 80.0)
    }

    func testTurnRightBrickOver360() {
        turnRight(withInitialRotation: 0, andRotation: 400.0)
        turnRight(withInitialRotation: -80, andRotation: 400.0)
    }

    func testTurnRightBrickNegative() {
        turnRight(withInitialRotation: 0, andRotation: -20.0)
        turnRight(withInitialRotation: -80, andRotation: -20.0)
        turnRight(withInitialRotation: -20, andRotation: -20.0)
    }

    func testTurnRightBrickNegativeOver360() {
        turnRight(withInitialRotation: 0, andRotation: -400.0)
        turnRight(withInitialRotation: -80, andRotation: -560.0)
        turnRight(withInitialRotation: -20, andRotation: -400.0)
    }

    func testTurnRightBrickWithoutRotation() {
        //[self turnRightWithInitialRotation:0 andRotation:0.0f];
        //[self turnRightWithInitialRotation:-80 andRotation:0.0f];
        //[self turnRightWithInitialRotation:-180 andRotation:0.0f];
        turnRight(withInitialRotation: -190, andRotation: 0.0)
        //[self turnRightWithInitialRotation:290 andRotation:0.0f];
    }

    func testTurnRightBrickWrongInput() {
        let object = SpriteObject()
        let spriteNode = CBSpriteNode(spriteObject: object)
        object.spriteNode = spriteNode
        spriteNode.catrobatRotation = 0.0

        let script = WhenScript()
        script.object = object

        let brick = TurnRightBrick()
        brick.script = script

        brick.degrees = Formula(string: "a")

        let action: () -> Void = brick.actionBlock(formulaInterpreter!)
        action()

        XCTAssertEqual(0.0, spriteNode.catrobatRotation, accuracy: 0.0001, "TurnRightBrick not correct")
    }

    func turnRight(withInitialRotation initialRotation: CGFloat, andRotation rotation: CGFloat) {
        let initialRotation = initialRotation
        let object = SpriteObject()
        let spriteNode = CBSpriteNode(spriteObject: object)
        object.spriteNode = spriteNode

        spriteNode.catrobatRotation = Double(initialRotation)

        let script = WhenScript()
        script.object = object

        let brick = TurnRightBrick()
        brick.script = script

        brick.degrees = Formula(float: Float(rotation))

        let action: () -> Void = brick.actionBlock(formulaInterpreter!)
        action()
    }
}
