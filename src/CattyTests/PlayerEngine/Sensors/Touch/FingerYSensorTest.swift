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

final class FingerYSensorTest: XCTestCase {

    var touchManager: TouchManagerMock!
    var sensor: FingerYSensor!

    let screenWidth = 500.0
    let screenHeight = 500.0

    var spriteObject: SpriteObject!
    var spriteNode: CBSpriteNodeMock!

    override func setUp() {
        super.setUp()
        touchManager = TouchManagerMock()
        sensor = FingerYSensor { [weak self] in self?.touchManager }

        spriteObject = SpriteObject()
        spriteNode = CBSpriteNodeMock(spriteObject: spriteObject)
        spriteNode.mockedScene = SceneBuilder(program: ProgramMock(width: CGFloat(screenWidth), andHeight: CGFloat(screenHeight))).build()
    }

    override func tearDown() {
        sensor = nil
        touchManager = nil
        spriteNode = nil
        super.tearDown()
    }

    func testDefaultRawValue() {
        let sensor = FingerYSensor { nil }
        XCTAssertEqual(type(of: sensor).defaultRawValue, sensor.rawValue(), accuracy: Double.epsilon)
    }

    func testRawValue() {
        touchManager.lastTouch = CGPoint(x: 105, y: 201)
        XCTAssertEqual(201, sensor.rawValue())

        touchManager.lastTouch = CGPoint(x: 45, y: -13)
        XCTAssertEqual(-13, sensor.rawValue())
    }

    func testConvertToStandardized() {
        touchManager.lastTouch = CGPoint(x: 200, y: 200) // a random point to mock the screen touching

        XCTAssertEqual(0 - Double(screenHeight / 2), sensor.convertToStandardized(rawValue: 0, for: spriteObject))
        XCTAssertEqual(100 - Double(screenHeight / 2), sensor.convertToStandardized(rawValue: 100, for: spriteObject))
        XCTAssertEqual(333 - Double(screenHeight / 2), sensor.convertToStandardized(rawValue: 333, for: spriteObject))
        XCTAssertEqual(-333 - Double(screenHeight / 2), sensor.convertToStandardized(rawValue: -333, for: spriteObject))
    }

    func testTag() {
        XCTAssertEqual("FINGER_Y", sensor.tag())
    }

    func testRequiredResources() {
        XCTAssertEqual(ResourceType.touchHandler, type(of: sensor).requiredResource)
    }

    func testFormulaEditorSections() {
        let sections = sensor.formulaEditorSections(for: SpriteObject())
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual(.device(position: type(of: sensor).position), sections.first)
    }
}
