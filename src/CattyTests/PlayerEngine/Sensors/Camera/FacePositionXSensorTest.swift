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

final class FacePositionXSensorTest: XCTestCase {

    var facePositionXSensors = [DeviceDoubleSensor]()
    var cameraManagerMock: FaceDetectionManagerMock!
    var stageSize: CGSize!

    override func setUp() {
        super.setUp()
        self.cameraManagerMock = FaceDetectionManagerMock()
        self.stageSize = CGSize(width: 1080, height: 1920)
        self.cameraManagerMock.setFaceDetectionFrameSize(stageSize)
        self.facePositionXSensors.append(FacePositionXSensor(stageSize: stageSize, faceDetectionManagerGetter: { [ weak self ] in self?.cameraManagerMock }))
        self.facePositionXSensors.append(SecondFacePositionXSensor(stageSize: stageSize, faceDetectionManagerGetter: { [ weak self ] in self?.cameraManagerMock }))
    }

    override func tearDown() {
        self.cameraManagerMock = nil
        self.facePositionXSensors.removeAll()
        super.tearDown()
    }

    func testDefaultRawValue() {
        let firstFacePositionXSensor = FacePositionXSensor(stageSize: stageSize, faceDetectionManagerGetter: { nil })
        XCTAssertEqual(type(of: firstFacePositionXSensor).defaultRawValue, firstFacePositionXSensor.rawValue(landscapeMode: false), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: firstFacePositionXSensor).defaultRawValue, firstFacePositionXSensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)

        let secondFacePositionXSensor = SecondFacePositionXSensor(stageSize: stageSize, faceDetectionManagerGetter: { nil })
        XCTAssertEqual(type(of: secondFacePositionXSensor).defaultRawValue, secondFacePositionXSensor.rawValue(landscapeMode: false), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: secondFacePositionXSensor).defaultRawValue, secondFacePositionXSensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)
    }

    func testRawValue() {
        // only positive values - (0, 0) is at the bottom left
        for faceIndex in 0..<FaceDetectionManager.maxFaceCount {
            self.cameraManagerMock.facePositionRatioFromLeft[faceIndex] = 0
            XCTAssertEqual(0, self.facePositionXSensors[faceIndex].rawValue(landscapeMode: false))
            XCTAssertEqual(0, self.facePositionXSensors[faceIndex].rawValue(landscapeMode: true))

            self.cameraManagerMock.facePositionRatioFromLeft[faceIndex] = 56
            XCTAssertEqual(56, self.facePositionXSensors[faceIndex].rawValue(landscapeMode: false))
            XCTAssertEqual(56, self.facePositionXSensors[faceIndex].rawValue(landscapeMode: true))
        }
    }

    func testConvertToStandardized() {
        for faceIndex in 0..<FaceDetectionManager.maxFaceCount {
            XCTAssertEqual(type(of: facePositionXSensors[faceIndex]).defaultRawValue, facePositionXSensors[faceIndex].convertToStandardized(rawValue: 0))

            XCTAssertEqual(Double(stageSize.width * 0.02) - Double(stageSize.width / 2), facePositionXSensors[faceIndex].convertToStandardized(rawValue: 0.02))
            XCTAssertEqual(Double(stageSize.width * 0.45) - Double(stageSize.width / 2), facePositionXSensors[faceIndex].convertToStandardized(rawValue: 0.45))
            XCTAssertEqual(Double(stageSize.width * 0.93) - Double(stageSize.width / 2), facePositionXSensors[faceIndex].convertToStandardized(rawValue: 0.93))
            XCTAssertEqual(Double(stageSize.width / 2), facePositionXSensors[faceIndex].convertToStandardized(rawValue: 1.0))
        }
    }

    func testStandardizedValue() {
        for faceIndex in 0..<FaceDetectionManager.maxFaceCount {
            let convertToStandardizedValue = facePositionXSensors[faceIndex].convertToStandardized(rawValue: facePositionXSensors[faceIndex].rawValue(landscapeMode: false))
            let standardizedValue = facePositionXSensors[faceIndex].standardizedValue(landscapeMode: false)
            let standardizedValueLandscape = facePositionXSensors[faceIndex].standardizedValue(landscapeMode: true)
            XCTAssertEqual(convertToStandardizedValue, standardizedValue)
            XCTAssertEqual(standardizedValue, standardizedValueLandscape)
        }
    }

    func testTag() {
        XCTAssertEqual("FACE_X", facePositionXSensors[0].tag())
        XCTAssertEqual("SECOND_FACE_X", facePositionXSensors[1].tag())
    }

    func testRequiredResources() {
        for faceIndex in 0..<FaceDetectionManager.maxFaceCount {
            XCTAssertEqual(ResourceType.faceDetection, type(of: facePositionXSensors[faceIndex]).requiredResource)
        }
    }

    func testFormulaEditorSections() {
        for faceIndex in 0..<FaceDetectionManager.maxFaceCount {
            let sections = facePositionXSensors[faceIndex].formulaEditorSections(for: SpriteObject())
            XCTAssertEqual(1, sections.count)
            let position = faceIndex == 0 ? FacePositionXSensor.position : SecondFacePositionXSensor.position
            XCTAssertEqual(.sensors(position: position, subsection: .visual), sections.first)
        }
    }
}
