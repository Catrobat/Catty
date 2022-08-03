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

final class EyebrowSensorTest: XCTestCase {

    var eyebrowXSensors = [DeviceDoubleSensor]()
    var eyebrowYSensors = [DeviceDoubleSensor]()
    var visualDetectionManagerMock: VisualDetectionManagerMock!
    var stageSize: CGSize!

    override func setUp() {
        super.setUp()
        self.visualDetectionManagerMock = VisualDetectionManagerMock()
        self.stageSize = CGSize(width: 1080, height: 1920)
        self.eyebrowXSensors.append(LeftEyebrowInnerXSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.eyebrowXSensors.append(LeftEyebrowCenterXSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.eyebrowXSensors.append(LeftEyebrowOuterXSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.eyebrowXSensors.append(RightEyebrowInnerXSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.eyebrowXSensors.append(RightEyebrowCenterXSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.eyebrowXSensors.append(RightEyebrowOuterXSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.eyebrowYSensors.append(LeftEyebrowInnerYSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.eyebrowYSensors.append(LeftEyebrowCenterYSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.eyebrowYSensors.append(LeftEyebrowOuterYSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.eyebrowYSensors.append(RightEyebrowInnerYSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.eyebrowYSensors.append(RightEyebrowCenterYSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.eyebrowYSensors.append(RightEyebrowOuterYSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
    }

    override func tearDown() {
        self.visualDetectionManagerMock = nil
        self.eyebrowXSensors.removeAll()
        self.eyebrowYSensors.removeAll()
        super.tearDown()
    }

    func testDefaultRawValue() {
        var eyebrowSensors = [DeviceDoubleSensor]()
        eyebrowSensors.append(LeftEyebrowInnerXSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        eyebrowSensors.append(LeftEyebrowCenterXSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        eyebrowSensors.append(LeftEyebrowOuterXSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        eyebrowSensors.append(RightEyebrowInnerXSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        eyebrowSensors.append(RightEyebrowCenterXSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        eyebrowSensors.append(RightEyebrowOuterXSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        eyebrowSensors.append(LeftEyebrowInnerYSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        eyebrowSensors.append(LeftEyebrowCenterYSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        eyebrowSensors.append(LeftEyebrowOuterYSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        eyebrowSensors.append(RightEyebrowInnerYSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        eyebrowSensors.append(RightEyebrowCenterYSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        eyebrowSensors.append(RightEyebrowOuterYSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))

        for eyebrowSensor in eyebrowSensors {
            XCTAssertEqual(type(of: eyebrowSensor).defaultRawValue, eyebrowSensor.rawValue(landscapeMode: false), accuracy: Double.epsilon)
            XCTAssertEqual(type(of: eyebrowSensor).defaultRawValue, eyebrowSensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)
        }
    }

    func testRawValue() {
        visualDetectionManagerMock.setAllEyebrowSensorValueRatios(to: 0)
        for eyebrowSensor in eyebrowXSensors + eyebrowYSensors {
            XCTAssertEqual(0, eyebrowSensor.rawValue(landscapeMode: false))
            XCTAssertEqual(0, eyebrowSensor.rawValue(landscapeMode: true))
        }

        visualDetectionManagerMock.setAllEyebrowSensorValueRatios(to: 0.95)
        for eyebrowSensor in eyebrowXSensors + eyebrowYSensors {
            XCTAssertEqual(0.95, eyebrowSensor.rawValue(landscapeMode: false))
            XCTAssertEqual(0.95, eyebrowSensor.rawValue(landscapeMode: true))
        }
    }

    func testConvertToStandardized() {
        for eyebrowSensor in eyebrowXSensors {
            XCTAssertEqual(type(of: eyebrowSensor).defaultRawValue, eyebrowSensor.convertToStandardized(rawValue: 0))

            XCTAssertEqual(Double(stageSize.width * 0.02) - Double(stageSize.width / 2), eyebrowSensor.convertToStandardized(rawValue: 0.02))
            XCTAssertEqual(Double(stageSize.width * 0.45) - Double(stageSize.width / 2), eyebrowSensor.convertToStandardized(rawValue: 0.45))
            XCTAssertEqual(Double(stageSize.width * 0.93) - Double(stageSize.width / 2), eyebrowSensor.convertToStandardized(rawValue: 0.93))
            XCTAssertEqual(Double(stageSize.width / 2), eyebrowSensor.convertToStandardized(rawValue: 1.0))
        }

        for eyebrowSensor in eyebrowYSensors {
            XCTAssertEqual(type(of: eyebrowSensor).defaultRawValue, eyebrowSensor.convertToStandardized(rawValue: 0))

            XCTAssertEqual(Double(stageSize.height * 0.01) - Double(stageSize.height / 2), eyebrowSensor.convertToStandardized(rawValue: 0.01))
            XCTAssertEqual(Double(stageSize.height * 0.4) - Double(stageSize.height / 2), eyebrowSensor.convertToStandardized(rawValue: 0.4))
            XCTAssertEqual(Double(stageSize.height * 0.95) - Double(stageSize.height / 2), eyebrowSensor.convertToStandardized(rawValue: 0.95))
            XCTAssertEqual(Double(stageSize.height / 2), eyebrowSensor.convertToStandardized(rawValue: 1.0))
        }
    }

    func testStandardizedValue() {
        for eyebrowSensor in eyebrowXSensors + eyebrowYSensors {
            let convertToStandardizedValue = eyebrowSensor.convertToStandardized(rawValue: eyebrowSensor.rawValue(landscapeMode: false))
            let standardizedValue = eyebrowSensor.standardizedValue(landscapeMode: false)
            let standardizedValueLandscape = eyebrowSensor.standardizedValue(landscapeMode: true)
            XCTAssertEqual(convertToStandardizedValue, standardizedValue)
            XCTAssertEqual(standardizedValue, standardizedValueLandscape)
        }
    }

    func testTag() {
        XCTAssertEqual("LEFT_EYEBROW_INNER_X", eyebrowXSensors[0].tag())
        XCTAssertEqual("LEFT_EYEBROW_CENTER_X", eyebrowXSensors[1].tag())
        XCTAssertEqual("LEFT_EYEBROW_OUTER_X", eyebrowXSensors[2].tag())
        XCTAssertEqual("RIGHT_EYEBROW_INNER_X", eyebrowXSensors[3].tag())
        XCTAssertEqual("RIGHT_EYEBROW_CENTER_X", eyebrowXSensors[4].tag())
        XCTAssertEqual("RIGHT_EYEBROW_OUTER_X", eyebrowXSensors[5].tag())

        XCTAssertEqual("LEFT_EYEBROW_INNER_Y", eyebrowYSensors[0].tag())
        XCTAssertEqual("LEFT_EYEBROW_CENTER_Y", eyebrowYSensors[1].tag())
        XCTAssertEqual("LEFT_EYEBROW_OUTER_Y", eyebrowYSensors[2].tag())
        XCTAssertEqual("RIGHT_EYEBROW_INNER_Y", eyebrowYSensors[3].tag())
        XCTAssertEqual("RIGHT_EYEBROW_CENTER_Y", eyebrowYSensors[4].tag())
        XCTAssertEqual("RIGHT_EYEBROW_OUTER_Y", eyebrowYSensors[5].tag())
    }

    func testRequiredResources() {
        for eyebrowSensor in eyebrowXSensors + eyebrowYSensors {
            XCTAssertEqual(ResourceType.faceDetection, type(of: eyebrowSensor).requiredResource)
        }
    }

    func testFormulaEditorSections() {
        for eyebrowSensor in eyebrowXSensors + eyebrowYSensors {
            let sections = eyebrowSensor.formulaEditorSections(for: SpriteObject())
            XCTAssertEqual(1, sections.count)
            XCTAssertEqual(.sensors(position: type(of: eyebrowSensor).position, subsection: .pose), sections.first)
        }
    }
}
