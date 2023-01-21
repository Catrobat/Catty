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

final class CBSpriteNodeStitchExtensionTests: XCTestCase {

    var stage: Stage!
    var spriteNode: CBSpriteNode!
    var initialPosition: CGPoint!

    override func setUp() {
        let scene = Scene(name: "testScene")
        let object = SpriteObject()
        object.scene = scene
        spriteNode = CBSpriteNode(spriteObject: object)
        spriteNode.name = "testName"

        stage = StageBuilder(project: ProjectMock()).build()
        stage.addChild(spriteNode)

        initialPosition = CGPoint.zero
    }

    private func getAllLineShapeNodes() -> [LineShapeNode] {
        var allShapeNodes = [LineShapeNode]()
        stage.enumerateChildNodes(withName: SpriteKitDefines.stitchingLineShapeNodeName) { node, _ in
            guard let line = node as? LineShapeNode else {
                XCTFail("Could not cast SKNode to LineShapeNode")
                return
            }
            allShapeNodes.append(line)
        }
        return allShapeNodes
    }

    private func getAllPointShapeNodes() -> [CircleShapeNode] {
        var allShapeNodes = [CircleShapeNode]()
        stage.enumerateChildNodes(withName: SpriteKitDefines.stitchingPointShapeNodeName) { node, _ in
            guard let point = node as? CircleShapeNode else {
                XCTFail("Could not cast SKNode to CircleShapeNode")
                return
            }
            allShapeNodes.append(point)
        }
        return allShapeNodes
    }

    func testWhenSpritePositionChangedLine() {
        spriteNode.position = initialPosition
        spriteNode.embroideryStream.add(Stitch(atPosition: spriteNode.position))

        XCTAssertEqual(stage.children.count, 1)

        spriteNode.position = CGPoint(x: 1, y: 1)
        spriteNode.embroideryStream.add(Stitch(atPosition: spriteNode.position))

        spriteNode.update(CACurrentMediaTime())

        XCTAssertEqual(stage.children.count, 4)

        var allLineShapeNodes = getAllLineShapeNodes()

        XCTAssertEqual(allLineShapeNodes.count, 1)
        XCTAssertEqual(allLineShapeNodes[0].strokeColor, SpriteKitDefines.currentStitchingColor)
        XCTAssertEqual(allLineShapeNodes[0].pathStartPoint, initialPosition)
        XCTAssertEqual(allLineShapeNodes[0].pathEndPoint, spriteNode.position)

        spriteNode.position = CGPoint(x: 2, y: 2)
        spriteNode.embroideryStream.add(Stitch(atPosition: spriteNode.position))
        spriteNode.update(CACurrentMediaTime())

        XCTAssertEqual(stage.children.count, 6)

        allLineShapeNodes = getAllLineShapeNodes()

        XCTAssertEqual(allLineShapeNodes.count, 2)
        XCTAssertEqual(allLineShapeNodes[1].pathStartPoint, CGPoint(x: 1, y: 1))
        XCTAssertEqual(allLineShapeNodes[1].pathEndPoint, CGPoint(x: 2, y: 2))
    }

    func testWhenSpritePositionChangedPoint() {
        spriteNode.position = initialPosition
        spriteNode.embroideryStream.add(Stitch(atPosition: spriteNode.position))

        XCTAssertEqual(stage.children.count, 1)

        spriteNode.position = CGPoint(x: 1, y: 1)
        spriteNode.embroideryStream.add(Stitch(atPosition: spriteNode.position))
        spriteNode.update(CACurrentMediaTime())

        XCTAssertEqual(stage.children.count, 4)

        var allPointShapeNodes = getAllPointShapeNodes()

        XCTAssertEqual(allPointShapeNodes.count, 2)
        XCTAssertEqual(allPointShapeNodes[0].strokeColor, SpriteKitDefines.currentStitchingColor)
        XCTAssertEqual(allPointShapeNodes[0].fillColor, SpriteKitDefines.currentStitchingColor)
        XCTAssertEqual(allPointShapeNodes[0].point, initialPosition)

        spriteNode.position = CGPoint(x: 2, y: 2)
        let third = Stitch(atPosition: spriteNode.position)
        spriteNode.embroideryStream.add(third)
        spriteNode.update(CACurrentMediaTime())

        XCTAssertEqual(stage.children.count, 6)

        allPointShapeNodes = getAllPointShapeNodes()

        XCTAssertEqual(allPointShapeNodes.count, 3)
        XCTAssertEqual(allPointShapeNodes[1].point, CGPoint(x: 1, y: 1))
        XCTAssertEqual(allPointShapeNodes[2].point, CGPoint(x: 2, y: 2))
    }

    func testWhenSpritePositionNotChanged() {
        spriteNode.position = initialPosition

        XCTAssertEqual(stage.children.count, 1)

        spriteNode.update(CACurrentMediaTime())

        XCTAssertEqual(stage.children.count, 1)
    }

