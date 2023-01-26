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
        XCTAssertEqual(type(of: sensor).defaultRawValue, sensor.rawValue(landscapeMode: false), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: sensor).defaultRawValue, sensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)

    }

    func testRawValue() {
        // test maximum value
        motionManager.attitude = (pitch: 0, roll: Double.pi)
        XCTAssertEqual(sensor.rawValue(landscapeMode: false), Double.pi, accuracy: Double.epsilon)
        XCTAssertNotEqual(-sensor.rawValue(landscapeMode: true), Double.pi, accuracy: Double.epsilon)

        motionManager.attitude = (pitch: Double.pi, roll: Double.pi)
        XCTAssertEqual(sensor.rawValue(landscapeMode: true), Double.pi, accuracy: Double.epsilon)
        XCTAssertEqual(sensor.rawValue(landscapeMode: false), sensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)

        // test minimum value
        motionManager.attitude = (pitch: 0, roll: -Double.pi)
        XCTAssertEqual(sensor.rawValue(landscapeMode: false), -Double.pi, accuracy: Double.epsilon)
        XCTAssertNotEqual(-sensor.rawValue(landscapeMode: true), -Double.pi, accuracy: Double.epsilon)

        motionManager.attitude = (pitch: -Double.pi, roll: -Double.pi)
        XCTAssertEqual(sensor.rawValue(landscapeMode: true), -Double.pi, accuracy: Double.epsilon)
        XCTAssertEqual(sensor.rawValue(landscapeMode: false), sensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)

        // test no inclination
        motionManager.attitude = (pitch: 0, roll: 0)
        XCTAssertEqual(sensor.rawValue(landscapeMode: false), 0, accuracy: Double.epsilon)
        XCTAssertEqual(sensor.rawValue(landscapeMode: true), 0, accuracy: Double.epsilon)

        // tests inside the range
        motionManager.attitude = (pitch: 0, roll: Double.pi / 2)
        XCTAssertEqual(sensor.rawValue(landscapeMode: false), Double.pi / 2, accuracy: Double.epsilon)
        XCTAssertNotEqual(sensor.rawValue(landscapeMode: true), Double.pi / 2, accuracy: Double.epsilon)

        motionManager.attitude = (pitch: Double.pi / 2, roll: Double.pi / 2)
        XCTAssertEqual(sensor.rawValue(landscapeMode: true), Double.pi / 2, accuracy: Double.epsilon)
        XCTAssertEqual(sensor.rawValue(landscapeMode: false), sensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)

        motionManager.attitude = (pitch: 0, roll: -Double.pi / 3)
        XCTAssertEqual(sensor.rawValue(landscapeMode: false), -Double.pi / 3, accuracy: Double.epsilon)
        XCTAssertNotEqual(sensor.rawValue(landscapeMode: true), -Double.pi / 3, accuracy: Double.epsilon)

        motionManager.attitude = (pitch: -Double.pi / 3, roll: -Double.pi / 3)
        XCTAssertEqual(sensor.rawValue(landscapeMode: true), -Double.pi / 3, accuracy: Double.epsilon)
        XCTAssertEqual(sensor.rawValue(landscapeMode: false), sensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)
    }

    func testRawValueLandscapeModeScreenDown() {
        motionManager.zAcceleration = 0.5 // or any other positive value read by accelerationZ the sensors

        motionManager.attitude.pitch = Double.pi / 4
        XCTAssertEqual(-sensor.rawValue(landscapeMode: true), Double.pi + motionManager.attitude.pitch, accuracy: Double.epsilon)

        motionManager.attitude.pitch = 0
        XCTAssertEqual(-sensor.rawValue(landscapeMode: true), -Double.pi + motionManager.attitude.pitch, accuracy: Double.epsilon)

        motionManager.attitude.pitch = -Double.pi / 4
        XCTAssertEqual(-sensor.rawValue(landscapeMode: true), -Double.pi - motionManager.attitude.pitch, accuracy: Double.epsilon)
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

    func testStandardizedValue() {
        let convertToStandardizedValue = sensor.convertToStandardized(rawValue: sensor.rawValue(landscapeMode: false))
        let standardizedValue = sensor.standardizedValue(landscapeMode: false)
        let standardizedValueLandscape = sensor.standardizedValue(landscapeMode: true)
        XCTAssertEqual(convertToStandardizedValue, standardizedValue)
        XCTAssertEqual(standardizedValue, standardizedValueLandscape)
    }

    func testTag() {
        XCTAssertEqual("X_INCLINATION", sensor.tag())
    }

    func testRequiredResources() {
        XCTAssertEqual(ResourceType.accelerometerAndDeviceMotion, type(of: sensor).requiredResource)
    }

    func testFormulaEditorSections() {
        let sections = sensor.formulaEditorSections(for: SpriteObject())
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual(.sensors(position: type(of: sensor).position, subsection: .device), sections.first)
    }
}
