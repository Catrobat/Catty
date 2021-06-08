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

final class CBSpriteNodeTests: XCTestCase {

    final let epsilon = 0.001
    var spriteNode: CBSpriteNodeMock!
    var spriteObject: SpriteObject!
    var lookA: Look!
    var lookB: Look!

    private func calculateScreenRatio(width: CGFloat, height: CGFloat) -> CGFloat {
        let deviceScreenRect = UIScreen.main.nativeBounds
        let deviceDiagonalPixel = CGFloat(sqrt(pow(deviceScreenRect.width, 2) + pow(deviceScreenRect.height, 2)))

        let creatorDiagonalPixel = CGFloat(sqrt(pow(width, 2) + pow(height, 2)))

        return creatorDiagonalPixel / deviceDiagonalPixel
    }

    override func setUp() {
        let scene1 = Scene(name: "testScene")
        spriteObject = SpriteObject()
        spriteObject.scene = scene1
        spriteObject.name = "SpriteObjectName"

        spriteNode = CBSpriteNodeMock(spriteObject: spriteObject)
        spriteObject.spriteNode = spriteNode

        spriteNode.mockedStage = StageBuilder(project: ProjectMock(width: 300, andHeight: 400)).build()

        lookA = Look(name: "objectLooka", filePath: "pathA")
        lookB = Look(name: "objectLookB", filePath: "pathB")

        spriteObject.add(lookA, andSaveToDisk: false)
        spriteObject.add(lookB, andSaveToDisk: false)
    }

    func testPosition() {
        spriteNode.catrobatPosition = CBPosition(x: 10, y: 20)

        XCTAssertEqual(PositionXSensor.convertToRaw(userInput: 10, for: spriteNode.spriteObject),
                       Double(spriteNode.position.x),
                       accuracy: epsilon,
                       "SpriteNode catrobatPosition not correct")
        XCTAssertEqual(PositionYSensor.convertToRaw(userInput: 20, for: spriteNode.spriteObject),
                       Double(spriteNode.position.y),
                       accuracy: epsilon,
                       "SpriteNode catrobatPosition not correct")
    }

    func testPositionX() {
        spriteNode.catrobatPosition = CBPosition(x: 10, y: spriteNode.catrobatPosition.y)
        XCTAssertEqual(PositionXSensor.convertToRaw(userInput: 10, for: spriteNode.spriteObject),
                       Double(spriteNode.position.x),
                       accuracy: epsilon,
                       "SpriteNode catrobatPosition not correct")
    }

    func testPositionY() {
        spriteNode.catrobatPosition = CBPosition(x: spriteNode.catrobatPosition.x, y: 20)
        XCTAssertEqual(PositionYSensor.convertToRaw(userInput: 20, for: spriteNode.spriteObject),
                       Double(spriteNode.position.y),
                       accuracy: epsilon,
                       "SpriteNode catrobatPosition not correct")
    }

    func testSize() {
        spriteNode.catrobatSize = 30.0
        XCTAssertEqual(SizeSensor.convertToRaw(userInput: 30.0, for: spriteNode.spriteObject),
                       Double(spriteNode.xScale),
                       accuracy: epsilon,
                       "SpriteNode catrobatSize not correct")
        XCTAssertEqual(SizeSensor.convertToRaw(userInput: 30.0, for: spriteNode.spriteObject),
                       Double(spriteNode.yScale),
                       accuracy: epsilon,
                       "SpriteNode catrobatSize not correct")
    }

