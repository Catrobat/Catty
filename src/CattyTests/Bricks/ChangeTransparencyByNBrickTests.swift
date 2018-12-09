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

final class ChangeTransparencyByNBrickTests: AbstractBrickTests {

    func testChangeTransparencyByNBrickPositive() {
        let object = SpriteObject()
        let spriteNode = CBSpriteNode(spriteObject: object)

        scene!.addChild(spriteNode)
        spriteNode.catrobatTransparency = 0.0

        let transparency = Formula()
        let formulaTree = FormulaElement()
        formulaTree.type = ElementType.NUMBER
        formulaTree.value = "20"
        transparency.formulaTree = formulaTree

        let script = WhenScript()
        script.object = object

        let brick = ChangeTransparencyByNBrick()
        brick.script = script
        brick.changeTransparency = transparency

        let action: () -> Void = brick.actionBlock(formulaInterpreter!)
        action()

        XCTAssertEqual(20.0,
                       spriteNode.catrobatTransparency,
                       accuracy: Double.epsilon,
                       "ChangeTransparencyBrick is not correctly calculated")
    }

    func testChangeTransparencyByNBrickNegative() {
        let object = SpriteObject()
        let spriteNode = CBSpriteNode(spriteObject: object)
        object.spriteNode = spriteNode

        scene!.addChild(spriteNode)
        spriteNode.catrobatTransparency = 30.0

        let transparency = Formula()
        let formulaTree = FormulaElement()
        formulaTree.type = ElementType.NUMBER
        formulaTree.value = "-20"
        transparency.formulaTree = formulaTree

        let script = WhenScript()
        script.object = object

        let brick = ChangeTransparencyByNBrick()
        brick.script = script
        brick.changeTransparency = transparency

        let action: () -> Void = brick.actionBlock(formulaInterpreter!)
        action()

        XCTAssertEqual(10.0,
                       spriteNode.catrobatTransparency,
                       accuracy: Double.epsilon,
                       "ChangeTransparencyBrick is not correctly calculated")
    }

    func testChangeTransparencyByNBrickOutOfRange() {
        let object = SpriteObject()
        let spriteNode = CBSpriteNode(spriteObject: object)
        object.spriteNode = spriteNode

        scene!.addChild(spriteNode)
        spriteNode.catrobatTransparency = 0.0

        let transparency = Formula()
        let formulaTree = FormulaElement()
        formulaTree.type = ElementType.NUMBER
        formulaTree.value = "150"
        transparency.formulaTree = formulaTree

        let script = WhenScript()
        script.object = object

        let brick = ChangeTransparencyByNBrick()
        brick.script = script
        brick.changeTransparency = transparency

        let action: () -> Void = brick.actionBlock(formulaInterpreter!)
        action()

        XCTAssertEqual(100.0,
                       spriteNode.catrobatTransparency,
                       accuracy: Double.epsilon,
                       "ChangeTransparencyBrick is not correctly calculated")
    }

    func testChangeTransparencyByNBrickWrongInput() {
        let object = SpriteObject()
        let spriteNode = CBSpriteNode(spriteObject: object)
        object.spriteNode = spriteNode

        scene!.addChild(spriteNode)
        spriteNode.catrobatTransparency = 0.0

        let transparency = Formula()
        let formulaTree = FormulaElement()
        formulaTree.type = ElementType.NUMBER
        formulaTree.value = "a"
        transparency.formulaTree = formulaTree

        let script = WhenScript()
        script.object = object

        let brick = ChangeTransparencyByNBrick()
        brick.script = script
        brick.changeTransparency = transparency

        let action: () -> Void = brick.actionBlock(formulaInterpreter!)
        action()

        XCTAssertEqual(0.0,
                       spriteNode.catrobatTransparency,
                       accuracy: Double.epsilon,
                       "ChangeTransparencyBrick is not correctly calculated")
    }
}
