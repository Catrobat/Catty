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

final class ElbowSensorTest: XCTestCase {

    var elbowXSensors = [DeviceDoubleSensor]()
    var elbowYSensors = [DeviceDoubleSensor]()
    var visualDetectionManagerMock: VisualDetectionManagerMock!
    var stageSize: CGSize!

    override func setUp() {
        super.setUp()
        self.visualDetectionManagerMock = VisualDetectionManagerMock()
        self.stageSize = CGSize(width: 1080, height: 1920)
        self.elbowXSensors.append(LeftElbowXSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.elbowXSensors.append(RightElbowXSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.elbowYSensors.append(LeftElbowYSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.elbowYSensors.append(RightElbowYSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
    }

    override func tearDown() {
        self.visualDetectionManagerMock = nil
        self.elbowXSensors.removeAll()
        self.elbowYSensors.removeAll()
        super.tearDown()
    }

    func testDefaultRawValue() {
        var elbowSensors = [DeviceDoubleSensor]()
        elbowSensors.append(LeftElbowXSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        elbowSensors.append(RightElbowXSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        elbowSensors.append(LeftElbowYSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        elbowSensors.append(RightElbowYSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))

        for elbowSensor in elbowSensors {
            XCTAssertEqual(type(of: elbowSensor).defaultRawValue, elbowSensor.rawValue(landscapeMode: false), accuracy: Double.epsilon)
            XCTAssertEqual(type(of: elbowSensor).defaultRawValue, elbowSensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)
        }
    }

    func testRawValue() {
        visualDetectionManagerMock.setAllElbowSensorValueRatios(to: 0)
        for elbowSensor in elbowXSensors + elbowYSensors {
            XCTAssertEqual(0, elbowSensor.rawValue(landscapeMode: false))
            XCTAssertEqual(0, elbowSensor.rawValue(landscapeMode: true))
        }

        visualDetectionManagerMock.setAllElbowSensorValueRatios(to: 0.95)
        for elbowSensor in elbowXSensors + elbowYSensors {
            XCTAssertEqual(0.95, elbowSensor.rawValue(landscapeMode: false))
            XCTAssertEqual(0.95, elbowSensor.rawValue(landscapeMode: true))
        }
    }

    func testConvertToStandardized() {
        for elbowSensor in elbowXSensors {
            XCTAssertEqual(Double(stageSize.width * 0.02) - Double(stageSize.width / 2), elbowSensor.convertToStandardized(rawValue: 0.02))
            XCTAssertEqual(Double(stageSize.width * 0.45) - Double(stageSize.width / 2), elbowSensor.convertToStandardized(rawValue: 0.45))
            XCTAssertEqual(Double(stageSize.width * 0.93) - Double(stageSize.width / 2), elbowSensor.convertToStandardized(rawValue: 0.93))
            XCTAssertEqual(Double(stageSize.width / 2), elbowSensor.convertToStandardized(rawValue: 1.0))
        }

        for elbowSensor in elbowYSensors {
            XCTAssertEqual(Double(stageSize.height * 0.01) - Double(stageSize.height / 2), elbowSensor.convertToStandardized(rawValue: 0.01))
            XCTAssertEqual(Double(stageSize.height * 0.4) - Double(stageSize.height / 2), elbowSensor.convertToStandardized(rawValue: 0.4))
            XCTAssertEqual(Double(stageSize.height * 0.95) - Double(stageSize.height / 2), elbowSensor.convertToStandardized(rawValue: 0.95))
            XCTAssertEqual(Double(stageSize.height / 2), elbowSensor.convertToStandardized(rawValue: 1.0))
        }
    }

    func testStandardizedValue() {
        for elbowSensor in elbowXSensors + elbowYSensors {
            let convertToStandardizedValue = elbowSensor.convertToStandardized(rawValue: elbowSensor.rawValue(landscapeMode: false))
            let standardizedValue = elbowSensor.standardizedValue(landscapeMode: false)
            let convertToStandardizedValueLandscape = elbowSensor.convertToStandardized(rawValue: elbowSensor.rawValue(landscapeMode: true))
            let standardizedValueLandscape = elbowSensor.standardizedValue(landscapeMode: true)
            XCTAssertEqual(convertToStandardizedValue, standardizedValue)
            XCTAssertEqual(convertToStandardizedValueLandscape, standardizedValueLandscape)
        }
    }

    func testTag() {
        XCTAssertEqual("LEFT_ELBOW_X", elbowXSensors[0].tag())
        XCTAssertEqual("RIGHT_ELBOW_X", elbowXSensors[1].tag())

        XCTAssertEqual("LEFT_ELBOW_Y", elbowYSensors[0].tag())
        XCTAssertEqual("RIGHT_ELBOW_Y", elbowYSensors[1].tag())
    }

    func testRequiredResources() {
        for elbowSensor in elbowXSensors + elbowYSensors {
            XCTAssertEqual(ResourceType.bodyPoseDetection, type(of: elbowSensor).requiredResource)
        }
    }

    func testFormulaEditorSections() {
        for elbowSensor in elbowXSensors + elbowYSensors {
            let sections = elbowSensor.formulaEditorSections(for: SpriteObject())
            XCTAssertEqual(1, sections.count)
            XCTAssertEqual(.sensors(position: type(of: elbowSensor).position, subsection: .pose), sections.first)
        }
    }
}
