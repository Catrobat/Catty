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

final class RingFingerSensorTest: XCTestCase {

    var ringFingerXSensors = [DeviceDoubleSensor]()
    var ringFingerYSensors = [DeviceDoubleSensor]()
    var visualDetectionManagerMock: VisualDetectionManagerMock!
    var stageSize: CGSize!

    override func setUp() {
        super.setUp()
        self.visualDetectionManagerMock = VisualDetectionManagerMock()
        self.stageSize = CGSize(width: 1080, height: 1920)
        self.ringFingerXSensors.append(LeftRingFingerKnuckleXSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.ringFingerXSensors.append(RightRingFingerKnuckleXSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.ringFingerYSensors.append(LeftRingFingerKnuckleYSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.ringFingerYSensors.append(RightRingFingerKnuckleYSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
    }

    override func tearDown() {
        self.visualDetectionManagerMock = nil
        self.ringFingerXSensors.removeAll()
        self.ringFingerYSensors.removeAll()
        super.tearDown()
    }

    func testDefaultRawValue() {
        var ringFingerSensors = [DeviceDoubleSensor]()
        ringFingerSensors.append(LeftRingFingerKnuckleXSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        ringFingerSensors.append(RightRingFingerKnuckleXSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        ringFingerSensors.append(LeftRingFingerKnuckleYSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        ringFingerSensors.append(RightRingFingerKnuckleYSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))

        for ringFingerSensor in ringFingerSensors {
            XCTAssertEqual(type(of: ringFingerSensor).defaultRawValue, ringFingerSensor.rawValue(landscapeMode: false), accuracy: Double.epsilon)
            XCTAssertEqual(type(of: ringFingerSensor).defaultRawValue, ringFingerSensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)
        }
    }

    func testRawValue() {
        visualDetectionManagerMock.setAllRingFingerSensorValueRatios(to: 0)
        for ringFingerSensor in ringFingerXSensors + ringFingerYSensors {
            XCTAssertEqual(0, ringFingerSensor.rawValue(landscapeMode: false))
            XCTAssertEqual(0, ringFingerSensor.rawValue(landscapeMode: true))
        }

        visualDetectionManagerMock.setAllRingFingerSensorValueRatios(to: 0.95)
        for ringFingerSensor in ringFingerXSensors + ringFingerYSensors {
            XCTAssertEqual(0.95, ringFingerSensor.rawValue(landscapeMode: false))
            XCTAssertEqual(0.95, ringFingerSensor.rawValue(landscapeMode: true))
        }
    }

    func testConvertToStandardized() {
        for ringFingerSensor in ringFingerXSensors {
            XCTAssertEqual(Double(stageSize.width * 0.02) - Double(stageSize.width / 2), ringFingerSensor.convertToStandardized(rawValue: 0.02))
            XCTAssertEqual(Double(stageSize.width * 0.45) - Double(stageSize.width / 2), ringFingerSensor.convertToStandardized(rawValue: 0.45))
            XCTAssertEqual(Double(stageSize.width * 0.93) - Double(stageSize.width / 2), ringFingerSensor.convertToStandardized(rawValue: 0.93))
            XCTAssertEqual(Double(stageSize.width / 2), ringFingerSensor.convertToStandardized(rawValue: 1.0))
        }

        for ringFingerSensor in ringFingerYSensors {
            XCTAssertEqual(Double(stageSize.height * 0.01) - Double(stageSize.height / 2), ringFingerSensor.convertToStandardized(rawValue: 0.01))
            XCTAssertEqual(Double(stageSize.height * 0.4) - Double(stageSize.height / 2), ringFingerSensor.convertToStandardized(rawValue: 0.4))
            XCTAssertEqual(Double(stageSize.height * 0.95) - Double(stageSize.height / 2), ringFingerSensor.convertToStandardized(rawValue: 0.95))
            XCTAssertEqual(Double(stageSize.height / 2), ringFingerSensor.convertToStandardized(rawValue: 1.0))
        }
    }

    func testStandardizedValue() {
        for ringFingerSensor in ringFingerXSensors + ringFingerYSensors {
            let convertToStandardizedValue = ringFingerSensor.convertToStandardized(rawValue: ringFingerSensor.rawValue(landscapeMode: false))
            let standardizedValue = ringFingerSensor.standardizedValue(landscapeMode: false)
            let convertToStandardizedValueLandscape = ringFingerSensor.convertToStandardized(rawValue: ringFingerSensor.rawValue(landscapeMode: true))
            let standardizedValueLandscape = ringFingerSensor.standardizedValue(landscapeMode: true)
            XCTAssertEqual(convertToStandardizedValue, standardizedValue)
            XCTAssertEqual(convertToStandardizedValueLandscape, standardizedValueLandscape)
        }
    }

    func testTag() {
        XCTAssertEqual("LEFT_RING_FINGER_X", ringFingerXSensors[0].tag())
        XCTAssertEqual("RIGHT_RING_FINGER_X", ringFingerXSensors[1].tag())

        XCTAssertEqual("LEFT_RING_FINGER_Y", ringFingerYSensors[0].tag())
        XCTAssertEqual("RIGHT_RING_FINGER_Y", ringFingerYSensors[1].tag())
    }

    func testRequiredResources() {
        for ringFingerSensor in ringFingerXSensors + ringFingerYSensors {
            XCTAssertEqual(ResourceType.handPoseDetection, type(of: ringFingerSensor).requiredResource)
        }
    }

    func testFormulaEditorSections() {
        for ringFingerSensor in ringFingerXSensors + ringFingerYSensors {
            let sections = ringFingerSensor.formulaEditorSections(for: SpriteObject())
            XCTAssertEqual(1, sections.count)
            XCTAssertEqual(.sensors(position: type(of: ringFingerSensor).position, subsection: .pose), sections.first)
        }
    }
}
