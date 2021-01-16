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

final class RotationSensorTest: XCTestCase {

    var spriteObject: SpriteObject!
    var spriteNode: CBSpriteNodeMock!
    var sensor: RotationSensor!

    override func setUp() {
        super.setUp()
        spriteObject = SpriteObject()
        let scene = Scene(name: "testScene")
        spriteObject.scene = scene
        spriteNode = CBSpriteNodeMock(spriteObject: spriteObject)
        sensor = RotationSensor()
    }

    override func tearDown() {
        spriteObject = nil
        super.tearDown()
    }

    func testDefaultRawValue() {
        spriteObject.spriteNode = nil
        XCTAssertEqual(type(of: sensor).defaultRawValue, type(of: sensor).rawValue(for: spriteObject))
    }

    func testRawValue() {
        // head up
        spriteNode.zRotation = 90
        XCTAssertEqual(90, type(of: sensor).rawValue(for: spriteObject), accuracy: Double.epsilon)

        // head down
        spriteNode.zRotation = -90
        XCTAssertEqual(-90, type(of: sensor).rawValue(for: spriteObject), accuracy: Double.epsilon)

        // head to the right
        spriteNode.zRotation = 180
        XCTAssertEqual(180, type(of: sensor).rawValue(for: spriteObject), accuracy: Double.epsilon)

        // head to the left
        spriteNode.zRotation = 0
        XCTAssertEqual(0, type(of: sensor).rawValue(for: spriteObject), accuracy: Double.epsilon)
    }

    func testSetRawValue() {
        let expectedRawValue = type(of: sensor).convertToRaw(userInput: 90, for: spriteObject)
        type(of: sensor).setRawValue(userInput: 90, for: spriteObject)
        XCTAssertEqual(expectedRawValue, Double(spriteNode.zRotation), accuracy: 0.001)
    }

    func testConvertToStandarized() {
        // on the first circle
        XCTAssertEqual(90, type(of: sensor).convertToStandardized(rawValue: 0, for: spriteObject), accuracy: Double.epsilon)
        XCTAssertEqual(-90, type(of: sensor).convertToStandardized(rawValue: Double.pi, for: spriteObject), accuracy: Double.epsilon)
        XCTAssertEqual(0, type(of: sensor).convertToStandardized(rawValue: Double.pi / 2, for: spriteObject), accuracy: Double.epsilon)
        XCTAssertEqual(90, type(of: sensor).convertToStandardized(rawValue: Double.pi * 2, for: spriteObject), accuracy: Double.epsilon)
        XCTAssertEqual(60, type(of: sensor).convertToStandardized(rawValue: Double.pi / 6, for: spriteObject), accuracy: Double.epsilon)

        // after the first circle (360)
        XCTAssertEqual(-90, type(of: sensor).convertToStandardized(rawValue: Double.pi * 5, for: spriteObject), accuracy: Double.epsilon)

        // before the first circle circle (0)
        XCTAssertEqual(90, type(of: sensor).convertToStandardized(rawValue: -Double.pi * 4, for: spriteObject), accuracy: Double.epsilon)
        XCTAssertEqual(135, type(of: sensor).convertToStandardized(rawValue: -Double.pi / 4, for: spriteObject), accuracy: Double.epsilon)
    }

    func testConvertToRaw() {
        // on the first circle
        XCTAssertEqual(0, type(of: sensor).convertToRaw(userInput: 90, for: spriteObject), accuracy: Double.epsilon)
        XCTAssertEqual(Double.pi * 3 / 2, type(of: sensor).convertToRaw(userInput: 180, for: spriteObject), accuracy: Double.epsilon)
        XCTAssertEqual(-Double.pi / 2, type(of: sensor).convertToRaw(userInput: -180, for: spriteObject), accuracy: Double.epsilon)
        XCTAssertEqual(Double.pi / 4, type(of: sensor).convertToRaw(userInput: 45, for: spriteObject), accuracy: Double.epsilon)
        XCTAssertEqual(Double.pi / 3, type(of: sensor).convertToRaw(userInput: 30, for: spriteObject), accuracy: Double.epsilon)
        XCTAssertEqual(Double.pi / 2, type(of: sensor).convertToRaw(userInput: 0, for: spriteObject), accuracy: Double.epsilon)

        // before the first circle
        XCTAssertEqual(-Double.pi, type(of: sensor).convertToRaw(userInput: -450, for: spriteObject), accuracy: Double.epsilon)

        // after the first circle
        XCTAssertEqual(Double.pi / 2, type(of: sensor).convertToRaw(userInput: 720, for: spriteObject), accuracy: Double.epsilon)
    }

