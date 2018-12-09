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

final class IfOnEdgeBounceBrickTests: AbstractBrickTests {
    var spriteObject: SpriteObject?
    var script: Script?
    var brick: IfOnEdgeBounceBrick?

    var screenWidth: CGFloat?
    var screenHeight: CGFloat?
    var objectWidth: Double?
    var objectHeight: CGFloat?
    var topBorderPosition: CGFloat?
    var bottomBorderPosition: CGFloat?
    var rightBorderPosition: CGFloat?
    var leftBorderPosition: CGFloat?
    var bounceTopPosition: CGFloat?
    var bounceBottomPosition: CGFloat?
    var bounceRightPosition: CGFloat?
    var bounceLeftPosition: CGFloat?

    override func setUp() {
        super.setUp()

        screenWidth = 480
        screenHeight = 800
        objectWidth = 100
        objectHeight = 100
        topBorderPosition = screenHeight! / 2
        bottomBorderPosition = -1 * topBorderPosition!
        rightBorderPosition = screenWidth! / 2
        leftBorderPosition = -1 * rightBorderPosition!
        bounceTopPosition = topBorderPosition! - CGFloat(objectHeight! / 2)
        bounceBottomPosition = -1 * bounceTopPosition!
        bounceRightPosition = rightBorderPosition! - CGFloat(objectWidth! / 2)
        bounceLeftPosition = -1 * bounceRightPosition!

        scene = SceneBuilder(program: ProgramMock(width: screenWidth!, andHeight: screenHeight!)).build()
        spriteObject = SpriteObject()
        let spriteNode = CBSpriteNode(spriteObject: spriteObject!)
        scene!.addChild(spriteNode)
        spriteNode.color = UIColor.black
        spriteNode.size = CGSize(width: CGFloat(objectWidth!), height: objectHeight!)
        spriteObject?.spriteNode = spriteNode
        spriteNode.catrobatPosition = CGPoint(x: 0, y: 0)
        spriteObject?.name = "Test"

        script = WhenScript()
        script?.object = spriteObject

        brick = IfOnEdgeBounceBrick()
        brick?.script = script
    }

    func testNoBounce() {
        setPosition(CGPoint(x: 0, y: 0), andRotation: 90)
        checkPosition(CGPoint(x: 0, y: 0), andRotation: 90)
    }

    func testTopBounce() {
        let rotations = [[90, 90], [120, 120], [150, 150], [180, 180], [-150, -150], [-120, -120], [-90, -90], [-60, -120], [-30, -150], [0, 180], [30, 150], [60, 120]]

        for rotation: [Int] in rotations {
            let rotationBefore = CGFloat(Float(rotation[0]))
            let rotationAfter = CGFloat(Float(rotation[1]))
            setPosition(CGPoint(x: 0, y: topBorderPosition!), andRotation: rotationBefore)
            checkPosition(CGPoint(x: 0, y: bounceTopPosition!), andRotation: rotationAfter)
        }
    }

    func testBottomBounce() {
        let rotations = [[90, 90], [120, 60], [150, 30], [180, 0], [-150, -30], [-120, -60], [-90, -90], [-60, -60], [-30, -30], [0, 0], [30, 30], [60, 60]]

        for rotation: [Int] in rotations {
            let rotationBefore = CGFloat(Float(rotation[0]))
            let rotationAfter = CGFloat(Float(rotation[1]))
            setPosition(CGPoint(x: 0, y: bottomBorderPosition!), andRotation: rotationBefore)
            checkPosition(CGPoint(x: 0, y: bounceBottomPosition!), andRotation: rotationAfter)
        }
    }

    func testLeftBounce() {
        let rotations = [[90, 90], [120, 120], [150, 150], [180, 180], [-150, 150], [-120, 120], [-90, 90], [-60, 60], [-30, 30], [0, 0], [30, 30], [60, 60]]

        for rotation: [Int] in rotations {
            let rotationBefore = CGFloat(Float(rotation[0]))
            let rotationAfter = CGFloat(Float(rotation[1]))
            setPosition(CGPoint(x: leftBorderPosition!, y: 0), andRotation: rotationBefore)
            checkPosition(CGPoint(x: bounceLeftPosition!, y: 0), andRotation: rotationAfter)
        }
    }

