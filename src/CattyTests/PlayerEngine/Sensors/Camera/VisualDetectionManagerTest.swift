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
import Vision

final class VisualDetectionManagerTest: XCTestCase {

    var manager: VisualDetectionManagerMock!
    var stageSize: CGSize!

    override func setUp() {
        super.setUp()
        manager = VisualDetectionManagerMock()
        stageSize = CGSize(width: 1080, height: 1920)
        manager.setVisualDetectionFrameSize(stageSize)
    }

    override func tearDown() {
        manager = nil
        super.tearDown()
    }

    func testReset() {
        for faceIndex in 0..<VisualDetectionManager.maxFaceCount {
            manager.isFaceDetected[faceIndex] = true
            manager.facePositionXRatio[faceIndex] = 0.1
            manager.facePositionYRatio[faceIndex] = 0.2
            manager.faceSizeRatio[faceIndex] = 1.0
        }
        manager.visualDetectionFrameSize = CGSize.zero

        manager.reset()

        for faceIndex in 0..<VisualDetectionManager.maxFaceCount {
            XCTAssertFalse(manager.isFaceDetected[faceIndex])
            XCTAssertNil(manager.facePositionXRatio[faceIndex])
            XCTAssertNil(manager.facePositionYRatio[faceIndex])
            XCTAssertNil(manager.faceSizeRatio[faceIndex])
        }
        XCTAssertNil(manager.visualDetectionFrameSize)
    }

    func testCameraPosition() {
        var position = AVCaptureDevice.Position.front
        CameraPreviewHandler.shared().switchCameraPosition(to: position)

        XCTAssertEqual(position, manager.cameraPosition())

        position = AVCaptureDevice.Position.back
        CameraPreviewHandler.shared().switchCameraPosition(to: position)

        XCTAssertEqual(position, manager.cameraPosition())
    }

    func testNoFaceDetected() {
        manager.handleDetectedFaceObservations([])
        for faceIndex in 0..<VisualDetectionManager.maxFaceCount {
            XCTAssertFalse(manager.isFaceDetected[faceIndex])
            XCTAssertNil(manager.facePositionXRatio[faceIndex])
            XCTAssertNil(manager.facePositionYRatio[faceIndex])
            XCTAssertNil(manager.faceSizeRatio[faceIndex])
        }
        XCTAssertNil(manager.visualDetectionFrameSize)
    }

    func testSingleFaceDetected() {
        let firstFaceDimensions = CGRect(x: 10, y: 200, width: 100, height: 150)
        let faceObservationBoundingBox = computeBoundingBoxInNormalizedCoordinates(faceDimensions: firstFaceDimensions)
        let faceObservation = VNFaceObservationMock(boundingBox: faceObservationBoundingBox)

        XCTAssertNil(manager.previousFaceObservations)

        manager.handleDetectedFaceObservations([faceObservation])

        XCTAssertNotNil(manager.previousFaceObservations)
        XCTAssertEqual(manager.previousFaceObservations?.count, 1)
        XCTAssert(manager.isFaceDetected[0])
        XCTAssertEqual(Double(stageSize.width) * manager.faceSizeRatio[0]!, Double(firstFaceDimensions.width))
        XCTAssertEqual(manager.facePositionXRatio[0], faceObservationBoundingBox.origin.x + faceObservationBoundingBox.width / 2)
        XCTAssertEqual(manager.facePositionYRatio[0], faceObservationBoundingBox.origin.y + faceObservationBoundingBox.height / 2)
    }

    func testTwoFacesDetected() {
        let firstFaceDimensions = CGRect(x: 10, y: 200, width: 100, height: 150)
        let secondFaceDimensions = CGRect(x: 50, y: 50, width: 300, height: 350)
        let firstFaceObservationBoundingBox = computeBoundingBoxInNormalizedCoordinates(faceDimensions: firstFaceDimensions)
        let secondFaceObservationBoundingBox = computeBoundingBoxInNormalizedCoordinates(faceDimensions: secondFaceDimensions)
        let firstFaceObservation = VNFaceObservationMock(boundingBox: firstFaceObservationBoundingBox)
        let secondFaceObservation = VNFaceObservationMock(boundingBox: secondFaceObservationBoundingBox)

        XCTAssertNil(manager.previousFaceObservations)

        manager.handleDetectedFaceObservations([firstFaceObservation, secondFaceObservation])

        XCTAssertNotNil(manager.previousFaceObservations)
        XCTAssertEqual(manager.previousFaceObservations?.count, VisualDetectionManager.maxFaceCount)

        for faceIndex in 0..<VisualDetectionManager.maxFaceCount {
            let faceDimensions = faceIndex == 0 ? firstFaceDimensions : secondFaceDimensions
            let faceObservationBoundingBox = faceIndex == 0 ? firstFaceObservationBoundingBox : secondFaceObservationBoundingBox
            XCTAssert(manager.isFaceDetected[faceIndex])
            XCTAssertEqual(Double(stageSize.width) * manager.faceSizeRatio[faceIndex]!, Double(faceDimensions.width))
            XCTAssertEqual(manager.facePositionXRatio[faceIndex], faceObservationBoundingBox.origin.x + faceObservationBoundingBox.width / 2)
            XCTAssertEqual(manager.facePositionYRatio[faceIndex], faceObservationBoundingBox.origin.y + faceObservationBoundingBox.height / 2)
        }
    }