    func testConvertToSceneDegrees() {
        // rotationDegreeOffset = ± 90

        // on the first trigonometric circle, in absolute value
        XCTAssertEqual(90, type(of: sensor).convertSceneToDegrees(0, for: spriteObject), accuracy: Double.epsilon)
        XCTAssertEqual(0, type(of: sensor).convertSceneToDegrees(90, for: spriteObject), accuracy: Double.epsilon)
        XCTAssertEqual(-90, type(of: sensor).convertSceneToDegrees(-180, for: spriteObject), accuracy: Double.epsilon)
        XCTAssertEqual(-90, type(of: sensor).convertSceneToDegrees(180, for: spriteObject), accuracy: Double.epsilon)
        XCTAssertEqual(-130, type(of: sensor).convertSceneToDegrees(220, for: spriteObject), accuracy: Double.epsilon)
        XCTAssertEqual(150, type(of: sensor).convertSceneToDegrees(-60, for: spriteObject), accuracy: Double.epsilon)

        // on other trigonometric circles => periodicity
        XCTAssertEqual(0, type(of: sensor).convertSceneToDegrees(450, for: spriteObject), accuracy: Double.epsilon)
        XCTAssertEqual(-90, type(of: sensor).convertSceneToDegrees(900, for: spriteObject), accuracy: Double.epsilon)
        XCTAssertEqual(-130, type(of: sensor).convertSceneToDegrees(-500, for: spriteObject), accuracy: Double.epsilon)
        XCTAssertEqual(90, type(of: sensor).convertSceneToDegrees(-1080, for: spriteObject), accuracy: Double.epsilon)

        // Note: the values returned are always between (-179, 180) - a single circle rotated
    }

    func testTag() {
        XCTAssertEqual("OBJECT_ROTATION", sensor.tag())
    }

    func testRequiredResources() {
        XCTAssertEqual(ResourceType.noResources, type(of: sensor).requiredResource)
    }

    func testFormulaEditorSections() {
        let sections = sensor.formulaEditorSections(for: spriteObject)
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual(.object(position: type(of: sensor).position), sections.first)
    }

    func testSetRawValueWithRotationStyleAllAround() {
        spriteNode.rotationStyle = RotationStyle.allAround

        type(of: sensor).setRawValue(userInput: 90.0, for: spriteObject)
        XCTAssertEqual(90.0, spriteNode.rotationDegreeOffset)
        XCTAssertEqual(0.0, Double(spriteNode.zRotation), accuracy: Double.epsilon)
        XCTAssertEqual(90.0, Double(spriteNode.catrobatRotation), accuracy: Double.epsilon)

        type(of: sensor).setRawValue(userInput: -90.0, for: spriteObject)
        XCTAssertEqual(90.0, spriteNode.rotationDegreeOffset)
        XCTAssertEqual(-3.1416, Double(spriteNode.zRotation), accuracy: Double.epsilon)
        XCTAssertEqual(-90.0, Double(spriteNode.catrobatRotation), accuracy: Double.epsilon)

        type(of: sensor).setRawValue(userInput: 180.0, for: spriteObject)
        XCTAssertEqual(90.0, spriteNode.rotationDegreeOffset)
        XCTAssertEqual(4.7124, Double(spriteNode.zRotation), accuracy: Double.epsilon)
        XCTAssertEqual(180.0, Double(spriteNode.catrobatRotation), accuracy: Double.epsilon)

        type(of: sensor).setRawValue(userInput: 0.0, for: spriteObject)
        XCTAssertEqual(90.0, spriteNode.rotationDegreeOffset)
        XCTAssertEqual(1.5708, Double(spriteNode.zRotation), accuracy: Double.epsilon)
        XCTAssertEqual(0.0, Double(spriteNode.catrobatRotation), accuracy: Double.epsilon)

        type(of: sensor).setRawValue(userInput: 400.0, for: spriteObject)
        XCTAssertEqual(90.0, spriteNode.rotationDegreeOffset)
        XCTAssertEqual(0.8727, Double(spriteNode.zRotation), accuracy: Double.epsilon)
        XCTAssertEqual(40.0, Double(spriteNode.catrobatRotation), accuracy: Double.epsilon)

        type(of: sensor).setRawValue(userInput: -400.0, for: spriteObject)
        XCTAssertEqual(90.0, spriteNode.rotationDegreeOffset)
        XCTAssertEqual(-4.0143, Double(spriteNode.zRotation), accuracy: Double.epsilon)
        XCTAssertEqual(-40.0, Double(spriteNode.catrobatRotation), accuracy: Double.epsilon)
    }

