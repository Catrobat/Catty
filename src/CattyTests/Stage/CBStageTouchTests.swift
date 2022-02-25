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

open class MockTouch: UITouch {
    var point: CGPoint!
    var lastNodeName: String!

    public init(point: CGPoint) {
        self.point = point
    }

    override open func location(in view: UIView?) -> CGPoint {
        self.point
    }

    override open func location(in node: SKNode) -> CGPoint {
        self.lastNodeName = node.name
        return self.point
    }
}

open class MockImage: UIImage {
    public convenience init?(size: CGSize) {
        let rect = CGRect(origin: .zero, size: size)
        let color = UIColor.black
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }

    override open func isTransparentPixel(at point: CGPoint) -> Bool {
        false
    }
}

final class CBSceneTouchTests: XCTestCase {

    var stage: Stage!
    var spriteNodeA: CBSpriteNode!
    var spriteNodeB: CBSpriteNode!

    override func setUp() {
        stage = StageBuilder(project: ProjectMock(width: 400, andHeight: 800)).build()
        stage.scheduler.running = true

        let look = Look(name: "Look", filePath: "Look")

        let scene = Scene(name: "testScene")
        let spriteObjectA = SpriteObject()
        spriteObjectA.scene = scene
        spriteObjectA.name = "SpriteObjectA"
        spriteObjectA.add(look, andSaveToDisk: false)
        spriteNodeA = CBSpriteNode(spriteObject: spriteObjectA)
        spriteNodeA.currentUIImageLook = MockImage(size: CGSize(width: 100, height: 100))

        let spriteObjectB = SpriteObject()
        spriteObjectB.scene = scene
        spriteObjectB.name = "SpriteObjectB"
        spriteObjectB.add(look, andSaveToDisk: false)
        spriteNodeB = CBSpriteNode(spriteObject: spriteObjectB)
        spriteNodeB.currentUIImageLook = MockImage(size: CGSize(width: 100, height: 100))
    }

    func testTouchedWithTouch() {
        spriteNodeA.size = CGSize(width: 10, height: 10)
        spriteNodeA.position = CGPoint(x: 10, y: 10)
        stage.addChild(spriteNodeA)

        var touch = MockTouch(point: CGPoint(x: 10, y: 10))
        var touchResult = stage.touchedWithTouch(touch)
        XCTAssertTrue(touchResult, "Error while detecting touch event")
        XCTAssertEqual(spriteNodeA.name, touch.lastNodeName, "Invalid object touched")

        touch = MockTouch(point: CGPoint(x: 21, y: 21))
        touchResult = stage.touchedWithTouch(touch)
        XCTAssertFalse(touchResult, "Error while detecting touch event")
        XCTAssertNotEqual(spriteNodeA.name, touch.lastNodeName, "Invalid object touched")
    }

    func testZPosition() {
        spriteNodeA.size = CGSize(width: 10, height: 10)
        spriteNodeA.position = CGPoint(x: 10, y: 10)
        spriteNodeA.zPosition = 1
        stage.addChild(spriteNodeA)

        spriteNodeB.size = spriteNodeA.size
        spriteNodeB.position = spriteNodeA.position
        spriteNodeB.zPosition = 2
        stage.addChild(spriteNodeB)

        let touch = MockTouch(point: CGPoint(x: 10, y: 10))
        let nodes = stage.nodes(at: touch.point)
        XCTAssertEqual(2, nodes.count, "Invalid number of nodes")

        var touchResult = stage.touchedWithTouch(touch)
        XCTAssertTrue(touchResult, "Error while detecting touch event")
        XCTAssertEqual(spriteNodeB.name, touch.lastNodeName, "Invalid object touched")

        spriteNodeA.zPosition = 10
        touchResult = stage.touchedWithTouch(touch)
        XCTAssertTrue(touchResult, "Error while detecting touch event")
        XCTAssertEqual(spriteNodeA.name, touch.lastNodeName, "Invalid object touched")

        touchResult = stage.touchedWithTouch(MockTouch(point: CGPoint(x: 21, y: 21)))
        XCTAssertFalse(touchResult, "Error while detecting touch event")
    }

    func testSKSpriteNode() {
        let nonSpriteObject = SKSpriteNode()
        nonSpriteObject.size = CGSize(width: 10, height: 10)
        nonSpriteObject.position = CGPoint(x: 10, y: 10)
        stage.addChild(nonSpriteObject)

        let touch = MockTouch(point: CGPoint(x: 10, y: 10))
        let nodes = stage.nodes(at: touch.point)
        XCTAssertEqual(1, nodes.count, "Invalid number of nodes")

        let touchResult = stage.touchedWithTouch(touch)
        XCTAssertFalse(touchResult, "Error while detecting touch event")
    }
}
