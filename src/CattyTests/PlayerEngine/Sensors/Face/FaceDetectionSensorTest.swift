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

final class FaceDetectionSensorTest: XCTestCase {

    var faceDetectedSensors = [DeviceDoubleSensor]()
    var cameraManagerMock: VisualDetectionManagerMock!

    func testDefaultRawValue() {
        let firstFaceSensor = FaceDetectedSensor { nil }
        XCTAssertEqual(type(of: firstFaceSensor).defaultRawValue, firstFaceSensor.rawValue(landscapeMode: false), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: firstFaceSensor).defaultRawValue, firstFaceSensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)

        let secondFaceSensor = SecondFaceDetectedSensor { nil }
        XCTAssertEqual(type(of: secondFaceSensor).defaultRawValue, secondFaceSensor.rawValue(landscapeMode: false), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: secondFaceSensor).defaultRawValue, secondFaceSensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)
    }

    override func setUp() {
        super.setUp()
        self.cameraManagerMock = VisualDetectionManagerMock()
        self.faceDetectedSensors.append(FaceDetectedSensor { [ weak self ] in self?.cameraManagerMock })
        self.faceDetectedSensors.append(SecondFaceDetectedSensor { [ weak self ] in self?.cameraManagerMock })
    }

    override func tearDown() {
        self.cameraManagerMock = nil
        self.faceDetectedSensors.removeAll()
        super.tearDown()
    }

    func testRawValue() {
        for faceIndex in 0..<VisualDetectionManager.maxFaceCount {
            self.cameraManagerMock.isFaceDetected[faceIndex] = true
            XCTAssertEqual(1, self.faceDetectedSensors[faceIndex].rawValue(landscapeMode: false))
            XCTAssertEqual(1, self.faceDetectedSensors[faceIndex].rawValue(landscapeMode: true))

            self.cameraManagerMock.isFaceDetected[faceIndex] = false
            XCTAssertEqual(0, self.faceDetectedSensors[faceIndex].rawValue(landscapeMode: false))
            XCTAssertEqual(0, self.faceDetectedSensors[faceIndex].rawValue(landscapeMode: true))
        }
    }

    func testConvertToStandardized() {
        for faceIndex in 0..<VisualDetectionManager.maxFaceCount {
            XCTAssertEqual(0, faceDetectedSensors[faceIndex].convertToStandardized(rawValue: 0))
            XCTAssertEqual(1, faceDetectedSensors[faceIndex].convertToStandardized(rawValue: 1))
        }
    }

    func testStandardizedValue() {
        for faceIndex in 0..<VisualDetectionManager.maxFaceCount {
            let convertToStandardizedValue = faceDetectedSensors[faceIndex].convertToStandardized(rawValue: faceDetectedSensors[faceIndex].rawValue(landscapeMode: false))
            let standardizedValue = faceDetectedSensors[faceIndex].standardizedValue(landscapeMode: false)
            let standardizedValueLandscape = faceDetectedSensors[faceIndex].standardizedValue(landscapeMode: true)
            XCTAssertEqual(convertToStandardizedValue, standardizedValue)
            XCTAssertEqual(standardizedValue, standardizedValueLandscape)
        }
    }

    func testTag() {
        XCTAssertEqual("FACE_DETECTED", faceDetectedSensors[0].tag())
        XCTAssertEqual("SECOND_FACE_DETECTED", faceDetectedSensors[1].tag())
    }

    func testRequiredResources() {
        for faceIndex in 0..<VisualDetectionManager.maxFaceCount {
            XCTAssertEqual(ResourceType.faceDetection, type(of: faceDetectedSensors[faceIndex]).requiredResource)
        }
    }

    func testFormulaEditorSections() {
        for faceIndex in 0..<VisualDetectionManager.maxFaceCount {
            let sections = faceDetectedSensors[faceIndex].formulaEditorSections(for: SpriteObject())
            XCTAssertEqual(1, sections.count)
            XCTAssertEqual(.sensors(position: type(of: faceDetectedSensors[faceIndex]).position, subsection: .visual), sections.first)
        }
    }
}
