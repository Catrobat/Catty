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

final class StampBrickTests: XCTestCase {

    func testStampBrick() {
        let stage = StageBuilder(project: ProjectMock()).build()

        let object = SpriteObject()
        let scene = Scene()
        object.scene = scene
        let spriteNode = CBSpriteNode(spriteObject: object)
        object.spriteNode = spriteNode

        stage.addChild(spriteNode)

        let script = Script()
        script.object = object

        let brick = StampBrick()
        brick.script = script

        let action = brick.actionBlock()
        XCTAssertEqual(stage.children.count, 1)
        XCTAssertNil(stage.childNode(withName: SpriteKitDefines.stampedSpriteNodeName))
        action()

        XCTAssertEqual(stage.children.count, 2)
        let stampedSpriteNode = stage.childNode(withName: SpriteKitDefines.stampedSpriteNodeName) as? SKSpriteNode
        XCTAssertNotNil(stampedSpriteNode)
        XCTAssertEqual(stampedSpriteNode?.position, spriteNode.position)
        XCTAssertEqual(stampedSpriteNode?.zPosition, spriteNode.zPosition)
        XCTAssertEqual(stampedSpriteNode?.zRotation, spriteNode.zRotation)
        XCTAssertEqual(stampedSpriteNode?.size, spriteNode.size)
        XCTAssertEqual(stampedSpriteNode?.alpha, spriteNode.alpha)

        spriteNode.position = CGPoint(x: 10, y: 20)
        spriteNode.zRotation = 90.0
        spriteNode.alpha = 0.5
        action()

        XCTAssertEqual(stage.children.count, 3)
        let stampedSpriteNode2 = stage.children[2] as? SKSpriteNode
        XCTAssertNotEqual(stampedSpriteNode?.position, spriteNode.position)
        XCTAssertNotEqual(stampedSpriteNode?.zRotation, spriteNode.zRotation)
        XCTAssertNotEqual(stampedSpriteNode?.alpha, spriteNode.alpha)
        XCTAssertEqual(stampedSpriteNode?.zPosition, spriteNode.zPosition)
        XCTAssertEqual(stampedSpriteNode?.size, spriteNode.size)

        XCTAssertEqual(stampedSpriteNode2?.position, spriteNode.position)
        XCTAssertEqual(stampedSpriteNode2?.zPosition, spriteNode.zPosition)
        XCTAssertEqual(stampedSpriteNode2?.zRotation, spriteNode.zRotation)
        XCTAssertEqual(stampedSpriteNode2?.size, spriteNode.size)
        XCTAssertEqual(stampedSpriteNode2?.alpha, spriteNode.alpha)
    }

}
