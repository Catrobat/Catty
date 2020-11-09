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

final class SetSizeToBrickTests: AbstractBrickTest {

    var brick: SetSizeToBrick!
    var spriteNode: CBSpriteNode!
    var object: SpriteObject!
    var script: WhenScript!

    override func setUp() {
        super.setUp()
        object = SpriteObject()
        let scene = Scene(name: "testScene")
        object.scene = scene
        script = WhenScript()
        spriteNode = CBSpriteNode(spriteObject: object)
        object.spriteNode = spriteNode
        script.object = object

        brick = SetSizeToBrick()
        brick.script = script
    }

    func testSetSizeToBrickPositive() {
        brick.size = Formula(integer: 130)

        let action = brick.actionBlock(self.formulaInterpreter)
        action()

        XCTAssertEqual(130.0, spriteNode.catrobatSize, accuracy: 0.0001, "Size not correct")
    }

    func testSetSizeToBrickNegative() {
        brick.size = Formula(integer: -130)

        let action = brick.actionBlock(self.formulaInterpreter)
        action()

        XCTAssertEqual(0.0, spriteNode.catrobatSize, accuracy: 0.0001, "Size not correct")
    }

    func testSetSizeToBrickWrongInput() {
        brick.size = Formula(string: "a")

        let action = brick.actionBlock(self.formulaInterpreter)
        action()

        XCTAssertEqual(0.0, spriteNode.catrobatSize, accuracy: 0.0001, "Size not correct")
    }
    func testMutableCopy() {
              let brick = SetSizeToBrick()
              let script = Script()
              let object = SpriteObject()
              let scene = Scene(name: "testScene")
              object.scene = scene

              script.object = object
              brick.script = script
              brick.size = Formula(integer: 130)
              let copiedBrick: SetSizeToBrick = brick.mutableCopy(with: CBMutableCopyContext()) as! SetSizeToBrick

              XCTAssertTrue(brick.isEqual(to: copiedBrick))
              XCTAssertFalse(brick === copiedBrick)
       }
}
