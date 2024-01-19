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
import Vision

extension VisualDetectionManager {
    func handleDetectedFaceObservations(_ faceObservations: [VNFaceObservation]) {
        guard !faceObservations.isEmpty else {
            resetFaceDetection()
            return
        }

        var currentFaceObservations = faceObservations
        var isFaceDetected = [false, false]
        let facesDetected = min(currentFaceObservations.count, VisualDetectionManager.maxFaceCount)

        if previousFaceObservations == nil {
            previousFaceObservations = Array(currentFaceObservations[..<facesDetected])
        } else {
            for previousFaceIndex in 0..<VisualDetectionManager.maxFaceCount {
                if currentFaceObservations.isEmpty {
                    if previousFaceIndex < previousFaceObservations!.count {
                        previousFaceObservations?.remove(at: previousFaceIndex)
                    }
                } else {
                    var matchingFaceObservation = currentFaceObservations[0]
                    if previousFaceIndex < previousFaceObservations!.count {
                        let previousFaceObservation = previousFaceObservations![previousFaceIndex]

                        var minimumEuclideanDistance = Double.greatestFiniteMagnitude
                        for currentFaceIndex in 0..<currentFaceObservations.count {
                            let currentFaceObservation = currentFaceObservations[currentFaceIndex]
                            let euclideanDistance = calculateEuclideanDistance(previousFaceObservation, currentFaceObservation)
                            if euclideanDistance < minimumEuclideanDistance {
                                minimumEuclideanDistance = euclideanDistance
                                matchingFaceObservation = currentFaceObservation
                            }
                        }
                    }
                    if previousFaceIndex >= previousFaceObservations!.count {
                        previousFaceObservations?.append(matchingFaceObservation)
                    } else {
                        previousFaceObservations![previousFaceIndex] = matchingFaceObservation
                    }
                    currentFaceObservations.removeObject(matchingFaceObservation)
                }
            }
        }

        for faceIndex in 0..<previousFaceObservations!.count {
            let faceObservation = previousFaceObservations![faceIndex]
            self.facePositionXRatio[faceIndex] = faceObservation.boundingBox.origin.x + faceObservation.boundingBox.width / 2
            self.facePositionYRatio[faceIndex] = faceObservation.boundingBox.origin.y + faceObservation.boundingBox.height / 2
            self.faceSizeRatio[faceIndex] = max(faceObservation.boundingBox.width, faceObservation.boundingBox.height)
            isFaceDetected[faceIndex] = true
        }
        self.isFaceDetected = isFaceDetected

        if self.isFaceDetected[0] {
            let faceObservation = previousFaceObservations![0]
            if let landmarks = faceObservation.landmarks {
                if let nose = landmarks.noseCrest {
                    handleNoseLandmark(nose)
                }
                if let leftEye = landmarks.leftEye {
                    handleEyeLandmark(leftEye, isLeft: true)
                }
                if let leftPupil = landmarks.leftPupil {
                    handlePupilLandmark(leftPupil, isLeft: true)
                }
                if let rightEye = landmarks.rightEye {
                    handleEyeLandmark(rightEye, isLeft: false)
                }
                if let rightPupil = landmarks.rightPupil {
                    handlePupilLandmark(rightPupil, isLeft: false)
                }
                if let outerLips = landmarks.outerLips {
                    handleOuterLipsLandmark(outerLips)
                }
                if let leftEyebrow = landmarks.leftEyebrow {
                    handleEyebrowLandmark(leftEyebrow, isLeft: true)
                }
                if let rightEyebrow = landmarks.rightEyebrow {
                    handleEyebrowLandmark(rightEyebrow, isLeft: false)
                }
                if let faceContour = landmarks.faceContour {
                    handleFaceContourLandmark(faceContour, faceBoundingBox: faceObservation.boundingBox)
                }
            }
        }
    }

    func handleNoseLandmark(_ nose: VNFaceLandmarkRegion2D) {
        self.faceLandmarkPositionRatioDictionary[NoseXSensor.tag] = nose.pointsInImage(imageSize: normalizedSize)[nose.pointCount / 2].x
        self.faceLandmarkPositionRatioDictionary[NoseYSensor.tag] = nose.pointsInImage(imageSize: normalizedSize)[nose.pointCount / 2].y
    }

