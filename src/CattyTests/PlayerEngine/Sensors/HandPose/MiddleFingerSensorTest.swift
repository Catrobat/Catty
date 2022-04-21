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

final class MiddleFingerSensorTest: XCTestCase {

    var middleFingerXSensor: LeftMiddleFingerKnuckleXSensor!
    var middleFingerYSensor: LeftMiddleFingerKnuckleYSensor!
    var visualDetectionManagerMock: VisualDetectionManagerMock!
    var stageSize: CGSize!

    override func setUp() {
        super.setUp()
        self.visualDetectionManagerMock = VisualDetectionManagerMock()
        self.stageSize = CGSize(width: 1080, height: 1920)
        self.visualDetectionManagerMock.setVisualDetectionFrameSize(stageSize)
        self.middleFingerXSensor = LeftMiddleFingerKnuckleXSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock })
        self.middleFingerYSensor = LeftMiddleFingerKnuckleYSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock })
    }

    override func tearDown() {
        self.visualDetectionManagerMock = nil
        self.middleFingerXSensor = nil
        self.middleFingerYSensor = nil
        super.tearDown()
    }

    func testDefaultRawValue() {
        let middleFingerXSensor = LeftMiddleFingerKnuckleXSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil })
        XCTAssertEqual(type(of: middleFingerXSensor).defaultRawValue, middleFingerXSensor.rawValue(landscapeMode: false), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: middleFingerXSensor).defaultRawValue, middleFingerXSensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)

        let middleFingerYSensor = LeftMiddleFingerKnuckleYSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil })
        XCTAssertEqual(type(of: middleFingerYSensor).defaultRawValue, middleFingerYSensor.rawValue(landscapeMode: false), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: middleFingerYSensor).defaultRawValue, middleFingerYSensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)
    }

    func testRawValue() {
        self.visualDetectionManagerMock.handPosePositionRatioDictionary[LeftMiddleFingerKnuckleXSensor.tag] = 0
        XCTAssertEqual(0, self.middleFingerXSensor.rawValue(landscapeMode: false))
        XCTAssertEqual(0, self.middleFingerXSensor.rawValue(landscapeMode: true))

        self.visualDetectionManagerMock.handPosePositionRatioDictionary[LeftMiddleFingerKnuckleYSensor.tag] = 0.95
        XCTAssertEqual(0.95, self.middleFingerYSensor.rawValue(landscapeMode: false))
        XCTAssertEqual(0.95, self.middleFingerYSensor.rawValue(landscapeMode: true))
    }

    func testConvertToStandardized() {
        XCTAssertEqual(type(of: middleFingerXSensor).defaultRawValue, middleFingerXSensor.convertToStandardized(rawValue: 0))

        XCTAssertEqual(Double(stageSize.width * 0.02) - Double(stageSize.width / 2), middleFingerXSensor.convertToStandardized(rawValue: 0.02))
        XCTAssertEqual(Double(stageSize.width * 0.45) - Double(stageSize.width / 2), middleFingerXSensor.convertToStandardized(rawValue: 0.45))
        XCTAssertEqual(Double(stageSize.width * 0.93) - Double(stageSize.width / 2), middleFingerXSensor.convertToStandardized(rawValue: 0.93))
        XCTAssertEqual(Double(stageSize.width / 2), middleFingerXSensor.convertToStandardized(rawValue: 1.0))

        XCTAssertEqual(type(of: middleFingerYSensor).defaultRawValue, middleFingerYSensor.convertToStandardized(rawValue: 0))

        XCTAssertEqual(Double(stageSize.height * 0.01) - Double(stageSize.height / 2), middleFingerYSensor.convertToStandardized(rawValue: 0.01))
        XCTAssertEqual(Double(stageSize.height * 0.4) - Double(stageSize.height / 2), middleFingerYSensor.convertToStandardized(rawValue: 0.4))
        XCTAssertEqual(Double(stageSize.height * 0.95) - Double(stageSize.height / 2), middleFingerYSensor.convertToStandardized(rawValue: 0.95))
        XCTAssertEqual(Double(stageSize.height / 2), middleFingerYSensor.convertToStandardized(rawValue: 1.0))
    }

    func testStandardizedValue() {
        var convertToStandardizedValue = middleFingerXSensor.convertToStandardized(rawValue: middleFingerXSensor.rawValue(landscapeMode: false))
        var standardizedValue = middleFingerXSensor.standardizedValue(landscapeMode: false)
        var standardizedValueLandscape = middleFingerXSensor.standardizedValue(landscapeMode: true)
        XCTAssertEqual(convertToStandardizedValue, standardizedValue)
        XCTAssertEqual(standardizedValue, standardizedValueLandscape)

        convertToStandardizedValue = middleFingerYSensor.convertToStandardized(rawValue: middleFingerYSensor.rawValue(landscapeMode: false))
        standardizedValue = middleFingerYSensor.standardizedValue(landscapeMode: false)
        standardizedValueLandscape = middleFingerYSensor.standardizedValue(landscapeMode: true)
        XCTAssertEqual(convertToStandardizedValue, standardizedValue)
        XCTAssertEqual(standardizedValue, standardizedValueLandscape)
    }

    func testTag() {
        XCTAssertEqual("LEFT_MIDDLE_FINGER_X", middleFingerXSensor.tag())
        XCTAssertEqual("LEFT_MIDDLE_FINGER_Y", middleFingerYSensor.tag())
    }

    func testRequiredResources() {
        XCTAssertEqual(ResourceType.faceDetection, type(of: middleFingerXSensor).requiredResource)
        XCTAssertEqual(ResourceType.faceDetection, type(of: middleFingerYSensor).requiredResource)
    }

    func testFormulaEditorSections() {
        var sections = middleFingerXSensor.formulaEditorSections(for: SpriteObject())
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual(.sensors(position: type(of: middleFingerXSensor).position, subsection: .pose), sections.first)

        sections = middleFingerYSensor.formulaEditorSections(for: SpriteObject())
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual(.sensors(position: type(of: middleFingerYSensor).position, subsection: .pose), sections.first)
    }
}
