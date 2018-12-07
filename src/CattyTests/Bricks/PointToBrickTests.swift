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

final class PointToBrickTests: XCTestCase {
    var scene: CBScene?

    override func setUp() {
        super.setUp()
        scene = SceneBuilder(program: ProgramMock()).build()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testPointToBrickZeroDegrees() {
        let firstObject = SpriteObject()
        let firstSpriteNode = CBSpriteNode(spriteObject: firstObject)
        firstObject.spriteNode = firstSpriteNode
        let secondObject = SpriteObject()
        let secondSpriteNode = CBSpriteNode(spriteObject: secondObject)
        secondObject.spriteNode = secondSpriteNode

        scene?.addChild(firstSpriteNode)
        scene?.addChild(secondSpriteNode)

        firstSpriteNode.position = CGPoint(x: 0, y: 0)
        secondSpriteNode.position = CGPoint(x: 0, y: 10)

        let script = WhenScript()
        script.object = firstObject

        let brick = PointToBrick()
        brick.script = script
        brick.pointedObject = secondObject

        let dispatchBlock: () -> Void = brick.actionBlock()
        dispatchBlock()

        XCTAssertEqual(0, firstSpriteNode.catrobatRotation, accuracy: 0.1, "PointToBrick not correct")
    }

    func testPointToBrickSamePosition() {
        let firstObject = SpriteObject()
        let firstSpriteNode = CBSpriteNode(spriteObject: firstObject)
        firstObject.spriteNode = firstSpriteNode
        let secondObject = SpriteObject()
        let secondSpriteNode = CBSpriteNode(spriteObject: secondObject)
        secondObject.spriteNode = secondSpriteNode

        scene?.addChild(firstSpriteNode)
        scene?.addChild(secondSpriteNode)

        firstSpriteNode.position = CGPoint(x: 0, y: 0)
        secondSpriteNode.position = CGPoint(x: 0, y: 0)

        let script = WhenScript()
        script.object = firstObject
        let brick = PointToBrick()
        brick.script = script
        brick.pointedObject = secondObject
        let dispatchBlock: () -> Void = brick.actionBlock()
        dispatchBlock()

        XCTAssertEqual(0, firstSpriteNode.catrobatRotation, accuracy: 0.1, "PointToBrick not correct")
    }

    func testPointToBrick45Degrees() {
        let firstObject = SpriteObject()
        let firstSpriteNode = CBSpriteNode(spriteObject: firstObject)
        firstObject.spriteNode = firstSpriteNode
        let secondObject = SpriteObject()
        let secondSpriteNode = CBSpriteNode(spriteObject: secondObject)
        secondObject.spriteNode = secondSpriteNode

        scene?.addChild(firstSpriteNode)
        scene?.addChild(secondSpriteNode)

        firstSpriteNode.position = CGPoint(x: 0, y: 0)
        secondSpriteNode.position = CGPoint(x: 1, y: 1)

        let script = WhenScript()
        script.object = firstObject

        let brick = PointToBrick()
        brick.script = script
        brick.pointedObject = secondObject
        let dispatchBlock: () -> Void = brick.actionBlock()
        dispatchBlock()

        XCTAssertEqual(45.0, firstSpriteNode.catrobatRotation, accuracy: 0.1, "PointToBrick not correct")
    }
}
