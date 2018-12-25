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

final class PositionXSensorTest: XCTestCase {

    let screenWidth = 500
    let screenHeight = 500

    var spriteObject: SpriteObject!
    var spriteNode: CBSpriteNodeMock!
    var sensor: PositionXSensor!

    override func setUp() {
        super.setUp()
        spriteObject = SpriteObject()
        spriteNode = CBSpriteNodeMock(spriteObject: spriteObject)
        spriteNode.mockedScene = SceneBuilder(program: ProgramMock(width: CGFloat(screenWidth), andHeight: CGFloat(screenHeight))).build()
        sensor = PositionXSensor()
    }

    override func tearDown() {
        spriteObject = nil
        super.tearDown()
    }

    func testDefaultRawValue() {
        spriteNode.mockedPosition = CGPoint(x: 12, y: 34)
        XCTAssertNotEqual(type(of: sensor).rawValue(for: spriteObject), type(of: sensor).defaultRawValue, accuracy: Double.epsilon)

        spriteObject.spriteNode = nil
        XCTAssertEqual(type(of: sensor).rawValue(for: spriteObject), type(of: sensor).defaultRawValue, accuracy: Double.epsilon)
    }

    func testRawValue() {
        // test point inside the screen, positive X value
        spriteNode.mockedPosition = CGPoint(x: 12, y: 34)
        XCTAssertEqual(type(of: sensor).rawValue(for: spriteObject), 12, accuracy: Double.epsilon)

        // test point inside the screen, negative X value
        spriteNode.mockedPosition = CGPoint(x: -55, y: 34)
        XCTAssertEqual(type(of: sensor).rawValue(for: spriteObject), -55, accuracy: Double.epsilon)

        // test middle of the screen
        spriteNode.mockedPosition = CGPoint(x: 0, y: 0)
        XCTAssertEqual(type(of: sensor).rawValue(for: spriteObject), 0, accuracy: Double.epsilon)

        // test right edge of the screen iPhone 8 Plus
        spriteNode.mockedPosition = CGPoint(x: 187, y: 100)
        XCTAssertEqual(type(of: sensor).rawValue(for: spriteObject), 187, accuracy: Double.epsilon)

        // test left edge of the screen iPhone 8 Plus
        spriteNode.mockedPosition = CGPoint(x: -187, y: 100)
        XCTAssertEqual(type(of: sensor).rawValue(for: spriteObject), -187, accuracy: Double.epsilon)

        // test outside of the screen
        spriteNode.mockedPosition = CGPoint(x: 10000, y: 30)
        XCTAssertEqual(type(of: sensor).rawValue(for: spriteObject), 10000, accuracy: Double.epsilon)

        // test float value
        spriteNode.mockedPosition = CGPoint(x: 20.22, y: 44)
        XCTAssertEqual(type(of: sensor).rawValue(for: spriteObject), 20.22, accuracy: Double.epsilon)

        // test random point
        let randomX = drand48() * 100
        spriteNode.mockedPosition = CGPoint(x: randomX, y: 34)
        XCTAssertEqual(type(of: sensor).rawValue(for: spriteObject), randomX, accuracy: Double.epsilon)
    }

    func testSetRawValue() {
        let expectedRawValue = type(of: sensor).convertToRaw(userInput: 10, for: spriteObject)
        type(of: sensor).setRawValue(userInput: 10, for: spriteObject)
        XCTAssertEqual(expectedRawValue, Double(spriteNode.position.x), accuracy: 0.001)
    }

    func testConvertToStandardized() {
        // random
        XCTAssertEqual(Double(10 - screenWidth / 2), type(of: sensor).convertToStandardized(rawValue: 10, for: spriteObject))

        // center
        XCTAssertEqual(Double(250 - screenWidth / 2), type(of: sensor).convertToStandardized(rawValue: 250, for: spriteObject))

        // left
        XCTAssertEqual(Double(63 - screenWidth / 2), type(of: sensor).convertToStandardized(rawValue: 63, for: spriteObject))

        // right
        XCTAssertEqual(Double(437 - screenWidth / 2), type(of: sensor).convertToStandardized(rawValue: 437, for: spriteObject))

        spriteObject.spriteNode = nil
        XCTAssertEqual(type(of: sensor).defaultRawValue, type(of: sensor).convertToStandardized(rawValue: 437, for: spriteObject))
    }

    func testConvertToRaw() {
        // random
        XCTAssertEqual(Double(10 + screenWidth / 2), type(of: sensor).convertToRaw(userInput: 10, for: spriteObject))

        // center
        XCTAssertEqual(Double(0 + screenWidth / 2), type(of: sensor).convertToRaw(userInput: 0, for: spriteObject))

        // left
        XCTAssertEqual(Double(-187 + screenWidth / 2), type(of: sensor).convertToRaw(userInput: -187, for: spriteObject))

        // right
        XCTAssertEqual(Double(187 + screenWidth / 2), type(of: sensor).convertToRaw(userInput: 187, for: spriteObject))
    }

    func testTag() {
        XCTAssertEqual("OBJECT_X", sensor.tag())
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
