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

final class SpriteBubbleConstraintsTests: XCTestCase {

    var parent: CBSpriteNodeMock!
    var child: SKNode!
    var bubbleConstraint: SpriteBubbleConstraint!

    override func setUp() {
        let object = SpriteObject()
        let scene = Scene(name: "testScene")
        object.scene = scene
        parent = CBSpriteNodeMock(spriteObject: object)
        parent.mockedStage = StageBuilder(project: ProjectMock(width: CGFloat(kIphoneXStageWidth), andHeight: CGFloat(kIphoneXStageHeight))).build()

        BubbleBrickHelper.addBubble(to: parent, withText: "Hello", andType: CBBubbleType.thought)
        child = parent.children.first!

        bubbleConstraint = SpriteBubbleConstraint(bubble: child,
                                                  parent: parent,
                                                  width: 200,
                                                  height: 200,
                                                  position: CGPoint(x: 300, y: 400),
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

    func testRightXCollision() {
        XCTAssertEqual(child.xScale, 1)
        parent.position.x = 1000
        bubbleConstraint.apply()
        XCTAssertEqual(child.xScale, -1)
    }

    func testLeftXCollision() {
        parent.position.x = 1000
        bubbleConstraint.apply()
        parent.position.x = -1000
        bubbleConstraint.apply()
        XCTAssertEqual(child.xScale, 1)
    }
}
