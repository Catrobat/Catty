/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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

final class AccelerationXSensorTest: XCTestCase {

    var motionManager: MotionManagerMock!
    var sensor: AccelerationXSensor!

    override func setUp() {
        super.setUp()
        motionManager = MotionManagerMock()
        sensor = AccelerationXSensor { [weak self] in self?.motionManager }
    }

    override func tearDown() {
        sensor = nil
        motionManager = nil
        super.tearDown()
    }

    func testDefaultRawValue() {
        let sensor = AccelerationXSensor { nil }
        XCTAssertEqual(type(of: sensor).defaultRawValue, sensor.rawValue(landscapeMode: false), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: sensor).defaultRawValue, sensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)
    }

    func testRawValue() {
        motionManager.xUserAcceleration = 0
        motionManager.yUserAcceleration = 0
        XCTAssertEqual(motionManager.xUserAcceleration, sensor.rawValue(landscapeMode: false), accuracy: Double.epsilon)
        XCTAssertEqual(motionManager.yUserAcceleration, sensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)

        motionManager.xUserAcceleration = 9.8
        XCTAssertEqual(motionManager.xUserAcceleration, sensor.rawValue(landscapeMode: false), accuracy: Double.epsilon)
        XCTAssertNotEqual(motionManager.xUserAcceleration, sensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)

        motionManager.yUserAcceleration = 9.8
        XCTAssertEqual(sensor.rawValue(landscapeMode: true), sensor.rawValue(landscapeMode: false), accuracy: Double.epsilon)

        motionManager.xUserAcceleration = -9.8
        XCTAssertEqual(motionManager.xUserAcceleration, sensor.rawValue(landscapeMode: false), accuracy: Double.epsilon)
        XCTAssertNotEqual(motionManager.xUserAcceleration, sensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)

        motionManager.yUserAcceleration = -9.8
        XCTAssertEqual(sensor.rawValue(landscapeMode: true), sensor.rawValue(landscapeMode: false), accuracy: Double.epsilon)
    }

    func testConvertToStandardized() {
        XCTAssertEqual(0, sensor.convertToStandardized(rawValue: 0), accuracy: Double.epsilon)
        XCTAssertEqual(9.8, sensor.convertToStandardized(rawValue: 1), accuracy: Double.epsilon)
        XCTAssertEqual(-9.8, sensor.convertToStandardized(rawValue: -1), accuracy: Double.epsilon)
        XCTAssertEqual(98, sensor.convertToStandardized(rawValue: 10), accuracy: Double.epsilon)
        XCTAssertEqual(-98, sensor.convertToStandardized(rawValue: -10), accuracy: Double.epsilon)
    }

    func testStandardizedValue() {
        let convertToStandardizedValue = sensor.convertToStandardized(rawValue: sensor.rawValue(landscapeMode: false))
        let standardizedValue = sensor.standardizedValue(landscapeMode: false)
        let standardizedValueLandscape = sensor.standardizedValue(landscapeMode: true)
        XCTAssertEqual(convertToStandardizedValue, standardizedValue)
        XCTAssertEqual(standardizedValue, standardizedValueLandscape)
    }

    func testTag() {
        XCTAssertEqual("X_ACCELERATION", sensor.tag())
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
