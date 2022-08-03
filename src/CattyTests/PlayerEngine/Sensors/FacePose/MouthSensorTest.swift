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

final class MouthSensorTest: XCTestCase {

    var mouthXSensors = [DeviceDoubleSensor]()
    var mouthYSensors = [DeviceDoubleSensor]()
    var visualDetectionManagerMock: VisualDetectionManagerMock!
    var stageSize: CGSize!

    override func setUp() {
        super.setUp()
        self.visualDetectionManagerMock = VisualDetectionManagerMock()
        self.stageSize = CGSize(width: 1080, height: 1920)
        self.mouthXSensors.append(MouthLeftCornerXSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.mouthXSensors.append(MouthRightCornerXSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.mouthYSensors.append(MouthLeftCornerYSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.mouthYSensors.append(MouthRightCornerYSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
    }

    override func tearDown() {
        self.visualDetectionManagerMock = nil
        self.mouthXSensors.removeAll()
        self.mouthYSensors.removeAll()
        super.tearDown()
    }

    func testDefaultRawValue() {
        var mouthSensors = [DeviceDoubleSensor]()
        mouthSensors.append(MouthLeftCornerXSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        mouthSensors.append(MouthRightCornerXSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        mouthSensors.append(MouthLeftCornerYSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        mouthSensors.append(MouthRightCornerYSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))

        for mouthSensor in mouthSensors {
            XCTAssertEqual(type(of: mouthSensor).defaultRawValue, mouthSensor.rawValue(landscapeMode: false), accuracy: Double.epsilon)
            XCTAssertEqual(type(of: mouthSensor).defaultRawValue, mouthSensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)
        }
    }

    func testRawValue() {
        visualDetectionManagerMock.setAllMouthSensorValueRatios(to: 0)
        for mouthSensor in mouthXSensors + mouthYSensors {
            XCTAssertEqual(0, mouthSensor.rawValue(landscapeMode: false))
            XCTAssertEqual(0, mouthSensor.rawValue(landscapeMode: true))
        }

        visualDetectionManagerMock.setAllMouthSensorValueRatios(to: 0.95)
        for mouthSensor in mouthXSensors + mouthYSensors {
            XCTAssertEqual(0.95, mouthSensor.rawValue(landscapeMode: false))
            XCTAssertEqual(0.95, mouthSensor.rawValue(landscapeMode: true))
        }
    }

    func testConvertToStandardized() {
        for mouthSensor in mouthXSensors {
            XCTAssertEqual(type(of: mouthSensor).defaultRawValue, mouthSensor.convertToStandardized(rawValue: 0))

            XCTAssertEqual(Double(stageSize.width * 0.02) - Double(stageSize.width / 2), mouthSensor.convertToStandardized(rawValue: 0.02))
            XCTAssertEqual(Double(stageSize.width * 0.45) - Double(stageSize.width / 2), mouthSensor.convertToStandardized(rawValue: 0.45))
            XCTAssertEqual(Double(stageSize.width * 0.93) - Double(stageSize.width / 2), mouthSensor.convertToStandardized(rawValue: 0.93))
            XCTAssertEqual(Double(stageSize.width / 2), mouthSensor.convertToStandardized(rawValue: 1.0))
        }

        for mouthSensor in mouthYSensors {
            XCTAssertEqual(type(of: mouthSensor).defaultRawValue, mouthSensor.convertToStandardized(rawValue: 0))

            XCTAssertEqual(Double(stageSize.height * 0.01) - Double(stageSize.height / 2), mouthSensor.convertToStandardized(rawValue: 0.01))
            XCTAssertEqual(Double(stageSize.height * 0.4) - Double(stageSize.height / 2), mouthSensor.convertToStandardized(rawValue: 0.4))
            XCTAssertEqual(Double(stageSize.height * 0.95) - Double(stageSize.height / 2), mouthSensor.convertToStandardized(rawValue: 0.95))
            XCTAssertEqual(Double(stageSize.height / 2), mouthSensor.convertToStandardized(rawValue: 1.0))
        }
    }

    func testStandardizedValue() {
        for mouthSensor in mouthXSensors + mouthYSensors {
            let convertToStandardizedValue = mouthSensor.convertToStandardized(rawValue: mouthSensor.rawValue(landscapeMode: false))
            let standardizedValue = mouthSensor.standardizedValue(landscapeMode: false)
            let standardizedValueLandscape = mouthSensor.standardizedValue(landscapeMode: true)
            XCTAssertEqual(convertToStandardizedValue, standardizedValue)
            XCTAssertEqual(standardizedValue, standardizedValueLandscape)
        }
    }

    func testTag() {
        XCTAssertEqual("MOUTH_LEFT_CORNER_X", mouthXSensors[0].tag())
        XCTAssertEqual("MOUTH_RIGHT_CORNER_X", mouthXSensors[1].tag())

        XCTAssertEqual("MOUTH_LEFT_CORNER_Y", mouthYSensors[0].tag())
        XCTAssertEqual("MOUTH_RIGHT_CORNER_Y", mouthYSensors[1].tag())
    }

    func testRequiredResources() {
        for mouthSensor in mouthXSensors + mouthYSensors {
            XCTAssertEqual(ResourceType.faceDetection, type(of: mouthSensor).requiredResource)
        }
    }

    func testFormulaEditorSections() {
        for mouthSensor in mouthXSensors + mouthYSensors {
            let sections = mouthSensor.formulaEditorSections(for: SpriteObject())
            XCTAssertEqual(1, sections.count)
            XCTAssertEqual(.sensors(position: type(of: mouthSensor).position, subsection: .pose), sections.first)
        }
    }
}
