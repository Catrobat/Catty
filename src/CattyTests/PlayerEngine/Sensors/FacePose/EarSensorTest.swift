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

final class EarSensorTest: XCTestCase {

    var earXSensors = [DeviceDoubleSensor]()
    var earYSensors = [DeviceDoubleSensor]()
    var visualDetectionManagerMock: VisualDetectionManagerMock!
    var stageSize: CGSize!

    override func setUp() {
        super.setUp()
        self.visualDetectionManagerMock = VisualDetectionManagerMock()
        self.stageSize = CGSize(width: 1080, height: 1920)
        self.earXSensors.append(LeftEarXSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.earXSensors.append(RightEarXSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.earYSensors.append(LeftEarYSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.earYSensors.append(RightEarYSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
    }

    override func tearDown() {
        self.visualDetectionManagerMock = nil
        self.earXSensors.removeAll()
        self.earYSensors.removeAll()
        super.tearDown()
    }

    func testDefaultRawValue() {
        var earSensors = [DeviceDoubleSensor]()
        earSensors.append(LeftEarXSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        earSensors.append(RightEarXSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        earSensors.append(LeftEarYSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        earSensors.append(RightEarYSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))

        for earSensor in earSensors {
            XCTAssertEqual(type(of: earSensor).defaultRawValue, earSensor.rawValue(landscapeMode: false), accuracy: Double.epsilon)
            XCTAssertEqual(type(of: earSensor).defaultRawValue, earSensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)
        }
    }

    func testRawValue() {
        visualDetectionManagerMock.setAllEarSensorValueRatios(to: 0)
        for earSensor in earXSensors + earYSensors {
            XCTAssertEqual(0, earSensor.rawValue(landscapeMode: false))
            XCTAssertEqual(0, earSensor.rawValue(landscapeMode: true))
        }

        visualDetectionManagerMock.setAllEarSensorValueRatios(to: 0.95)
        for earSensor in earXSensors + earYSensors {
            XCTAssertEqual(0.95, earSensor.rawValue(landscapeMode: false))
            XCTAssertEqual(0.95, earSensor.rawValue(landscapeMode: true))
        }
    }

    func testConvertToStandardized() {
        for earSensor in earXSensors {
            XCTAssertEqual(Double(stageSize.width * 0.02) - Double(stageSize.width / 2), earSensor.convertToStandardized(rawValue: 0.02))
            XCTAssertEqual(Double(stageSize.width * 0.45) - Double(stageSize.width / 2), earSensor.convertToStandardized(rawValue: 0.45))
            XCTAssertEqual(Double(stageSize.width * 0.93) - Double(stageSize.width / 2), earSensor.convertToStandardized(rawValue: 0.93))
            XCTAssertEqual(Double(stageSize.width / 2), earSensor.convertToStandardized(rawValue: 1.0))
        }

        for earSensor in earYSensors {
            XCTAssertEqual(Double(stageSize.height * 0.01) - Double(stageSize.height / 2), earSensor.convertToStandardized(rawValue: 0.01))
            XCTAssertEqual(Double(stageSize.height * 0.4) - Double(stageSize.height / 2), earSensor.convertToStandardized(rawValue: 0.4))
            XCTAssertEqual(Double(stageSize.height * 0.95) - Double(stageSize.height / 2), earSensor.convertToStandardized(rawValue: 0.95))
            XCTAssertEqual(Double(stageSize.height / 2), earSensor.convertToStandardized(rawValue: 1.0))
        }
    }

    func testStandardizedValue() {
        for earSensor in earXSensors + earYSensors {
            let convertToStandardizedValue = earSensor.convertToStandardized(rawValue: earSensor.rawValue(landscapeMode: false))
            let standardizedValue = earSensor.standardizedValue(landscapeMode: false)
            let convertToStandardizedValueLandscape = earSensor.convertToStandardized(rawValue: earSensor.rawValue(landscapeMode: true))
            let standardizedValueLandscape = earSensor.standardizedValue(landscapeMode: true)
            XCTAssertEqual(convertToStandardizedValue, standardizedValue)
            XCTAssertEqual(convertToStandardizedValueLandscape, standardizedValueLandscape)
        }
    }

    func testTag() {
        XCTAssertEqual("LEFT_EAR_X", earXSensors[0].tag())
        XCTAssertEqual("RIGHT_EAR_X", earXSensors[1].tag())

        XCTAssertEqual("LEFT_EAR_Y", earYSensors[0].tag())
        XCTAssertEqual("RIGHT_EAR_Y", earYSensors[1].tag())
    }

    func testRequiredResources() {
        for earSensor in earXSensors + earYSensors {
            XCTAssertEqual(ResourceType.faceDetection, type(of: earSensor).requiredResource)
        }
    }

    func testFormulaEditorSections() {
        for earSensor in earXSensors + earYSensors {
            let sections = earSensor.formulaEditorSections(for: SpriteObject())
            XCTAssertEqual(1, sections.count)
            XCTAssertEqual(.sensors(position: type(of: earSensor).position, subsection: .pose), sections.first)
        }
    }
}
