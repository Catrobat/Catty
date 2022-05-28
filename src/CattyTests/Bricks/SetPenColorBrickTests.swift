/**
 *  Copyright (C) 2010-2022 The Catrobat Team
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

final class SetPenColorBrickTests: AbstractBrickTest {

    func testSetPenColorBrick() {
        let object = SpriteObject()
        let scene = Scene(name: "testScene")
        object.scene = scene
        let spriteNode = CBSpriteNode(spriteObject: object)
        object.spriteNode = spriteNode

        let script = Script()
        script.object = object

        let brick = SetPenColorBrick()
        brick.script = script
        brick.red = Formula(integer: 255)
        brick.green = Formula(integer: 10)
        brick.blue = Formula(integer: 100)

        let expectedPenColor = UIColor(red: 255, green: 10, blue: 100)

        let action = brick.actionBlock(self.formulaInterpreter)
        XCTAssertEqual(spriteNode.penConfiguration.color, SpriteKitDefines.defaultPenColor)
        action()
        XCTAssertEqual(spriteNode.penConfiguration.color, expectedPenColor)

    }

    func testPenColorBrickWhenMaxValueOutOfRange() {
        let object = SpriteObject()
        let scene = Scene(name: "testScene")
        object.scene = scene
        let spriteNode = CBSpriteNode(spriteObject: object)
        object.spriteNode = spriteNode

        let script = Script()
        script.object = object

        let brick = SetPenColorBrick()
        brick.script = script

        brick.red = Formula(double: Double(Int.max) + 100)
        brick.green = Formula(double: 10)
        brick.blue = Formula(double: 100)

        let expectedPenColor = UIColor(red: Int.max, green: 10, blue: 100)

        let action = brick.actionBlock(self.formulaInterpreter)
        XCTAssertEqual(spriteNode.penConfiguration.color, SpriteKitDefines.defaultPenColor)
        action()
        XCTAssertEqual(spriteNode.penConfiguration.color, expectedPenColor)
    }

    func testPenColorBrickWhenMinValueOutOfRange() {
        let object = SpriteObject()
        let scene = Scene(name: "testScene")
        object.scene = scene
        let spriteNode = CBSpriteNode(spriteObject: object)
        object.spriteNode = spriteNode

        let script = Script()
        script.object = object

        let brick = SetPenColorBrick()
        brick.script = script

        brick.red = Formula(double: Double(Int.min) - 100)
        brick.green = Formula(double: 10)
        brick.blue = Formula(double: 100)

        let expectedPenColor = UIColor(red: Int.min, green: 10, blue: 100)

        let action = brick.actionBlock(self.formulaInterpreter)
        XCTAssertEqual(spriteNode.penConfiguration.color, SpriteKitDefines.defaultPenColor)
        action()
        XCTAssertEqual(spriteNode.penConfiguration.color, expectedPenColor)
    }

}
