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

final class GoNStepsBackBrickTests: AbstractBrickTests {

    func testGoNStepsBackBrickSingle() {
        let program = Program()
        let object1 = SpriteObject()
        let spriteNode1 = CBSpriteNode(spriteObject: object1)
        object1.spriteNode = spriteNode1
        object1.program = program
        spriteNode1.zPosition = 5

        let object2 = SpriteObject()
        let spriteNode2 = CBSpriteNode(spriteObject: object2)
        object2.spriteNode = spriteNode2
        spriteNode2.zPosition = 3

        program.objectList.add(object1 as Any)
        program.objectList.add(object2 as Any)

        let script = WhenScript()
        script.object = object1

        let brick = GoNStepsBackBrick()
        brick.script = script

        brick.steps = Formula(integer: 1)

        let action: () -> Void = brick.actionBlock(formulaInterpreter!)
        action()
        XCTAssertEqual(spriteNode1.zPosition, CGFloat(4.0), "GoNStepsBack is not correctly calculated")
        XCTAssertEqual(spriteNode2.zPosition, CGFloat(3.0), "GoNStepsBack is not correctly calculated")
    }

    func testGoNStepsBackBrickTwice() {
        let program = Program()
        let object1 = SpriteObject()
        let spriteNode1 = CBSpriteNode(spriteObject: object1)
        object1.spriteNode = spriteNode1
        object1.program = program
        spriteNode1.zPosition = 6

        let object2 = SpriteObject()
        let spriteNode2 = CBSpriteNode(spriteObject: object2)
        object2.spriteNode = spriteNode2
        spriteNode2.zPosition = 3

        program.objectList.add(object1 as Any)
        program.objectList.add(object2 as Any)

        let script = WhenScript()
        script.object = object1

        let brick = GoNStepsBackBrick()
        brick.script = script

        brick.steps = Formula(integer: 2)

        let action: () -> Void = brick.actionBlock(formulaInterpreter!)
        action()
        XCTAssertEqual(spriteNode1.zPosition, CGFloat(4.0), "GoNStepsBack is not correctly calculated")
        XCTAssertEqual(spriteNode2.zPosition, CGFloat(3.0), "GoNStepsBack is not correctly calculated")
    }

    func testGoNStepsBackBrickComeToSameLayer() {
        let program = Program()
        let object1 = SpriteObject()
        object1.program = program
        let spriteNode1 = CBSpriteNode(spriteObject: object1)
        object1.spriteNode = spriteNode1
        spriteNode1.zPosition = 5

        let object2 = SpriteObject()
        let spriteNode2 = CBSpriteNode(spriteObject: object2)
        object2.spriteNode = spriteNode2
        spriteNode2.zPosition = 3

        program.objectList.add(object1 as Any)
        program.objectList.add(object2 as Any)

        let script = WhenScript()
        script.object = object1

        let brick = GoNStepsBackBrick()
        brick.script = script

        brick.steps = Formula(integer: 2)

        let action: () -> Void = brick.actionBlock(formulaInterpreter!)
        action()
        XCTAssertEqual(spriteNode1.zPosition, CGFloat(3.0), "GoNStepsBack is not correctly calculated")
        XCTAssertEqual(spriteNode2.zPosition, CGFloat(4.0), "GoNStepsBack is not correctly calculated")
    }

    func testGoNStepsBackBrickOutOfRange() {
        let program = Program()
        let object1 = SpriteObject()
        let spriteNode1 = CBSpriteNode(spriteObject: object1)
        object1.spriteNode = spriteNode1
        object1.program = program
        spriteNode1.zPosition = 5

        let object2 = SpriteObject()
        let spriteNode2 = CBSpriteNode(spriteObject: object2)
        object2.spriteNode = spriteNode2
        spriteNode2.zPosition = 3

        program.objectList.add(object1 as Any)
        program.objectList.add(object2 as Any)

        let script = WhenScript()
        script.object = object1

        let brick = GoNStepsBackBrick()
        brick.script = script

        brick.steps = Formula(integer: 10)

        let action: () -> Void = brick.actionBlock(formulaInterpreter!)
        action()
        XCTAssertEqual(spriteNode1.zPosition, CGFloat(1.0), "GoNStepsBack is not correctly calculated")
        XCTAssertEqual(spriteNode2.zPosition, CGFloat(4.0), "GoNStepsBack is not correctly calculated")
    }

    func testGoNStepsBackBrickWronginput() {
        let program = Program()
        let object1 = SpriteObject()
        object1.program = program
        let spriteNode1 = CBSpriteNode(spriteObject: object1)
        object1.spriteNode = spriteNode1
        spriteNode1.zPosition = 5

        let object2 = SpriteObject()
        let spriteNode2 = CBSpriteNode(spriteObject: object2)
        object2.spriteNode = spriteNode2
        spriteNode2.zPosition = 3

        program.objectList.add(object1 as Any)
        program.objectList.add(object2 as Any)

        let script = WhenScript()
        script.object = object1

        let brick = GoNStepsBackBrick()
        brick.script = script

        brick.steps = Formula(string: "a")

        let action: () -> Void = brick.actionBlock(formulaInterpreter!)
        action()
        XCTAssertEqual(spriteNode1.zPosition, CGFloat(5.0), "GoNStepsBack is not correctly calculated")
        XCTAssertEqual(spriteNode2.zPosition, CGFloat(3.0), "GoNStepsBack is not correctly calculated")
    }

    func testTitleSingular() {
        let brick = GoNStepsBackBrick()
        brick.steps = Formula(integer: 1)
        XCTAssertTrue((kLocalizedGoBack + ("%@ " + (kLocalizedLayer)) == brick.brickTitle), "Wrong brick title")
    }

    func testTitlePlural() {
        let brick = GoNStepsBackBrick()
        brick.steps = Formula(integer: 2)
        XCTAssertTrue((kLocalizedGoBack + ("%@ " + (kLocalizedLayers)) == brick.brickTitle), "Wrong brick title")
    }
}
