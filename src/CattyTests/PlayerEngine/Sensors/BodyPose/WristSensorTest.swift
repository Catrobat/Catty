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

final class WristSensorTest: XCTestCase {

    var wristXSensors = [DeviceDoubleSensor]()
    var wristYSensors = [DeviceDoubleSensor]()
    var visualDetectionManagerMock: VisualDetectionManagerMock!
    var stageSize: CGSize!

    override func setUp() {
        super.setUp()
        self.visualDetectionManagerMock = VisualDetectionManagerMock()
        self.stageSize = CGSize(width: 1080, height: 1920)
        self.wristXSensors.append(LeftWristXSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.wristXSensors.append(RightWristXSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.wristYSensors.append(LeftWristYSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.wristYSensors.append(RightWristYSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
    }

    override func tearDown() {
        self.visualDetectionManagerMock = nil
        self.wristXSensors.removeAll()
        self.wristYSensors.removeAll()
        super.tearDown()
    }

    func testDefaultRawValue() {
        var wristSensors = [DeviceDoubleSensor]()
        wristSensors.append(LeftWristXSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        wristSensors.append(RightWristXSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        wristSensors.append(LeftWristYSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        wristSensors.append(RightWristYSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))

        for wristSensor in wristSensors {
            XCTAssertEqual(type(of: wristSensor).defaultRawValue, wristSensor.rawValue(landscapeMode: false), accuracy: Double.epsilon)
            XCTAssertEqual(type(of: wristSensor).defaultRawValue, wristSensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)
        }
    }

    func testRawValue() {
        visualDetectionManagerMock.setAllWristSensorValueRatios(to: 0)
        for wristSensor in wristXSensors + wristYSensors {
            XCTAssertEqual(0, wristSensor.rawValue(landscapeMode: false))
            XCTAssertEqual(0, wristSensor.rawValue(landscapeMode: true))
        }

        visualDetectionManagerMock.setAllWristSensorValueRatios(to: 0.95)
        for wristSensor in wristXSensors + wristYSensors {
            XCTAssertEqual(0.95, wristSensor.rawValue(landscapeMode: false))
            XCTAssertEqual(0.95, wristSensor.rawValue(landscapeMode: true))
        }
    }

    func testConvertToStandardized() {
        for wristSensor in wristXSensors {
            XCTAssertEqual(Double(stageSize.width * 0.02) - Double(stageSize.width / 2), wristSensor.convertToStandardized(rawValue: 0.02))
            XCTAssertEqual(Double(stageSize.width * 0.45) - Double(stageSize.width / 2), wristSensor.convertToStandardized(rawValue: 0.45))
            XCTAssertEqual(Double(stageSize.width * 0.93) - Double(stageSize.width / 2), wristSensor.convertToStandardized(rawValue: 0.93))
            XCTAssertEqual(Double(stageSize.width / 2), wristSensor.convertToStandardized(rawValue: 1.0))
        }

        for wristSensor in wristYSensors {
            XCTAssertEqual(Double(stageSize.height * 0.01) - Double(stageSize.height / 2), wristSensor.convertToStandardized(rawValue: 0.01))
            XCTAssertEqual(Double(stageSize.height * 0.4) - Double(stageSize.height / 2), wristSensor.convertToStandardized(rawValue: 0.4))
            XCTAssertEqual(Double(stageSize.height * 0.95) - Double(stageSize.height / 2), wristSensor.convertToStandardized(rawValue: 0.95))
            XCTAssertEqual(Double(stageSize.height / 2), wristSensor.convertToStandardized(rawValue: 1.0))
        }
    }

    func testStandardizedValue() {
        for wristSensor in wristXSensors + wristYSensors {
            let convertToStandardizedValue = wristSensor.convertToStandardized(rawValue: wristSensor.rawValue(landscapeMode: false))
            let standardizedValue = wristSensor.standardizedValue(landscapeMode: false)
            let convertToStandardizedValueLandscape = wristSensor.convertToStandardized(rawValue: wristSensor.rawValue(landscapeMode: true))
            let standardizedValueLandscape = wristSensor.standardizedValue(landscapeMode: true)
            XCTAssertEqual(convertToStandardizedValue, standardizedValue)
            XCTAssertEqual(convertToStandardizedValueLandscape, standardizedValueLandscape)
        }
    }

    func testTag() {
        XCTAssertEqual("LEFT_WRIST_X", wristXSensors[0].tag())
        XCTAssertEqual("RIGHT_WRIST_X", wristXSensors[1].tag())

        XCTAssertEqual("LEFT_WRIST_Y", wristYSensors[0].tag())
        XCTAssertEqual("RIGHT_WRIST_Y", wristYSensors[1].tag())
    }

    func testRequiredResources() {
        for wristSensor in wristXSensors + wristYSensors {
            XCTAssertEqual(ResourceType.bodyPoseDetection, type(of: wristSensor).requiredResource)
        }
    }

    func testFormulaEditorSections() {
        for wristSensor in wristXSensors + wristYSensors {
            let sections = wristSensor.formulaEditorSections(for: SpriteObject())
            XCTAssertEqual(1, sections.count)
            XCTAssertEqual(.sensors(position: type(of: wristSensor).position, subsection: .pose), sections.first)
        }
    }
}
