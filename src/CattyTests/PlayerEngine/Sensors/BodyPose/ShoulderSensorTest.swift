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

final class ShoulderSensorTest: XCTestCase {

    var shoulderXSensors = [DeviceDoubleSensor]()
    var shoulderYSensors = [DeviceDoubleSensor]()
    var visualDetectionManagerMock: VisualDetectionManagerMock!
    var stageSize: CGSize!

    override func setUp() {
        super.setUp()
        self.visualDetectionManagerMock = VisualDetectionManagerMock()
        self.stageSize = CGSize(width: 1080, height: 1920)
        self.visualDetectionManagerMock.setVisualDetectionFrameSize(stageSize)
        self.shoulderXSensors.append(LeftShoulderXSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.shoulderXSensors.append(RightShoulderXSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.shoulderYSensors.append(LeftShoulderYSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.shoulderYSensors.append(RightShoulderYSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
    }

    override func tearDown() {
        self.visualDetectionManagerMock = nil
        self.shoulderXSensors.removeAll()
        self.shoulderYSensors.removeAll()
        super.tearDown()
    }

    func testDefaultRawValue() {
        var shoulderSensors = [DeviceDoubleSensor]()
        shoulderSensors.append(LeftShoulderXSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        shoulderSensors.append(RightShoulderXSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        shoulderSensors.append(LeftShoulderYSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        shoulderSensors.append(RightShoulderYSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))

        for shoulderSensor in shoulderSensors {
            XCTAssertEqual(type(of: shoulderSensor).defaultRawValue, shoulderSensor.rawValue(landscapeMode: false), accuracy: Double.epsilon)
            XCTAssertEqual(type(of: shoulderSensor).defaultRawValue, shoulderSensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)
        }
    }

    func testRawValue() {
        visualDetectionManagerMock.setAllShoulderSensorValueRatios(to: 0)
        for shoulderSensor in shoulderXSensors + shoulderYSensors {
            XCTAssertEqual(0, shoulderSensor.rawValue(landscapeMode: false))
            XCTAssertEqual(0, shoulderSensor.rawValue(landscapeMode: true))
        }

        visualDetectionManagerMock.setAllShoulderSensorValueRatios(to: 0.95)
        for shoulderSensor in shoulderXSensors + shoulderYSensors {
            XCTAssertEqual(0.95, shoulderSensor.rawValue(landscapeMode: false))
            XCTAssertEqual(0.95, shoulderSensor.rawValue(landscapeMode: true))
        }
    }

    func testConvertToStandardized() {
        for shoulderSensor in shoulderXSensors {
            XCTAssertEqual(type(of: shoulderSensor).defaultRawValue, shoulderSensor.convertToStandardized(rawValue: 0))

            XCTAssertEqual(Double(stageSize.width * 0.02) - Double(stageSize.width / 2), shoulderSensor.convertToStandardized(rawValue: 0.02))
            XCTAssertEqual(Double(stageSize.width * 0.45) - Double(stageSize.width / 2), shoulderSensor.convertToStandardized(rawValue: 0.45))
            XCTAssertEqual(Double(stageSize.width * 0.93) - Double(stageSize.width / 2), shoulderSensor.convertToStandardized(rawValue: 0.93))
            XCTAssertEqual(Double(stageSize.width / 2), shoulderSensor.convertToStandardized(rawValue: 1.0))
        }

        for shoulderSensor in shoulderYSensors {
            XCTAssertEqual(type(of: shoulderSensor).defaultRawValue, shoulderSensor.convertToStandardized(rawValue: 0))

            XCTAssertEqual(Double(stageSize.height * 0.01) - Double(stageSize.height / 2), shoulderSensor.convertToStandardized(rawValue: 0.01))
            XCTAssertEqual(Double(stageSize.height * 0.4) - Double(stageSize.height / 2), shoulderSensor.convertToStandardized(rawValue: 0.4))
            XCTAssertEqual(Double(stageSize.height * 0.95) - Double(stageSize.height / 2), shoulderSensor.convertToStandardized(rawValue: 0.95))
            XCTAssertEqual(Double(stageSize.height / 2), shoulderSensor.convertToStandardized(rawValue: 1.0))
        }
    }

    func testStandardizedValue() {
        for shoulderSensor in shoulderXSensors + shoulderYSensors {
            let convertToStandardizedValue = shoulderSensor.convertToStandardized(rawValue: shoulderSensor.rawValue(landscapeMode: false))
            let standardizedValue = shoulderSensor.standardizedValue(landscapeMode: false)
            let standardizedValueLandscape = shoulderSensor.standardizedValue(landscapeMode: true)
            XCTAssertEqual(convertToStandardizedValue, standardizedValue)
            XCTAssertEqual(standardizedValue, standardizedValueLandscape)
        }
    }

    func testTag() {
        XCTAssertEqual("LEFT_SHOULDER_X", shoulderXSensors[0].tag())
        XCTAssertEqual("RIGHT_SHOULDER_X", shoulderXSensors[1].tag())

        XCTAssertEqual("LEFT_SHOULDER_Y", shoulderYSensors[0].tag())
        XCTAssertEqual("RIGHT_SHOULDER_Y", shoulderYSensors[1].tag())
    }

    func testRequiredResources() {
        for shoulderSensor in shoulderXSensors + shoulderYSensors {
            XCTAssertEqual(ResourceType.faceDetection, type(of: shoulderSensor).requiredResource)
        }
    }

    func testFormulaEditorSections() {
        for shoulderSensor in shoulderXSensors + shoulderYSensors {
            let sections = shoulderSensor.formulaEditorSections(for: SpriteObject())
            XCTAssertEqual(1, sections.count)
            XCTAssertEqual(.sensors(position: type(of: shoulderSensor).position, subsection: .pose), sections.first)
        }
    }
}