    func testRightBounce() {
        let rotations = [[90, -90], [120, -120], [150, -150], [180, 180], [-150, -150], [-120, -120], [-90, -90], [-60, -60], [-30, -30], [0, 0], [30, -30], [60, -60]]

        for rotation: [Int] in rotations {
            let rotationBefore = CGFloat(Float(rotation[0]))
            let rotationAfter = CGFloat(Float(rotation[1]))
            setPosition(CGPoint(x: rightBorderPosition!, y: 0), andRotation: rotationBefore)
            checkPosition(CGPoint(x: bounceRightPosition!, y: 0), andRotation: rotationAfter)
        }
    }

    func testUpLeftBounce() {
        setPosition(CGPoint(x: leftBorderPosition!, y: topBorderPosition!), andRotation: 135)
        checkPosition(CGPoint(x: bounceLeftPosition!, y: bounceTopPosition!), andRotation: 135)

        setPosition(CGPoint(x: leftBorderPosition!, y: topBorderPosition!), andRotation: -45)
        checkPosition(CGPoint(x: bounceLeftPosition!, y: bounceTopPosition!), andRotation: 135)
    }

    func testUpRightBounce() {
        setPosition(CGPoint(x: rightBorderPosition!, y: topBorderPosition!), andRotation: -135)
        checkPosition(CGPoint(x: bounceRightPosition!, y: bounceTopPosition!), andRotation: -135)

        setPosition(CGPoint(x: rightBorderPosition!, y: topBorderPosition!), andRotation: -45)
        checkPosition(CGPoint(x: bounceRightPosition!, y: bounceTopPosition!), andRotation: -135)
    }

    func testBottomLeftBounce() {
        setPosition(CGPoint(x: leftBorderPosition!, y: bottomBorderPosition!), andRotation: 45)
        checkPosition(CGPoint(x: bounceLeftPosition!, y: bounceBottomPosition!), andRotation: 45)

        setPosition(CGPoint(x: leftBorderPosition!, y: bottomBorderPosition!), andRotation: -135)
        checkPosition(CGPoint(x: bounceLeftPosition!, y: bounceBottomPosition!), andRotation: 45)
    }

    func testBottomRightBounce() {
        setPosition(CGPoint(x: rightBorderPosition!, y: bottomBorderPosition!), andRotation: -45)
        checkPosition(CGPoint(x: bounceRightPosition!, y: bounceBottomPosition!), andRotation: -45)

        setPosition(CGPoint(x: rightBorderPosition!, y: bottomBorderPosition!), andRotation: 135)
        checkPosition(CGPoint(x: bounceRightPosition!, y: bounceBottomPosition!), andRotation: -45)
    }

    func testIsLookingDown() {
        XCTAssertFalse((brick?.isLookingDown(0))!, "Brick should not be looking down")
        XCTAssertFalse((brick?.isLookingDown(360))!, "Brick should not be looking down")
        XCTAssertFalse((brick?.isLookingDown(45))!, "Brick should not be looking down")
        XCTAssertFalse((brick?.isLookingDown(-45))!, "Brick should not be looking down")
        XCTAssertFalse((brick?.isLookingDown(315))!, "Brick should not be looking down")
        XCTAssertFalse((brick?.isLookingDown(90))!, "Brick should not be looking down")
        XCTAssertFalse((brick?.isLookingDown(-90))!, "Brick should not be looking down")
        XCTAssertFalse((brick?.isLookingDown(270))!, "Brick should not be looking down")
        XCTAssertTrue((brick?.isLookingDown(180))!, "Brick should be looking down")
        XCTAssertTrue((brick?.isLookingDown(91))!, "Brick should be looking down")
        XCTAssertTrue((brick?.isLookingDown(-91))!, "Brick should be looking down")
        XCTAssertTrue((brick?.isLookingDown(150))!, "Brick should be looking down")
        XCTAssertTrue((brick?.isLookingDown(179))!, "Brick should be looking down")
    }

