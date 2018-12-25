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

final class LastFingerIndexSensorTest: XCTestCase {

    var touchManager: TouchManagerMock!
    var sensor: LastFingerIndexSensor!

    override func setUp() {
        super.setUp()
        touchManager = TouchManagerMock()
        sensor = LastFingerIndexSensor { [weak self] in self?.touchManager }
    }

    override func tearDown() {
        sensor = nil
        touchManager = nil
        super.tearDown()
    }

    func testDefaultRawValue() {
        let sensor = LastFingerIndexSensor { nil }
        XCTAssertEqual(type(of: sensor).defaultRawValue, sensor.rawValue(), accuracy: Double.epsilon)
    }

    func testRawValue() {
        touchManager.touches = [CGPoint(x: 10, y: 20),
                                CGPoint(x: 100, y: 210),
                                CGPoint(x: -210, y: 40)]
        XCTAssertEqual(3, sensor.rawValue())

        touchManager.touches = [CGPoint(x: 100, y: 200)]
        XCTAssertEqual(1, sensor.rawValue())
    }

    func testConvertToStandardized() {
        XCTAssertEqual(2, sensor.convertToStandardized(rawValue: 2, for: SpriteObject()))
        XCTAssertEqual(10, sensor.convertToStandardized(rawValue: 10, for: SpriteObject()))
    }

    func testTag() {
        XCTAssertEqual("LAST_FINGER_INDEX", sensor.tag())
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