    func testRotation() {
        spriteNode.catrobatRotation = 10.0
        XCTAssertEqual(RotationSensor.convertToRaw(userInput: 10.0, for: spriteNode.spriteObject),
                       Double(spriteNode.zRotation),
                       accuracy: epsilon,
                       "SpriteNode catrobatRotation not correct")

        spriteNode.catrobatRotation = 180.0
        XCTAssertEqual(180.0,
                       spriteNode.catrobatRotation,
                       accuracy: epsilon,
                       "SpriteNode catrobatRotation not correct")

        spriteNode.catrobatRotation = 181.0
        XCTAssertEqual(-179.0,
                       spriteNode.catrobatRotation,
                       accuracy: epsilon,
                       "SpriteNode catrobatRotation not correct")

        spriteNode.catrobatRotation = 220.0
        XCTAssertEqual(-140.0,
                       spriteNode.catrobatRotation,
                       accuracy: epsilon,
                       "SpriteNode catrobatRotation not correct")

        spriteNode.catrobatRotation = 359.0
        XCTAssertEqual(-1.0,
                       spriteNode.catrobatRotation,
                       accuracy: epsilon,
                       "SpriteNode catrobatRotation not correct")

        spriteNode.catrobatRotation = 360.0
        XCTAssertEqual(0.0,
                       spriteNode.catrobatRotation,
                       accuracy: epsilon,
                       "SpriteNode catrobatRotation not correct")

        spriteNode.catrobatRotation = 361.0
        XCTAssertEqual(1.0,
                       spriteNode.catrobatRotation,
                       accuracy: epsilon,
                       "SpriteNode catrobatRotation not correct")

        spriteNode.catrobatRotation = -361.0
        XCTAssertEqual(-1.0,
                       spriteNode.catrobatRotation,
                       accuracy: epsilon,
                       "SpriteNode catrobatRotation not correct")

        spriteNode.catrobatRotation = -90.0
        XCTAssertEqual(-90.0,
                       spriteNode.catrobatRotation,
                       accuracy: epsilon,
                       "SpriteNode catrobatRotation not correct")

        spriteNode.catrobatRotation = -185.0
        XCTAssertEqual(175.0,
                       spriteNode.catrobatRotation,
                       accuracy: epsilon,
                       "SpriteNode catrobatRotation not correct")
    }

    func testLayer() {
        spriteNode.catrobatLayer = 2.0
        XCTAssertEqual(LayerSensor.convertToRaw(userInput: 2.0, for: spriteNode.spriteObject),
                       Double(spriteNode.zPosition),
                       accuracy: epsilon,
                       "SpriteNode catrobatLayer not correct")
    }

    func testTransparency() {
        spriteNode.catrobatTransparency = 90.0
        XCTAssertEqual(TransparencySensor.convertToRaw(userInput: 90.0, for: spriteNode.spriteObject),
                       Double(spriteNode.alpha),
                       accuracy: epsilon,
                       "SpriteNode catrobatTransparency not correct")
    }

    func testBrightness() {
        spriteNode.catrobatBrightness = 30.0
        XCTAssertEqual(BrightnessSensor.convertToRaw(userInput: 30.0, for: spriteNode.spriteObject),
                       Double(spriteNode.ciBrightness),
                       accuracy: epsilon,
                       "SpriteNode catrobatBrightness not correct")
    }

    func testColor() {
        spriteNode.catrobatColor = 40.0
        XCTAssertEqual(ColorSensor.convertToRaw(userInput: 40.0, for: spriteNode.spriteObject),
                       Double(spriteNode.ciHueAdjust),
                       accuracy: epsilon,
                       "SpriteNode catrobatColor not correct")
    }

    func testPenConfigurationInit() {
        XCTAssertEqual(spriteNode.penConfiguration.screenRatio, 1)

        let testProject1 = ProjectMock(width: 100, andHeight: 100)
        let scene = Scene(name: "testScene")
        let newSpriteObject = SpriteObject()
        newSpriteObject.scene = scene
        newSpriteObject.scene.project = testProject1
        spriteNode = CBSpriteNodeMock(spriteObject: newSpriteObject)

        XCTAssertEqual(spriteNode.penConfiguration.screenRatio, calculateScreenRatio(width: 100, height: 100))

        let testProject2 = ProjectMock(width: 200, andHeight: 200)
        newSpriteObject.scene.project = testProject2
        spriteNode = CBSpriteNodeMock(spriteObject: newSpriteObject)

        XCTAssertEqual(spriteNode.penConfiguration.screenRatio, calculateScreenRatio(width: 200, height: 200))
    }

    func testIsFlipped() {
        spriteNode.xScale = 1
        XCTAssertFalse(spriteNode.isFlipped(), "Should not be flipped!")

        spriteNode.xScale = -1
        XCTAssertTrue(spriteNode.isFlipped(), "Should be flipped!")

        spriteNode.xScale = 2
        XCTAssertFalse(spriteNode.isFlipped(), "Should not be flipped with size two!")

        spriteNode.xScale = -2
        XCTAssertTrue(spriteNode.isFlipped(), "Should be flipped with size two!")
    }

    func testLookForIndex() {
        XCTAssertNil(spriteNode.look(for: 0))
        XCTAssertEqual(spriteNode.look(for: 1)?.fileName, lookA.fileName)
        XCTAssertEqual(spriteNode.look(for: 2)?.fileName, lookB.fileName)
        XCTAssertNil(spriteNode.look(for: 3))
    }
}
