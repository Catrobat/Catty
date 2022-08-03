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

final class FacePositionSensorTest: XCTestCase {

    var facePositionXSensors = [DeviceDoubleSensor]()
    var facePositionYSensors = [DeviceDoubleSensor]()
    var visualDetectionManagerMock: VisualDetectionManagerMock!
    var stageSize: CGSize!

    override func setUp() {
        super.setUp()
        self.visualDetectionManagerMock = VisualDetectionManagerMock()
        self.stageSize = CGSize(width: 1080, height: 1920)
        self.facePositionXSensors.append(FacePositionXSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.facePositionXSensors.append(SecondFacePositionXSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.facePositionYSensors.append(FacePositionYSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
        self.facePositionYSensors.append(SecondFacePositionYSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock }))
    }

    override func tearDown() {
        self.visualDetectionManagerMock = nil
        self.facePositionXSensors.removeAll()
        self.facePositionYSensors.removeAll()
        super.tearDown()
    }

    func testDefaultRawValue() {
        var facePostionSensors = [DeviceDoubleSensor]()
        facePostionSensors.append(FacePositionXSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        facePostionSensors.append(SecondFacePositionXSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        facePostionSensors.append(FacePositionYSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))
        facePostionSensors.append(SecondFacePositionYSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil }))

        for facePositionSensor in facePostionSensors {
            XCTAssertEqual(type(of: facePositionSensor).defaultRawValue, facePositionSensor.rawValue(landscapeMode: false), accuracy: Double.epsilon)
            XCTAssertEqual(type(of: facePositionSensor).defaultRawValue, facePositionSensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)
        }
    }

    func testRawValue() {
        for faceIndex in 0..<VisualDetectionManager.maxFaceCount {
            self.visualDetectionManagerMock.facePositionXRatio[faceIndex] = 0
            XCTAssertEqual(0, self.facePositionXSensors[faceIndex].rawValue(landscapeMode: false))
            XCTAssertEqual(0, self.facePositionXSensors[faceIndex].rawValue(landscapeMode: true))

            self.visualDetectionManagerMock.facePositionYRatio[faceIndex] = 0.95
            XCTAssertEqual(0.95, self.facePositionYSensors[faceIndex].rawValue(landscapeMode: false))
            XCTAssertEqual(0.95, self.facePositionYSensors[faceIndex].rawValue(landscapeMode: true))
        }
    }

    func testConvertToStandardized() {
        for faceIndex in 0..<VisualDetectionManager.maxFaceCount {
            XCTAssertEqual(type(of: facePositionXSensors[faceIndex]).defaultRawValue, facePositionXSensors[faceIndex].convertToStandardized(rawValue: 0))

            XCTAssertEqual(Double(stageSize.width * 0.02) - Double(stageSize.width / 2), facePositionXSensors[faceIndex].convertToStandardized(rawValue: 0.02))
            XCTAssertEqual(Double(stageSize.width * 0.45) - Double(stageSize.width / 2), facePositionXSensors[faceIndex].convertToStandardized(rawValue: 0.45))
            XCTAssertEqual(Double(stageSize.width * 0.93) - Double(stageSize.width / 2), facePositionXSensors[faceIndex].convertToStandardized(rawValue: 0.93))
            XCTAssertEqual(Double(stageSize.width / 2), facePositionXSensors[faceIndex].convertToStandardized(rawValue: 1.0))

            XCTAssertEqual(type(of: facePositionYSensors[faceIndex]).defaultRawValue, facePositionYSensors[faceIndex].convertToStandardized(rawValue: 0))

            XCTAssertEqual(Double(stageSize.height * 0.01) - Double(stageSize.height / 2), facePositionYSensors[faceIndex].convertToStandardized(rawValue: 0.01))
            XCTAssertEqual(Double(stageSize.height * 0.4) - Double(stageSize.height / 2), facePositionYSensors[faceIndex].convertToStandardized(rawValue: 0.4))
            XCTAssertEqual(Double(stageSize.height * 0.95) - Double(stageSize.height / 2), facePositionYSensors[faceIndex].convertToStandardized(rawValue: 0.95))
            XCTAssertEqual(Double(stageSize.height / 2), facePositionYSensors[faceIndex].convertToStandardized(rawValue: 1.0))
        }
    }

    func testStandardizedValue() {
        for faceIndex in 0..<VisualDetectionManager.maxFaceCount {
            var convertToStandardizedValue = facePositionXSensors[faceIndex].convertToStandardized(rawValue: facePositionXSensors[faceIndex].rawValue(landscapeMode: false))
            var standardizedValue = facePositionXSensors[faceIndex].standardizedValue(landscapeMode: false)
            var standardizedValueLandscape = facePositionXSensors[faceIndex].standardizedValue(landscapeMode: true)
            XCTAssertEqual(convertToStandardizedValue, standardizedValue)
            XCTAssertEqual(standardizedValue, standardizedValueLandscape)

            convertToStandardizedValue = facePositionYSensors[faceIndex].convertToStandardized(rawValue: facePositionYSensors[faceIndex].rawValue(landscapeMode: false))
            standardizedValue = facePositionYSensors[faceIndex].standardizedValue(landscapeMode: false)
            standardizedValueLandscape = facePositionYSensors[faceIndex].standardizedValue(landscapeMode: true)
            XCTAssertEqual(convertToStandardizedValue, standardizedValue)
            XCTAssertEqual(standardizedValue, standardizedValueLandscape)
        }
    }

    func testTag() {
        XCTAssertEqual("FACE_X", facePositionXSensors[0].tag())
        XCTAssertEqual("SECOND_FACE_X", facePositionXSensors[1].tag())

        XCTAssertEqual("FACE_Y", facePositionYSensors[0].tag())
        XCTAssertEqual("SECOND_FACE_Y", facePositionYSensors[1].tag())
    }

    func testRequiredResources() {
        for faceIndex in 0..<VisualDetectionManager.maxFaceCount {
            XCTAssertEqual(ResourceType.faceDetection, type(of: facePositionXSensors[faceIndex]).requiredResource)
            XCTAssertEqual(ResourceType.faceDetection, type(of: facePositionYSensors[faceIndex]).requiredResource)
        }
    }

    func testFormulaEditorSections() {
        for faceIndex in 0..<VisualDetectionManager.maxFaceCount {
            var sections = facePositionYSensors[faceIndex].formulaEditorSections(for: SpriteObject())
            XCTAssertEqual(1, sections.count)
            XCTAssertEqual(.sensors(position: type(of: facePositionYSensors[faceIndex]).position, subsection: .visual), sections.first)

            sections = facePositionXSensors[faceIndex].formulaEditorSections(for: SpriteObject())
            XCTAssertEqual(1, sections.count)
            XCTAssertEqual(.sensors(position: type(of: facePositionXSensors[faceIndex]).position, subsection: .visual), sections.first)
        }
    }
}
