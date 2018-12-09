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

final class CBSpriteNodeTests: XCTestCase {

    var spriteNode: CBSpriteNodeMock!

    override func setUp() {
        let spriteObject = SpriteObject()
        spriteObject.name = "SpriteObjectName"

        spriteNode = CBSpriteNodeMock(spriteObject: spriteObject)
        spriteObject.spriteNode = spriteNode

        spriteNode.mockedScene = SceneBuilder(program: ProgramMock(width: 300, andHeight: 400)).build()
    }

    func testPosition() {
        spriteNode.catrobatPosition = CGPoint(x: 10, y: 20)

        XCTAssertEqual(PositionXSensor.convertToRaw(userInput: 10, for: spriteNode.spriteObject),
                       Double(spriteNode.position.x),
                       accuracy: Double.epsilon,
                       "SpriteNode catrobatPosition not correct")
        XCTAssertEqual(PositionYSensor.convertToRaw(userInput: 20, for: spriteNode.spriteObject),
                       Double(spriteNode.position.y),
                       accuracy: Double.epsilon,
                       "SpriteNode catrobatPosition not correct")
    }

    func testPositionX() {
        spriteNode.catrobatPositionX = 10
        XCTAssertEqual(PositionXSensor.convertToRaw(userInput: 10, for: spriteNode.spriteObject),
                       Double(spriteNode.position.x),
                       accuracy: Double.epsilon,
                       "SpriteNode catrobatPosition not correct")
    }

    func testPositionY() {
        spriteNode.catrobatPositionY = 20
        XCTAssertEqual(PositionYSensor.convertToRaw(userInput: 20, for: spriteNode.spriteObject),
                       Double(spriteNode.position.y),
                       accuracy: Double.epsilon,
                       "SpriteNode catrobatPosition not correct")
    }

    func testSize() {
        spriteNode.catrobatSize = 30.0
        XCTAssertEqual(SizeSensor.convertToRaw(userInput: 30.0, for: spriteNode.spriteObject),
                       Double(spriteNode.xScale),
                       accuracy: Double.epsilon,
                       "SpriteNode catrobatSize not correct")
        XCTAssertEqual(SizeSensor.convertToRaw(userInput: 30.0, for: spriteNode.spriteObject),
                       Double(spriteNode.yScale),
                       accuracy: Double.epsilon,
                       "SpriteNode catrobatSize not correct")
    }

    func testRotation() {
        spriteNode.catrobatRotation = 10.0
        XCTAssertEqual(RotationSensor.convertToRaw(userInput: 10.0, for: spriteNode.spriteObject),
                       Double(spriteNode.zRotation),
                       accuracy: Double.epsilon,
                       "SpriteNode catrobatRotation not correct")

        spriteNode.catrobatRotation = 180.0
        XCTAssertEqual(180.0,
                       spriteNode.catrobatRotation,
                       accuracy: Double.epsilon,
                       "SpriteNode catrobatRotation not correct")

        spriteNode.catrobatRotation = 181.0
        XCTAssertEqual(-179.0,
                       spriteNode.catrobatRotation,
                       accuracy: Double.epsilon,
                       "SpriteNode catrobatRotation not correct")

        spriteNode.catrobatRotation = 220.0
        XCTAssertEqual(-140.0,
                       spriteNode.catrobatRotation,
                       accuracy: Double.epsilon,
                       "SpriteNode catrobatRotation not correct")

        spriteNode.catrobatRotation = 359.0
        XCTAssertEqual(-1.0,
                       spriteNode.catrobatRotation,
                       accuracy: Double.epsilon,
                       "SpriteNode catrobatRotation not correct")

        spriteNode.catrobatRotation = 360.0
        XCTAssertEqual(0.0,
                       spriteNode.catrobatRotation,
                       accuracy: Double.epsilon,
                       "SpriteNode catrobatRotation not correct")

        spriteNode.catrobatRotation = 361.0
        XCTAssertEqual(1.0,
                       spriteNode.catrobatRotation,
                       accuracy: Double.epsilon,
                       "SpriteNode catrobatRotation not correct")

        spriteNode.catrobatRotation = -361.0
        XCTAssertEqual(-1.0,
                       spriteNode.catrobatRotation,
                       accuracy: Double.epsilon,
                       "SpriteNode catrobatRotation not correct")

        spriteNode.catrobatRotation = -90.0
        XCTAssertEqual(-90.0,
                       spriteNode.catrobatRotation,
                       accuracy: Double.epsilon,
                       "SpriteNode catrobatRotation not correct")

        spriteNode.catrobatRotation = -185.0
        XCTAssertEqual(175.0,
                       spriteNode.catrobatRotation,
                       accuracy: Double.epsilon,
                       "SpriteNode catrobatRotation not correct")
    }

    func testLayer() {
        spriteNode.catrobatLayer = 2.0
        XCTAssertEqual(LayerSensor.convertToRaw(userInput: 2.0, for: spriteNode.spriteObject),
                       Double(spriteNode.zPosition),
                       accuracy: Double.epsilon,
                       "SpriteNode catrobatLayer not correct")
    }

    func testTransparency() {
        spriteNode.catrobatTransparency = 90.0
        XCTAssertEqual(TransparencySensor.convertToRaw(userInput: 90.0, for: spriteNode.spriteObject),
                       Double(spriteNode.alpha),
                       accuracy: Double.epsilon,
                       "SpriteNode catrobatTransparency not correct")
    }

    func testBrightness() {
        spriteNode.catrobatBrightness = 30.0
        XCTAssertEqual(BrightnessSensor.convertToRaw(userInput: 30.0, for: spriteNode.spriteObject),
                       Double(spriteNode.ciBrightness),
                       accuracy: Double.epsilon,
                       "SpriteNode catrobatBrightness not correct")
    }

    func testColor() {
        spriteNode.catrobatColor = 40.0
        XCTAssertEqual(ColorSensor.convertToRaw(userInput: 40.0, for: spriteNode.spriteObject),
                       Double(spriteNode.ciHueAdjust),
                       accuracy: Double.epsilon,
                       "SpriteNode catrobatColor not correct")
    }
}