    func handleEyeLandmark(_ eye: VNFaceLandmarkRegion2D, isLeft: Bool) {
        if isLeft {
            self.faceLandmarkPositionRatioDictionary[LeftEyeInnerXSensor.tag] = eye.pointsInImage(imageSize: normalizedSize)[eye.pointCount / 2].x
            self.faceLandmarkPositionRatioDictionary[LeftEyeInnerYSensor.tag] = eye.pointsInImage(imageSize: normalizedSize)[eye.pointCount / 2].y

            self.faceLandmarkPositionRatioDictionary[LeftEyeOuterXSensor.tag] = eye.pointsInImage(imageSize: normalizedSize)[0].x
            self.faceLandmarkPositionRatioDictionary[LeftEyeOuterYSensor.tag] = eye.pointsInImage(imageSize: normalizedSize)[0].y
        } else {
            self.faceLandmarkPositionRatioDictionary[RightEyeInnerXSensor.tag] = eye.pointsInImage(imageSize: normalizedSize)[eye.pointCount / 2].x
            self.faceLandmarkPositionRatioDictionary[RightEyeInnerYSensor.tag] = eye.pointsInImage(imageSize: normalizedSize)[eye.pointCount / 2].y

            self.faceLandmarkPositionRatioDictionary[RightEyeOuterXSensor.tag] = eye.pointsInImage(imageSize: normalizedSize)[0].x
            self.faceLandmarkPositionRatioDictionary[RightEyeOuterYSensor.tag] = eye.pointsInImage(imageSize: normalizedSize)[0].y
        }
    }

    func handlePupilLandmark(_ pupil: VNFaceLandmarkRegion2D, isLeft: Bool) {
        if isLeft {
            self.faceLandmarkPositionRatioDictionary[LeftEyeCenterXSensor.tag] = pupil.pointsInImage(imageSize: normalizedSize)[0].x
            self.faceLandmarkPositionRatioDictionary[LeftEyeCenterYSensor.tag] = pupil.pointsInImage(imageSize: normalizedSize)[0].y
        } else {
            self.faceLandmarkPositionRatioDictionary[RightEyeCenterXSensor.tag] = pupil.pointsInImage(imageSize: normalizedSize)[0].x
            self.faceLandmarkPositionRatioDictionary[RightEyeCenterYSensor.tag] = pupil.pointsInImage(imageSize: normalizedSize)[0].y
        }
    }

    func handleFaceContourLandmark(_ faceContour: VNFaceLandmarkRegion2D, faceBoundingBox: CGRect) {
        self.faceLandmarkPositionRatioDictionary[LeftEarXSensor.tag] = faceContour.pointsInImage(imageSize: normalizedSize)[faceContour.pointCount - 2].x
        self.faceLandmarkPositionRatioDictionary[LeftEarYSensor.tag] = faceContour.pointsInImage(imageSize: normalizedSize)[faceContour.pointCount - 2].y

        self.faceLandmarkPositionRatioDictionary[RightEarXSensor.tag] = faceContour.pointsInImage(imageSize: normalizedSize)[1].x
        self.faceLandmarkPositionRatioDictionary[RightEarYSensor.tag] = faceContour.pointsInImage(imageSize: normalizedSize)[1].y

        calculateHeadTop()
    }

    func handleOuterLipsLandmark(_ outerLips: VNFaceLandmarkRegion2D) {
        self.faceLandmarkPositionRatioDictionary[MouthLeftCornerXSensor.tag] = outerLips.pointsInImage(imageSize: normalizedSize)[0].x
        self.faceLandmarkPositionRatioDictionary[MouthLeftCornerYSensor.tag] = outerLips.pointsInImage(imageSize: normalizedSize)[0].y

        self.faceLandmarkPositionRatioDictionary[MouthRightCornerXSensor.tag] = outerLips.pointsInImage(imageSize: normalizedSize)[outerLips.pointCount / 2].x
        self.faceLandmarkPositionRatioDictionary[MouthRightCornerYSensor.tag] = outerLips.pointsInImage(imageSize: normalizedSize)[outerLips.pointCount / 2].y
    }

