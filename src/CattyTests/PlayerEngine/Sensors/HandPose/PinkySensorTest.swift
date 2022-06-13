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

final class PinkySensorTest: XCTestCase {

    var pinkyXSensor: LeftPinkyKnuckleXSensor!
    var pinkyYSensor: LeftPinkyKnuckleYSensor!
    var visualDetectionManagerMock: VisualDetectionManagerMock!
    var stageSize: CGSize!

    override func setUp() {
        super.setUp()
        self.visualDetectionManagerMock = VisualDetectionManagerMock()
        self.stageSize = CGSize(width: 1080, height: 1920)
        self.visualDetectionManagerMock.setVisualDetectionFrameSize(stageSize)
        self.pinkyXSensor = LeftPinkyKnuckleXSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock })
        self.pinkyYSensor = LeftPinkyKnuckleYSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock })
    }

    override func tearDown() {
        self.visualDetectionManagerMock = nil
        self.pinkyXSensor = nil
        self.pinkyYSensor = nil
        super.tearDown()
    }

    func testDefaultRawValue() {
        let pinkyXSensor = LeftPinkyKnuckleXSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil })
        XCTAssertEqual(type(of: pinkyXSensor).defaultRawValue, pinkyXSensor.rawValue(landscapeMode: false), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: pinkyXSensor).defaultRawValue, pinkyXSensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)

        let pinkyYSensor = LeftPinkyKnuckleYSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil })
        XCTAssertEqual(type(of: pinkyYSensor).defaultRawValue, pinkyYSensor.rawValue(landscapeMode: false), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: pinkyYSensor).defaultRawValue, pinkyYSensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)
    }

    func testRawValue() {
        self.visualDetectionManagerMock.handPosePositionRatioDictionary[LeftPinkyKnuckleXSensor.tag] = 0
        XCTAssertEqual(0, self.pinkyXSensor.rawValue(landscapeMode: false))
        XCTAssertEqual(0, self.pinkyXSensor.rawValue(landscapeMode: true))

        self.visualDetectionManagerMock.handPosePositionRatioDictionary[LeftPinkyKnuckleYSensor.tag] = 0.95
        XCTAssertEqual(0.95, self.pinkyYSensor.rawValue(landscapeMode: false))
        XCTAssertEqual(0.95, self.pinkyYSensor.rawValue(landscapeMode: true))
    }

    func testConvertToStandardized() {
        XCTAssertEqual(type(of: pinkyXSensor).defaultRawValue, pinkyXSensor.convertToStandardized(rawValue: 0))

        XCTAssertEqual(Double(stageSize.width * 0.02) - Double(stageSize.width / 2), pinkyXSensor.convertToStandardized(rawValue: 0.02))
        XCTAssertEqual(Double(stageSize.width * 0.45) - Double(stageSize.width / 2), pinkyXSensor.convertToStandardized(rawValue: 0.45))
        XCTAssertEqual(Double(stageSize.width * 0.93) - Double(stageSize.width / 2), pinkyXSensor.convertToStandardized(rawValue: 0.93))
        XCTAssertEqual(Double(stageSize.width / 2), pinkyXSensor.convertToStandardized(rawValue: 1.0))

        XCTAssertEqual(type(of: pinkyYSensor).defaultRawValue, pinkyYSensor.convertToStandardized(rawValue: 0))

        XCTAssertEqual(Double(stageSize.height * 0.01) - Double(stageSize.height / 2), pinkyYSensor.convertToStandardized(rawValue: 0.01))
        XCTAssertEqual(Double(stageSize.height * 0.4) - Double(stageSize.height / 2), pinkyYSensor.convertToStandardized(rawValue: 0.4))
        XCTAssertEqual(Double(stageSize.height * 0.95) - Double(stageSize.height / 2), pinkyYSensor.convertToStandardized(rawValue: 0.95))
        XCTAssertEqual(Double(stageSize.height / 2), pinkyYSensor.convertToStandardized(rawValue: 1.0))
    }

    func testStandardizedValue() {
        var convertToStandardizedValue = pinkyXSensor.convertToStandardized(rawValue: pinkyXSensor.rawValue(landscapeMode: false))
        var standardizedValue = pinkyXSensor.standardizedValue(landscapeMode: false)
        var standardizedValueLandscape = pinkyXSensor.standardizedValue(landscapeMode: true)
        XCTAssertEqual(convertToStandardizedValue, standardizedValue)
        XCTAssertEqual(standardizedValue, standardizedValueLandscape)

        convertToStandardizedValue = pinkyYSensor.convertToStandardized(rawValue: pinkyYSensor.rawValue(landscapeMode: false))
        standardizedValue = pinkyYSensor.standardizedValue(landscapeMode: false)
        standardizedValueLandscape = pinkyYSensor.standardizedValue(landscapeMode: true)
        XCTAssertEqual(convertToStandardizedValue, standardizedValue)
        XCTAssertEqual(standardizedValue, standardizedValueLandscape)
    }

    func testTag() {
        XCTAssertEqual("LEFT_PINKY_X", pinkyXSensor.tag())
        XCTAssertEqual("LEFT_PINKY_Y", pinkyYSensor.tag())
    }

    func testRequiredResources() {
        XCTAssertEqual(ResourceType.faceDetection, type(of: pinkyXSensor).requiredResource)
        XCTAssertEqual(ResourceType.faceDetection, type(of: pinkyYSensor).requiredResource)
    }

    func testFormulaEditorSections() {
        var sections = pinkyXSensor.formulaEditorSections(for: SpriteObject())
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual(.sensors(position: type(of: pinkyXSensor).position, subsection: .pose), sections.first)

        sections = pinkyYSensor.formulaEditorSections(for: SpriteObject())
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual(.sensors(position: type(of: pinkyYSensor).position, subsection: .pose), sections.first)
    }
}
