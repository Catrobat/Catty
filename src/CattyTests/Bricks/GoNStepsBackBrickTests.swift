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

final class GoNStepsBackBrickTests: AbstractBrickTest {

    var spriteNode1: CBSpriteNode!
    var spriteNode2: CBSpriteNode!
    var brick: GoNStepsBackBrick!
    var script: WhenScript!
    var object1: SpriteObject!
    var object2: SpriteObject!
    var project: Project!

    override func setUp() {
        super.setUp()

        project = Project()
        let scene = Scene(name: "testScene")
        scene.project = project
        project.scene = scene

        object1 = SpriteObject()
        object1.scene = scene
        spriteNode1 = CBSpriteNode(spriteObject: object1)
        object1.spriteNode = spriteNode1

        object2 = SpriteObject()
        object2.scene = scene
        spriteNode2 = CBSpriteNode(spriteObject: object2)
        object2.spriteNode = spriteNode2

        project.scene.add(object: object1!)
        project.scene.add(object: object2!)

        script = WhenScript()
        script.object = object1

        brick = GoNStepsBackBrick()
        brick.script = script
    }

    func testGoNStepsBackBrickSingle() {
        spriteNode1.zPosition = 5
        spriteNode2.zPosition = 3
        brick.steps = Formula(integer: 1)

        let action = brick.actionBlock(self.formulaInterpreter)
        action()

        XCTAssertEqual(spriteNode1.zPosition, 4.0, "GoNStepsBack is not correctly calculated")
        XCTAssertEqual(spriteNode2.zPosition, 3.0, "GoNStepsBack is not correctly calculated")
    }

    func testGoNStepsBackBrickTwice() {
        spriteNode1.zPosition = 6
        spriteNode2.zPosition = 3
        brick.steps = Formula(integer: 2)

        let action = brick.actionBlock(self.formulaInterpreter)
        action()

        XCTAssertEqual(spriteNode1.zPosition, 4.0, "GoNStepsBack is not correctly calculated")
        XCTAssertEqual(spriteNode2.zPosition, 3.0, "GoNStepsBack is not correctly calculated")
    }

    func testGoNStepsBackBrickComeToSameLayer() {
        spriteNode1.zPosition = 5
        spriteNode2.zPosition = 3
        brick.steps = Formula(integer: 2)

        let action = brick.actionBlock(self.formulaInterpreter)
        action()

        XCTAssertEqual(spriteNode1.zPosition, 3.0, "GoNStepsBack is not correctly calculated")
        XCTAssertEqual(spriteNode2.zPosition, 4.0, "GoNStepsBack is not correctly calculated")
    }

    func testGoNStepsBackBrickOutOfRange() {
        spriteNode1.zPosition = 5
        spriteNode2.zPosition = 3
        brick.steps = Formula(integer: 10)

        let action = brick.actionBlock(self.formulaInterpreter)
        action()

        XCTAssertEqual(spriteNode1.zPosition, 1.0, "GoNStepsBack is not correctly calculated")
        XCTAssertEqual(spriteNode2.zPosition, 4.0, "GoNStepsBack is not correctly calculated")
    }

    func testGoNStepsBackBrickWronginput() {
        spriteNode1.zPosition = 5
        spriteNode2.zPosition = 3
        brick.steps = Formula(string: "a")

        let action = brick.actionBlock(self.formulaInterpreter)
        action()

        XCTAssertEqual(spriteNode1.zPosition, 5.0, "GoNStepsBack is not correctly calculated")
        XCTAssertEqual(spriteNode2.zPosition, 3.0, "GoNStepsBack is not correctly calculated")
    }

    func testMutableCopy() {
        brick.steps = Formula(double: 60.0)

        let copiedBrick: GoNStepsBackBrick = brick.mutableCopy(with: CBMutableCopyContext()) as! GoNStepsBackBrick

        XCTAssertTrue(brick.isEqual(to: copiedBrick))
        XCTAssertFalse(brick === copiedBrick)

        XCTAssertTrue(brick.steps.isEqual(to: copiedBrick.steps))
        XCTAssertFalse(brick.steps === copiedBrick.steps)
    }

    func testGetFormulas() {
        brick.steps = Formula(double: 1)
        var formulas = brick.getFormulas()

        XCTAssertEqual(formulas?.count, 1)
        XCTAssertEqual(brick.steps, formulas?[0])

        brick.steps = Formula(double: 22)
        formulas = brick.getFormulas()

        XCTAssertEqual(brick.steps, formulas?[0])
    }
}
