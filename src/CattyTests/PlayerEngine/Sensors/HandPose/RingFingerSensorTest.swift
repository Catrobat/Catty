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

final class RingFingerSensorTest: XCTestCase {

    var ringFingerXSensor: LeftRingFingerKnuckleXSensor!
    var ringFingerYSensor: LeftRingFingerKnuckleYSensor!
    var visualDetectionManagerMock: VisualDetectionManagerMock!
    var stageSize: CGSize!

    override func setUp() {
        super.setUp()
        self.visualDetectionManagerMock = VisualDetectionManagerMock()
        self.stageSize = CGSize(width: 1080, height: 1920)
        self.visualDetectionManagerMock.setVisualDetectionFrameSize(stageSize)
        self.ringFingerXSensor = LeftRingFingerKnuckleXSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock })
        self.ringFingerYSensor = LeftRingFingerKnuckleYSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock })
    }

    override func tearDown() {
        self.visualDetectionManagerMock = nil
        self.ringFingerXSensor = nil
        self.ringFingerYSensor = nil
        super.tearDown()
    }

    func testDefaultRawValue() {
        let ringFingerXSensor = LeftRingFingerKnuckleXSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil })
        XCTAssertEqual(type(of: ringFingerXSensor).defaultRawValue, ringFingerXSensor.rawValue(landscapeMode: false), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: ringFingerXSensor).defaultRawValue, ringFingerXSensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)

        let ringFingerYSensor = LeftRingFingerKnuckleYSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil })
        XCTAssertEqual(type(of: ringFingerYSensor).defaultRawValue, ringFingerYSensor.rawValue(landscapeMode: false), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: ringFingerYSensor).defaultRawValue, ringFingerYSensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)
    }

    func testRawValue() {
        self.visualDetectionManagerMock.handPosePositionRatioDictionary[LeftRingFingerKnuckleXSensor.tag] = 0
        XCTAssertEqual(0, self.ringFingerXSensor.rawValue(landscapeMode: false))
        XCTAssertEqual(0, self.ringFingerXSensor.rawValue(landscapeMode: true))

        self.visualDetectionManagerMock.handPosePositionRatioDictionary[LeftRingFingerKnuckleYSensor.tag] = 0.95
        XCTAssertEqual(0.95, self.ringFingerYSensor.rawValue(landscapeMode: false))
        XCTAssertEqual(0.95, self.ringFingerYSensor.rawValue(landscapeMode: true))
    }

    func testConvertToStandardized() {
        XCTAssertEqual(type(of: ringFingerXSensor).defaultRawValue, ringFingerXSensor.convertToStandardized(rawValue: 0))

        XCTAssertEqual(Double(stageSize.width * 0.02) - Double(stageSize.width / 2), ringFingerXSensor.convertToStandardized(rawValue: 0.02))
        XCTAssertEqual(Double(stageSize.width * 0.45) - Double(stageSize.width / 2), ringFingerXSensor.convertToStandardized(rawValue: 0.45))
        XCTAssertEqual(Double(stageSize.width * 0.93) - Double(stageSize.width / 2), ringFingerXSensor.convertToStandardized(rawValue: 0.93))
        XCTAssertEqual(Double(stageSize.width / 2), ringFingerXSensor.convertToStandardized(rawValue: 1.0))

        XCTAssertEqual(type(of: ringFingerYSensor).defaultRawValue, ringFingerYSensor.convertToStandardized(rawValue: 0))

        XCTAssertEqual(Double(stageSize.height * 0.01) - Double(stageSize.height / 2), ringFingerYSensor.convertToStandardized(rawValue: 0.01))
        XCTAssertEqual(Double(stageSize.height * 0.4) - Double(stageSize.height / 2), ringFingerYSensor.convertToStandardized(rawValue: 0.4))
        XCTAssertEqual(Double(stageSize.height * 0.95) - Double(stageSize.height / 2), ringFingerYSensor.convertToStandardized(rawValue: 0.95))
        XCTAssertEqual(Double(stageSize.height / 2), ringFingerYSensor.convertToStandardized(rawValue: 1.0))
    }

    func testStandardizedValue() {
        var convertToStandardizedValue = ringFingerXSensor.convertToStandardized(rawValue: ringFingerXSensor.rawValue(landscapeMode: false))
        var standardizedValue = ringFingerXSensor.standardizedValue(landscapeMode: false)
        var standardizedValueLandscape = ringFingerXSensor.standardizedValue(landscapeMode: true)
        XCTAssertEqual(convertToStandardizedValue, standardizedValue)
        XCTAssertEqual(standardizedValue, standardizedValueLandscape)

        convertToStandardizedValue = ringFingerYSensor.convertToStandardized(rawValue: ringFingerYSensor.rawValue(landscapeMode: false))
        standardizedValue = ringFingerYSensor.standardizedValue(landscapeMode: false)
        standardizedValueLandscape = ringFingerYSensor.standardizedValue(landscapeMode: true)
        XCTAssertEqual(convertToStandardizedValue, standardizedValue)
        XCTAssertEqual(standardizedValue, standardizedValueLandscape)
    }

    func testTag() {
        XCTAssertEqual("LEFT_RING_FINGER_X", ringFingerXSensor.tag())
        XCTAssertEqual("LEFT_RING_FINGER_Y", ringFingerYSensor.tag())
    }

    func testRequiredResources() {
        XCTAssertEqual(ResourceType.faceDetection, type(of: ringFingerXSensor).requiredResource)
        XCTAssertEqual(ResourceType.faceDetection, type(of: ringFingerYSensor).requiredResource)
    }

    func testFormulaEditorSections() {
        var sections = ringFingerXSensor.formulaEditorSections(for: SpriteObject())
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual(.sensors(position: type(of: ringFingerXSensor).position, subsection: .pose), sections.first)

        sections = ringFingerYSensor.formulaEditorSections(for: SpriteObject())
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual(.sensors(position: type(of: ringFingerYSensor).position, subsection: .pose), sections.first)
    }
}
