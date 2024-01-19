/**
 *  Copyright (C) 2010-2024 The Catrobat Team
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

final class FaceSizeSensorTest: XCTestCase {

    var faceSizeSensors = [DeviceDoubleSensor]()
    var cameraManagerMock: VisualDetectionManagerMock!
    var stageSize: CGSize!

    override func setUp() {
        super.setUp()
        self.cameraManagerMock = VisualDetectionManagerMock()
        self.stageSize = CGSize(width: 640, height: 1136)
        self.faceSizeSensors.append(FaceSizeSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.cameraManagerMock }))
        self.faceSizeSensors.append(SecondFaceSizeSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.cameraManagerMock }))
    }

    override func tearDown() {
        self.cameraManagerMock = nil
        self.faceSizeSensors.removeAll()
        super.tearDown()
    }

    func testDefaultRawValue() {
        let firstFaceSizeSensor = FaceSizeSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil })
        XCTAssertEqual(type(of: firstFaceSizeSensor).defaultRawValue, firstFaceSizeSensor.rawValue(landscapeMode: false), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: firstFaceSizeSensor).defaultRawValue, firstFaceSizeSensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)

        let secondFaceSizeSensor = SecondFaceSizeSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil })
        XCTAssertEqual(type(of: secondFaceSizeSensor).defaultRawValue, secondFaceSizeSensor.rawValue(landscapeMode: false), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: secondFaceSizeSensor).defaultRawValue, secondFaceSizeSensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)
    }

    func testRawValue() {
        for faceIndex in 0..<VisualDetectionManager.maxFaceCount {
            self.cameraManagerMock.faceSizeRatio[faceIndex] = 0.2
            XCTAssertEqual(0.2, faceSizeSensors[faceIndex].rawValue(landscapeMode: false), accuracy: Double.epsilon)
            XCTAssertEqual(0.2, faceSizeSensors[faceIndex].rawValue(landscapeMode: true), accuracy: Double.epsilon)

            self.cameraManagerMock.faceSizeRatio[faceIndex] = 0.5
            XCTAssertEqual(0.5, faceSizeSensors[faceIndex].rawValue(landscapeMode: false), accuracy: Double.epsilon)
            XCTAssertEqual(0.5, faceSizeSensors[faceIndex].rawValue(landscapeMode: true), accuracy: Double.epsilon)

            self.cameraManagerMock.faceSizeRatio[faceIndex] = 1.0
            XCTAssertEqual(1.0, faceSizeSensors[faceIndex].rawValue(landscapeMode: false), accuracy: Double.epsilon)
            XCTAssertEqual(1.0, faceSizeSensors[faceIndex].rawValue(landscapeMode: true), accuracy: Double.epsilon)
        }
    }

    func testConvertToStandardized() {
        for faceIndex in 0..<VisualDetectionManager.maxFaceCount {
            XCTAssertEqual(0, faceSizeSensors[faceIndex].convertToStandardized(rawValue: 0), accuracy: Double.epsilon)
            XCTAssertEqual(50, faceSizeSensors[faceIndex].convertToStandardized(rawValue: 0.5), accuracy: Double.epsilon)
            XCTAssertEqual(100, faceSizeSensors[faceIndex].convertToStandardized(rawValue: 1), accuracy: Double.epsilon)
            XCTAssertEqual(0, faceSizeSensors[faceIndex].convertToStandardized(rawValue: -20), accuracy: Double.epsilon)
            XCTAssertEqual(100, faceSizeSensors[faceIndex].convertToStandardized(rawValue: 150), accuracy: Double.epsilon)
        }
    }

    func testStandardizedValue() {
        for faceIndex in 0..<VisualDetectionManager.maxFaceCount {
            let convertToStandardizedValue = faceSizeSensors[faceIndex].convertToStandardized(rawValue: faceSizeSensors[faceIndex].rawValue(landscapeMode: false))
            let standardizedValue = faceSizeSensors[faceIndex].standardizedValue(landscapeMode: false)
            let standardizedValueLandscape = faceSizeSensors[faceIndex].standardizedValue(landscapeMode: true)
            XCTAssertEqual(convertToStandardizedValue, standardizedValue)
            XCTAssertEqual(standardizedValue, standardizedValueLandscape)
        }
    }

    func testTag() {
        XCTAssertEqual("FACE_SIZE", faceSizeSensors[0].tag())
        XCTAssertEqual("SECOND_FACE_SIZE", faceSizeSensors[1].tag())
    }

    func testRequiredResources() {
        for faceIndex in 0..<VisualDetectionManager.maxFaceCount {
            XCTAssertEqual(ResourceType.faceDetection, type(of: faceSizeSensors[faceIndex]).requiredResource)
        }
    }

    func testFormulaEditorSections() {
        for faceIndex in 0..<VisualDetectionManager.maxFaceCount {
            let sections = faceSizeSensors[faceIndex].formulaEditorSections(for: SpriteObject())
            XCTAssertEqual(1, sections.count)

            let position = faceIndex == 0 ? FaceSizeSensor.position : SecondFaceSizeSensor.position
            XCTAssertEqual(.sensors(position: position, subsection: .visual), sections.first)
        }
    }
}
