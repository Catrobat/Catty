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

final class ThumbSensorTest: XCTestCase {

    var thumbXSensors = [DeviceDoubleSensor]()
    var thumbYSensors = [DeviceDoubleSensor]()
    var visualDetectionManagerMock: VisualDetectionManagerMock!
    var stageSize: CGSize!

    override func setUp() {
        super.setUp()
        self.visualDetectionManagerMock = VisualDetectionManagerMock()
        self.stageSize = CGSize(width: 1080, height: 1920)
        self.thumbXSensors.append(LeftThumbKnuckleXSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.thumbXSensors.append(RightThumbKnuckleXSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.thumbYSensors.append(LeftThumbKnuckleYSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.thumbYSensors.append(RightThumbKnuckleYSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
    }

    override func tearDown() {
        self.visualDetectionManagerMock = nil
        self.thumbXSensors.removeAll()
        self.thumbYSensors.removeAll()
        super.tearDown()
    }

    func testDefaultRawValue() {
        var thumbSensors = [DeviceDoubleSensor]()
        thumbSensors.append(LeftThumbKnuckleXSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        thumbSensors.append(RightThumbKnuckleXSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        thumbSensors.append(LeftThumbKnuckleYSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        thumbSensors.append(RightThumbKnuckleYSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))

        for thumbSensor in thumbSensors {
            XCTAssertEqual(type(of: thumbSensor).defaultRawValue, thumbSensor.rawValue(landscapeMode: false), accuracy: Double.epsilon)
            XCTAssertEqual(type(of: thumbSensor).defaultRawValue, thumbSensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)
        }
    }

    func testRawValue() {
        visualDetectionManagerMock.setAllThumbSensorValueRatios(to: 0)
        for thumbSensor in thumbXSensors + thumbYSensors {
            XCTAssertEqual(0, thumbSensor.rawValue(landscapeMode: false))
            XCTAssertEqual(0, thumbSensor.rawValue(landscapeMode: true))
        }

        visualDetectionManagerMock.setAllThumbSensorValueRatios(to: 0.95)
        for thumbSensor in thumbXSensors + thumbYSensors {
            XCTAssertEqual(0.95, thumbSensor.rawValue(landscapeMode: false))
            XCTAssertEqual(0.95, thumbSensor.rawValue(landscapeMode: true))
        }
    }

    func testConvertToStandardized() {
        for thumbSensor in thumbXSensors {
            XCTAssertEqual(type(of: thumbSensor).defaultRawValue, thumbSensor.convertToStandardized(rawValue: 0))

            XCTAssertEqual(Double(stageSize.width * 0.02) - Double(stageSize.width / 2), thumbSensor.convertToStandardized(rawValue: 0.02))
            XCTAssertEqual(Double(stageSize.width * 0.45) - Double(stageSize.width / 2), thumbSensor.convertToStandardized(rawValue: 0.45))
            XCTAssertEqual(Double(stageSize.width * 0.93) - Double(stageSize.width / 2), thumbSensor.convertToStandardized(rawValue: 0.93))
            XCTAssertEqual(Double(stageSize.width / 2), thumbSensor.convertToStandardized(rawValue: 1.0))
        }

        for thumbSensor in thumbYSensors {
            XCTAssertEqual(type(of: thumbSensor).defaultRawValue, thumbSensor.convertToStandardized(rawValue: 0))

            XCTAssertEqual(Double(stageSize.height * 0.01) - Double(stageSize.height / 2), thumbSensor.convertToStandardized(rawValue: 0.01))
            XCTAssertEqual(Double(stageSize.height * 0.4) - Double(stageSize.height / 2), thumbSensor.convertToStandardized(rawValue: 0.4))
            XCTAssertEqual(Double(stageSize.height * 0.95) - Double(stageSize.height / 2), thumbSensor.convertToStandardized(rawValue: 0.95))
            XCTAssertEqual(Double(stageSize.height / 2), thumbSensor.convertToStandardized(rawValue: 1.0))
        }
    }

    func testStandardizedValue() {
        for thumbSensor in thumbXSensors + thumbYSensors {
            let convertToStandardizedValue = thumbSensor.convertToStandardized(rawValue: thumbSensor.rawValue(landscapeMode: false))
            let standardizedValue = thumbSensor.standardizedValue(landscapeMode: false)
            let standardizedValueLandscape = thumbSensor.standardizedValue(landscapeMode: true)
            XCTAssertEqual(convertToStandardizedValue, standardizedValue)
            XCTAssertEqual(standardizedValue, standardizedValueLandscape)
        }
    }

    func testTag() {
        XCTAssertEqual("LEFT_THUMB_X", thumbXSensors[0].tag())
        XCTAssertEqual("RIGHT_THUMB_X", thumbXSensors[1].tag())

        XCTAssertEqual("LEFT_THUMB_Y", thumbYSensors[0].tag())
        XCTAssertEqual("RIGHT_THUMB_Y", thumbYSensors[1].tag())
    }

    func testRequiredResources() {
        for thumbSensor in thumbXSensors + thumbYSensors {
            XCTAssertEqual(ResourceType.handPoseDetection, type(of: thumbSensor).requiredResource)
        }
    }

    func testFormulaEditorSections() {
        for thumbSensor in thumbXSensors + thumbYSensors {
            let sections = thumbSensor.formulaEditorSections(for: SpriteObject())
            XCTAssertEqual(1, sections.count)
            XCTAssertEqual(.sensors(position: type(of: thumbSensor).position, subsection: .pose), sections.first)
        }
    }
}
