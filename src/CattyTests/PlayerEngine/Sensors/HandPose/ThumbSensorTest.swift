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

final class ThumbSensorTest: XCTestCase {

    var thumbXSensor: LeftThumbKnuckleXSensor!
    var thumbYSensor: LeftThumbKnuckleYSensor!
    var visualDetectionManagerMock: VisualDetectionManagerMock!
    var stageSize: CGSize!

    override func setUp() {
        super.setUp()
        self.visualDetectionManagerMock = VisualDetectionManagerMock()
        self.stageSize = CGSize(width: 1080, height: 1920)
        self.visualDetectionManagerMock.setVisualDetectionFrameSize(stageSize)
        self.thumbXSensor = LeftThumbKnuckleXSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock })
        self.thumbYSensor = LeftThumbKnuckleYSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock })
    }

    override func tearDown() {
        self.visualDetectionManagerMock = nil
        self.thumbXSensor = nil
        self.thumbYSensor = nil
        super.tearDown()
    }

    func testDefaultRawValue() {
        let thumbXSensor = LeftThumbKnuckleXSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil })
        XCTAssertEqual(type(of: thumbXSensor).defaultRawValue, thumbXSensor.rawValue(landscapeMode: false), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: thumbXSensor).defaultRawValue, thumbXSensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)

        let thumbYSensor = LeftThumbKnuckleYSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil })
        XCTAssertEqual(type(of: thumbYSensor).defaultRawValue, thumbYSensor.rawValue(landscapeMode: false), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: thumbYSensor).defaultRawValue, thumbYSensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)
    }

    func testRawValue() {
        self.visualDetectionManagerMock.handPosePositionRatioDictionary[LeftThumbKnuckleXSensor.tag] = 0
        XCTAssertEqual(0, self.thumbXSensor.rawValue(landscapeMode: false))
        XCTAssertEqual(0, self.thumbXSensor.rawValue(landscapeMode: true))

        self.visualDetectionManagerMock.handPosePositionRatioDictionary[LeftThumbKnuckleYSensor.tag] = 0.95
        XCTAssertEqual(0.95, self.thumbYSensor.rawValue(landscapeMode: false))
        XCTAssertEqual(0.95, self.thumbYSensor.rawValue(landscapeMode: true))
    }

    func testConvertToStandardized() {
        XCTAssertEqual(type(of: thumbXSensor).defaultRawValue, thumbXSensor.convertToStandardized(rawValue: 0))

        XCTAssertEqual(Double(stageSize.width * 0.02) - Double(stageSize.width / 2), thumbXSensor.convertToStandardized(rawValue: 0.02))
        XCTAssertEqual(Double(stageSize.width * 0.45) - Double(stageSize.width / 2), thumbXSensor.convertToStandardized(rawValue: 0.45))
        XCTAssertEqual(Double(stageSize.width * 0.93) - Double(stageSize.width / 2), thumbXSensor.convertToStandardized(rawValue: 0.93))
        XCTAssertEqual(Double(stageSize.width / 2), thumbXSensor.convertToStandardized(rawValue: 1.0))

        XCTAssertEqual(type(of: thumbYSensor).defaultRawValue, thumbYSensor.convertToStandardized(rawValue: 0))

        XCTAssertEqual(Double(stageSize.height * 0.01) - Double(stageSize.height / 2), thumbYSensor.convertToStandardized(rawValue: 0.01))
        XCTAssertEqual(Double(stageSize.height * 0.4) - Double(stageSize.height / 2), thumbYSensor.convertToStandardized(rawValue: 0.4))
        XCTAssertEqual(Double(stageSize.height * 0.95) - Double(stageSize.height / 2), thumbYSensor.convertToStandardized(rawValue: 0.95))
        XCTAssertEqual(Double(stageSize.height / 2), thumbYSensor.convertToStandardized(rawValue: 1.0))
    }

    func testStandardizedValue() {
        var convertToStandardizedValue = thumbXSensor.convertToStandardized(rawValue: thumbXSensor.rawValue(landscapeMode: false))
        var standardizedValue = thumbXSensor.standardizedValue(landscapeMode: false)
        var standardizedValueLandscape = thumbXSensor.standardizedValue(landscapeMode: true)
        XCTAssertEqual(convertToStandardizedValue, standardizedValue)
        XCTAssertEqual(standardizedValue, standardizedValueLandscape)

        convertToStandardizedValue = thumbYSensor.convertToStandardized(rawValue: thumbYSensor.rawValue(landscapeMode: false))
        standardizedValue = thumbYSensor.standardizedValue(landscapeMode: false)
        standardizedValueLandscape = thumbYSensor.standardizedValue(landscapeMode: true)
        XCTAssertEqual(convertToStandardizedValue, standardizedValue)
        XCTAssertEqual(standardizedValue, standardizedValueLandscape)
    }

    func testTag() {
        XCTAssertEqual("LEFT_THUMB_X", thumbXSensor.tag())
        XCTAssertEqual("LEFT_THUMB_Y", thumbYSensor.tag())
    }

    func testRequiredResources() {
        XCTAssertEqual(ResourceType.faceDetection, type(of: thumbXSensor).requiredResource)
        XCTAssertEqual(ResourceType.faceDetection, type(of: thumbYSensor).requiredResource)
    }

    func testFormulaEditorSections() {
        var sections = thumbXSensor.formulaEditorSections(for: SpriteObject())
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual(.sensors(position: type(of: thumbXSensor).position, subsection: .pose), sections.first)

        sections = thumbYSensor.formulaEditorSections(for: SpriteObject())
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual(.sensors(position: type(of: thumbYSensor).position, subsection: .pose), sections.first)
    }
}
