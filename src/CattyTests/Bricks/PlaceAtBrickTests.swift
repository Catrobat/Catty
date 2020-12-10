/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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

final class PlaceAtBrickTests: AbstractBrickTest {

    var object: SpriteObject!
    var brick: PlaceAtBrick!
    var spriteNode: CBSpriteNode!
    var script: Script!

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

        brick = PlaceAtBrick()
        brick.script = script

    }

    func testPlaceAtBrickPositive() {
        brick.yPosition = Formula(integer: 20)
        brick.xPosition = Formula(integer: 20)

        let action = brick.actionBlock(self.formulaInterpreter)
        action()

        let testPoint = CBPosition(x: 20, y: 20)
        XCTAssertEqual( testPoint, spriteNode.catrobatPosition, "PlaceAtBrick is not correctly calculated")
    }

    func testPlaceAtBrickNegative() {
        brick.yPosition = Formula(integer: -20)
        brick.xPosition = Formula(integer: -20)

        let action = brick.actionBlock(self.formulaInterpreter)
        action()

        let testPoint = CBPosition(x: -20, y: -20)
        XCTAssertEqual( testPoint, spriteNode.catrobatPosition, "PlaceAtBrick is not correctly calculated")
    }

    func testPlaceAtBrickOutOfRange() {
        brick.yPosition = Formula(integer: -20000)
        brick.xPosition = Formula(integer: -20000)

        let action = brick.actionBlock(self.formulaInterpreter)
        action()

        let testPoint = CBPosition(x: -20000, y: -20000)
        XCTAssertEqual( testPoint, spriteNode.catrobatPosition, "PlaceAtBrick is not correctly calculated")
    }

    func testPlaceAtBrickWrongInput() {
        let brick = PlaceAtBrick()
        brick.script = script
        brick.yPosition = Formula(string: "a")
        brick.xPosition = Formula(string: "a")

        let action = brick.actionBlock(self.formulaInterpreter)
        action()

        let testPoint = CBPosition(x: 0, y: 0)
        XCTAssertEqual(spriteNode.catrobatPosition, testPoint, "PlaceAtBrick is not correctly calculated")
    }

    func testMutableCopy() {
        brick.xPosition = Formula(double: 60)
        brick.yPosition = Formula(double: 60)

        let copiedBrick: PlaceAtBrick = brick.mutableCopy(with: CBMutableCopyContext(), andErrorReporting: true) as! PlaceAtBrick

        XCTAssertTrue(brick.isEqual(to: copiedBrick))
        XCTAssertFalse(brick === copiedBrick)

        XCTAssertTrue(brick.xPosition.isEqual(to: copiedBrick.xPosition))
        XCTAssertFalse(brick.xPosition === copiedBrick.xPosition)

        XCTAssertTrue(brick.yPosition.isEqual(to: copiedBrick.yPosition))
        XCTAssertFalse(brick.yPosition === copiedBrick.yPosition)
    }

    func testGetFormulas() {
        brick.xPosition = Formula(double: 1)
        brick.yPosition = Formula(double: 2)
        var formulas = brick.getFormulas()

        XCTAssertEqual(formulas?.count, 2)
        XCTAssertEqual(brick.xPosition, formulas?[0])
        XCTAssertEqual(brick.yPosition, formulas?[1])

        brick.xPosition = Formula(double: 22)
        brick.yPosition = Formula(double: 21)
        formulas = brick.getFormulas()

        XCTAssertEqual(brick.xPosition, formulas?[0])
        XCTAssertEqual(brick.yPosition, formulas?[1])
    }
}
