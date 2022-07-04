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

final class IndexSensorTest: XCTestCase {

    var indexXSensors = [DeviceDoubleSensor]()
    var indexYSensors = [DeviceDoubleSensor]()
    var visualDetectionManagerMock: VisualDetectionManagerMock!
    var stageSize: CGSize!

    override func setUp() {
        super.setUp()
        self.visualDetectionManagerMock = VisualDetectionManagerMock()
        self.stageSize = CGSize(width: 1080, height: 1920)
        self.visualDetectionManagerMock.setVisualDetectionFrameSize(stageSize)
        self.indexXSensors.append(LeftIndexKnuckleXSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.indexXSensors.append(RightIndexKnuckleXSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.indexYSensors.append(LeftIndexKnuckleYSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.indexYSensors.append(RightIndexKnuckleYSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
    }

    override func tearDown() {
        self.visualDetectionManagerMock = nil
        self.indexXSensors.removeAll()
        self.indexYSensors.removeAll()
        super.tearDown()
    }

    func testDefaultRawValue() {
        var indexSensors = [DeviceDoubleSensor]()
        indexSensors.append(LeftIndexKnuckleXSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        indexSensors.append(RightIndexKnuckleXSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        indexSensors.append(LeftIndexKnuckleYSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        indexSensors.append(RightIndexKnuckleYSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))

        for indexSensor in indexSensors {
            XCTAssertEqual(type(of: indexSensor).defaultRawValue, indexSensor.rawValue(landscapeMode: false), accuracy: Double.epsilon)
            XCTAssertEqual(type(of: indexSensor).defaultRawValue, indexSensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)
        }
    }

    func testRawValue() {
        visualDetectionManagerMock.setAllIndexSensorValueRatios(to: 0)
        for indexSensor in indexXSensors + indexYSensors {
            XCTAssertEqual(0, indexSensor.rawValue(landscapeMode: false))
            XCTAssertEqual(0, indexSensor.rawValue(landscapeMode: true))
        }

        visualDetectionManagerMock.setAllIndexSensorValueRatios(to: 0.95)
        for indexSensor in indexXSensors + indexYSensors {
            XCTAssertEqual(0.95, indexSensor.rawValue(landscapeMode: false))
            XCTAssertEqual(0.95, indexSensor.rawValue(landscapeMode: true))
        }
    }

    func testConvertToStandardized() {
        for indexSensor in indexXSensors {
            XCTAssertEqual(type(of: indexSensor).defaultRawValue, indexSensor.convertToStandardized(rawValue: 0))

            XCTAssertEqual(Double(stageSize.width * 0.02) - Double(stageSize.width / 2), indexSensor.convertToStandardized(rawValue: 0.02))
            XCTAssertEqual(Double(stageSize.width * 0.45) - Double(stageSize.width / 2), indexSensor.convertToStandardized(rawValue: 0.45))
            XCTAssertEqual(Double(stageSize.width * 0.93) - Double(stageSize.width / 2), indexSensor.convertToStandardized(rawValue: 0.93))
            XCTAssertEqual(Double(stageSize.width / 2), indexSensor.convertToStandardized(rawValue: 1.0))
        }

        for indexSensor in indexYSensors {
            XCTAssertEqual(type(of: indexSensor).defaultRawValue, indexSensor.convertToStandardized(rawValue: 0))

            XCTAssertEqual(Double(stageSize.height * 0.01) - Double(stageSize.height / 2), indexSensor.convertToStandardized(rawValue: 0.01))
            XCTAssertEqual(Double(stageSize.height * 0.4) - Double(stageSize.height / 2), indexSensor.convertToStandardized(rawValue: 0.4))
            XCTAssertEqual(Double(stageSize.height * 0.95) - Double(stageSize.height / 2), indexSensor.convertToStandardized(rawValue: 0.95))
            XCTAssertEqual(Double(stageSize.height / 2), indexSensor.convertToStandardized(rawValue: 1.0))
        }
    }

    func testStandardizedValue() {
        for indexSensor in indexXSensors + indexYSensors {
            let convertToStandardizedValue = indexSensor.convertToStandardized(rawValue: indexSensor.rawValue(landscapeMode: false))
            let standardizedValue = indexSensor.standardizedValue(landscapeMode: false)
            let standardizedValueLandscape = indexSensor.standardizedValue(landscapeMode: true)
            XCTAssertEqual(convertToStandardizedValue, standardizedValue)
            XCTAssertEqual(standardizedValue, standardizedValueLandscape)
        }
    }

    func testTag() {
        XCTAssertEqual("LEFT_INDEX_X", indexXSensors[0].tag())
        XCTAssertEqual("RIGHT_INDEX_X", indexXSensors[1].tag())

        XCTAssertEqual("LEFT_INDEX_Y", indexYSensors[0].tag())
        XCTAssertEqual("RIGHT_INDEX_Y", indexYSensors[1].tag())
    }

    func testRequiredResources() {
        for indexSensor in indexXSensors + indexYSensors {
            XCTAssertEqual(ResourceType.faceDetection, type(of: indexSensor).requiredResource)
        }
    }

    func testFormulaEditorSections() {
        for indexSensor in indexXSensors + indexYSensors {
            let sections = indexSensor.formulaEditorSections(for: SpriteObject())
            XCTAssertEqual(1, sections.count)
            XCTAssertEqual(.sensors(position: type(of: indexSensor).position, subsection: .pose), sections.first)
        }
    }
}
