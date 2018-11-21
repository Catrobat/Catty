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

final class CompassDirectionSensorTest: XCTestCase {

    var locationManager: LocationManagerMock!
    var sensor: CompassDirectionSensor!

    override func setUp() {
        super.setUp()
        locationManager = LocationManagerMock()
        sensor = CompassDirectionSensor { [weak self] in self?.locationManager }
    }

    override func tearDown() {
        sensor = nil
        locationManager = nil
        super.tearDown()
    }

    func testDefaultRawValue() {
        let sensor = CompassDirectionSensor { nil }
        XCTAssertEqual(CompassDirectionSensor.defaultRawValue, sensor.rawValue(), accuracy: Double.epsilon)
    }

    func testRawValue() {
        // N
        locationManager.magneticHeading = 0
        XCTAssertEqual(0, sensor.rawValue())

        // E
        locationManager.magneticHeading = 90
        XCTAssertEqual(90, sensor.rawValue())

        // S
        locationManager.magneticHeading = 180
        XCTAssertEqual(180, sensor.rawValue())

        // W
        locationManager.magneticHeading = 270
        XCTAssertEqual(270, sensor.rawValue())

    }

    func testConvertToStandardized() {
        // N
        XCTAssertEqual(0, sensor.convertToStandardized(rawValue: 0))

        // N-E
        XCTAssertEqual(-45, sensor.convertToStandardized(rawValue: 45))

        // E
        XCTAssertEqual(-90, sensor.convertToStandardized(rawValue: 90))

        // S-E
        XCTAssertEqual(-135, sensor.convertToStandardized(rawValue: 135))

        // S
        XCTAssertEqual(-180, sensor.convertToStandardized(rawValue: 180))

        // S-W
        XCTAssertEqual(135, sensor.convertToStandardized(rawValue: 225))

        // W
        XCTAssertEqual(90, sensor.convertToStandardized(rawValue: 270))

        // Kanye's daughter
        XCTAssertEqual(45, sensor.convertToStandardized(rawValue: 315))
    }

    func testTag() {
        XCTAssertEqual("COMPASS_DIRECTION", sensor.tag())
    }

    func testRequiredResources() {
        XCTAssertEqual(ResourceType.compass, type(of: sensor).requiredResource)
    }

    func testFormulaEditorSection() {
        XCTAssertEqual(.device(position: type(of: sensor).position), sensor.formulaEditorSection(for: SpriteObject()))
    }
}
