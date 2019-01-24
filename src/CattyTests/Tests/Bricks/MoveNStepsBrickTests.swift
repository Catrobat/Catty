/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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

final class MoveNStepsBrickTests: AbstractBrickTests {
    var spriteNode: CBSpriteNode?
    var script: Script?
    var brick: MoveNStepsBrick?

    let SCREEN_WIDTH = 480.0
    let SCREEN_HEIGHT = 800.0
    let OBJECT_WIDTH = 100.0
    let OBJECT_HEIGHT = 100.0

    override func setUp() {
        super.setUp()
        scene = SceneBuilder(project: ProjectMock(width: CGFloat(SCREEN_WIDTH), andHeight: CGFloat(SCREEN_HEIGHT))).build()

        let spriteObject = SpriteObject()

        spriteNode = CBSpriteNode(spriteObject: spriteObject)
        spriteNode?.color = UIColor.black
        spriteNode?.size = CGSize(width: CGFloat(OBJECT_WIDTH), height: CGFloat(OBJECT_HEIGHT))
        if let aNode = spriteNode {
            scene!.addChild(aNode)
        }

        spriteObject.spriteNode = spriteNode
        spriteNode?.catrobatPosition = CGPoint(x: 0, y: 0)
        spriteObject.name = "Test"

        script = WhenScript()
        script?.object = spriteObject

        brick = MoveNStepsBrick()
        brick?.script = script
    }

    func testMoveNStepsBrickUp() {
        setPosition(CGPoint(x: 20, y: 20), andRotation: 0, andMoveSteps: 10)
        checkPosition(CGPoint(x: 20, y: 30))

        setPosition(CGPoint(x: 20, y: 20), andRotation: 0, andMoveSteps: -10)
        checkPosition(CGPoint(x: 20, y: 10))

        setPosition(CGPoint(x: CGFloat(SCREEN_WIDTH / 2), y: CGFloat(-SCREEN_HEIGHT / 2)), andRotation: 0, andMoveSteps: 10)
        checkPosition(CGPoint(x: CGFloat(SCREEN_WIDTH / 2), y: CGFloat(-SCREEN_HEIGHT / 2 + 10)))
    }

    func testMoveNStepsBrickDown() {
        setPosition(CGPoint(x: 20, y: 20), andRotation: 180, andMoveSteps: 10)
        checkPosition(CGPoint(x: 20, y: 10))

        setPosition(CGPoint(x: 20, y: 20), andRotation: 180, andMoveSteps: -10)
        checkPosition(CGPoint(x: 20, y: 30))

        setPosition(CGPoint(x: CGFloat(SCREEN_WIDTH / 2), y: CGFloat(SCREEN_HEIGHT / 2)), andRotation: 180, andMoveSteps: 10)
        checkPosition(CGPoint(x: CGFloat(SCREEN_WIDTH / 2), y: CGFloat(SCREEN_HEIGHT / 2 - 10)))
    }

    func testMoveNStepsBrickLeft() {
        setPosition(CGPoint(x: 20, y: 20), andRotation: 270, andMoveSteps: 10)
        checkPosition(CGPoint(x: 10, y: 20))

        setPosition(CGPoint(x: 20, y: 20), andRotation: 270, andMoveSteps: -10)
        checkPosition(CGPoint(x: 30, y: 20))

        setPosition(CGPoint(x: CGFloat(SCREEN_WIDTH / 2), y: CGFloat(SCREEN_HEIGHT / 2)), andRotation: 270, andMoveSteps: 10)
        checkPosition(CGPoint(x: CGFloat(SCREEN_WIDTH / 2 - 10), y: CGFloat(SCREEN_HEIGHT / 2)))
    }

    func testMoveNStepsBrickRight() {
        setPosition(CGPoint(x: 20, y: 20), andRotation: 90, andMoveSteps: 10)
        checkPosition(CGPoint(x: 30, y: 20))

        setPosition(CGPoint(x: 20, y: 20), andRotation: 90, andMoveSteps: -10)
        checkPosition(CGPoint(x: 10, y: 20))

        setPosition(CGPoint(x: CGFloat(-SCREEN_WIDTH / 2), y: CGFloat(SCREEN_HEIGHT / 2)), andRotation: 90, andMoveSteps: 10)
        checkPosition(CGPoint(x: CGFloat(-SCREEN_WIDTH / 2 + 10), y: CGFloat(SCREEN_HEIGHT / 2)))
    }

