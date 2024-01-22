/**
 *  Copyright (C) 2010-2024 The Catrobat Team
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

final class LatitudeSensorTest: XCTestCase {

    var locationManager: LocationManagerMock!
    var sensor: LatitudeSensor!

    override func setUp() {
        super.setUp()
        locationManager = LocationManagerMock()
        sensor = LatitudeSensor { [weak self] in self?.locationManager }
    }

    override func tearDown() {
        sensor = nil
        locationManager = nil
        super.tearDown()
    }

    func testDefaultRawValue() {
        let sensor = LatitudeSensor { nil }
        XCTAssertEqual(LatitudeSensor.defaultRawValue, sensor.rawValue(landscapeMode: false), accuracy: Double.epsilon)
        XCTAssertEqual(LatitudeSensor.defaultRawValue, sensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)
    }

    func testRawValue() {
        // min value - South Pole
        locationManager.latitude = -90
        XCTAssertEqual(-90, sensor.rawValue(landscapeMode: false))
        XCTAssertEqual(-90, sensor.rawValue(landscapeMode: true))

        // max value - North Pole
        locationManager.latitude = 90
        XCTAssertEqual(90, sensor.rawValue(landscapeMode: false))
        XCTAssertEqual(90, sensor.rawValue(landscapeMode: true))

        // center
        locationManager.latitude = 0
        XCTAssertEqual(0, sensor.rawValue(landscapeMode: false))
        XCTAssertEqual(0, sensor.rawValue(landscapeMode: true))

        // London
        locationManager.latitude = 51.5
        XCTAssertEqual(51.5, sensor.rawValue(landscapeMode: false))
        XCTAssertEqual(51.5, sensor.rawValue(landscapeMode: true))

        // Cape Town
        locationManager.latitude = -33.92
        XCTAssertEqual(-33.92, sensor.rawValue(landscapeMode: false))
        XCTAssertEqual(-33.92, sensor.rawValue(landscapeMode: true))

        // Munich
        locationManager.latitude = 48.13
        XCTAssertEqual(48.13, sensor.rawValue(landscapeMode: false))
        XCTAssertEqual(48.13, sensor.rawValue(landscapeMode: true))
    }

    func testConvertToStandardized() {
        XCTAssertEqual(100, sensor.convertToStandardized(rawValue: 100))
    }

    func testStandardizedValue() {
        let convertToStandardizedValue = sensor.convertToStandardized(rawValue: sensor.rawValue(landscapeMode: false))
        let standardizedValue = sensor.standardizedValue(landscapeMode: false)
        let standardizedValueLandscape = sensor.standardizedValue(landscapeMode: true)
        XCTAssertEqual(convertToStandardizedValue, standardizedValue)
        XCTAssertEqual(standardizedValue, standardizedValueLandscape)
    }

    func testTag() {
        XCTAssertEqual("LATITUDE", sensor.tag())
    }

    func testRequiredResources() {
        XCTAssertEqual(ResourceType.location, type(of: sensor).requiredResource)
    }

    func testFormulaEditorSections() {
        let sections = sensor.formulaEditorSections(for: SpriteObject())
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual(.sensors(position: type(of: sensor).position, subsection: .device), sections.first)
    }
}
