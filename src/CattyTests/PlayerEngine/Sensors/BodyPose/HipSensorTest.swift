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

class HipSensorTest: XCTestCase {

    var hipXSensors = [DeviceDoubleSensor]()
    var hipYSensors = [DeviceDoubleSensor]()
    var visualDetectionManagerMock: VisualDetectionManagerMock!
    var stageSize: CGSize!

    override func setUp() {
        super.setUp()
        self.visualDetectionManagerMock = VisualDetectionManagerMock()
        self.stageSize = CGSize(width: 1080, height: 1920)
        self.hipXSensors.append(LeftHipXSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.hipXSensors.append(RightHipXSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.hipYSensors.append(LeftHipYSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.hipYSensors.append(RightHipYSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
    }

    override func tearDown() {
        self.visualDetectionManagerMock = nil
        self.hipXSensors.removeAll()
        self.hipYSensors.removeAll()
        super.tearDown()
    }

    func testDefaultRawValue() {
        var hipSensors = [DeviceDoubleSensor]()
        hipSensors.append(LeftHipXSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        hipSensors.append(RightHipXSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        hipSensors.append(LeftHipYSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        hipSensors.append(RightHipYSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))

        for hipSensor in hipSensors {
            XCTAssertEqual(type(of: hipSensor).defaultRawValue, hipSensor.rawValue(landscapeMode: false), accuracy: Double.epsilon)
            XCTAssertEqual(type(of: hipSensor).defaultRawValue, hipSensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)
        }
    }

    func testRawValue() {
        visualDetectionManagerMock.setAllHipSensorValueRatios(to: 0)
        for hipSensor in hipXSensors + hipYSensors {
            XCTAssertEqual(0, hipSensor.rawValue(landscapeMode: false))
            XCTAssertEqual(0, hipSensor.rawValue(landscapeMode: true))
        }

        visualDetectionManagerMock.setAllHipSensorValueRatios(to: 0.95)
        for hipSensor in hipXSensors + hipYSensors {
            XCTAssertEqual(0.95, hipSensor.rawValue(landscapeMode: false))
            XCTAssertEqual(0.95, hipSensor.rawValue(landscapeMode: true))
        }
    }

    func testConvertToStandardized() {
        for hipSensor in hipXSensors {
            XCTAssertEqual(Double(stageSize.width * 0.02) - Double(stageSize.width / 2), hipSensor.convertToStandardized(rawValue: 0.02))
            XCTAssertEqual(Double(stageSize.width * 0.45) - Double(stageSize.width / 2), hipSensor.convertToStandardized(rawValue: 0.45))
            XCTAssertEqual(Double(stageSize.width * 0.93) - Double(stageSize.width / 2), hipSensor.convertToStandardized(rawValue: 0.93))
            XCTAssertEqual(Double(stageSize.width / 2), hipSensor.convertToStandardized(rawValue: 1.0))
        }

        for hipSensor in hipYSensors {
            XCTAssertEqual(Double(stageSize.height * 0.01) - Double(stageSize.height / 2), hipSensor.convertToStandardized(rawValue: 0.01))
            XCTAssertEqual(Double(stageSize.height * 0.4) - Double(stageSize.height / 2), hipSensor.convertToStandardized(rawValue: 0.4))
            XCTAssertEqual(Double(stageSize.height * 0.95) - Double(stageSize.height / 2), hipSensor.convertToStandardized(rawValue: 0.95))
            XCTAssertEqual(Double(stageSize.height / 2), hipSensor.convertToStandardized(rawValue: 1.0))
        }
    }

    func testStandardizedValue() {
        for hipSensor in hipXSensors + hipYSensors {
            let convertToStandardizedValue = hipSensor.convertToStandardized(rawValue: hipSensor.rawValue(landscapeMode: false))
            let standardizedValue = hipSensor.standardizedValue(landscapeMode: false)
            let convertToStandardizedValueLandscape = hipSensor.convertToStandardized(rawValue: hipSensor.rawValue(landscapeMode: true))
            let standardizedValueLandscape = hipSensor.standardizedValue(landscapeMode: true)
            XCTAssertEqual(convertToStandardizedValue, standardizedValue)
            XCTAssertEqual(convertToStandardizedValueLandscape, standardizedValueLandscape)
        }
    }

    func testTag() {
        XCTAssertEqual("LEFT_HIP_X", hipXSensors[0].tag())
        XCTAssertEqual("RIGHT_HIP_X", hipXSensors[1].tag())

        XCTAssertEqual("LEFT_HIP_Y", hipYSensors[0].tag())
        XCTAssertEqual("RIGHT_HIP_Y", hipYSensors[1].tag())
    }

    func testRequiredResources() {
        for hipSensor in hipXSensors + hipYSensors {
            XCTAssertEqual(ResourceType.bodyPoseDetection, type(of: hipSensor).requiredResource)
        }
    }

    func testFormulaEditorSections() {
        for hipSensor in hipXSensors + hipYSensors {
            let sections = hipSensor.formulaEditorSections(for: SpriteObject())
            XCTAssertEqual(1, sections.count)
            XCTAssertEqual(.sensors(position: type(of: hipSensor).position, subsection: .pose), sections.first)
        }
    }

}
