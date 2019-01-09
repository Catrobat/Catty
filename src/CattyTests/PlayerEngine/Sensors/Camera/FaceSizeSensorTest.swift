/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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

    var sensor: FaceSizeSensor!
    var cameraManagerMock: FaceDetectionManagerMock!
    var sceneSize: CGSize!

    override func setUp() {
        super.setUp()
        self.cameraManagerMock = FaceDetectionManagerMock()
        self.sceneSize = CGSize(width: 640, height: 1136)
        self.sensor = FaceSizeSensor(sceneSize: sceneSize, faceDetectionManagerGetter: { [ weak self ] in self?.cameraManagerMock })
    }

    override func tearDown() {
        self.cameraManagerMock = nil
        self.sensor = nil
        super.tearDown()
    }

    func testDefaultRawValue() {
        let sensor = FaceSizeSensor(sceneSize: sceneSize, faceDetectionManagerGetter: { nil })

        XCTAssertEqual(type(of: sensor).defaultRawValue, sensor.rawValue(), accuracy: Double.epsilon)
    }

    func testRawValue() {
        self.cameraManagerMock.faceSizeRatio = 0.2
        XCTAssertEqual(0.2, sensor.rawValue(), accuracy: Double.epsilon)

        self.cameraManagerMock.faceSizeRatio = 0.5
        XCTAssertEqual(0.5, sensor.rawValue(), accuracy: Double.epsilon)

        self.cameraManagerMock.faceSizeRatio = 1.0
        XCTAssertEqual(1.0, sensor.rawValue(), accuracy: Double.epsilon)
    }

    func testConvertToStandardized() {
        let frameWidth = 400
        let scaleFactor = Double(self.sceneSize.width) / Double(frameWidth)
        self.cameraManagerMock.faceDetectionFrameSize = CGSize(width: frameWidth, height: 700)

        XCTAssertEqual(0, sensor.convertToStandardized(rawValue: 0), accuracy: Double.epsilon)
        XCTAssertEqual(0.5 * scaleFactor * 100, sensor.convertToStandardized(rawValue: 0.5), accuracy: Double.epsilon)
        XCTAssertEqual(100, sensor.convertToStandardized(rawValue: 1), accuracy: Double.epsilon)
        XCTAssertEqual(0, sensor.convertToStandardized(rawValue: -20), accuracy: Double.epsilon)
        XCTAssertEqual(100, sensor.convertToStandardized(rawValue: 150), accuracy: Double.epsilon)

        self.cameraManagerMock.faceDetectionFrameSize = nil
        XCTAssertEqual(type(of: sensor).defaultRawValue, sensor.convertToStandardized(rawValue: 20), accuracy: Double.epsilon)
    }

    func testTag() {
        XCTAssertEqual("FACE_SIZE", sensor.tag())
    }

    func testRequiredResources() {
        XCTAssertEqual(ResourceType.faceDetection, type(of: sensor).requiredResource)
    }

    func testFormulaEditorSection() {
        XCTAssertEqual(.device(position: type(of: sensor).position), sensor.formulaEditorSection(for: SpriteObject()))
    }
}
