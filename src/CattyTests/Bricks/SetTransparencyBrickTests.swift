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

final class SetTransparencyToBrickTests: AbstractBrickTest {

    var brick: SetTransparencyBrick!
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

        script = WhenScript()
        script.object = object

        brick = SetTransparencyBrick()
        brick.script = script
    }

    func testSetTransparencyBrickPositve() {
        spriteNode.catrobatTransparency = 0.0
        brick.transparency = Formula(integer: 20)

        let action = brick.actionBlock(self.formulaInterpreter)
        action()

        XCTAssertEqual(20.0, spriteNode.catrobatTransparency, accuracy: 0.01, "ChangeTransparencyBrick is not correctly calculated")
    }

    func testSetTransparencyBrickNegative() {
        spriteNode.catrobatTransparency = 0.0
        brick.transparency = Formula(integer: -20)

        let action = brick.actionBlock(self.formulaInterpreter)
        action()

        XCTAssertEqual(0.0, spriteNode.catrobatTransparency, accuracy: 0.01, "ChangeTransparencyBrick is not correctly calculated")
    }

    func testSetTransparencyBrickWronginput() {
        spriteNode.catrobatTransparency = 10.0
        brick.transparency = Formula(string: "a")

        let action = brick.actionBlock(self.formulaInterpreter)
        action()

        XCTAssertEqual(0.0, spriteNode.catrobatTransparency, accuracy: 0.01, "ChangeTransparencyBrick is not correctly calculated")
    }
    func testMutableCopy() {
           let brick = SetTransparencyBrick()
           let script = Script()
           let object = SpriteObject()
           let scene = Scene(name: "testScene")
           object.scene = scene

           script.object = object
           brick.script = script
           brick.transparency = Formula(integer: 1)
           let copiedBrick: SetTransparencyBrick = brick.mutableCopy(with: CBMutableCopyContext()) as! SetTransparencyBrick

           XCTAssertTrue(brick.isEqual(to: copiedBrick))
           XCTAssertFalse(brick === copiedBrick)
    }
    func testGetFormulas() {
        brick.transparency = Formula(integer: 1)
        var formulas = brick.getFormulas()

        XCTAssertEqual(formulas?.count, 1)
        XCTAssertEqual(brick.transparency, formulas?[0])

        brick.transparency = Formula(integer: 22)
        formulas = brick.getFormulas()

        XCTAssertEqual(brick.transparency, formulas?[0])
     }

}
