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

final class AltitudeSensorTest: XCTestCase {

    var locationManager: LocationManagerMock!
    var sensor: AltitudeSensor!

    override func setUp() {
        super.setUp()
        locationManager = LocationManagerMock()
        sensor = AltitudeSensor { [weak self] in self?.locationManager }
    }

    override func tearDown() {
        sensor = nil
        locationManager = nil
        super.tearDown()
    }

    func testDefaultRawValue() {
        let sensor = AltitudeSensor { nil }
        XCTAssertEqual(AltitudeSensor.defaultRawValue, sensor.rawValue(), accuracy: Double.epsilon)
    }

    func testRawValue() {
        // sea level
        locationManager.altitude = 0
        XCTAssertEqual(0, sensor.rawValue())

        // below sea level
        locationManager.altitude = -250
        XCTAssertEqual(-250, sensor.rawValue())

        // field
        locationManager.altitude = 600
        XCTAssertEqual(600, sensor.rawValue())

        // mountain
        locationManager.altitude = 1500
        XCTAssertEqual(1500, sensor.rawValue())

        // Mt. Everest
        locationManager.altitude = 8848
        XCTAssertEqual(8848, sensor.rawValue())

        // float attitude
        locationManager.altitude = 2555.875
        XCTAssertEqual(2555.875, sensor.rawValue())
    }

    func testConvertToStandardized() {
        XCTAssertEqual(100, sensor.convertToStandardized(rawValue: 100))
    }

    func testTag() {
        XCTAssertEqual("ALTITUDE", sensor.tag())
    }

    func testRequiredResources() {
        XCTAssertEqual(ResourceType.location, type(of: sensor).requiredResource)
    }

    func testFormulaEditorSection() {
        XCTAssertEqual(.device(position: type(of: sensor).position), sensor.formulaEditorSection(for: SpriteObject()))
    }
}
