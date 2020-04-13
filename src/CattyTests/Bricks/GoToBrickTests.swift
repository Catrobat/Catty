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

final class GoToBrickTests: AbstractBrickTest {

    var brick: GoToBrick!
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
        spriteNode.catrobatPosition = CBPosition(x: 0, y: 0)

        script = WhenScript()
        script.object = object

        brick = GoToBrick()
        brick.script = script
    }

    func testGoToBrickTouchPosition() {
        brick.spinnerSelection = kGoToTouchPosition

        let touchManager = TouchManagerMock()
        let touch = CGPoint(x: 150, y: 250)
        touchManager.lastTouch = touch
        let action = brick.actionBlock(touchManager)
        action()

        guard let width = spriteNode.scene?.size.width else {
            XCTFail("No stage found!")
            return
        }

        guard let height = spriteNode.scene?.size.height else {
            XCTFail("No stage found!")
            return
        }

        XCTAssertEqual(spriteNode.catrobatPosition.x, Double(touch.x) - Double(width / 2))
        XCTAssertEqual(spriteNode.catrobatPosition.y, Double(touch.y) - Double(height / 2))

        let minXCorrd = Double(self.stage.size.width / 2.0) * (-1)
        let maxXCoord = Double(self.stage.size.width / 2.0)
        XCTAssertTrue(spriteNode.catrobatPosition.x >= minXCorrd && spriteNode.catrobatPosition.x <= maxXCoord)

        let minYCorrd = Double(stage.size.height / 2.0) * (-1)
        let maxYCoord = Double(stage.size.height / 2.0)
        XCTAssertTrue(spriteNode.catrobatPosition.y >= minYCorrd && spriteNode.catrobatPosition.y <= maxYCoord)
    }

    func testGoToBrickRandomPosition() {
        brick.spinnerSelection = kGoToRandomPosition

        let action = brick.actionBlock(self.formulaInterpreter.touchManager)
        action()
        let firstRandomPosition = spriteNode.catrobatPosition

        action()
        let secondRandomPosition = spriteNode.catrobatPosition

        XCTAssertNotEqual(firstRandomPosition, secondRandomPosition)

        let minXCorrd = Double(self.stage.size.width / 2.0) * (-1)
        let maxXCoord = Double(self.stage.size.width / 2.0)
        XCTAssertTrue(firstRandomPosition.x >= minXCorrd && firstRandomPosition.x <= maxXCoord)
        XCTAssertTrue(secondRandomPosition.x >= minXCorrd && secondRandomPosition.x <= maxXCoord)

        let minYCorrd = Double(stage.size.height / 2.0) * (-1)
        let maxYCoord = Double(stage.size.height / 2.0)
        XCTAssertTrue(firstRandomPosition.y >= minYCorrd && firstRandomPosition.y <= maxYCoord)
        XCTAssertTrue(secondRandomPosition.y >= minYCorrd && secondRandomPosition.y <= maxYCoord)
    }

    func testGoToBrickObject() {
        let goToObject = SpriteObject()
        let scene = Scene(name: "testScene")
        goToObject.scene = scene
        let goToSpriteNode = CBSpriteNode(spriteObject: goToObject)
        goToObject.spriteNode = goToSpriteNode

        self.stage.addChild(goToSpriteNode)
        goToSpriteNode.catrobatPosition = CBPosition(x: 150, y: 500)

        brick.goToObject = goToObject
        brick.spinnerSelection = kGoToOtherSpritePosition

        XCTAssertNotEqual(spriteNode.position, goToSpriteNode.position)

        let action = brick.actionBlock(self.formulaInterpreter.touchManager)
        action()

        XCTAssertEqual(spriteNode.position, goToSpriteNode.position)
    }

    func testMutableCopy() {
        brick.spinnerSelection = kGoToTouchPosition

        let copiedBrick: GoToBrick = brick.mutableCopy(with: CBMutableCopyContext(), andErrorReporting: true) as! GoToBrick

        XCTAssertTrue(brick.isEqual(to: copiedBrick))
        XCTAssertFalse(brick === copiedBrick)

        XCTAssertEqual(brick.spinnerSelection, copiedBrick.spinnerSelection)
    }

    func testBrickIsEqual() {
        let brick = GoToBrick()
        brick.spinnerSelection = kGoToTouchPosition
        let equalBrick = GoToBrick()
        equalBrick.spinnerSelection = kGoToTouchPosition

        XCTAssertTrue(brick.isEqual(to: equalBrick))

        let goToObject = SpriteObject()
        goToObject.name = "name"
        let scene = Scene(name: "testScene")
        goToObject.scene = scene
        let goToSpriteNode = CBSpriteNode(spriteObject: goToObject)
        goToObject.spriteNode = goToSpriteNode

        brick.spinnerSelection = kGoToOtherSpritePosition
        brick.goToObject = goToObject

        XCTAssertFalse(brick.isEqual(to: equalBrick))

        equalBrick.spinnerSelection = kGoToOtherSpritePosition
        equalBrick.goToObject = goToObject

        XCTAssertTrue(brick.isEqual(to: equalBrick))
    }

}
