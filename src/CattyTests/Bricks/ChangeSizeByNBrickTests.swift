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

final class ChangeSizeByNBrickTests: AbstractBrickTest {

    var brick: ChangeSizeByNBrick!
    var spriteNode: CBSpriteNode!
    var project: Project!
    var object: SpriteObject!
    var script: WhenScript!

    override func setUp() {
        super.setUp()
        let scene = Scene(name: "testScene")
        object = SpriteObject()
        object.scene = scene
        spriteNode = CBSpriteNode(spriteObject: object)
        object.spriteNode = spriteNode
        script = WhenScript()
        script.object = object
        brick = ChangeSizeByNBrick()
        brick.script = script
    }

    func testChangeSizeByNBrickPositive() {
        spriteNode.catrobatSize = 10.0
        brick.size = Formula(integer: 30)

        let action = brick.actionBlock(self.formulaInterpreter)
        action()

        XCTAssertEqual(40.0, spriteNode.catrobatSize, accuracy: 0.0001, "Size not correct")
    }

    func testChangeSizeByNBrickNegative() {
        spriteNode.catrobatSize = 50.0
        brick.size = Formula(integer: -30)

        let action = brick.actionBlock(self.formulaInterpreter)
        action()

        XCTAssertEqual(20.0, spriteNode.catrobatSize, accuracy: 0.0001, "Size not correct")
    }

    func testChangeSizeByNBrickWrongInput() {
        spriteNode.catrobatSize = 10.0
        brick.size = Formula(string: "a")

        let action = brick.actionBlock(self.formulaInterpreter)
        action()

        XCTAssertEqual(10.0, spriteNode.catrobatSize, accuracy: 0.0001, "Size not correct")
    }

    func testMutableCopy() {
        brick.size = Formula(integer: -50)

        let copiedBrick: ChangeSizeByNBrick = brick.mutableCopy(with: CBMutableCopyContext(), andErrorReporting: true) as! ChangeSizeByNBrick

        XCTAssertTrue(brick.isEqual(to: copiedBrick))
        XCTAssertFalse(brick === copiedBrick)

        XCTAssertTrue(brick.size.isEqual(to: copiedBrick.size))
        XCTAssertFalse(brick.size === copiedBrick.size)
    }

    func testGetFormulas() {
        brick.size = Formula(integer: 1)
        var formulas = brick.getFormulas()

        XCTAssertEqual(formulas?.count, 1)
        XCTAssertEqual(brick.size, formulas?[0])

        brick.size = Formula(integer: 22)
        formulas = brick.getFormulas()

        XCTAssertEqual(brick.size, formulas?[0])
    }
}
