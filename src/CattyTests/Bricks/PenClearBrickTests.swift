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

final class PenClearBrickTests: XCTestCase {

    func testPenClearBrick() {
        let stage = StageBuilder(project: ProjectMock()).build()

        let line1 = LineShapeNode(pathStartPoint: CGPoint.zero, pathEndPoint: CGPoint(x: 1, y: 1))
        line1.name = SpriteKitDefines.penShapeNodeName
        stage.addChild(line1)

        let line2 = LineShapeNode(pathStartPoint: CGPoint(x: 1, y: 1), pathEndPoint: CGPoint(x: 2, y: 2))
        line2.name = SpriteKitDefines.penShapeNodeName
        stage.addChild(line2)

        let object = SpriteObject()
        let spriteNode = CBSpriteNode(spriteObject: object)
        spriteNode.name = "testName"
        object.spriteNode = spriteNode

        stage.addChild(spriteNode)

        let script = Script()
        script.object = object

        let brick = PenClearBrick()
        brick.script = script

        let action = brick.actionBlock()
        XCTAssertEqual(stage.children.count, 3)
        action()
        XCTAssertEqual(stage.children.count, 1)
        XCTAssertNil(stage.childNode(withName: SpriteKitDefines.penShapeNodeName))
        XCTAssertNotNil(stage.childNode(withName: "testName"))
    }

    func testRemoveAllPreviousPositions() {

        let object = SpriteObject()
        let spriteNode = CBSpriteNode(spriteObject: object)
        spriteNode.name = "testName"
        object.spriteNode = spriteNode

        let script = Script()
        script.object = object

        let brick = PenClearBrick()
        brick.script = script

        let action = brick.actionBlock()
        action()

        XCTAssertEqual(spriteNode.penConfiguration.previousPositions.count, 0)

    }

}
