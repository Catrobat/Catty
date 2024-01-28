/**
 *  Copyright (C) 2010-2024 The Catrobat Team
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

final class SpriteBubbleConstraintsTests: XCTestCase {

    var parent: CBSpriteNodeMock!
    var child: SKNode!
    var bubbleConstraint: SpriteBubbleConstraint!
    var bubbleInitialPosition: CGPoint!
    var bubbleInvertedInitialPosition: CGPoint!
    var bubbleSize: CGSize!

    override func setUp() {
        let object = SpriteObject()
        let scene = Scene(name: "testScene")
        object.scene = scene
        parent = CBSpriteNodeMock(spriteObject: object)
        parent.mockedStage = StageBuilder(scene: ProjectMock(width: CGFloat(kIphoneXStageWidth), andHeight: CGFloat(kIphoneXStageHeight)).scenes[0] as! Scene).build()

        BubbleBrickHelper.addBubble(to: parent, withText: "Hello", andType: CBBubbleType.thought)
        child = parent.children.first!

        bubbleInitialPosition = CGPoint(x: 300, y: 400)
        bubbleInvertedInitialPosition = CGPoint(x: -300, y: 400)
        bubbleSize = CGSize(width: 200, height: 200)

        bubbleConstraint = SpriteBubbleConstraint(bubble: child,
                                                  parent: parent,
                                                  width: bubbleSize.width,
                                                  height: bubbleSize.height,
                                                  position: bubbleInitialPosition,
                                                  invertedPosition: bubbleInvertedInitialPosition,
                                                  bubbleTailHeight: 48)

    }

    func testBubbleSize() {
        let newSize = CGFloat(300)
        parent.catrobatSize = Double(newSize)
        bubbleConstraint.apply()
        XCTAssertEqual(100 / newSize, child.yScale, accuracy: 0.000001)
    }

    func testBubbleRotation() {
        parent.zRotation = 120
        bubbleConstraint.apply()
        XCTAssertEqual(-parent.zRotation, child.zRotation, accuracy: 0.000001)
    }

    func testBubbleCollisionX() {
        let bubbleOffsetX = bubbleInitialPosition.x
        let bubbleWidth = bubbleSize.width
        let sceneWidth = parent.scene.frame.width
        let delta: CGFloat = 10

        let bubbleIntersectsRightSceneEdge = sceneWidth - bubbleWidth - bubbleOffsetX

        parent.position.x = bubbleIntersectsRightSceneEdge - delta
        bubbleConstraint.apply()
        XCTAssertEqual(child.xScale, 1)
        XCTAssertEqual(child.position.x, bubbleOffsetX, accuracy: delta)

        parent.position.x = bubbleIntersectsRightSceneEdge + delta
        bubbleConstraint.apply()
        XCTAssertEqual(child.xScale, -1)
        XCTAssertEqual(child.position.x, bubbleOffsetX, accuracy: delta)

        let bubbleIntersectsLeftSceneEdge = bubbleWidth + bubbleOffsetX

        parent.position.x = bubbleIntersectsLeftSceneEdge + delta
        bubbleConstraint.apply()
        XCTAssertEqual(child.xScale, -1)
        XCTAssertEqual(child.position.x, -bubbleOffsetX, accuracy: delta)

        parent.position.x = bubbleIntersectsLeftSceneEdge - delta
        bubbleConstraint.apply()
        XCTAssertEqual(child.xScale, 1)
        XCTAssertEqual(child.position.x, -bubbleOffsetX, accuracy: delta)
    }
}
