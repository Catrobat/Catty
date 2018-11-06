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

final class RotationSensorTest: XCTestCase {

    var spriteObject: SpriteObject!
    var spriteNode: CBSpriteNodeMock!
    var sensor: RotationSensor!

    override func setUp() {
        spriteObject = SpriteObject()
        spriteNode = CBSpriteNodeMock(spriteObject: spriteObject)
        sensor = RotationSensor()
    }

    override func tearDown() {
        spriteObject = nil
    }

    func testDefaultRawValue() {
        spriteObject.spriteNode = nil
        XCTAssertEqual(type(of: sensor).defaultRawValue, type(of: sensor).rawValue(for: spriteObject))
    }

    func testRawValue() {
        // head up
        spriteNode.zRotation = 90
        XCTAssertEqual(90, type(of: sensor).rawValue(for: spriteObject), accuracy: 0.0001)

        // head down
        spriteNode.zRotation = -90
        XCTAssertEqual(-90, type(of: sensor).rawValue(for: spriteObject), accuracy: 0.0001)

        // head to the right
        spriteNode.zRotation = 180
        XCTAssertEqual(180, type(of: sensor).rawValue(for: spriteObject), accuracy: 0.0001)

        // head to the left
        spriteNode.zRotation = 0
        XCTAssertEqual(0, type(of: sensor).rawValue(for: spriteObject), accuracy: 0.0001)
    }

    func testSetRawValue() {
        let expectedRawValue = type(of: sensor).convertToRaw(userInput: 90, for: spriteObject)
        type(of: sensor).setRawValue(userInput: 90, for: spriteObject)
        XCTAssertEqual(expectedRawValue, Double(spriteNode.zRotation), accuracy: 0.001)
    }

    func testConvertToStandarized() {
        // on the first circle
        XCTAssertEqual(90, type(of: sensor).convertToStandardized(rawValue: 0, for: spriteObject), accuracy: 0.0001)
        XCTAssertEqual(-90, type(of: sensor).convertToStandardized(rawValue: Double.pi, for: spriteObject), accuracy: 0.0001)
        XCTAssertEqual(0, type(of: sensor).convertToStandardized(rawValue: Double.pi / 2, for: spriteObject), accuracy: 0.0001)
        XCTAssertEqual(90, type(of: sensor).convertToStandardized(rawValue: Double.pi * 2, for: spriteObject), accuracy: 0.0001)
        XCTAssertEqual(60, type(of: sensor).convertToStandardized(rawValue: Double.pi / 6, for: spriteObject), accuracy: 0.0001)

        // after the first circle (360)
        XCTAssertEqual(-90, type(of: sensor).convertToStandardized(rawValue: Double.pi * 5, for: spriteObject), accuracy: 0.0001)

        // before the first circle circle (0)
        XCTAssertEqual(90, type(of: sensor).convertToStandardized(rawValue: -Double.pi * 4, for: spriteObject), accuracy: 0.0001)
        XCTAssertEqual(135, type(of: sensor).convertToStandardized(rawValue: -Double.pi / 4, for: spriteObject), accuracy: 0.0001)
    }

    func testConvertToRaw() {
        // on the first circle
        XCTAssertEqual(0, type(of: sensor).convertToRaw(userInput: 90, for: spriteObject), accuracy: 0.0001)
        XCTAssertEqual(Double.pi * 3 / 2, type(of: sensor).convertToRaw(userInput: 180, for: spriteObject), accuracy: 0.0001)
        XCTAssertEqual(-Double.pi / 2, type(of: sensor).convertToRaw(userInput: -180, for: spriteObject), accuracy: 0.0001)
        XCTAssertEqual(Double.pi / 4, type(of: sensor).convertToRaw(userInput: 45, for: spriteObject), accuracy: 0.0001)
        XCTAssertEqual(Double.pi / 3, type(of: sensor).convertToRaw(userInput: 30, for: spriteObject), accuracy: 0.0001)
        XCTAssertEqual(Double.pi / 2, type(of: sensor).convertToRaw(userInput: 0, for: spriteObject), accuracy: 0.0001)

        // before the first circle
        XCTAssertEqual(-Double.pi, type(of: sensor).convertToRaw(userInput: -450, for: spriteObject), accuracy: 0.0001)

        // after the first circle
        XCTAssertEqual(Double.pi / 2, type(of: sensor).convertToRaw(userInput: 720, for: spriteObject), accuracy: 0.0001)
    }

    func testConvertToSceneDegrees() {
        // rotationDegreeOffset = ± 90

        // on the first trigonometric circle, in absolute value
        XCTAssertEqual(90, type(of: sensor).convertSceneToDegrees(0), accuracy: 0.0001)
        XCTAssertEqual(0, type(of: sensor).convertSceneToDegrees(90), accuracy: 0.0001)
        XCTAssertEqual(-90, type(of: sensor).convertSceneToDegrees(-180), accuracy: 0.0001)
        XCTAssertEqual(-90, type(of: sensor).convertSceneToDegrees(180), accuracy: 0.0001)
        XCTAssertEqual(-130, type(of: sensor).convertSceneToDegrees(220), accuracy: 0.0001)
        XCTAssertEqual(150, type(of: sensor).convertSceneToDegrees(-60), accuracy: 0.0001)

        // on other trigonometric circles => periodicity
        XCTAssertEqual(0, type(of: sensor).convertSceneToDegrees(450), accuracy: 0.0001)
        XCTAssertEqual(-90, type(of: sensor).convertSceneToDegrees(900), accuracy: 0.0001)
        XCTAssertEqual(-130, type(of: sensor).convertSceneToDegrees(-500), accuracy: 0.0001)
        XCTAssertEqual(90, type(of: sensor).convertSceneToDegrees(-1080), accuracy: 0.0001)

        // Note: the values returned are always between (-179, 180) - a single circle rotated
    }

    func testTag() {
        XCTAssertEqual("OBJECT_ROTATION", sensor.tag())
    }

    func testRequiredResources() {
        XCTAssertEqual(ResourceType.noResources, type(of: sensor).requiredResource)
    }

    func testFormulaEditorSection() {
        XCTAssertEqual(.object(position: type(of: sensor).position), sensor.formulaEditorSection(for: spriteObject))
    }
}
