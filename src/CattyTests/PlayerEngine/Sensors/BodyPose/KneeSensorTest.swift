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

class KneeSensorTest: XCTestCase {

    var kneeXSensors = [DeviceDoubleSensor]()
    var kneeYSensors = [DeviceDoubleSensor]()
    var visualDetectionManagerMock: VisualDetectionManagerMock!
    var stageSize: CGSize!

    override func setUp() {
        super.setUp()
        self.visualDetectionManagerMock = VisualDetectionManagerMock()
        self.stageSize = CGSize(width: 1080, height: 1920)
        self.kneeXSensors.append(LeftKneeXSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.kneeXSensors.append(RightKneeXSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.kneeYSensors.append(LeftKneeYSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.kneeYSensors.append(RightKneeYSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
    }

    override func tearDown() {
        self.visualDetectionManagerMock = nil
        self.kneeXSensors.removeAll()
        self.kneeYSensors.removeAll()
        super.tearDown()
    }

    func testDefaultRawValue() {
        var kneeSensors = [DeviceDoubleSensor]()
        kneeSensors.append(LeftKneeXSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        kneeSensors.append(RightKneeXSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        kneeSensors.append(LeftKneeYSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        kneeSensors.append(RightKneeYSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))

        for kneeSensor in kneeSensors {
            XCTAssertEqual(type(of: kneeSensor).defaultRawValue, kneeSensor.rawValue(landscapeMode: false), accuracy: Double.epsilon)
            XCTAssertEqual(type(of: kneeSensor).defaultRawValue, kneeSensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)
        }
    }

    func testRawValue() {
        visualDetectionManagerMock.setAllKneeSensorValueRatios(to: 0)
        for kneeSensor in kneeXSensors + kneeYSensors {
            XCTAssertEqual(0, kneeSensor.rawValue(landscapeMode: false))
            XCTAssertEqual(0, kneeSensor.rawValue(landscapeMode: true))
        }

        visualDetectionManagerMock.setAllKneeSensorValueRatios(to: 0.95)
        for kneeSensor in kneeXSensors + kneeYSensors {
            XCTAssertEqual(0.95, kneeSensor.rawValue(landscapeMode: false))
            XCTAssertEqual(0.95, kneeSensor.rawValue(landscapeMode: true))
        }
    }

    func testConvertToStandardized() {
        for kneeSensor in kneeXSensors {
            XCTAssertEqual(type(of: kneeSensor).defaultRawValue, kneeSensor.convertToStandardized(rawValue: 0))

            XCTAssertEqual(Double(stageSize.width * 0.02) - Double(stageSize.width / 2), kneeSensor.convertToStandardized(rawValue: 0.02))
            XCTAssertEqual(Double(stageSize.width * 0.45) - Double(stageSize.width / 2), kneeSensor.convertToStandardized(rawValue: 0.45))
            XCTAssertEqual(Double(stageSize.width * 0.93) - Double(stageSize.width / 2), kneeSensor.convertToStandardized(rawValue: 0.93))
            XCTAssertEqual(Double(stageSize.width / 2), kneeSensor.convertToStandardized(rawValue: 1.0))
        }

        for kneeSensor in kneeYSensors {
            XCTAssertEqual(type(of: kneeSensor).defaultRawValue, kneeSensor.convertToStandardized(rawValue: 0))

            XCTAssertEqual(Double(stageSize.height * 0.01) - Double(stageSize.height / 2), kneeSensor.convertToStandardized(rawValue: 0.01))
            XCTAssertEqual(Double(stageSize.height * 0.4) - Double(stageSize.height / 2), kneeSensor.convertToStandardized(rawValue: 0.4))
            XCTAssertEqual(Double(stageSize.height * 0.95) - Double(stageSize.height / 2), kneeSensor.convertToStandardized(rawValue: 0.95))
            XCTAssertEqual(Double(stageSize.height / 2), kneeSensor.convertToStandardized(rawValue: 1.0))
        }
    }

    func testStandardizedValue() {
        for kneeSensor in kneeXSensors + kneeYSensors {
            let convertToStandardizedValue = kneeSensor.convertToStandardized(rawValue: kneeSensor.rawValue(landscapeMode: false))
            let standardizedValue = kneeSensor.standardizedValue(landscapeMode: false)
            let standardizedValueLandscape = kneeSensor.standardizedValue(landscapeMode: true)
            XCTAssertEqual(convertToStandardizedValue, standardizedValue)
            XCTAssertEqual(standardizedValue, standardizedValueLandscape)
        }
    }

    func testTag() {
        XCTAssertEqual("LEFT_KNEE_X", kneeXSensors[0].tag())
        XCTAssertEqual("RIGHT_KNEE_X", kneeXSensors[1].tag())

        XCTAssertEqual("LEFT_KNEE_Y", kneeYSensors[0].tag())
        XCTAssertEqual("RIGHT_KNEE_Y", kneeYSensors[1].tag())
    }

    func testRequiredResources() {
        for kneeSensor in kneeXSensors + kneeYSensors {
            XCTAssertEqual(ResourceType.bodyPoseDetection, type(of: kneeSensor).requiredResource)
        }
    }

    func testFormulaEditorSections() {
        for kneeSensor in kneeXSensors + kneeYSensors {
            let sections = kneeSensor.formulaEditorSections(for: SpriteObject())
            XCTAssertEqual(1, sections.count)
            XCTAssertEqual(.sensors(position: type(of: kneeSensor).position, subsection: .pose), sections.first)
        }
    }
}
