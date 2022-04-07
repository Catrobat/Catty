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

final class FacePositionYSensorTest: XCTestCase {

    var facePositionYSensors = [DeviceDoubleSensor]()
    var cameraManagerMock: FaceDetectionManagerMock!
    var stageSize: CGSize!

    override func setUp() {
        super.setUp()
        self.cameraManagerMock = FaceDetectionManagerMock()
        self.stageSize = CGSize(width: 640, height: 1136)
        self.facePositionYSensors.append(FacePositionYSensor(stageSize: stageSize, faceDetectionManagerGetter: { [ weak self ] in self?.cameraManagerMock }))
        self.facePositionYSensors.append(SecondFacePositionYSensor(stageSize: stageSize, faceDetectionManagerGetter: { [ weak self ] in self?.cameraManagerMock }))
    }

    override func tearDown() {
        self.cameraManagerMock = nil
        self.facePositionYSensors.removeAll()
        super.tearDown()
    }

    func testDefaultRawValue() {
        let firstFacePositionYSensor = FacePositionYSensor(stageSize: self.stageSize, faceDetectionManagerGetter: { nil })
        XCTAssertEqual(type(of: firstFacePositionYSensor).defaultRawValue, firstFacePositionYSensor.rawValue(landscapeMode: false), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: firstFacePositionYSensor).defaultRawValue, firstFacePositionYSensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)

        let secondFacePositionYSensor = SecondFacePositionYSensor(stageSize: self.stageSize, faceDetectionManagerGetter: { nil })
        XCTAssertEqual(type(of: secondFacePositionYSensor).defaultRawValue, secondFacePositionYSensor.rawValue(landscapeMode: false), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: secondFacePositionYSensor).defaultRawValue, secondFacePositionYSensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)
    }

    func testRawValue() {
        // only positive values - (0, 0) is at the bottom left
        for faceIndex in 0..<FaceDetectionManager.maxFaceCount {
            self.cameraManagerMock.facePositionRatioFromBottom[faceIndex] = 0
            XCTAssertEqual(0, self.facePositionYSensors[faceIndex].rawValue(landscapeMode: false))
            XCTAssertEqual(0, self.facePositionYSensors[faceIndex].rawValue(landscapeMode: true))

            self.cameraManagerMock.facePositionRatioFromBottom[faceIndex] = 256
            XCTAssertEqual(256, self.facePositionYSensors[faceIndex].rawValue(landscapeMode: false))
            XCTAssertEqual(256, self.facePositionYSensors[faceIndex].rawValue(landscapeMode: true))
        }
    }

    func testConvertToStandardized() {
        for faceIndex in 0..<FaceDetectionManager.maxFaceCount {
            XCTAssertEqual(type(of: facePositionYSensors[faceIndex]).defaultRawValue, facePositionYSensors[faceIndex].convertToStandardized(rawValue: 0))

            XCTAssertEqual(Double(stageSize.height * 0.01) - Double(stageSize.height / 2), facePositionYSensors[faceIndex].convertToStandardized(rawValue: 0.01))
            XCTAssertEqual(Double(stageSize.height * 0.4) - Double(stageSize.height / 2), facePositionYSensors[faceIndex].convertToStandardized(rawValue: 0.4))
            XCTAssertEqual(Double(stageSize.height * 0.95) - Double(stageSize.height / 2), facePositionYSensors[faceIndex].convertToStandardized(rawValue: 0.95))
            XCTAssertEqual(Double(stageSize.height / 2), facePositionYSensors[faceIndex].convertToStandardized(rawValue: 1.0))
        }
    }

    func testStandardizedValue() {
        for faceIndex in 0..<FaceDetectionManager.maxFaceCount {
            let convertToStandardizedValue = facePositionYSensors[faceIndex].convertToStandardized(rawValue: facePositionYSensors[faceIndex].rawValue(landscapeMode: false))
            let standardizedValue = facePositionYSensors[faceIndex].standardizedValue(landscapeMode: false)
            let standardizedValueLandscape = facePositionYSensors[faceIndex].standardizedValue(landscapeMode: true)
            XCTAssertEqual(convertToStandardizedValue, standardizedValue)
            XCTAssertEqual(standardizedValue, standardizedValueLandscape)
        }
    }

    func testTag() {
        XCTAssertEqual("FACE_Y", facePositionYSensors[0].tag())
        XCTAssertEqual("SECOND_FACE_Y", facePositionYSensors[1].tag())
    }

    func testRequiredResources() {
        for faceIndex in 0..<FaceDetectionManager.maxFaceCount {
            XCTAssertEqual(ResourceType.faceDetection, type(of: facePositionYSensors[faceIndex]).requiredResource)
        }
    }

    func testFormulaEditorSections() {
        for faceIndex in 0..<FaceDetectionManager.maxFaceCount {
            let sections = facePositionYSensors[faceIndex].formulaEditorSections(for: SpriteObject())
            XCTAssertEqual(1, sections.count)
            let position = faceIndex == 0 ? FacePositionYSensor.position : SecondFacePositionYSensor.position
            XCTAssertEqual(.sensors(position: position, subsection: .visual), sections.first)
        }
    }
}
