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

final class IfOnEdgeBounceBrickTests: AbstractBrickTest {

    var spriteObject: SpriteObject!
    var script: Script!
    var brick: IfOnEdgeBounceBrick!

    static let SCREEN_WIDTH = CGFloat(480)
    static let SCREEN_HEIGHT = CGFloat(800)
    static let OBJECT_WIDTH = CGFloat(100)
    static let OBJECT_HEIGHT = CGFloat(100)
    static let TOP_BORDER_POSITION = SCREEN_HEIGHT / 2
    static let BOTTOM_BORDER_POSITION = -TOP_BORDER_POSITION
    static let RIGHT_BORDER_POSITION = SCREEN_WIDTH / 2
    static let LEFT_BORDER_POSITION = -RIGHT_BORDER_POSITION
    static let BOUNCE_TOP_POSITION = TOP_BORDER_POSITION - (OBJECT_HEIGHT / 2)
    static let BOUNCE_BOTTOM_POSITION = -(BOUNCE_TOP_POSITION)
    static let BOUNCE_RIGHT_POSITION = RIGHT_BORDER_POSITION - (OBJECT_WIDTH / 2)
    static let BOUNCE_LEFT_POSITION = -(BOUNCE_RIGHT_POSITION)
    static let EPSILON = CGFloat(0.001)

    override func setUp() {
        super.setUp()
        self.stage = StageBuilder(project: ProjectMock(width: IfOnEdgeBounceBrickTests.SCREEN_WIDTH, andHeight: IfOnEdgeBounceBrickTests.SCREEN_HEIGHT)).build()

        let scene = Scene(name: "testScene")
        self.spriteObject = SpriteObject()
        self.spriteObject.scene = scene
        let spriteNode = CBSpriteNode(spriteObject: self.spriteObject)
        self.stage.addChild(spriteNode)
        spriteNode.color = UIColor.black
        spriteNode.size = CGSize(width: IfOnEdgeBounceBrickTests.OBJECT_WIDTH, height: IfOnEdgeBounceBrickTests.OBJECT_HEIGHT)
        self.spriteObject.spriteNode = spriteNode
        spriteNode.catrobatPosition = CBPosition(x: 0, y: 0)
        self.spriteObject.name = "Test"

        self.script = WhenScript()
        self.script.object = self.spriteObject

        self.brick = IfOnEdgeBounceBrick()
        self.brick.script = self.script
    }

    func testNoBounce() {
        setPosition(position: CBPosition(x: 0, y: 0), rotation: 90.0)
        checkPosition(position: CBPosition(x: 0, y: 0), rotation: 90.0)
    }

    func testTopBounce() {
        let rotations: [(Double, Double)] = [(90.0, 90.0), (120.0, 120.0), (150.0, 150.0), (180.0, 180.0),
                                             (-150.0, -150.0), (-120.0, -120.0), (-90.0, -90.0), (-60.0, -120.0),
                                             (-30.0, -150.0), (0.0, 180.0), (30.0, 150.0), (60.0, 120.0)]

        for rotation in rotations {
            let rotationBefore = rotation.0
            let rotationAfter = rotation.1
            setPosition(position: CBPosition(x: 0, y: IfOnEdgeBounceBrickTests.TOP_BORDER_POSITION), rotation: rotationBefore)
            checkPosition(position: CBPosition(x: 0, y: IfOnEdgeBounceBrickTests.BOUNCE_TOP_POSITION), rotation: rotationAfter)
        }
    }

    func testBottomBounce() {
        let rotations: [(Double, Double)] = [(90.0, 90.0), (120.0, 60.0), (150.0, 30.0), (180.0, 0.0),
                                             (-150.0, -30.0), (-120.0, -60.0), (-90.0, -90.0), (-60.0, -60.0),
                                             (-30.0, -30.0), (0.0, 0.0), (30.0, 30.0), (60.0, 60.0)]

        for rotation in rotations {
            let rotationBefore = rotation.0
            let rotationAfter = rotation.1
            setPosition(position: CBPosition(x: 0, y: IfOnEdgeBounceBrickTests.BOTTOM_BORDER_POSITION), rotation: rotationBefore)
            checkPosition(position: CBPosition(x: 0, y: IfOnEdgeBounceBrickTests.BOUNCE_BOTTOM_POSITION), rotation: rotationAfter)
        }
    }

