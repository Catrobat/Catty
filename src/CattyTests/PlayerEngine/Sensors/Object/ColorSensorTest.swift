/**
 *  Copyright (C) 2010-2023 The Catrobat Team
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

final class ColorSensorTest: XCTestCase {

    var spriteObject: SpriteObject!
    var spriteNode: CBSpriteNodeMock!
    var sensor: ColorSensor!

    override func setUp() {
        super.setUp()
        let scene = Scene(name: "testScene")
        spriteObject = SpriteObject()
        spriteObject.scene = scene
        spriteNode = CBSpriteNodeMock(spriteObject: spriteObject)
        sensor = ColorSensor()
    }

    override func tearDown() {
        spriteObject = nil
        super.tearDown()
    }

    func testDefaultRawValue() {
        spriteObject.spriteNode = nil
        XCTAssertEqual(type(of: sensor).defaultRawValue, type(of: sensor).rawValue(for: spriteObject), accuracy: Double.epsilon)
    }

    func testRawValue() {
        spriteNode.ciHueAdjust = 0.0
        XCTAssertEqual(0, type(of: sensor).rawValue(for: spriteObject), accuracy: Double.epsilon)

        spriteNode.ciHueAdjust = -60
        XCTAssertEqual(-60, type(of: sensor).rawValue(for: spriteObject), accuracy: Double.epsilon)

        spriteNode.ciHueAdjust = 210
        XCTAssertEqual(210, type(of: sensor).rawValue(for: spriteObject), accuracy: Double.epsilon)
    }

    func testSetRawValue() {
        let expectedRawValue = type(of: sensor).convertToRaw(userInput: 50, for: spriteObject)
        type(of: sensor).setRawValue(userInput: 50, for: spriteObject)
        XCTAssertEqual(expectedRawValue, Double(spriteNode.ciHueAdjust), accuracy: 0.001)
    }

    func testConvertToStandarized() {
        XCTAssertEqual(0, type(of: sensor).convertToStandardized(rawValue: 0, for: spriteObject), accuracy: Double.epsilon)
        XCTAssertEqual(100, type(of: sensor).convertToStandardized(rawValue: Double.pi, for: spriteObject), accuracy: Double.epsilon)
        XCTAssertEqual(199.99, type(of: sensor).convertToStandardized(rawValue: 1.9999 * Double.pi, for: spriteObject), accuracy: Double.epsilon)
    }

    func testConvertToRaw() {
        XCTAssertEqual(0, type(of: sensor).convertToRaw(userInput: 0, for: spriteObject), accuracy: Double.epsilon)
        XCTAssertEqual(Double.pi, type(of: sensor).convertToRaw(userInput: 100, for: spriteObject), accuracy: Double.epsilon)
        XCTAssertEqual(Double.pi / 4, type(of: sensor).convertToRaw(userInput: 25, for: spriteObject), accuracy: Double.epsilon)
        XCTAssertEqual(0.5 * Double.pi, type(of: sensor).convertToRaw(userInput: 10000000050, for: spriteObject), accuracy: Double.epsilon)

        // outside the range
        XCTAssertEqual(0, type(of: sensor).convertToRaw(userInput: 200, for: spriteObject), accuracy: Double.epsilon)
        XCTAssertEqual(Double.pi / 2, type(of: sensor).convertToRaw(userInput: 250, for: spriteObject), accuracy: Double.epsilon)
        XCTAssertEqual(0, type(of: sensor).convertToRaw(userInput: 400, for: spriteObject), accuracy: Double.epsilon)
        XCTAssertEqual(Double.pi, type(of: sensor).convertToRaw(userInput: -100, for: spriteObject), accuracy: Double.epsilon)
        XCTAssertEqual(Double.pi, type(of: sensor).convertToRaw(userInput: -300, for: spriteObject), accuracy: Double.epsilon)
        XCTAssertEqual(0, type(of: sensor).convertToRaw(userInput: 100000000000000000000, for: spriteObject), accuracy: Double.epsilon)
        XCTAssertEqual(0, type(of: sensor).convertToRaw(userInput: -100000000000000000000, for: spriteObject), accuracy: Double.epsilon)
    }

    func testTag() {
        XCTAssertEqual("OBJECT_COLOR", sensor.tag())
    }

    func testRequiredResources() {
        XCTAssertEqual(ResourceType.noResources, type(of: sensor).requiredResource)
    }

    func testFormulaEditorSections() {
        let sections = sensor.formulaEditorSections(for: SpriteObject())
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual(.object(position: type(of: sensor).position, subsection: .general), sections.first)
    }
}
