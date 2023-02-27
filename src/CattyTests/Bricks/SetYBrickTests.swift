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

final class SetYBrickTests: AbstractBrickTest {

    var brick: SetYBrick!
    var spriteNode: CBSpriteNode!
    var object: SpriteObject!
    var script: WhenScript!

    override func setUp() {
        super.setUp()
        object = SpriteObject()
        let scene = Scene(name: "testScene")
        object.scene = scene
        spriteNode = CBSpriteNode(spriteObject: object)
        object.spriteNode = spriteNode

        self.stage.addChild(spriteNode)
        spriteNode.catrobatPosition = CBPosition(x: 0, y: 0)

        script = WhenScript()
        script.object = object

        brick = SetYBrick()
        brick.script = script

    }

    func testSetYBrickPositive() {
        brick.yPosition = Formula(integer: 20)

        let action = brick.actionBlock(self.formulaInterpreter)
        action()

        XCTAssertEqual(spriteNode.catrobatPosition.y, 20.0, "SetyBrick is not correctly calculated")
    }

    func testSetYBrickNegative() {
        brick.yPosition = Formula(integer: -20)

        let action = brick.actionBlock(self.formulaInterpreter)
        action()

        XCTAssertEqual(spriteNode.catrobatPosition.y, -20.0, "SetyBrick is not correctly calculated")
    }

    func testSetYBrickOutOfRange() {
        brick.yPosition = Formula(integer: 50000)

        let action = brick.actionBlock(self.formulaInterpreter)
        action()

        XCTAssertEqual(spriteNode.catrobatPosition.y, 50000.0, "SetyBrick is not correctly calculated")
    }

    func testSetYBrickWrongInput() {
        brick.yPosition = Formula(string: "a")

        let action = brick.actionBlock(self.formulaInterpreter)
        action()

        XCTAssertEqual(spriteNode.catrobatPosition.y, 0.0, "SetyBrick is not correctly calculated")
    }

    func testGetFormulas() {
        brick.yPosition = Formula(integer: 1)
        var formulas = brick.getFormulas()

        XCTAssertEqual(formulas?.count, 1)
        XCTAssertEqual(brick.yPosition, formulas?[0])

        brick.yPosition = Formula(integer: 22)
        formulas = brick.getFormulas()

        XCTAssertEqual(brick.yPosition, formulas?[0])
    }

    func testMutableCopy() {
        brick.yPosition = Formula(double: 2.0)

        let copiedBrick: SetYBrick = brick.mutableCopy(with: CBMutableCopyContext(), andErrorReporting: true) as! SetYBrick

        XCTAssertTrue(brick.isEqual(to: copiedBrick))
        XCTAssertFalse(brick === copiedBrick)
        XCTAssertTrue(brick.yPosition.isEqual(to: copiedBrick.yPosition))
        XCTAssertFalse(brick.yPosition === copiedBrick.yPosition)
    }
}
