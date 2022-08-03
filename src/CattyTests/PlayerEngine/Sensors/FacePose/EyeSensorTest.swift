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

final class EyeSensorTest: XCTestCase {

    var eyeXSensors = [DeviceDoubleSensor]()
    var eyeYSensors = [DeviceDoubleSensor]()
    var visualDetectionManagerMock: VisualDetectionManagerMock!
    var stageSize: CGSize!

    override func setUp() {
        super.setUp()
        self.visualDetectionManagerMock = VisualDetectionManagerMock()
        self.stageSize = CGSize(width: 1080, height: 1920)
        self.eyeXSensors.append(LeftEyeInnerXSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.eyeXSensors.append(LeftEyeCenterXSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.eyeXSensors.append(LeftEyeOuterXSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.eyeXSensors.append(RightEyeInnerXSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.eyeXSensors.append(RightEyeCenterXSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.eyeXSensors.append(RightEyeOuterXSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.eyeYSensors.append(LeftEyeInnerYSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.eyeYSensors.append(LeftEyeCenterYSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.eyeYSensors.append(LeftEyeOuterYSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.eyeYSensors.append(RightEyeInnerYSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.eyeYSensors.append(RightEyeCenterYSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.eyeYSensors.append(RightEyeOuterYSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
    }

    override func tearDown() {
        self.visualDetectionManagerMock = nil
        self.eyeXSensors.removeAll()
        self.eyeYSensors.removeAll()
        super.tearDown()
    }

    func testDefaultRawValue() {
        var eyeSensors = [DeviceDoubleSensor]()
        eyeSensors.append(LeftEyeInnerXSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        eyeSensors.append(LeftEyeCenterXSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        eyeSensors.append(LeftEyeOuterXSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        eyeSensors.append(RightEyeInnerXSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        eyeSensors.append(RightEyeCenterXSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        eyeSensors.append(RightEyeOuterXSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        eyeSensors.append(LeftEyeInnerYSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        eyeSensors.append(LeftEyeCenterYSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        eyeSensors.append(LeftEyeOuterYSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        eyeSensors.append(RightEyeInnerYSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        eyeSensors.append(RightEyeCenterYSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        eyeSensors.append(RightEyeOuterYSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))

        for eyeSensor in eyeSensors {
            XCTAssertEqual(type(of: eyeSensor).defaultRawValue, eyeSensor.rawValue(landscapeMode: false), accuracy: Double.epsilon)
            XCTAssertEqual(type(of: eyeSensor).defaultRawValue, eyeSensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)
        }
    }

    func testRawValue() {
        visualDetectionManagerMock.setAllEyeSensorValueRatios(to: 0)
        for eyeSensor in eyeXSensors + eyeYSensors {
            XCTAssertEqual(0, eyeSensor.rawValue(landscapeMode: false))
            XCTAssertEqual(0, eyeSensor.rawValue(landscapeMode: true))
        }

        visualDetectionManagerMock.setAllEyeSensorValueRatios(to: 0.95)
        for eyeSensor in eyeXSensors + eyeYSensors {
            XCTAssertEqual(0.95, eyeSensor.rawValue(landscapeMode: false))
            XCTAssertEqual(0.95, eyeSensor.rawValue(landscapeMode: true))
        }
    }

    func testConvertToStandardized() {
        for eyeSensor in eyeXSensors {
            XCTAssertEqual(type(of: eyeSensor).defaultRawValue, eyeSensor.convertToStandardized(rawValue: 0))

            XCTAssertEqual(Double(stageSize.width * 0.02) - Double(stageSize.width / 2), eyeSensor.convertToStandardized(rawValue: 0.02))
            XCTAssertEqual(Double(stageSize.width * 0.45) - Double(stageSize.width / 2), eyeSensor.convertToStandardized(rawValue: 0.45))
            XCTAssertEqual(Double(stageSize.width * 0.93) - Double(stageSize.width / 2), eyeSensor.convertToStandardized(rawValue: 0.93))
            XCTAssertEqual(Double(stageSize.width / 2), eyeSensor.convertToStandardized(rawValue: 1.0))
        }

        for eyeSensor in eyeYSensors {
            XCTAssertEqual(type(of: eyeSensor).defaultRawValue, eyeSensor.convertToStandardized(rawValue: 0))

            XCTAssertEqual(Double(stageSize.height * 0.01) - Double(stageSize.height / 2), eyeSensor.convertToStandardized(rawValue: 0.01))
            XCTAssertEqual(Double(stageSize.height * 0.4) - Double(stageSize.height / 2), eyeSensor.convertToStandardized(rawValue: 0.4))
            XCTAssertEqual(Double(stageSize.height * 0.95) - Double(stageSize.height / 2), eyeSensor.convertToStandardized(rawValue: 0.95))
            XCTAssertEqual(Double(stageSize.height / 2), eyeSensor.convertToStandardized(rawValue: 1.0))
        }
    }

    func testStandardizedValue() {
        for eyeSensor in eyeXSensors + eyeYSensors {
            let convertToStandardizedValue = eyeSensor.convertToStandardized(rawValue: eyeSensor.rawValue(landscapeMode: false))
            let standardizedValue = eyeSensor.standardizedValue(landscapeMode: false)
            let standardizedValueLandscape = eyeSensor.standardizedValue(landscapeMode: true)
            XCTAssertEqual(convertToStandardizedValue, standardizedValue)
            XCTAssertEqual(standardizedValue, standardizedValueLandscape)
        }
    }

    func testTag() {
        XCTAssertEqual("LEFT_EYE_INNER_X", eyeXSensors[0].tag())
        XCTAssertEqual("LEFT_EYE_CENTER_X", eyeXSensors[1].tag())
        XCTAssertEqual("LEFT_EYE_OUTER_X", eyeXSensors[2].tag())
        XCTAssertEqual("RIGHT_EYE_INNER_X", eyeXSensors[3].tag())
        XCTAssertEqual("RIGHT_EYE_CENTER_X", eyeXSensors[4].tag())
        XCTAssertEqual("RIGHT_EYE_OUTER_X", eyeXSensors[5].tag())

        XCTAssertEqual("LEFT_EYE_INNER_Y", eyeYSensors[0].tag())
        XCTAssertEqual("LEFT_EYE_CENTER_Y", eyeYSensors[1].tag())
        XCTAssertEqual("LEFT_EYE_OUTER_Y", eyeYSensors[2].tag())
        XCTAssertEqual("RIGHT_EYE_INNER_Y", eyeYSensors[3].tag())
        XCTAssertEqual("RIGHT_EYE_CENTER_Y", eyeYSensors[4].tag())
        XCTAssertEqual("RIGHT_EYE_OUTER_Y", eyeYSensors[5].tag())
    }

    func testRequiredResources() {
        for eyeSensor in eyeXSensors + eyeYSensors {
            XCTAssertEqual(ResourceType.faceDetection, type(of: eyeSensor).requiredResource)
        }
    }

    func testFormulaEditorSections() {
        for eyeSensor in eyeXSensors + eyeYSensors {
            let sections = eyeSensor.formulaEditorSections(for: SpriteObject())
            XCTAssertEqual(1, sections.count)
            XCTAssertEqual(.sensors(position: type(of: eyeSensor).position, subsection: .pose), sections.first)
        }
    }
}
