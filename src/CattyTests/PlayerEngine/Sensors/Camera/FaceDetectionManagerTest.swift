/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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

final class FaceDetectionManagerTest: XCTestCase {

    var manager: FaceDetectionManager!

    override func setUp() {
        super.setUp()
        manager = FaceDetectionManagerMock()
    }

    override func tearDown() {
        manager = nil
        super.tearDown()
    }

    func testReset() {
        manager.isFaceDetected = true
        manager.facePositionRatioFromLeft = 0.1
        manager.facePositionRatioFromBottom = 0.2
        manager.faceSizeRatio = 1.0
        manager.faceDetectionFrameSize = CGSize.zero

        manager.reset()

        XCTAssertFalse(manager.isFaceDetected)
        XCTAssertNil(manager.facePositionRatioFromLeft)
        XCTAssertNil(manager.facePositionRatioFromBottom)
        XCTAssertNil(manager.faceSizeRatio)
        XCTAssertNil(manager.faceDetectionFrameSize)
    }

    func testCameraPosition() {
        var position = AVCaptureDevice.Position.front
        CameraPreviewHandler.shared().switchCameraPosition(to: position)

        XCTAssertEqual(position, manager.cameraPosition())

        position = AVCaptureDevice.Position.back
        CameraPreviewHandler.shared().switchCameraPosition(to: position)

        XCTAssertEqual(position, manager.cameraPosition())
    }

    func testCaptureFaceDetected() {
        let invalidFeature = FeatureMock(type: "invalidType", bounds: CGRect.zero)

        manager.captureFace(for: [invalidFeature], in: CGRect.zero)
        XCTAssertFalse(manager.isFaceDetected)
        XCTAssertNil(manager.faceDetectionFrameSize)
        XCTAssertNil(manager.facePositionRatioFromLeft)
        XCTAssertNil(manager.facePositionRatioFromBottom)
        XCTAssertNil(manager.faceSizeRatio)
        XCTAssertNil(manager.faceDetectionFrameSize)

        let validFeature = FeatureMock(type: CIFeatureTypeFace, bounds: CGRect.zero)
        manager.captureFace(for: [validFeature], in: CGRect.zero)

        XCTAssertTrue(manager.isFaceDetected)
    }

    func testCaptureFaceSizeRatio() {
        let faceDimensions = CGRect(x: 10, y: 200, width: 100, height: 150)
        let imageDimensions = CGRect(x: 0, y: 0, width: 400, height: 900)

        let feature = FeatureMock(type: CIFeatureTypeFace, bounds: faceDimensions)
        manager.captureFace(for: [feature], in: imageDimensions)

        XCTAssertEqual(Double(feature.bounds.width / imageDimensions.width), manager.faceSizeRatio)
    }

    func testCaptureFaceFrameSize() {
        let imageDimensions = CGRect(x: 0, y: 0, width: 100, height: 300)

        let feature = FeatureMock(type: CIFeatureTypeFace, bounds: CGRect.zero)
        manager.captureFace(for: [feature], in: imageDimensions)

        XCTAssertEqual(imageDimensions.size, manager.faceDetectionFrameSize!)
    }

    func testCaptureFacePositionFromBottom() {
        let faceDimensions = CGRect(x: 90, y: 800, width: 100, height: 150)
        let imageDimensions = CGRect(x: 0, y: 0, width: 400, height: 900)
        let feature = FeatureMock(type: CIFeatureTypeFace, bounds: faceDimensions)

        let centerOfFace = CGPoint(x: faceDimensions.origin.x + faceDimensions.size.width / 2,
                                   y: faceDimensions.origin.y + faceDimensions.size.height / 2)

        CameraPreviewHandler.shared().switchCameraPosition(to: AVCaptureDevice.Position.back)

        manager.captureFace(for: [feature], in: imageDimensions)
        XCTAssertEqual(Double(centerOfFace.y / imageDimensions.height), manager.facePositionRatioFromBottom!)

        CameraPreviewHandler.shared().switchCameraPosition(to: AVCaptureDevice.Position.front)

        manager.captureFace(for: [feature], in: imageDimensions)
        XCTAssertEqual(Double(centerOfFace.y / imageDimensions.height), manager.facePositionRatioFromBottom!)
    }

    func testCaptureFacePositionFromLeft() {
        let faceDimensions = CGRect(x: 90, y: 800, width: 200, height: 350)
        let imageDimensions = CGRect(x: 0, y: 0, width: 500, height: 1920)
        let feature = FeatureMock(type: CIFeatureTypeFace, bounds: faceDimensions)

        let centerOfFace = CGPoint(x: faceDimensions.origin.x + faceDimensions.size.width / 2,
                                   y: faceDimensions.origin.y + faceDimensions.size.height / 2)

        CameraPreviewHandler.shared().switchCameraPosition(to: AVCaptureDevice.Position.back)

        manager.captureFace(for: [feature], in: imageDimensions)
        XCTAssertEqual(Double(centerOfFace.x / imageDimensions.width), manager.facePositionRatioFromLeft!)

        CameraPreviewHandler.shared().switchCameraPosition(to: AVCaptureDevice.Position.front)

        manager.captureFace(for: [feature], in: imageDimensions)
        XCTAssertEqual(1 - Double(centerOfFace.x / imageDimensions.width), manager.facePositionRatioFromLeft!)
    }
}
