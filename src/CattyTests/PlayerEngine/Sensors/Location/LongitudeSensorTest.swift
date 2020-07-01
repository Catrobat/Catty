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

final class LongitudeSensorTest: XCTestCase {

    var locationManager: LocationManagerMock!
    var sensor: LongitudeSensor!

    override func setUp() {
        super.setUp()
        locationManager = LocationManagerMock()
        sensor = LongitudeSensor { [weak self] in self?.locationManager }
    }

    override func tearDown() {
        sensor = nil
        locationManager = nil
        super.tearDown()
    }

    func testDefaultRawValue() {
        let sensor = LongitudeSensor { nil }
        XCTAssertEqual(LongitudeSensor.defaultRawValue, sensor.rawValue(), accuracy: Double.epsilon)
    }

    func testRawValue() {
        // min value
        locationManager.longitude = -180
        XCTAssertEqual(-180, sensor.rawValue())

        // max value
        locationManager.longitude = 180
        XCTAssertEqual(180, sensor.rawValue())

        // center
        locationManager.longitude = 0
        XCTAssertEqual(0, sensor.rawValue())

        // London
        locationManager.longitude = -0.127
        XCTAssertEqual(-0.127, sensor.rawValue())

        // Cape Town
        locationManager.longitude = 18.424
        XCTAssertEqual(18.424, sensor.rawValue())

        // Alaska
        locationManager.longitude = -149.49
        XCTAssertEqual(-149.49, sensor.rawValue())
    }

    func testConvertToStandardized() {
        XCTAssertEqual(100, sensor.convertToStandardized(rawValue: 100, landscapeMode: false))
    }

    func testStandardizedValue() {
        let convertToStandardizedValue = sensor.convertToStandardized(rawValue: sensor.rawValue(), landscapeMode: false)
        let standardizedValue = sensor.standardizedValue(landscapeMode: false)
        let standardizedValueLandscape = sensor.standardizedValue(landscapeMode: true)
        XCTAssertEqual(convertToStandardizedValue, standardizedValue)
        XCTAssertEqual(standardizedValue, standardizedValueLandscape)
    }

    func testTag() {
        XCTAssertEqual("LONGITUDE", sensor.tag())
    }

    func testRequiredResources() {
        XCTAssertEqual(ResourceType.location, type(of: sensor).requiredResource)
    }

    func testFormulaEditorSections() {
        let sections = sensor.formulaEditorSections(for: SpriteObject())
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual(.device(position: type(of: sensor).position), sections.first)
    }
}
