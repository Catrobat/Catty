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

final class PointToBrickTests: AbstractBrickTest {

    var firstSpriteNode: CBSpriteNode!
    var secondSpriteNode: CBSpriteNode!
    var script: Script!
    var brick: PointToBrick!

    override func setUp() {
        self.stage = StageBuilder(project: ProjectMock()).build()

        let firstObject = SpriteObject()
        let scene = Scene(name: "testScene")
        firstObject.scene = scene
        firstSpriteNode = CBSpriteNode(spriteObject: firstObject)
        firstObject.spriteNode = firstSpriteNode
        let secondObject = SpriteObject()
        secondObject.scene = scene
        secondSpriteNode = CBSpriteNode(spriteObject: secondObject)
        secondObject.spriteNode = secondSpriteNode

        self.stage.addChild(firstSpriteNode)
        self.stage.addChild(secondSpriteNode)

        script = WhenScript()
        script.object = firstObject

        brick = PointToBrick()
        brick.script = script
        brick.pointedObject = secondObject
    }

    func testPointToBrickZeroDegrees() {
        firstSpriteNode.setPositionForCropping(CGPoint(x: 0, y: 0))
        secondSpriteNode.setPositionForCropping(CGPoint(x: 0, y: 10))

        let dispatchBlock = brick.actionBlock()
        dispatchBlock()

        XCTAssertEqual(0, firstSpriteNode.catrobatRotation, accuracy: 0.1, "PointToBrick not correct")
    }

    func testPointToBrickSamePosition() {
        firstSpriteNode.setPositionForCropping(CGPoint(x: 0, y: 0))
        secondSpriteNode.setPositionForCropping(CGPoint(x: 0, y: 0))

        let dispatchBlock = brick.actionBlock()
        dispatchBlock()

        XCTAssertEqual(0, firstSpriteNode.catrobatRotation, accuracy: 0.1, "PointToBrick not correct")
    }

    func testPointToBrick45Degrees() {
        firstSpriteNode.setPositionForCropping(CGPoint(x: 0, y: 0))
        secondSpriteNode.setPositionForCropping(CGPoint(x: 1, y: 1))

        let dispatchBlock = brick.actionBlock()
        dispatchBlock()

        XCTAssertEqual(45.0, firstSpriteNode.catrobatRotation, accuracy: 0.1, "PointToBrick not correct")
    }

    func testMutableCopy() {
        let brick = PointToBrick()
        let script = Script()
        let object = SpriteObject()
        let scene = Scene(name: "testScene")
        object.scene = scene

        script.object = object
        brick.script = script
        let pointedObject = SpriteObject()
        pointedObject.name = "pointedObject"
        brick.pointedObject = pointedObject

        let copiedBrick: PointToBrick = brick.mutableCopy(with: CBMutableCopyContext(), andErrorReporting: true) as! PointToBrick

        XCTAssertTrue(brick.isEqual(to: copiedBrick))
        XCTAssertFalse(brick === copiedBrick)
        XCTAssertTrue(brick.pointedObject.isEqual(to: copiedBrick.pointedObject))
        XCTAssertTrue(brick.pointedObject === copiedBrick.pointedObject)
    }

}
