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

final class SizeSensorTest: XCTestCase {

    var spriteObject: SpriteObject!
    var spriteNode: CBSpriteNodeMock!
    var sensor: SizeSensor!

    override func setUp() {
        super.setUp()
        spriteObject = SpriteObject()
        spriteNode = CBSpriteNodeMock(spriteObject: spriteObject)
        sensor = SizeSensor()
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
        spriteNode.xScale = 1.0
        XCTAssertEqual(1.0, type(of: sensor).rawValue(for: spriteObject), accuracy: Double.epsilon)

        spriteNode.xScale = 0.0
        XCTAssertEqual(0, type(of: sensor).rawValue(for: spriteObject), accuracy: Double.epsilon)

        spriteNode.xScale = 0.5
        XCTAssertEqual(0.5, type(of: sensor).rawValue(for: spriteObject), accuracy: Double.epsilon)
    }

    func testSetRawValue() {
        let expectedRawValue = type(of: sensor).convertToRaw(userInput: 10, for: spriteObject)
        type(of: sensor).setRawValue(userInput: 10, for: spriteObject)
        XCTAssertEqual(expectedRawValue, Double(spriteNode.xScale), accuracy: 0.001)
        XCTAssertEqual(expectedRawValue, Double(spriteNode.yScale), accuracy: 0.001)
    }

    func testConvertToStandarized() {
        XCTAssertEqual(0, type(of: sensor).convertToStandardized(rawValue: 0, for: spriteObject), accuracy: Double.epsilon)
        XCTAssertEqual(2.5, type(of: sensor).convertToStandardized(rawValue: 0.025, for: spriteObject), accuracy: Double.epsilon)
        XCTAssertEqual(25, type(of: sensor).convertToStandardized(rawValue: 0.25, for: spriteObject), accuracy: Double.epsilon)
        XCTAssertEqual(100, type(of: sensor).convertToStandardized(rawValue: 1.0, for: spriteObject), accuracy: Double.epsilon)
    }

    func testConvertToRaw() {
        XCTAssertEqual(0, type(of: sensor).convertToRaw(userInput: 0, for: spriteObject), accuracy: Double.epsilon)
        XCTAssertEqual(0, type(of: sensor).convertToRaw(userInput: -10, for: spriteObject), accuracy: Double.epsilon)
        XCTAssertEqual(2.4, type(of: sensor).convertToRaw(userInput: 240, for: spriteObject), accuracy: Double.epsilon)
        XCTAssertEqual(1.2, type(of: sensor).convertToRaw(userInput: 120, for: spriteObject), accuracy: Double.epsilon)
        XCTAssertEqual(0.6, type(of: sensor).convertToRaw(userInput: 60, for: spriteObject), accuracy: Double.epsilon)
    }

    func testTag() {
        XCTAssertEqual("OBJECT_SIZE", sensor.tag())
    }

    func testRequiredResources() {
        XCTAssertEqual(ResourceType.noResources, type(of: sensor).requiredResource)
    }

    func testFormulaEditorSections() {
        let sections = sensor.formulaEditorSections(for: spriteObject)
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual(.object(position: type(of: sensor).position), sections.first)
    }
}
