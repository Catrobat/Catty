/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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

final class FaceDetectionSensorTest: XCTestCase {

    var sensor: FaceDetectedSensor!
    var cameraManagerMock: FaceDetectionManagerMock!

    func testDefaultRawValue() {
        let sensor = FaceDetectedSensor { nil }
        XCTAssertEqual(type(of: sensor).defaultRawValue, sensor.rawValue(landscapeMode: false), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: sensor).defaultRawValue, sensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)
    }

    override func setUp() {
        super.setUp()
        self.cameraManagerMock = FaceDetectionManagerMock()
        self.sensor = FaceDetectedSensor { [ weak self ] in self?.cameraManagerMock }
    }

    override func tearDown() {
        self.cameraManagerMock = nil
        self.sensor = nil
        super.tearDown()
    }

    func testRawValue() {
        self.cameraManagerMock.isFaceDetected = true
        XCTAssertEqual(1, self.sensor.rawValue(landscapeMode: false))
        XCTAssertEqual(1, self.sensor.rawValue(landscapeMode: true))

        self.cameraManagerMock.isFaceDetected = false
        XCTAssertEqual(0, self.sensor.rawValue(landscapeMode: false))
        XCTAssertEqual(0, self.sensor.rawValue(landscapeMode: true))
    }

    func testConvertToStandardized() {
        XCTAssertEqual(0, sensor.convertToStandardized(rawValue: 0))
        XCTAssertEqual(1, sensor.convertToStandardized(rawValue: 1))
    }

    func testStandardizedValue() {
        let convertToStandardizedValue = sensor.convertToStandardized(rawValue: sensor.rawValue(landscapeMode: false))
        let standardizedValue = sensor.standardizedValue(landscapeMode: false)
        let standardizedValueLandscape = sensor.standardizedValue(landscapeMode: true)
        XCTAssertEqual(convertToStandardizedValue, standardizedValue)
        XCTAssertEqual(standardizedValue, standardizedValueLandscape)
    }

    func testTag() {
        XCTAssertEqual("FACE_DETECTED", sensor.tag())
    }

    func testRequiredResources() {
        XCTAssertEqual(ResourceType.faceDetection, type(of: sensor).requiredResource)
    }

    func testFormulaEditorSections() {
        let sections = sensor.formulaEditorSections(for: SpriteObject())
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual(.device(position: type(of: sensor).position), sections.first)
    }
}
