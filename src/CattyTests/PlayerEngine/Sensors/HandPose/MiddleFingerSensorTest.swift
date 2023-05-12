/**
 *  Copyright (C) 2010-2023 The Catrobat Team
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

    var middleFingerXSensors = [DeviceDoubleSensor]()
    var middleFingerYSensors = [DeviceDoubleSensor]()
    var visualDetectionManagerMock: VisualDetectionManagerMock!
    var stageSize: CGSize!

    override func setUp() {
        super.setUp()
        self.visualDetectionManagerMock = VisualDetectionManagerMock()
        self.stageSize = CGSize(width: 1080, height: 1920)
        self.middleFingerXSensors.append(LeftMiddleFingerKnuckleXSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.middleFingerXSensors.append(RightMiddleFingerKnuckleXSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.middleFingerYSensors.append(LeftMiddleFingerKnuckleYSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.middleFingerYSensors.append(RightMiddleFingerKnuckleYSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
    }

    override func tearDown() {
        self.visualDetectionManagerMock = nil
        self.middleFingerXSensors.removeAll()
        self.middleFingerYSensors.removeAll()
        super.tearDown()
    }

    func testDefaultRawValue() {
        var middleFingerSensors = [DeviceDoubleSensor]()
        middleFingerSensors.append(LeftMiddleFingerKnuckleXSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        middleFingerSensors.append(RightMiddleFingerKnuckleXSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        middleFingerSensors.append(LeftMiddleFingerKnuckleYSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        middleFingerSensors.append(RightMiddleFingerKnuckleYSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))

        for middleFingerSensor in middleFingerSensors {
            XCTAssertEqual(type(of: middleFingerSensor).defaultRawValue, middleFingerSensor.rawValue(landscapeMode: false), accuracy: Double.epsilon)
            XCTAssertEqual(type(of: middleFingerSensor).defaultRawValue, middleFingerSensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)
        }
    }

    func testRawValue() {
        visualDetectionManagerMock.setAllMiddleFingerSensorValueRatios(to: 0)
        for middleFingerSensor in middleFingerXSensors + middleFingerYSensors {
            XCTAssertEqual(0, middleFingerSensor.rawValue(landscapeMode: false))
            XCTAssertEqual(0, middleFingerSensor.rawValue(landscapeMode: true))
        }

        visualDetectionManagerMock.setAllMiddleFingerSensorValueRatios(to: 0.95)
        for middleFingerSensor in middleFingerXSensors + middleFingerYSensors {
            XCTAssertEqual(0.95, middleFingerSensor.rawValue(landscapeMode: false))
            XCTAssertEqual(0.95, middleFingerSensor.rawValue(landscapeMode: true))
        }
    }

    func testConvertToStandardized() {
        for middleFingerSensor in middleFingerXSensors {
            XCTAssertEqual(type(of: middleFingerSensor).defaultRawValue, middleFingerSensor.convertToStandardized(rawValue: 0))

            XCTAssertEqual(Double(stageSize.width * 0.02) - Double(stageSize.width / 2), middleFingerSensor.convertToStandardized(rawValue: 0.02))
            XCTAssertEqual(Double(stageSize.width * 0.45) - Double(stageSize.width / 2), middleFingerSensor.convertToStandardized(rawValue: 0.45))
            XCTAssertEqual(Double(stageSize.width * 0.93) - Double(stageSize.width / 2), middleFingerSensor.convertToStandardized(rawValue: 0.93))
            XCTAssertEqual(Double(stageSize.width / 2), middleFingerSensor.convertToStandardized(rawValue: 1.0))
        }

        for middleFingerSensor in middleFingerYSensors {
            XCTAssertEqual(type(of: middleFingerSensor).defaultRawValue, middleFingerSensor.convertToStandardized(rawValue: 0))

            XCTAssertEqual(Double(stageSize.height * 0.01) - Double(stageSize.height / 2), middleFingerSensor.convertToStandardized(rawValue: 0.01))
            XCTAssertEqual(Double(stageSize.height * 0.4) - Double(stageSize.height / 2), middleFingerSensor.convertToStandardized(rawValue: 0.4))
            XCTAssertEqual(Double(stageSize.height * 0.95) - Double(stageSize.height / 2), middleFingerSensor.convertToStandardized(rawValue: 0.95))
            XCTAssertEqual(Double(stageSize.height / 2), middleFingerSensor.convertToStandardized(rawValue: 1.0))
        }
    }

    func testStandardizedValue() {
        for middleFingerSensor in middleFingerXSensors + middleFingerYSensors {
            let convertToStandardizedValue = middleFingerSensor.convertToStandardized(rawValue: middleFingerSensor.rawValue(landscapeMode: false))
            let standardizedValue = middleFingerSensor.standardizedValue(landscapeMode: false)
            let standardizedValueLandscape = middleFingerSensor.standardizedValue(landscapeMode: true)
            XCTAssertEqual(convertToStandardizedValue, standardizedValue)
            XCTAssertEqual(standardizedValue, standardizedValueLandscape)
        }
    }

    func testTag() {
        XCTAssertEqual("LEFT_MIDDLE_FINGER_X", middleFingerXSensors[0].tag())
        XCTAssertEqual("RIGHT_MIDDLE_FINGER_X", middleFingerXSensors[1].tag())

        XCTAssertEqual("LEFT_MIDDLE_FINGER_Y", middleFingerYSensors[0].tag())
        XCTAssertEqual("RIGHT_MIDDLE_FINGER_Y", middleFingerYSensors[1].tag())
    }

    func testRequiredResources() {
        for middleFingerSensor in middleFingerXSensors + middleFingerYSensors {
            XCTAssertEqual(ResourceType.handPoseDetection, type(of: middleFingerSensor).requiredResource)
        }
    }

    func testFormulaEditorSections() {
        for middleFingerSensor in middleFingerXSensors + middleFingerYSensors {
            let sections = middleFingerSensor.formulaEditorSections(for: SpriteObject())
            XCTAssertEqual(1, sections.count)
            XCTAssertEqual(.sensors(position: type(of: middleFingerSensor).position, subsection: .pose), sections.first)
        }
    }
}
