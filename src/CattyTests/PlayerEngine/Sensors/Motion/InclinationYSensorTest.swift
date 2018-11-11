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

final class InclinationYSensorTest: XCTestCase {

    var motionManager: MotionManagerMock!
    var sensor: InclinationYSensor!

    override func setUp() {
        super.setUp()
        motionManager = MotionManagerMock()
        sensor = InclinationYSensor { [weak self] in self?.motionManager }
    }

    override func tearDown() {
        sensor = nil
        motionManager = nil
        super.tearDown()
    }

    func testDefaultRawValue() {
        let sensor = InclinationYSensor { nil }
        XCTAssertEqual(type(of: sensor).defaultRawValue, sensor.rawValue(), accuracy: Double.epsilon)
    }

    func testRawValue() {
        // test maximum value
        motionManager.attitude = (pitch: Double.pi / 2, roll: 0)
        XCTAssertEqual(sensor.rawValue(), Double.pi / 2, accuracy: Double.epsilon)

        // test minimum value
        motionManager.attitude = (pitch: -Double.pi / 2, roll: 0)
        XCTAssertEqual(sensor.rawValue(), -Double.pi / 2, accuracy: Double.epsilon)

        // test no inclination
        motionManager.attitude = (pitch: 0, roll: 0)
        XCTAssertEqual(sensor.rawValue(), 0, accuracy: Double.epsilon)

        // tests inside the range
        motionManager.attitude = (pitch: Double.pi / 3, roll: 0)
        XCTAssertEqual(sensor.rawValue(), Double.pi / 3, accuracy: Double.epsilon)

        motionManager.attitude = (pitch: -Double.pi / 6, roll: 0)
        XCTAssertEqual(sensor.rawValue(), -Double.pi / 6, accuracy: Double.epsilon)
    }

    func testConvertToStandardizedScreenUp() {
        motionManager.zAcceleration = -0.5 // or any other negative value read by acceleration the sensors

        // no inclination
        XCTAssertEqual(sensor.convertToStandardized(rawValue: 0), 0, accuracy: Double.epsilon)

        // half up - home botton down
        XCTAssertEqual(sensor.convertToStandardized(rawValue: Double.pi / 4), 45, accuracy: Double.epsilon)

        // up - face to face to the user
        XCTAssertEqual(sensor.convertToStandardized(rawValue: Double.pi / 2), 90, accuracy: Double.epsilon)

        // half up - home button up
        XCTAssertEqual(sensor.convertToStandardized(rawValue: -Double.pi / 4), -45, accuracy: Double.epsilon)
    }

    func testConvertToStandardizedScreenDown() {
        motionManager.zAcceleration = 0.5 //or any other positive value read by the acceleration sensors

        // half down - home button down
        XCTAssertEqual(sensor.convertToStandardized(rawValue: Double.pi / 4), 135, accuracy: Double.epsilon)

        // up - with the back to the user
        XCTAssertEqual(sensor.convertToStandardized(rawValue: -Double.pi / 2), -90, accuracy: Double.epsilon)

        // half down - home button up
        XCTAssertEqual(sensor.convertToStandardized(rawValue: -Double.pi / 4), -135, accuracy: Double.epsilon)
    }

    func testTag() {
        XCTAssertEqual("Y_INCLINATION", sensor.tag())
    }

    func testRequiredResources() {
        XCTAssertEqual(ResourceType.accelerometerAndDeviceMotion, type(of: sensor).requiredResource)
    }

    func testFormulaEditorSection() {
        XCTAssertEqual(.device(position: type(of: sensor).position), sensor.formulaEditorSection(for: SpriteObject()))
    }
}