    func handleEyebrowLandmark(_ eyebrow: VNFaceLandmarkRegion2D, isLeft: Bool) {
        if isLeft {
            self.faceLandmarkPositionRatioDictionary[LeftEyebrowInnerXSensor.tag] = eyebrow.pointsInImage(imageSize: normalizedSize)[eyebrow.pointCount / 2].x
            self.faceLandmarkPositionRatioDictionary[LeftEyebrowInnerYSensor.tag] = eyebrow.pointsInImage(imageSize: normalizedSize)[eyebrow.pointCount / 2].y

            self.faceLandmarkPositionRatioDictionary[LeftEyebrowCenterXSensor.tag] = eyebrow.pointsInImage(imageSize: normalizedSize)[eyebrow.pointCount / 4].x
            self.faceLandmarkPositionRatioDictionary[LeftEyebrowCenterYSensor.tag] = eyebrow.pointsInImage(imageSize: normalizedSize)[eyebrow.pointCount / 4].y

            self.faceLandmarkPositionRatioDictionary[LeftEyebrowOuterXSensor.tag] = eyebrow.pointsInImage(imageSize: normalizedSize)[0].x
            self.faceLandmarkPositionRatioDictionary[LeftEyebrowOuterYSensor.tag] = eyebrow.pointsInImage(imageSize: normalizedSize)[0].y
        } else {
            self.faceLandmarkPositionRatioDictionary[RightEyebrowInnerXSensor.tag] = eyebrow.pointsInImage(imageSize: normalizedSize)[eyebrow.pointCount / 2].x
            self.faceLandmarkPositionRatioDictionary[RightEyebrowInnerYSensor.tag] = eyebrow.pointsInImage(imageSize: normalizedSize)[eyebrow.pointCount / 2].y

            self.faceLandmarkPositionRatioDictionary[RightEyebrowCenterXSensor.tag] = eyebrow.pointsInImage(imageSize: normalizedSize)[eyebrow.pointCount / 4].x
            self.faceLandmarkPositionRatioDictionary[RightEyebrowCenterYSensor.tag] = eyebrow.pointsInImage(imageSize: normalizedSize)[eyebrow.pointCount / 4].y

            self.faceLandmarkPositionRatioDictionary[RightEyebrowOuterXSensor.tag] = eyebrow.pointsInImage(imageSize: normalizedSize)[0].x
            self.faceLandmarkPositionRatioDictionary[RightEyebrowOuterYSensor.tag] = eyebrow.pointsInImage(imageSize: normalizedSize)[0].y
        }
    }

    func calculateHeadTop() {
        if let leftEyebrowX = self.faceLandmarkPositionRatioDictionary[LeftEyebrowCenterXSensor.tag],
           let leftEyebrowY = self.faceLandmarkPositionRatioDictionary[LeftEyebrowCenterYSensor.tag],
           let rightEyebrowX = self.faceLandmarkPositionRatioDictionary[RightEyebrowCenterXSensor.tag],
           let rightEyebrowY = self.faceLandmarkPositionRatioDictionary[RightEyebrowCenterYSensor.tag],
           let noseX = self.faceLandmarkPositionRatioDictionary[NoseXSensor.tag],
           let noseY = self.faceLandmarkPositionRatioDictionary[NoseYSensor.tag] {
            self.faceLandmarkPositionRatioDictionary[HeadTopXSensor.tag] = rightEyebrowX + (leftEyebrowX - noseX)
            self.faceLandmarkPositionRatioDictionary[HeadTopYSensor.tag] = rightEyebrowY + (leftEyebrowY - noseY)
        }
    }

    func calculateEuclideanDistance(_ previousFaceObservation: VNFaceObservation, _ currentFaceObservation: VNFaceObservation) -> Double {
        let distanceX = previousFaceObservation.boundingBox.origin.x - currentFaceObservation.boundingBox.origin.x
        let distanceY = previousFaceObservation.boundingBox.origin.y - currentFaceObservation.boundingBox.origin.y
        return sqrt(pow(distanceX, 2) + pow(distanceY, 2))
    }
}