    func testLeftBounce() {
        let rotations: [(Double, Double)] = [(90.0, 90.0), (120.0, 120.0), (150.0, 150.0), (180.0, 180.0),
                                             (-150.0, 150.0), (-120.0, 120.0), (-90.0, 90.0), (-60.0, 60.0),
                                             (-30.0, 30.0), (0.0, 0.0), (30.0, 30.0), (60.0, 60.0)]

        for rotation in rotations {
            let rotationBefore = rotation.0
            let rotationAfter = rotation.1
            setPosition(position: CBPosition(x: IfOnEdgeBounceBrickTests.LEFT_BORDER_POSITION, y: 0), rotation: rotationBefore)
            checkPosition(position: CBPosition(x: IfOnEdgeBounceBrickTests.BOUNCE_LEFT_POSITION, y: 0), rotation: rotationAfter)
        }
    }

    func testRightBounce() {
        let rotations: [(Double, Double)] = [(90.0, -90.0), (120.0, -120.0), (150.0, -150.0), (180.0, 180.0),
                                             (-150.0, -150.0), (-120.0, -120.0), (-90.0, -90.0), (-60.0, -60.0),
                                             (-30.0, -30.0), (0.0, 0.0), (30.0, -30.0), (60.0, -60.0)]

        for rotation in rotations {
            let rotationBefore = rotation.0
            let rotationAfter = rotation.1
            setPosition(position: CBPosition(x: IfOnEdgeBounceBrickTests.RIGHT_BORDER_POSITION, y: 0), rotation: rotationBefore)
            checkPosition(position: CBPosition(x: IfOnEdgeBounceBrickTests.BOUNCE_RIGHT_POSITION, y: 0), rotation: rotationAfter)
        }
    }

    func testUpLeftBounce() {
        setPosition(position: CBPosition(x: IfOnEdgeBounceBrickTests.LEFT_BORDER_POSITION, y: IfOnEdgeBounceBrickTests.TOP_BORDER_POSITION), rotation: 135)
        checkPosition(position: CBPosition(x: IfOnEdgeBounceBrickTests.BOUNCE_LEFT_POSITION, y: IfOnEdgeBounceBrickTests.BOUNCE_TOP_POSITION), rotation: 135)

        setPosition(position: CBPosition(x: IfOnEdgeBounceBrickTests.LEFT_BORDER_POSITION, y: IfOnEdgeBounceBrickTests.TOP_BORDER_POSITION), rotation: -45)
        checkPosition(position: CBPosition(x: IfOnEdgeBounceBrickTests.BOUNCE_LEFT_POSITION, y: IfOnEdgeBounceBrickTests.BOUNCE_TOP_POSITION), rotation: 135)
    }

    func testUpRightBounce() {
        setPosition(position: CBPosition(x: IfOnEdgeBounceBrickTests.RIGHT_BORDER_POSITION, y: IfOnEdgeBounceBrickTests.TOP_BORDER_POSITION), rotation: -135)
        checkPosition(position: CBPosition(x: IfOnEdgeBounceBrickTests.BOUNCE_RIGHT_POSITION, y: IfOnEdgeBounceBrickTests.BOUNCE_TOP_POSITION), rotation: -135)

        setPosition(position: CBPosition(x: IfOnEdgeBounceBrickTests.RIGHT_BORDER_POSITION, y: IfOnEdgeBounceBrickTests.TOP_BORDER_POSITION), rotation: -45)
        checkPosition(position: CBPosition(x: IfOnEdgeBounceBrickTests.BOUNCE_RIGHT_POSITION, y: IfOnEdgeBounceBrickTests.BOUNCE_TOP_POSITION), rotation: -135)
    }

