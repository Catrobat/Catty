/**
 *  Copyright (C) 2010-2017 The Catrobat Team
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

public class MockTouch : UITouch {
    var point : CGPoint!
    var lastNodeName : String!
    
    public init(point: CGPoint) {
        self.point = point
    }
    
    override public func locationInView(view: UIView?) -> CGPoint {
        return self.point
    }
    
    override public func locationInNode(node: SKNode) -> CGPoint {
        self.lastNodeName = node.name
        return self.point
    }
}

public class MockImage : UIImage {
    public convenience init?(size: CGSize) {
        let rect = CGRect(origin: .zero, size: size)
        let color = UIColor.blackColor()
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.CGImage else { return nil }
        self.init(CGImage: cgImage)
    }
    
    override public func isTransparentPixelAtPoint(point : CGPoint) -> Bool {
        return false
    }
}

final class CBSceneTouchTests: XCTestCase {

    var scene : CBScene!
    var spriteNodeA : CBSpriteNode!
    var spriteNodeB : CBSpriteNode!
    
    override func setUp() {
        let logger = CBLogger(name: "Logger")
        let broadcastHandler = CBBroadcastHandler(logger: logger)
        let scheduler = CBScheduler(logger: logger, broadcastHandler: broadcastHandler)
        scheduler.running = true
        
        scene = CBScene(size: CGSize(width: 400, height: 800), logger: logger, scheduler: scheduler, frontend: CBFrontend(logger: logger, program: nil),
                        backend: CBBackend(logger: logger), broadcastHandler: broadcastHandler)
        
        let look = Look()
        look.name = "Look"
        
        let spriteObjectA = SpriteObject()
        spriteObjectA.name = "SpriteObjectA"
        spriteObjectA.addLook(look, andSaveToDisk: false)
        spriteNodeA = CBSpriteNode(spriteObject: spriteObjectA)
        spriteNodeA.currentUIImageLook = MockImage(size: CGSizeMake(100, 100))
        
        let spriteObjectB = SpriteObject()
        spriteObjectB.name = "SpriteObjectB"
        spriteObjectB.addLook(look, andSaveToDisk: false)
        spriteNodeB = CBSpriteNode(spriteObject: spriteObjectB)
        spriteNodeB.currentUIImageLook = MockImage(size: CGSizeMake(100, 100))
    }
    
    func testTouchedWithTouch() {
        spriteNodeA.size = CGSizeMake(10, 10)
        spriteNodeA.position = CGPoint(x: 10, y: 10)
        scene.addChild(spriteNodeA)
        
        var touch = MockTouch(point: CGPoint(x: 10, y: 10))
        var touchResult = scene.touchedWithTouch(touch)
        XCTAssertTrue(touchResult, "Error while detecting touch event")
        XCTAssertEqual(spriteNodeA.name, touch.lastNodeName, "Invalid object touched")
        
        touch = MockTouch(point: CGPoint(x: 21, y: 21))
        touchResult = scene.touchedWithTouch(touch)
        XCTAssertFalse(touchResult, "Error while detecting touch event")
        XCTAssertNotEqual(spriteNodeA.name, touch.lastNodeName, "Invalid object touched")
    }
    
    func testZPosition() {
        spriteNodeA.size = CGSizeMake(10, 10)
        spriteNodeA.position = CGPoint(x: 10, y: 10)
        spriteNodeA.zPosition = 1
        scene.addChild(spriteNodeA)
        
        spriteNodeB.size = spriteNodeA.size
        spriteNodeB.position = spriteNodeA.position
        spriteNodeB.zPosition = 2
        scene.addChild(spriteNodeB)
        
        let touch = MockTouch(point: CGPoint(x: 10, y: 10))
        let nodes = scene.nodesAtPoint(touch.point)
        XCTAssertEqual(2, nodes.count, "Invalid number of nodes")
        
        var touchResult = scene.touchedWithTouch(touch)
        XCTAssertTrue(touchResult, "Error while detecting touch event")
        XCTAssertEqual(spriteNodeB.name, touch.lastNodeName, "Invalid object touched")
        
        spriteNodeA.zPosition = 10
        touchResult = scene.touchedWithTouch(touch)
        XCTAssertTrue(touchResult, "Error while detecting touch event")
        XCTAssertEqual(spriteNodeA.name, touch.lastNodeName, "Invalid object touched")
        
        touchResult = scene.touchedWithTouch(MockTouch(point: CGPoint(x: 21, y: 21)))
        XCTAssertFalse(touchResult, "Error while detecting touch event")
    }
    
    func testSKSpriteNode() {
        let nonSpriteObject = SKSpriteNode()
        nonSpriteObject.size = CGSizeMake(10, 10)
        nonSpriteObject.position = CGPoint(x: 10, y: 10)
        scene.addChild(nonSpriteObject)
        
        let touch = MockTouch(point: CGPoint(x: 10, y: 10))
        let nodes = scene.nodesAtPoint(touch.point)
        XCTAssertEqual(1, nodes.count, "Invalid number of nodes")
        
        let touchResult = scene.touchedWithTouch(touch)
        XCTAssertFalse(touchResult, "Error while detecting touch event")
    }
}
