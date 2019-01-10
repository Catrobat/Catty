/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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

final class InclinationXSensorTest: XCTestCase {

    var motionManager: MotionManagerMock!
    var sensor: InclinationXSensor!

    override func setUp() {
        super.setUp()
        motionManager = MotionManagerMock()
        sensor = InclinationXSensor { [weak self] in self?.motionManager }
    }

    override func tearDown() {
        sensor = nil
        motionManager = nil
        super.tearDown()
    }

    func testDefaultRawValue() {
        let sensor = InclinationXSensor { nil }
        XCTAssertEqual(type(of: sensor).defaultRawValue, sensor.rawValue(), accuracy: Double.epsilon)
    }

    func testRawValue() {
        // test maximum value
        motionManager.attitude = (roll: Double.pi, pitch: 0)
        XCTAssertEqual(sensor.rawValue(), Double.pi, accuracy: Double.epsilon)

        // test minimum value
        motionManager.attitude = (roll: -Double.pi, pitch: 0)
        XCTAssertEqual(sensor.rawValue(), -Double.pi, accuracy: Double.epsilon)

        // test no inclination
        motionManager.attitude = (roll: 0, pitch: 0)
        XCTAssertEqual(sensor.rawValue(), 0, accuracy: Double.epsilon)

        // tests inside the range
        motionManager.attitude = (roll: Double.pi / 2, pitch: 0)
        XCTAssertEqual(sensor.rawValue(), Double.pi / 2, accuracy: Double.epsilon)

        motionManager.attitude = (roll: -Double.pi / 3, pitch: 0)
        XCTAssertEqual(sensor.rawValue(), -Double.pi / 3, accuracy: Double.epsilon)
    }

    // does not depend on the orientation of the screen (left/right, up/down)
    func testConvertToStandardized() {
        // test no inclination
        XCTAssertEqual(sensor.convertToStandardized(rawValue: 0), 0, accuracy: Double.epsilon)

        // test screen half left
        XCTAssertEqual(sensor.convertToStandardized(rawValue: -Double.pi / 4), 45, accuracy: Double.epsilon)

        // test screen half right
        XCTAssertEqual(sensor.convertToStandardized(rawValue: Double.pi / 4), -45, accuracy: Double.epsilon)

        // test screen left
        XCTAssertEqual(sensor.convertToStandardized(rawValue: -Double.pi / 2), 90, accuracy: Double.epsilon)

        // test screen right
        XCTAssertEqual(sensor.convertToStandardized(rawValue: Double.pi / 2), -90, accuracy: Double.epsilon)

        // test screen left, then down
        XCTAssertEqual(sensor.convertToStandardized(rawValue: -Double.pi), 180, accuracy: Double.epsilon)

        // test screen right, then down
        XCTAssertEqual(sensor.convertToStandardized(rawValue: Double.pi), -180, accuracy: Double.epsilon)
    }

    func testTag() {
        XCTAssertEqual("X_INCLINATION", sensor.tag())
    }

    func testRequiredResources() {
        XCTAssertEqual(ResourceType.deviceMotion, type(of: sensor).requiredResource)
    }

    func testFormulaEditorSections() {
        let sections = sensor.formulaEditorSections(for: SpriteObject())
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual(.device(position: type(of: sensor).position), sections.first)
    }
}
