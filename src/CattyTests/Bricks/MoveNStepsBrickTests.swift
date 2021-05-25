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

final class MoveNStepsBrickTests: AbstractBrickTest {

    var spriteNode: CBSpriteNode!
    var script: Script!
    var brick: MoveNStepsBrick!

    let SCREEN_WIDTH = 480.0
    let SCREEN_HEIGHT = 800.0
    let OBJECT_WIDTH = 100.0
    let OBJECT_HEIGHT = 100.0
    let EPSILON: CGFloat = 0.001

    override func setUp() {
        super.setUp()
        self.stage = StageBuilder(project: ProjectMock(width: CGFloat(SCREEN_WIDTH), andHeight: CGFloat(SCREEN_HEIGHT))).build()

        let spriteObject = SpriteObject()
        let scene = Scene(name: "testScene")
        spriteObject.scene = scene

        self.spriteNode = CBSpriteNode(spriteObject: spriteObject)
        self.spriteNode.color = UIColor.black
        self.spriteNode.size = CGSize(width: OBJECT_WIDTH, height: OBJECT_HEIGHT)
        self.stage.addChild(spriteNode)

        spriteObject.spriteNode = self.spriteNode
        self.spriteNode.catrobatPosition = CBPosition(x: 0, y: 0)
        spriteObject.name = "Test"

        self.script = WhenScript()
        self.script.object = spriteObject

        self.brick = MoveNStepsBrick()
        self.brick.script = self.script
    }

    func testMoveNStepsBrickUp() {
        setPosition(position: CBPosition(x: 20, y: 20), rotation: 0, steps: 10)
        checkPosition(position: CBPosition(x: 20, y: 30))

        setPosition(position: CBPosition(x: 20, y: 20), rotation: 0, steps: -10)
        checkPosition(position: CBPosition(x: 20, y: 10))

        setPosition(position: CBPosition(x: SCREEN_WIDTH / 2, y: -SCREEN_HEIGHT / 2), rotation: 0, steps: 10)
        checkPosition(position: CBPosition(x: SCREEN_WIDTH / 2, y: -SCREEN_HEIGHT / 2 + 10))
    }

    func testMoveNStepsBrickDown() {
        setPosition(position: CBPosition(x: 20, y: 20), rotation: 180, steps: 10)
        checkPosition(position: CBPosition(x: 20, y: 10))

        setPosition(position: CBPosition(x: 20, y: 20), rotation: 180, steps: -10)
        checkPosition(position: CBPosition(x: 20, y: 30))

        setPosition(position: CBPosition(x: SCREEN_WIDTH / 2, y: SCREEN_HEIGHT / 2), rotation: 180, steps: 10)
        checkPosition(position: CBPosition(x: SCREEN_WIDTH / 2, y: SCREEN_HEIGHT / 2 - 10))
    }

    func testMoveNStepsBrickLeft() {
        setPosition(position: CBPosition(x: 20, y: 20), rotation: 270, steps: 10)
        checkPosition(position: CBPosition(x: 10, y: 20))

        setPosition(position: CBPosition(x: 20, y: 20), rotation: 270, steps: -10)
        checkPosition(position: CBPosition(x: 30, y: 20))

        setPosition(position: CBPosition(x: SCREEN_WIDTH / 2, y: SCREEN_HEIGHT / 2), rotation: 270, steps: 10)
        checkPosition(position: CBPosition(x: SCREEN_WIDTH / 2 - 10, y: SCREEN_HEIGHT / 2))
    }

    func testMoveNStepsBrickRight() {
        setPosition(position: CBPosition(x: 20, y: 20), rotation: 90, steps: 10)
        checkPosition(position: CBPosition(x: 30, y: 20))

        setPosition(position: CBPosition(x: 20, y: 20), rotation: 90, steps: -10)
        checkPosition(position: CBPosition(x: 10, y: 20))

        setPosition(position: CBPosition(x: -SCREEN_WIDTH / 2, y: SCREEN_HEIGHT / 2), rotation: 90, steps: 10)
        checkPosition(position: CBPosition(x: -SCREEN_WIDTH / 2 + 10, y: SCREEN_HEIGHT / 2 ))
    }

    func testMoveNStepsBrickLeftUp() {
        setPosition(position: CBPosition(x: SCREEN_WIDTH / 2, y: -SCREEN_HEIGHT / 2), rotation: 280, steps: 10)

        let rotation = Util.degree(toRadians: 280)
        let xPosition = SCREEN_WIDTH / 2 + 10 * sin(rotation)
        let yPosition = -SCREEN_HEIGHT / 2 + 10 * cos(rotation)

        checkPosition(position: CBPosition(x: xPosition, y: yPosition))
    }

    func testMoveNStepsBrickRightUp() {
        setPosition(position: CBPosition(x: -SCREEN_WIDTH / 2, y: -SCREEN_HEIGHT / 2), rotation: 80, steps: 10)

        let rotation = Util.degree(toRadians: 80)
        let xPosition = -SCREEN_WIDTH / 2 + 10 * sin(rotation)
        let yPosition = -SCREEN_HEIGHT / 2 + 10 * cos(rotation)

        checkPosition(position: CBPosition(x: xPosition, y: yPosition))
    }

    func testMoveNStepsBrickLeftDown() {
        setPosition(position: CBPosition(x: SCREEN_WIDTH / 2, y: SCREEN_HEIGHT / 2), rotation: 200, steps: 10)

        let rotation = Util.degree(toRadians: 200)
        let xPosition = SCREEN_WIDTH / 2 + 10 * sin(rotation)
        let yPosition = SCREEN_HEIGHT / 2 + 10 * cos(rotation)

        checkPosition(position: CBPosition(x: xPosition, y: yPosition))
    }

    func testMoveNStepsBrickRightDown() {
        setPosition(position: CBPosition(x: -SCREEN_WIDTH / 2, y: SCREEN_HEIGHT / 2), rotation: 110, steps: 10)

        let rotation = Util.degree(toRadians: 110)
        let xPosition = -SCREEN_WIDTH / 2 + 10 * sin(rotation)
        let yPosition = SCREEN_HEIGHT / 2 + 10 * cos(rotation)

        checkPosition(position: CBPosition(x: xPosition, y: yPosition))
    }

    func setPosition(position: CBPosition, rotation: Double, steps: Float) {
        self.spriteNode.catrobatPosition = position
        self.spriteNode.catrobatRotation = rotation

        self.brick.steps = Formula(float: steps)

        let action = self.brick.actionBlock(self.formulaInterpreter)
        action()
    }

    func checkPosition(position: CBPosition) {
        XCTAssertEqual(position.x, self.spriteNode.catrobatPosition.x, accuracy: Double(EPSILON), "Wrong x after MoveNStepsBrick")
        XCTAssertEqual(position.y, self.spriteNode.catrobatPosition.y, accuracy: Double(EPSILON), "Wrong y after MoveNStepsBrick")
    }

    func testMutableCopy() {
        brick.steps = Formula(double: 76.8)

        let copiedBrick: MoveNStepsBrick = brick.mutableCopy(with: CBMutableCopyContext(), andErrorReporting: true) as! MoveNStepsBrick

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