    func testMultipleFacesDetected() {
        let detectedFacesCount = 5
        var faceDimensions = [CGRect]()
        var faceObservationBoundingBoxes = [CGRect]()
        var faceObservations = [VNFaceObservationMock]()

        for faceIndex in 0..<detectedFacesCount {
            let faceDimension = CGRect(x: faceIndex * 10, y: faceIndex * 10, width: 100, height: 100)
            let faceObservationBoundingBox = computeBoundingBoxInNormalizedCoordinates(faceDimensions: faceDimension)
            faceDimensions.append(faceDimension)
            faceObservationBoundingBoxes.append(faceObservationBoundingBox)
            faceObservations.append(VNFaceObservationMock(boundingBox: faceObservationBoundingBox))
        }

        XCTAssertNil(manager.previousFaceObservations)

        manager.handleDetectedFaceObservations(faceObservations)

        XCTAssertNotNil(manager.previousFaceObservations)
        XCTAssertEqual(manager.previousFaceObservations?.count, VisualDetectionManager.maxFaceCount)

        for faceIndex in 0..<VisualDetectionManager.maxFaceCount {
            XCTAssert(manager.isFaceDetected[faceIndex])
            XCTAssertEqual(Double(stageSize.width) * manager.faceSizeRatio[faceIndex]!, Double(faceDimensions[faceIndex].width))
            XCTAssertEqual(manager.facePositionXRatio[faceIndex], faceObservationBoundingBoxes[faceIndex].origin.x + faceObservationBoundingBoxes[faceIndex].width / 2)
            XCTAssertEqual(manager.facePositionYRatio[faceIndex], faceObservationBoundingBoxes[faceIndex].origin.y + faceObservationBoundingBoxes[faceIndex].height / 2)
        }
    }

    func testNoFacesTracked() {
        let previousFaceObservations = [VNFaceObservationMock(boundingBox: CGRect(x: 0.1, y: 0.1, width: 0.5, height: 0.5)),
                                        VNFaceObservationMock(boundingBox: CGRect(x: 0.3, y: 0.3, width: 0.5, height: 0.5))]
        manager.previousFaceObservations = previousFaceObservations

        XCTAssertNotNil(manager.previousFaceObservations)
        XCTAssertEqual(manager.previousFaceObservations?.count, VisualDetectionManager.maxFaceCount)

        manager.handleDetectedFaceObservations([])

        XCTAssertNil(manager.previousFaceObservations)

        for faceIndex in 0..<VisualDetectionManager.maxFaceCount {
            XCTAssertFalse(manager.isFaceDetected[faceIndex])
        }
    }

    func testSingleFaceTrackedWithSmallestEuclideanDistance() {
        let previousFaceObservations = [VNFaceObservationMock(boundingBox: CGRect(x: 0.1, y: 0.1, width: 0.5, height: 0.5)),
                                        VNFaceObservationMock(boundingBox: CGRect(x: 0.3, y: 0.3, width: 0.5, height: 0.5))]
        manager.previousFaceObservations = previousFaceObservations

        let currentFaceObservations = [VNFaceObservationMock(boundingBox: CGRect(x: 0.35, y: 0.35, width: 0.5, height: 0.5))]

        XCTAssertNotNil(manager.previousFaceObservations)
        XCTAssertEqual(manager.previousFaceObservations?.count, VisualDetectionManager.maxFaceCount)

        manager.handleDetectedFaceObservations(currentFaceObservations)

        XCTAssertNotNil(manager.previousFaceObservations)
        XCTAssertEqual(manager.previousFaceObservations?.count, 1)
        XCTAssert(manager.isFaceDetected[0])
    }

    func testTwoFacesTrackedWithSmallestEuclideanDistance() {
        let previousFaceObservations = [VNFaceObservationMock(boundingBox: CGRect(x: 0.1, y: 0.1, width: 0.5, height: 0.5)),
                                        VNFaceObservationMock(boundingBox: CGRect(x: 0.3, y: 0.3, width: 0.5, height: 0.5))]
        manager.previousFaceObservations = previousFaceObservations

        let currentFaceObservations = [VNFaceObservationMock(boundingBox: CGRect(x: 0.35, y: 0.35, width: 0.5, height: 0.5)),
                                       VNFaceObservationMock(boundingBox: CGRect(x: 0.15, y: 0.15, width: 0.5, height: 0.5))]

        XCTAssertNotNil(manager.previousFaceObservations)
        XCTAssertEqual(manager.previousFaceObservations?.count, VisualDetectionManager.maxFaceCount)

        manager.handleDetectedFaceObservations(currentFaceObservations)

        XCTAssertNotNil(manager.previousFaceObservations)
        XCTAssertEqual(manager.previousFaceObservations!.count, 2)
        XCTAssertEqual(manager.previousFaceObservations![0], currentFaceObservations[1])
        XCTAssertEqual(manager.previousFaceObservations![1], currentFaceObservations[0])
    }

    func testNoFaceLandmarksDetected() {
        let faceObservation = VNFaceObservationMock(boundingBox: CGRect(x: 0.1, y: 0.1, width: 0.5, height: 0.5))

        manager.handleDetectedFaceObservations([faceObservation])

        XCTAssert(manager.faceLandmarkPositionRatioDictionary.isEmpty)
    }

    func computeBoundingBoxInNormalizedCoordinates(faceDimensions: CGRect) -> CGRect {
        CGRect(
            x: faceDimensions.origin.x / stageSize.width,
            y: faceDimensions.origin.y / stageSize.height,
            width: faceDimensions.width / stageSize.width,
            height: faceDimensions.height / stageSize.height)
    }
}
