/**
 *  Copyright (C) 2010-2022 The Catrobat Team
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

final class FacePositionXSensorTest: XCTestCase {

    var sensor: FacePositionXSensor!
    var cameraManagerMock: FaceDetectionManagerMock!
    var stageSize: CGSize!

    override func setUp() {
        super.setUp()
        self.cameraManagerMock = FaceDetectionManagerMock()
        self.stageSize = CGSize(width: 1080, height: 1920)
        self.sensor = FacePositionXSensor(stageSize: stageSize, faceDetectionManagerGetter: { [ weak self ] in self?.cameraManagerMock })
    }

    override func tearDown() {
        self.cameraManagerMock = nil
        self.sensor = nil
        super.tearDown()
    }

    func testDefaultRawValue() {
        let sensor = FacePositionXSensor(stageSize: stageSize, faceDetectionManagerGetter: { nil })
        XCTAssertEqual(type(of: sensor).defaultRawValue, sensor.rawValue(landscapeMode: false), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: sensor).defaultRawValue, sensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)
    }

    func testRawValue() {
        // only positive values - (0, 0) is at the bottom left
        self.cameraManagerMock.facePositionRatioFromLeft = 0
        XCTAssertEqual(0, self.sensor.rawValue(landscapeMode: false))
        XCTAssertEqual(0, self.sensor.rawValue(landscapeMode: true))

        self.cameraManagerMock.facePositionRatioFromLeft = 56
        XCTAssertEqual(56, self.sensor.rawValue(landscapeMode: false))
        XCTAssertEqual(56, self.sensor.rawValue(landscapeMode: true))
    }

    func testConvertToStandardized() {
        XCTAssertEqual(type(of: sensor).defaultRawValue, sensor.convertToStandardized(rawValue: 0))

        XCTAssertEqual(Double(stageSize.width * 0.02) - Double(stageSize.width / 2), sensor.convertToStandardized(rawValue: 0.02))
        XCTAssertEqual(Double(stageSize.width * 0.45) - Double(stageSize.width / 2), sensor.convertToStandardized(rawValue: 0.45))
        XCTAssertEqual(Double(stageSize.width * 0.93) - Double(stageSize.width / 2), sensor.convertToStandardized(rawValue: 0.93))
        XCTAssertEqual(Double(stageSize.width / 2), sensor.convertToStandardized(rawValue: 1.0))
    }

    func testStandardizedValue() {
        let convertToStandardizedValue = sensor.convertToStandardized(rawValue: sensor.rawValue(landscapeMode: false))
        let standardizedValue = sensor.standardizedValue(landscapeMode: false)
        let standardizedValueLandscape = sensor.standardizedValue(landscapeMode: true)
        XCTAssertEqual(convertToStandardizedValue, standardizedValue)
        XCTAssertEqual(standardizedValue, standardizedValueLandscape)
    }

    func testTag() {
        XCTAssertEqual("FACE_X_POSITION", sensor.tag())
    }

    func testRequiredResources() {
        XCTAssertEqual(ResourceType.faceDetection, type(of: sensor).requiredResource)
    }

    func testFormulaEditorSections() {
        let sections = sensor.formulaEditorSections(for: SpriteObject())
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual(.sensors(position: type(of: sensor).position, subsection: .visual), sections.first)
    }
}
