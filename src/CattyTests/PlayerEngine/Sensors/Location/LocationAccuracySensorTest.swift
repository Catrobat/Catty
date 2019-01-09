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

final class LocationAccuracySensorTest: XCTestCase {

    var locationManager: LocationManagerMock!
    var sensor: LocationAccuracySensor!

    override func setUp() {
        super.setUp()
        locationManager = LocationManagerMock()
        sensor = LocationAccuracySensor { [weak self] in self?.locationManager }
    }

    override func tearDown() {
        self.sensor = nil
        self.locationManager = nil
        super.tearDown()
    }

    func testDefaultRawValue() {
        let sensor = LocationAccuracySensor { nil }
        XCTAssertEqual(LocationAccuracySensor.defaultRawValue, sensor.rawValue(), accuracy: Double.epsilon)
    }

    func testRawValue() {
        // positive value => valid location
        locationManager.locationAccuracy = 10
        XCTAssertEqual(10, sensor.rawValue())

        // negative value => invalid location
        locationManager.locationAccuracy = -5
        XCTAssertEqual(-5, sensor.rawValue())
    }

    func testConvertToStandardized() {
        // valid location
        XCTAssertEqual(100, sensor.convertToStandardized(rawValue: 100))

        // invalid location
        XCTAssertEqual(0, sensor.convertToStandardized(rawValue: -1))
    }

    func testTag() {
        XCTAssertEqual("LOCATION_ACCURACY", sensor.tag())
    }

    func testRequiredResources() {
        XCTAssertEqual(ResourceType.location, type(of: sensor).requiredResource)
    }

    func testFormulaEditorSection() {
        XCTAssertEqual(.device(position: type(of: sensor).position), sensor.formulaEditorSection(for: SpriteObject()))
    }
}
