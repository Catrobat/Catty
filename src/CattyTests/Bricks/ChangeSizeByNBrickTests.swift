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

final class ChangeSizeByNBrickTests: AbstractBrickTests {

    func testChangeSizeByNBrickPositive() {
        let object = SpriteObject()
        let spriteNode = CBSpriteNode(spriteObject: object)
        object.spriteNode = spriteNode
        spriteNode.catrobatSize = 10.0

        let script = WhenScript()
        script.object = object

        let brick = ChangeSizeByNBrick()
        brick.script = script

        brick.size = Formula(integer: 30)

        let action: () -> Void = brick.actionBlock(formulaInterpreter!)
        action()

        XCTAssertEqual(40.0, spriteNode.catrobatSize, accuracy: 0.0001, "Size not correct")
    }

    func testChangeSizeByNBrickNegative() {
        let object = SpriteObject()
        let spriteNode = CBSpriteNode(spriteObject: object)
        object.spriteNode = spriteNode
        spriteNode.catrobatSize = 50.0

        let script = WhenScript()
        script.object = object

        let brick = ChangeSizeByNBrick()
        brick.script = script

        brick.size = Formula(integer: -30)

        let action: () -> Void = brick.actionBlock(formulaInterpreter!)
        action()

        XCTAssertEqual(20.0, spriteNode.catrobatSize, accuracy: 0.0001, "Size not correct")
    }

    func testChangeSizeByNBrickWrongInput() {
        let object = SpriteObject()
        let spriteNode = CBSpriteNode(spriteObject: object)
        object.spriteNode = spriteNode
        spriteNode.catrobatSize = 10.0

        let script = WhenScript()
        script.object = object

        let brick = ChangeSizeByNBrick()
        brick.script = script

        brick.size = Formula(string: "a")

        let action: () -> Void = brick.actionBlock(formulaInterpreter!)
        action()

        XCTAssertEqual(10.0, spriteNode.catrobatSize, accuracy: 0.0001, "Size not correct")
    }
}