    func testBottomLeftBounce() {
        setPosition(position: CBPosition(x: IfOnEdgeBounceBrickTests.LEFT_BORDER_POSITION, y: IfOnEdgeBounceBrickTests.BOTTOM_BORDER_POSITION), rotation: 45)
        checkPosition(position: CBPosition(x: IfOnEdgeBounceBrickTests.BOUNCE_LEFT_POSITION, y: IfOnEdgeBounceBrickTests.BOUNCE_BOTTOM_POSITION), rotation: 45)

        setPosition(position: CBPosition(x: IfOnEdgeBounceBrickTests.LEFT_BORDER_POSITION, y: IfOnEdgeBounceBrickTests.BOTTOM_BORDER_POSITION), rotation: -135)
        checkPosition(position: CBPosition(x: IfOnEdgeBounceBrickTests.BOUNCE_LEFT_POSITION, y: IfOnEdgeBounceBrickTests.BOUNCE_BOTTOM_POSITION), rotation: 45)
    }

    func testBottomRightBounce() {
        setPosition(position: CBPosition(x: IfOnEdgeBounceBrickTests.RIGHT_BORDER_POSITION, y: IfOnEdgeBounceBrickTests.BOTTOM_BORDER_POSITION), rotation: -45)
        checkPosition(position: CBPosition(x: IfOnEdgeBounceBrickTests.BOUNCE_RIGHT_POSITION, y: IfOnEdgeBounceBrickTests.BOUNCE_BOTTOM_POSITION), rotation: -45)

        setPosition(position: CBPosition(x: IfOnEdgeBounceBrickTests.RIGHT_BORDER_POSITION, y: IfOnEdgeBounceBrickTests.BOTTOM_BORDER_POSITION), rotation: 135)
        checkPosition(position: CBPosition(x: IfOnEdgeBounceBrickTests.BOUNCE_RIGHT_POSITION, y: IfOnEdgeBounceBrickTests.BOUNCE_BOTTOM_POSITION), rotation: -45)
    }

    func testIsLookingDown() {
        XCTAssertFalse(self.brick.isLookingDown(0), "Brick should not be looking down")
        XCTAssertFalse(self.brick.isLookingDown(360), "Brick should not be looking down")
        XCTAssertFalse(self.brick.isLookingDown(45), "Brick should not be looking down")
        XCTAssertFalse(self.brick.isLookingDown(-45), "Brick should not be looking down")
        XCTAssertFalse(self.brick.isLookingDown(315), "Brick should not be looking down")
        XCTAssertFalse(self.brick.isLookingDown(90), "Brick should not be looking down")
        XCTAssertFalse(self.brick.isLookingDown(-90), "Brick should not be looking down")
        XCTAssertFalse(self.brick.isLookingDown(270), "Brick should not be looking down")
        XCTAssertTrue(self.brick.isLookingDown(180), "Brick should be looking down")
        XCTAssertTrue(self.brick.isLookingDown(91), "Brick should be looking down")
        XCTAssertTrue(self.brick.isLookingDown(-91), "Brick should be looking down")
        XCTAssertTrue(self.brick.isLookingDown(150), "Brick should be looking down")
        XCTAssertTrue(self.brick.isLookingDown(179), "Brick should be looking down")
    }

    func testIsLookingUp() {
        XCTAssertFalse(self.brick.isLookingUp(180), "Brick should not be looking up")
        XCTAssertFalse(self.brick.isLookingUp(540), "Brick should not be looking up")
        XCTAssertFalse(self.brick.isLookingUp(135), "Brick should not be looking up")
        XCTAssertFalse(self.brick.isLookingUp(-135), "Brick should not be looking up")
        XCTAssertFalse(self.brick.isLookingUp(225), "Brick should not be looking up")
        XCTAssertFalse(self.brick.isLookingUp(90), "Brick should not be looking up")
        XCTAssertFalse(self.brick.isLookingUp(-90), "Brick should not be looking up")
        XCTAssertFalse(self.brick.isLookingUp(270), "Brick should not be looking up")
        XCTAssertTrue(self.brick.isLookingUp(0), "Brick should be looking up")
        XCTAssertTrue(self.brick.isLookingUp(360), "Brick should be looking up")
        XCTAssertTrue(self.brick.isLookingUp(89), "Brick should be looking up")
        XCTAssertTrue(self.brick.isLookingUp(-89), "Brick should be looking up")
        XCTAssertTrue(self.brick.isLookingUp(1), "Brick should be looking up")
    }