    func testIsLookingUp() {
        XCTAssertFalse((brick?.isLookingUp(180))!, "Brick should not be looking up")
        XCTAssertFalse((brick?.isLookingUp(540))!, "Brick should not be looking up")
        XCTAssertFalse((brick?.isLookingUp(135))!, "Brick should not be looking up")
        XCTAssertFalse((brick?.isLookingUp(-135))!, "Brick should not be looking up")
        XCTAssertFalse((brick?.isLookingUp(225))!, "Brick should not be looking up")
        XCTAssertFalse((brick?.isLookingUp(90))!, "Brick should not be looking up")
        XCTAssertFalse((brick?.isLookingUp(-90))!, "Brick should not be looking up")
        XCTAssertFalse((brick?.isLookingUp(270))!, "Brick should not be looking up")
        XCTAssertTrue((brick?.isLookingUp(0))!, "Brick should be looking up")
        XCTAssertTrue((brick?.isLookingUp(360))!, "Brick should be looking up")
        XCTAssertTrue((brick?.isLookingUp(89))!, "Brick should be looking up")
        XCTAssertTrue((brick?.isLookingUp(-89))!, "Brick should be looking up")
        XCTAssertTrue((brick?.isLookingUp(1))!, "Brick should be looking up")
    }

    func testIsLookingLeft() {
        XCTAssertFalse((brick?.isLookingLeft(0))!, "Brick should not be looking left")
        XCTAssertFalse((brick?.isLookingLeft(360))!, "Brick should not be looking left")
        XCTAssertFalse((brick?.isLookingLeft(180))!, "Brick should not be looking left")
        XCTAssertFalse((brick?.isLookingLeft(-180))!, "Brick should not be looking left")
        XCTAssertFalse((brick?.isLookingLeft(45))!, "Brick should not be looking left")
        XCTAssertFalse((brick?.isLookingLeft(135))!, "Brick should not be looking left")
        XCTAssertFalse((brick?.isLookingLeft(-270))!, "Brick should not be looking left")
        XCTAssertTrue((brick?.isLookingLeft(-10))!, "Brick should be looking left")
        XCTAssertTrue((brick?.isLookingLeft(181))!, "Brick should be looking left")
        XCTAssertTrue((brick?.isLookingLeft(359))!, "Brick should be looking left")
        XCTAssertTrue((brick?.isLookingLeft(270))!, "Brick should be looking left")
    }

    func testIsLookingRight() {
        XCTAssertFalse((brick?.isLookingRight(0))!, "Brick should not be looking right")
        XCTAssertFalse((brick?.isLookingRight(360))!, "Brick should not be looking right")
        XCTAssertFalse((brick?.isLookingRight(180))!, "Brick should not be looking right")
        XCTAssertFalse((brick?.isLookingRight(-180))!, "Brick should not be looking right")
        XCTAssertFalse((brick?.isLookingRight(270))!, "Brick should not be looking right")
        XCTAssertFalse((brick?.isLookingRight(-45))!, "Brick should not be looking right")
        XCTAssertTrue((brick?.isLookingRight(1))!, "Brick should not be looking right")
        XCTAssertTrue((brick?.isLookingRight(179))!, "Brick should not be looking right")
        XCTAssertTrue((brick?.isLookingRight(-270))!, "Brick should be looking right")
        XCTAssertTrue((brick?.isLookingRight(90))!, "Brick should be looking right")
    }

    func setPosition(_ position: CGPoint, andRotation rotation: CGFloat) {
        spriteObject?.spriteNode.catrobatPosition = position
        spriteObject?.spriteNode.catrobatRotation = Double(rotation)

        let action: () -> Void? = (brick?.actionBlock())!
        action()
    }

    func checkPosition(_ position: CGPoint, andRotation expectedStandardizedRotation: CGFloat) {
        let spriteNode: CBSpriteNode = spriteObject!.spriteNode

        XCTAssertEqual(Double(position.x), Double(spriteNode.catrobatPosition.x), accuracy: Double.epsilon, "Wrong x after bounce")
        XCTAssertEqual(Double(position.y), Double(spriteNode.catrobatPosition.y), accuracy: Double.epsilon, "Wrong y after bounce")

        XCTAssertEqual(Double(expectedStandardizedRotation), Double(spriteNode.catrobatRotation), accuracy: Double.epsilon, "Wrong rotation after bounce")
    }
}