    func testDrawnLineAttributes() {
        let secondPosition = CGPoint(x: 1, y: 1)
        let thirdPosition = CGPoint(x: 2, y: 2)

        spriteNode.position = initialPosition
        spriteNode.embroideryStream.add(Stitch(atPosition: spriteNode.position))

        spriteNode.position = secondPosition
        spriteNode.embroideryStream.add(Stitch(atPosition: spriteNode.position))

        spriteNode.update(CACurrentMediaTime())

        spriteNode.position = thirdPosition
        spriteNode.embroideryStream.add(Stitch(atPosition: spriteNode.position))

        spriteNode.update(CACurrentMediaTime())

        XCTAssertEqual(stage.children.count, 6)

        let lines = getAllLineShapeNodes()
        XCTAssertEqual(lines.count, 2)

        let firstLine = lines.first!

        XCTAssertEqual(firstLine.name, SpriteKitDefines.stitchingLineShapeNodeName)
        XCTAssertEqual(firstLine.strokeColor, SpriteKitDefines.currentStitchingColor)
        XCTAssertEqual(firstLine.zPosition, SpriteKitDefines.defaultStitchingZPosition)
        XCTAssertEqual(firstLine.pathStartPoint, initialPosition)
        XCTAssertEqual(firstLine.pathEndPoint, secondPosition)

        let secondLine = lines[1]

        XCTAssertEqual(secondLine.name, SpriteKitDefines.stitchingLineShapeNodeName)
        XCTAssertEqual(secondLine.zPosition, SpriteKitDefines.defaultStitchingZPosition)
        XCTAssertEqual(secondLine.pathStartPoint, secondPosition)
        XCTAssertEqual(secondLine.pathEndPoint, thirdPosition)
    }

    func testDrawnPointAttributes() {
        spriteNode.position = initialPosition
        spriteNode.embroideryStream.add(Stitch(atPosition: spriteNode.position))

        spriteNode.position = CGPoint(x: 1, y: 1)
        spriteNode.embroideryStream.add(Stitch(atPosition: spriteNode.position))

        spriteNode.update(CACurrentMediaTime())

        XCTAssertEqual(stage.children.count, 4)

        let points = getAllPointShapeNodes()
        XCTAssertEqual(points.count, 2)

        let firstPoint = points.first!

        XCTAssertEqual(firstPoint.name, SpriteKitDefines.stitchingPointShapeNodeName)
        XCTAssertEqual(firstPoint.strokeColor, SpriteKitDefines.currentStitchingColor)
        XCTAssertEqual(firstPoint.fillColor, SpriteKitDefines.currentStitchingColor)
        XCTAssertEqual(firstPoint.zPosition, SpriteKitDefines.defaultStitchingZPosition)
        XCTAssertEqual(firstPoint.point, initialPosition)

        let secondPoint = points[1]

        XCTAssertEqual(secondPoint.name, SpriteKitDefines.stitchingPointShapeNodeName)
        XCTAssertEqual(secondPoint.zPosition, SpriteKitDefines.defaultStitchingZPosition)
        XCTAssertEqual(secondPoint.point, spriteNode.position)
    }

    func testEmbroideryChildNodesDrawOnlyOnce() {
        spriteNode.position = initialPosition
        spriteNode.embroideryStream.add(Stitch(atPosition: spriteNode.position))

        spriteNode.position = CGPoint(x: 1, y: 1)
        spriteNode.embroideryStream.add(Stitch(atPosition: spriteNode.position))

        spriteNode.update(CACurrentMediaTime())
        spriteNode.update(CACurrentMediaTime())

        let childNodes = stage.children
        XCTAssertEqual(childNodes.count, 4)

        XCTAssertEqual(childNodes[0].name!, spriteNode.name!)
        XCTAssertEqual(childNodes[1].name, SpriteKitDefines.stitchingPointShapeNodeName)
        XCTAssertEqual(childNodes[2].name, SpriteKitDefines.stitchingPointShapeNodeName)
        XCTAssertEqual(childNodes[3].name, SpriteKitDefines.stitchingLineShapeNodeName)
    }

    func testClearDrawEmbroideryQueueStack() {
        spriteNode.position = initialPosition
        spriteNode.embroideryStream.add(Stitch(atPosition: spriteNode.position))

        XCTAssertEqual(spriteNode.embroideryStream.drawEmbroideryQueue.count, 1)

        spriteNode.update(CACurrentMediaTime())

        XCTAssertEqual(spriteNode.embroideryStream.drawEmbroideryQueue.count, 1)

        spriteNode.position = CGPoint(x: 1, y: 1)
        spriteNode.embroideryStream.add(Stitch(atPosition: spriteNode.position))

        XCTAssertEqual(spriteNode.embroideryStream.drawEmbroideryQueue.count, 2)

        spriteNode.update(CACurrentMediaTime())

        XCTAssertEqual(spriteNode.embroideryStream.drawEmbroideryQueue.count, 1)
    }

    func testIsDrawn() {
        spriteNode.position = initialPosition
        spriteNode.embroideryStream.add(Stitch(atPosition: spriteNode.position))

        spriteNode.position = CGPoint(x: 1, y: 1)
        spriteNode.embroideryStream.add(Stitch(atPosition: spriteNode.position))

        XCTAssertEqual(spriteNode.embroideryStream.count, 2)
        XCTAssertFalse(spriteNode.embroideryStream[0].isDrawn)
        XCTAssertFalse(spriteNode.embroideryStream[1].isDrawn)

        spriteNode.update(CACurrentMediaTime())

        XCTAssertEqual(spriteNode.embroideryStream.count, 2)
        XCTAssertTrue(spriteNode.embroideryStream[0].isDrawn)
        XCTAssertTrue(spriteNode.embroideryStream[1].isDrawn)
    }

    func testDrawInterpolatedStitches() {
        spriteNode.position = initialPosition
        spriteNode.embroideryStream.add(Stitch(atPosition: spriteNode.position))

        spriteNode.position = CGPoint(x: 100, y: 100)
        spriteNode.embroideryStream.add(Stitch(atPosition: spriteNode.position))

        let interpolatedStitches = spriteNode.embroideryStream.filter { $0.isInterpolated }
        XCTAssertFalse(interpolatedStitches.isEmpty)

        spriteNode.update(CACurrentMediaTime())

        XCTAssertEqual(stage.children.count, 4 + interpolatedStitches.count)
    }
}
