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

final class PinkySensorTest: XCTestCase {

    var pinkyXSensors = [DeviceDoubleSensor]()
    var pinkyYSensors = [DeviceDoubleSensor]()
    var visualDetectionManagerMock: VisualDetectionManagerMock!
    var stageSize: CGSize!

    override func setUp() {
        super.setUp()
        self.visualDetectionManagerMock = VisualDetectionManagerMock()
        self.stageSize = CGSize(width: 1080, height: 1920)
        self.pinkyXSensors.append(LeftPinkyKnuckleXSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.pinkyXSensors.append(RightPinkyKnuckleXSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.pinkyYSensors.append(LeftPinkyKnuckleYSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.pinkyYSensors.append(RightPinkyKnuckleYSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
    }

    override func tearDown() {
        self.visualDetectionManagerMock = nil
        self.pinkyXSensors.removeAll()
        self.pinkyYSensors.removeAll()
        super.tearDown()
    }

    func testDefaultRawValue() {
        var pinkySensors = [DeviceDoubleSensor]()
        pinkySensors.append(LeftPinkyKnuckleXSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        pinkySensors.append(RightPinkyKnuckleXSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        pinkySensors.append(LeftPinkyKnuckleYSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        pinkySensors.append(RightPinkyKnuckleYSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))

        for pinkySensor in pinkySensors {
            XCTAssertEqual(type(of: pinkySensor).defaultRawValue, pinkySensor.rawValue(landscapeMode: false), accuracy: Double.epsilon)
            XCTAssertEqual(type(of: pinkySensor).defaultRawValue, pinkySensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)
        }
    }

    func testRawValue() {
        visualDetectionManagerMock.setAllPinkySensorValueRatios(to: 0)
        for pinkySensor in pinkyXSensors + pinkyYSensors {
            XCTAssertEqual(0, pinkySensor.rawValue(landscapeMode: false))
            XCTAssertEqual(0, pinkySensor.rawValue(landscapeMode: true))
        }

        visualDetectionManagerMock.setAllPinkySensorValueRatios(to: 0.95)
        for pinkySensor in pinkyXSensors + pinkyYSensors {
            XCTAssertEqual(0.95, pinkySensor.rawValue(landscapeMode: false))
            XCTAssertEqual(0.95, pinkySensor.rawValue(landscapeMode: true))
        }
    }

    func testConvertToStandardized() {
        for pinkySensor in pinkyXSensors {

            XCTAssertEqual(Double(stageSize.width * 0.02) - Double(stageSize.width / 2), pinkySensor.convertToStandardized(rawValue: 0.02))
            XCTAssertEqual(Double(stageSize.width * 0.45) - Double(stageSize.width / 2), pinkySensor.convertToStandardized(rawValue: 0.45))
            XCTAssertEqual(Double(stageSize.width * 0.93) - Double(stageSize.width / 2), pinkySensor.convertToStandardized(rawValue: 0.93))
            XCTAssertEqual(Double(stageSize.width / 2), pinkySensor.convertToStandardized(rawValue: 1.0))
        }

        for pinkySensor in pinkyYSensors {

            XCTAssertEqual(Double(stageSize.height * 0.01) - Double(stageSize.height / 2), pinkySensor.convertToStandardized(rawValue: 0.01))
            XCTAssertEqual(Double(stageSize.height * 0.4) - Double(stageSize.height / 2), pinkySensor.convertToStandardized(rawValue: 0.4))
            XCTAssertEqual(Double(stageSize.height * 0.95) - Double(stageSize.height / 2), pinkySensor.convertToStandardized(rawValue: 0.95))
            XCTAssertEqual(Double(stageSize.height / 2), pinkySensor.convertToStandardized(rawValue: 1.0))
        }
    }

    func testStandardizedValue() {
        for pinkySensor in pinkyXSensors + pinkyYSensors {
            let convertToStandardizedValue = pinkySensor.convertToStandardized(rawValue: pinkySensor.rawValue(landscapeMode: false))
            let standardizedValue = pinkySensor.standardizedValue(landscapeMode: false)
            let convertToStandardizedValueLandscape = pinkySensor.convertToStandardized(rawValue: pinkySensor.rawValue(landscapeMode: true))
            let standardizedValueLandscape = pinkySensor.standardizedValue(landscapeMode: true)
            XCTAssertEqual(convertToStandardizedValue, standardizedValue)
            XCTAssertEqual(convertToStandardizedValueLandscape, standardizedValueLandscape)
        }
    }

    func testTag() {
        XCTAssertEqual("LEFT_PINKY_X", pinkyXSensors[0].tag())
        XCTAssertEqual("RIGHT_PINKY_X", pinkyXSensors[1].tag())

        XCTAssertEqual("LEFT_PINKY_Y", pinkyYSensors[0].tag())
        XCTAssertEqual("RIGHT_PINKY_Y", pinkyYSensors[1].tag())
    }

    func testRequiredResources() {
        for pinkySensor in pinkyXSensors + pinkyYSensors {
            XCTAssertEqual(ResourceType.handPoseDetection, type(of: pinkySensor).requiredResource)
        }
    }

    func testFormulaEditorSections() {
        for pinkySensor in pinkyXSensors + pinkyYSensors {
            let sections = pinkySensor.formulaEditorSections(for: SpriteObject())
            XCTAssertEqual(1, sections.count)
            XCTAssertEqual(.sensors(position: type(of: pinkySensor).position, subsection: .pose), sections.first)
        }
    }
}
