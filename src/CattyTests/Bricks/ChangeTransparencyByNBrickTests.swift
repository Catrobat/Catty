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

final class ChangeTransparencyByNBrickTests: AbstractBrickTest {

    var brick: ChangeTransparencyByNBrick!
    var spriteNode: CBSpriteNode!
    var project: Project!
    var object: SpriteObject!
    var script: WhenScript!
    var formulaTree: FormulaElement!

    override func setUp() {
        super.setUp()
        object = SpriteObject()
        spriteNode = CBSpriteNode(spriteObject: object)
        object.spriteNode = spriteNode
        self.scene.addChild(spriteNode)

        let transparency = Formula()
        formulaTree = FormulaElement()
        formulaTree.type = ElementType.NUMBER
        transparency.formulaTree = formulaTree
        script = WhenScript()
        script.object = object
        brick = ChangeTransparencyByNBrick()
        brick.script = script
        brick.changeTransparency = transparency
    }

    func testChangeTransparencyByNBrickPositive() {
        spriteNode.catrobatTransparency = 0.0
        formulaTree.value = "20"

        let action = brick.actionBlock(self.formulaInterpreter)
        action()

        XCTAssertEqual(20.0, spriteNode.catrobatTransparency, accuracy: 0.01, "ChangeTransparencyBrick is not correctly calculated")
    }

    func testChangeTransparencyByNBrickNegative() {
        spriteNode.catrobatTransparency = 30.0
        formulaTree.value = "-20"

        let action = brick.actionBlock(self.formulaInterpreter)
        action()

        XCTAssertEqual(10.0, spriteNode.catrobatTransparency, accuracy: 0.01, "ChangeTransparencyBrick is not correctly calculated")
    }

    func testChangeTransparencyByNBrickOutOfRange() {
        spriteNode.catrobatTransparency = 0.0

        formulaTree.value = "150"

        let action = brick.actionBlock(self.formulaInterpreter)
        action()

        XCTAssertEqual(100.0, spriteNode.catrobatTransparency, accuracy: 0.01, "ChangeTransparencyBrick is not correctly calculated")
    }

    func testChangeTransparencyByNBrickWrongInput() {
        spriteNode.catrobatTransparency = 0.0
        formulaTree.value = "a"

        let action = brick.actionBlock(self.formulaInterpreter)
        action()

        XCTAssertEqual(0.0, spriteNode.catrobatTransparency, accuracy: 0.01, "ChangeTransparencyBrick is not correctly calculated")
    }

    func testMutableCopy() {
        brick.changeTransparency = Formula(integer: -5)

        let copiedBrick: ChangeTransparencyByNBrick = brick.mutableCopy(with: CBMutableCopyContext(), andErrorReporting: true) as! ChangeTransparencyByNBrick

        XCTAssertTrue(brick.isEqual(to: copiedBrick))
        XCTAssertFalse(brick === copiedBrick)

        copiedBrick.changeTransparency = Formula(integer: 5)
        brick.changeTransparency = Formula(integer: 5)
        XCTAssertTrue(brick.changeTransparency.isEqual(to: copiedBrick.changeTransparency))
        XCTAssertFalse(brick.changeTransparency === copiedBrick.changeTransparency)
    }
}
