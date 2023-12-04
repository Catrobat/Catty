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

final class CBSpriteNodePenExtensionTests: XCTestCase {

    var stage: Stage!
    var spriteNode: CBSpriteNode!
    var initialPosition: CGPoint!

    override func setUp() {
        let scene = Scene(name: "testScene")
        let object = SpriteObject()
        object.scene = scene
        spriteNode = CBSpriteNode(spriteObject: object)
        spriteNode.name = "testName"

        stage = StageBuilder(scene: ProjectMock().scenes[0] as! Scene).build()
        stage.addChild(spriteNode)

        initialPosition = CGPoint.zero
    }

    private func getAllLineShapeNodes() -> [LineShapeNode] {
        var allShapeNodes = [LineShapeNode]()
        stage.enumerateChildNodes(withName: SpriteKitDefines.penShapeNodeName) { node, _ in
            guard let line = node as? LineShapeNode else {
                XCTFail("Could not cast SKNode to LineShapeNode")
                return
            }
            allShapeNodes.append(line)
        }
        return allShapeNodes
    }

    func testWhenSpritePositionChangedPenUp() {
        spriteNode.penConfiguration.penDown = false
        spriteNode.position = CGPoint(x: 1, y: 1)

        XCTAssertEqual(stage.children.count, 1)

        spriteNode.update(CACurrentMediaTime())

        XCTAssertEqual(stage.children.count, 1)
    }

    func testWhenSpritePositionChangedPenDown() {
        spriteNode.penConfiguration.penDown = true
        spriteNode.penConfiguration.previousPositions.append(initialPosition)
        spriteNode.position = initialPosition

        XCTAssertEqual(stage.children.count, 1)

        spriteNode.position = CGPoint(x: 1, y: 1)
        spriteNode.update(CACurrentMediaTime())

        XCTAssertEqual(stage.children.count, 2)

        var allShapeNodes = getAllLineShapeNodes()

        XCTAssertEqual(allShapeNodes.count, 1)
        XCTAssertEqual(allShapeNodes[0].lineWidth, spriteNode.penConfiguration.size, accuracy: CGFloat(0.01))
        XCTAssertEqual(allShapeNodes[0].strokeColor, SpriteKitDefines.defaultPenColor)
        XCTAssertEqual(allShapeNodes[0].pathStartPoint, initialPosition)
        XCTAssertEqual(allShapeNodes[0].pathEndPoint, spriteNode.position)

        spriteNode.position = CGPoint(x: 2, y: 2)
        spriteNode.update(CACurrentMediaTime())

        XCTAssertEqual(stage.children.count, 3)

        allShapeNodes = getAllLineShapeNodes()

        XCTAssertEqual(allShapeNodes.count, 2)
        XCTAssertEqual(allShapeNodes[1].pathStartPoint, CGPoint(x: 1, y: 1))
        XCTAssertEqual(allShapeNodes[1].pathEndPoint, spriteNode.position)

    }

    func testWhenSpritePositionNotChangedPenUp() {
        spriteNode.penConfiguration.penDown = false
        spriteNode.position = initialPosition

        XCTAssertEqual(stage.children.count, 1)

        spriteNode.update(CACurrentMediaTime())

        XCTAssertEqual(stage.children.count, 1)
    }

    func testWhenSpritePositionNotChangedPenDown() {
        spriteNode.penConfiguration.penDown = true
        spriteNode.position = initialPosition

        XCTAssertEqual(stage.children.count, 1)

        spriteNode.update(CACurrentMediaTime())

        XCTAssertEqual(stage.children.count, 1)
    }

    func testDrawnLineAttributes() {
        spriteNode.penConfiguration.penDown = true
        spriteNode.penConfiguration.previousPositions.append(initialPosition)
        spriteNode.penConfiguration.color = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)

        spriteNode.penConfiguration.catrobatSize = 5.0

        spriteNode.position = CGPoint(x: 1, y: 1)
        spriteNode.update(CACurrentMediaTime())

        XCTAssertEqual(stage.children.count, 2)

        guard let line = stage.childNode(withName: SpriteKitDefines.penShapeNodeName) as? LineShapeNode else {
            XCTFail("LineShapeNode for the drawn line not found with default name")
            return
        }

        XCTAssertEqual(line.lineWidth, CGFloat(5.0 * PenConfiguration.sizeConversionFactor), accuracy: CGFloat(0.01))
        XCTAssertEqual(line.strokeColor, UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0))
        XCTAssertEqual(line.zPosition, SpriteKitDefines.defaultPenZPosition)
    }
}
