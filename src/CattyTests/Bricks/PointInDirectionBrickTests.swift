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

final class PointInDirectionBrickTests: AbstractBrickTest {

    func testPointInDirectionBrick() {
        let object = SpriteObject()
        let scene = Scene(name: "testScene")
        object.scene = scene
        let spriteNode = CBSpriteNode(spriteObject: object)
        object.spriteNode = spriteNode

        self.stage.addChild(spriteNode)
        spriteNode.catrobatPosition = CBPosition(x: 0, y: 0)

        let script = WhenScript()
        script.object = object

        let brick = PointInDirectionBrick()
        brick.script = script
        brick.degrees = Formula(integer: 20)

        let action = brick.actionBlock(self.formulaInterpreter)
        action()

        XCTAssertEqual(20.0, spriteNode.catrobatRotation, accuracy: 0.0001, "PointInDirectionBrick is not correctly calculated")
    }

    func testMutableCopy() {
        let brick = PointInDirectionBrick()
        brick.degrees = Formula(double: 270)

        let copiedBrick: PointInDirectionBrick = brick.mutableCopy(with: CBMutableCopyContext(), andErrorReporting: true) as! PointInDirectionBrick

        XCTAssertTrue(brick.isEqual(to: copiedBrick))
        XCTAssertFalse(brick === copiedBrick)

        XCTAssertTrue(brick.degrees.isEqual(to: copiedBrick.degrees))
        XCTAssertFalse(brick.degrees === copiedBrick.degrees)
    }

    func testGetFormulas() {
        let brick = PointInDirectionBrick()
        brick.degrees = Formula(double: 1)
        var formulas = brick.getFormulas()

        XCTAssertEqual(formulas?.count, 1)
        XCTAssertEqual(brick.degrees, formulas?[0])

        brick.degrees = Formula(double: 22)
        formulas = brick.getFormulas()

        XCTAssertEqual(brick.degrees, formulas?[0])
    }
}