    func testMoveNStepsBrickLeftUp() {
        setPosition(CGPoint(x: CGFloat(SCREEN_WIDTH / 2), y: CGFloat(-SCREEN_HEIGHT / 2)), andRotation: 280, andMoveSteps: 10)

        let rotation = Util.degree(toRadians: 280)
        let xPosition = CGFloat(SCREEN_WIDTH / 2 + 10 * sin(rotation))
        let yPosition = CGFloat(-SCREEN_HEIGHT / 2 + 10 * cos(rotation))

        checkPosition(CGPoint(x: xPosition, y: yPosition))
    }

    func testMoveNStepsBrickRightUp() {
        setPosition(CGPoint(x: CGFloat(-SCREEN_WIDTH / 2), y: CGFloat(-SCREEN_HEIGHT / 2)), andRotation: 80, andMoveSteps: 10)

        let rotation = Util.degree(toRadians: 80)
        let xPosition = CGFloat(-SCREEN_WIDTH / 2 + 10 * sin(rotation))
        let yPosition = CGFloat(-SCREEN_HEIGHT / 2 + 10 * cos(rotation))

        checkPosition(CGPoint(x: xPosition, y: yPosition))
    }

    func testMoveNStepsBrickLeftDown() {
        setPosition(CGPoint(x: CGFloat(SCREEN_WIDTH / 2), y: CGFloat(SCREEN_HEIGHT / 2)), andRotation: 200, andMoveSteps: 10)

        let rotation = Util.degree(toRadians: 200)
        let xPosition = CGFloat(SCREEN_WIDTH / 2 + 10 * sin(rotation))
        let yPosition = CGFloat(SCREEN_HEIGHT / 2 + 10 * cos(rotation))

        checkPosition(CGPoint(x: xPosition, y: yPosition))
    }

    func testMoveNStepsBrickRightDown() {
        setPosition(CGPoint(x: CGFloat(-SCREEN_WIDTH / 2), y: CGFloat(SCREEN_HEIGHT / 2)), andRotation: 110, andMoveSteps: 10)

        let rotation = Util.degree(toRadians: 110)
        let xPosition = CGFloat(-SCREEN_WIDTH / 2 + 10 * sin(rotation))
        let yPosition = CGFloat(SCREEN_HEIGHT / 2 + 10 * cos(rotation))

        checkPosition(CGPoint(x: xPosition, y: yPosition))
    }

    func setPosition(_ position: CGPoint, andRotation rotation: CGFloat, andMoveSteps steps: CGFloat) {
        spriteNode?.catrobatPosition = position
        spriteNode?.catrobatRotation = Double(rotation)

        brick?.steps = Formula(float: Float(steps))

        let action: () -> Void? = (brick?.actionBlock(formulaInterpreter!))!
        action()
    }

    func checkPosition(_ position: CGPoint) {
        XCTAssertEqual(Double(position.x), Double((spriteNode?.catrobatPosition.x)!), accuracy: Double.epsilon, "Wrong x after MoveNStepsBrick")
        XCTAssertEqual(Double(position.y), Double((spriteNode?.catrobatPosition.y)!), accuracy: Double.epsilon, "Wrong y after MoveNStepsBrick")
    }

    func testTitleSingular() {
        let brick = MoveNStepsBrick()
        brick.steps = Formula(double: 1)
        XCTAssertTrue((kLocalizedMove + (" %@ " + (kLocalizedStep)) == brick.brickTitle), "Wrong brick title")
    }

    func testTitlePlural() {
        let brick = MoveNStepsBrick()
        brick.steps = Formula(double: 2)
        XCTAssertTrue((kLocalizedMove + (" %@ " + (kLocalizedSteps)) == brick.brickTitle), "Wrong brick title")
    }
}