    func testSetRawValueWithRotationStyleDonNotRotate() {
        spriteNode.rotationStyle = RotationStyle.notRotate

        type(of: sensor).setRawValue(userInput: 90.0, for: spriteObject)
        XCTAssertEqual(90.0, spriteNode.rotationDegreeOffset)
        XCTAssertEqual(0.0, Double(spriteNode.zRotation), accuracy: Double.epsilon)
        XCTAssertEqual(90.0, Double(spriteNode.catrobatRotation), accuracy: Double.epsilon)

        type(of: sensor).setRawValue(userInput: -90.0, for: spriteObject)
        XCTAssertEqual(-90.0, spriteNode.rotationDegreeOffset)
        XCTAssertEqual(0.0, Double(spriteNode.zRotation), accuracy: Double.epsilon)
        XCTAssertEqual(-90.0, Double(spriteNode.catrobatRotation), accuracy: Double.epsilon)

        type(of: sensor).setRawValue(userInput: 180.0, for: spriteObject)
        XCTAssertEqual(180.0, spriteNode.rotationDegreeOffset)
        XCTAssertEqual(0.0, Double(spriteNode.zRotation), accuracy: Double.epsilon)
        XCTAssertEqual(180.0, Double(spriteNode.catrobatRotation), accuracy: Double.epsilon)

        type(of: sensor).setRawValue(userInput: 0, for: spriteObject)
        XCTAssertEqual(0.0, spriteNode.rotationDegreeOffset)
        XCTAssertEqual(0.0, Double(spriteNode.zRotation), accuracy: Double.epsilon)
        XCTAssertEqual(0.0, Double(spriteNode.catrobatRotation), accuracy: Double.epsilon)

        type(of: sensor).setRawValue(userInput: 400.0, for: spriteObject)
        XCTAssertEqual(400.0, spriteNode.rotationDegreeOffset)
        XCTAssertEqual(0.0, Double(spriteNode.zRotation), accuracy: Double.epsilon)
        XCTAssertEqual(40.0, Double(spriteNode.catrobatRotation), accuracy: Double.epsilon)

        type(of: sensor).setRawValue(userInput: -400.0, for: spriteObject)
        XCTAssertEqual(-400.0, spriteNode.rotationDegreeOffset)
        XCTAssertEqual(0.0, Double(spriteNode.zRotation), accuracy: Double.epsilon)
        XCTAssertEqual(-40.0, Double(spriteNode.catrobatRotation), accuracy: Double.epsilon)
    }

    func testSetRawValueWithRotationStyleLeftRight() {
        spriteNode.rotationStyle = RotationStyle.leftRight

        type(of: sensor).setRawValue(userInput: 90.0, for: spriteObject)
        XCTAssertEqual(90.0, spriteNode.rotationDegreeOffset)
        XCTAssertFalse(spriteNode.isFlipped())
        XCTAssertEqual(0.0, Double(spriteNode.zRotation), accuracy: Double.epsilon)
        XCTAssertEqual(90.0, Double(spriteNode.catrobatRotation), accuracy: Double.epsilon)

        type(of: sensor).setRawValue(userInput: -90.0, for: spriteObject)
        XCTAssertEqual(-90.0, spriteNode.rotationDegreeOffset)
        XCTAssertTrue(spriteNode.isFlipped())
        XCTAssertEqual(0.0, Double(spriteNode.zRotation), accuracy: Double.epsilon)
        XCTAssertEqual(-90.0, Double(spriteNode.catrobatRotation), accuracy: Double.epsilon)

        type(of: sensor).setRawValue(userInput: 180.0, for: spriteObject)
        XCTAssertEqual(180.0, spriteNode.rotationDegreeOffset)
        XCTAssertFalse(spriteNode.isFlipped())
        XCTAssertEqual(0.0, Double(spriteNode.zRotation), accuracy: Double.epsilon)
        XCTAssertEqual(180.0, Double(spriteNode.catrobatRotation), accuracy: Double.epsilon)

        type(of: sensor).setRawValue(userInput: 0, for: spriteObject)
        XCTAssertEqual(0.0, spriteNode.rotationDegreeOffset)
        XCTAssertFalse(spriteNode.isFlipped())
        XCTAssertEqual(0.0, Double(spriteNode.zRotation), accuracy: Double.epsilon)
        XCTAssertEqual(0.0, Double(spriteNode.catrobatRotation), accuracy: Double.epsilon)

        type(of: sensor).setRawValue(userInput: 400.0, for: spriteObject)
        XCTAssertEqual(400.0, spriteNode.rotationDegreeOffset)
        XCTAssertFalse(spriteNode.isFlipped())
        XCTAssertEqual(0.0, Double(spriteNode.zRotation), accuracy: Double.epsilon)
        XCTAssertEqual(40.0, Double(spriteNode.catrobatRotation), accuracy: Double.epsilon)

        type(of: sensor).setRawValue(userInput: -400, for: spriteObject)
        XCTAssertEqual(-400.0, spriteNode.rotationDegreeOffset)
        XCTAssertFalse(spriteNode.isFlipped())
        XCTAssertEqual(0.0, Double(spriteNode.zRotation), accuracy: Double.epsilon)
        XCTAssertEqual(-40.0, Double(spriteNode.catrobatRotation), accuracy: Double.epsilon)
    }

    func testSetRawValueWithRotationStyleAllAroundAfterLeftRight() {
        spriteNode.rotationStyle = RotationStyle.leftRight
        type(of: sensor).setRawValue(userInput: 180.0, for: spriteObject)
        XCTAssertEqual(180.0, spriteNode.rotationDegreeOffset)

        spriteNode.rotationStyle = RotationStyle.allAround
        type(of: sensor).setRawValue(userInput: 180.0, for: spriteObject)
        XCTAssertEqual(90.0, spriteNode.rotationDegreeOffset)
    }
}