    func testIsLookingLeft() {
        XCTAssertFalse(self.brick.isLookingLeft(0), "Brick should not be looking left")
        XCTAssertFalse(self.brick.isLookingLeft(360), "Brick should not be looking left")
        XCTAssertFalse(self.brick.isLookingLeft(180), "Brick should not be looking left")
        XCTAssertFalse(self.brick.isLookingLeft(-180), "Brick should not be looking left")
        XCTAssertFalse(self.brick.isLookingLeft(45), "Brick should not be looking left")
        XCTAssertFalse(self.brick.isLookingLeft(135), "Brick should not be looking left")
        XCTAssertFalse(self.brick.isLookingLeft(-270), "Brick should not be looking left")
        XCTAssertTrue(self.brick.isLookingLeft(-10), "Brick should be looking left")
        XCTAssertTrue(self.brick.isLookingLeft(181), "Brick should be looking left")
        XCTAssertTrue(self.brick.isLookingLeft(359), "Brick should be looking left")
        XCTAssertTrue(self.brick.isLookingLeft(270), "Brick should be looking left")
    }

    func testIsLookingRight() {
        XCTAssertFalse(self.brick.isLookingRight(0), "Brick should not be looking right")
        XCTAssertFalse(self.brick.isLookingRight(360), "Brick should not be looking right")
        XCTAssertFalse(self.brick.isLookingRight(180), "Brick should not be looking right")
        XCTAssertFalse(self.brick.isLookingRight(-180), "Brick should not be looking right")
        XCTAssertFalse(self.brick.isLookingRight(270), "Brick should not be looking right")
        XCTAssertFalse(self.brick.isLookingRight(-45), "Brick should not be looking right")
        XCTAssertTrue(self.brick.isLookingRight(1), "Brick should not be looking right")
        XCTAssertTrue(self.brick.isLookingRight(179), "Brick should not be looking right")
        XCTAssertTrue(self.brick.isLookingRight(-270), "Brick should be looking right")
        XCTAssertTrue(self.brick.isLookingRight(90), "Brick should be looking right")
    }

    private func setPosition(position: CBPosition, rotation: Double) {
        self.spriteObject.spriteNode.catrobatPosition = position
        self.spriteObject.spriteNode.catrobatRotation = rotation

        let action = brick.actionBlock()
        action()
    }

    private func checkPosition(position: CBPosition, rotation: Double) {
        XCTAssertEqual(position.x, self.spriteObject.spriteNode.catrobatPosition.x, accuracy: Double(IfOnEdgeBounceBrickTests.EPSILON), "Wrong x after bounce")
        XCTAssertEqual(position.y, self.spriteObject.spriteNode.catrobatPosition.y, accuracy: Double(IfOnEdgeBounceBrickTests.EPSILON), "Wrong y after bounce")
        XCTAssertEqual(rotation, self.spriteObject.spriteNode.catrobatRotation, accuracy: Double(IfOnEdgeBounceBrickTests.EPSILON), "Wrong rotation after bounce")
    }

    func testMutableCopy() {
        brick = IfOnEdgeBounceBrick()

        let copiedBrick: IfOnEdgeBounceBrick = brick.mutableCopy(with: CBMutableCopyContext(), andErrorReporting: true) as! IfOnEdgeBounceBrick

        XCTAssertTrue(brick.isEqual(to: copiedBrick))
        XCTAssertFalse(brick === copiedBrick)
    }
}
