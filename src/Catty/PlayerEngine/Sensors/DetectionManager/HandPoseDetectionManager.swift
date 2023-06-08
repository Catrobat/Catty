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
import Vision

@available(iOS 14.0, *)
extension VisualDetectionManager {
    func handleHumanHandPoseObservations(_ handPoseObservations: [VNHumanHandPoseObservation]) {
        guard !handPoseObservations.isEmpty else {
            resetHandPoses()
            return
        }

        var leftHand: VNHumanHandPoseObservation?
        var rightHand: VNHumanHandPoseObservation?
        if #available(iOS 15.0, *) {
            var leftHands = handPoseObservations.filter({ $0.chirality == .left })
            var rightHands = handPoseObservations.filter({ $0.chirality == .right })
            if cameraPosition() == .front {
                let tmpHands = leftHands
                leftHands = rightHands
                rightHands = tmpHands
            }

            if rightHands.count == 2 && leftHands.isEmpty {
                rightHand = rightHands[0]
                leftHand = rightHands[1]
            } else if leftHands.count == 2 && rightHands.isEmpty {
                leftHand = leftHands[0]
                rightHand = leftHands[1]
            } else {
                if leftHands.isNotEmpty {
                    leftHand = leftHands.first
                }
                if rightHands.isNotEmpty {
                    rightHand = rightHands.first
                }
            }
        } else {
            leftHand = handPoseObservations.first
            if handPoseObservations.count > 1 {
                rightHand = handPoseObservations[1]
                if let leftHandPinky = try? leftHand!.recognizedPoint(.littlePIP),
                   let rightHandPinky = try? rightHand!.recognizedPoint(.littlePIP) {
                    if rightHandPinky.x < leftHandPinky.x {
                        rightHand = handPoseObservations[0]
                        leftHand = handPoseObservations[1]
                    }
                }
            }
        }

        if let leftHand = leftHand {
            handleHandObservation(leftHand, isLeft: true)
        } else {
            removeLeftHandPoses()
        }

        if let rightHand = rightHand {
            handleHandObservation(rightHand, isLeft: false)
        } else {
            removeRightHandPoses()
        }
    }

    func handleHandObservation(_ hand: VNHumanHandPoseObservation, isLeft: Bool) {
        let pinkyPoints = try? hand.recognizedPoints(.littleFinger)
        let ringFingerPoints = try? hand.recognizedPoints(.ringFinger)
        let middleFingerPoints = try? hand.recognizedPoints(.middleFinger)
        let indexPoints = try? hand.recognizedPoints(.indexFinger)
        let thumbPoints = try? hand.recognizedPoints(.thumb)

        if let pinkyKnuckle = pinkyPoints?[.littlePIP] {
            if pinkyKnuckle.confidence > minConfidence {
                if isLeft {
                    handPosePositionRatioDictionary[LeftPinkyKnuckleXSensor.tag] = pinkyKnuckle.x
                    handPosePositionRatioDictionary[LeftPinkyKnuckleYSensor.tag] = pinkyKnuckle.y
                } else {
                    handPosePositionRatioDictionary[RightPinkyKnuckleXSensor.tag] = pinkyKnuckle.x
                    handPosePositionRatioDictionary[RightPinkyKnuckleYSensor.tag] = pinkyKnuckle.y
                }
            }
        }
        if let ringFingerPoints = ringFingerPoints?[.ringPIP] {
            if ringFingerPoints.confidence > minConfidence {
                if isLeft {
                    handPosePositionRatioDictionary[LeftRingFingerKnuckleXSensor.tag] = ringFingerPoints.x
                    handPosePositionRatioDictionary[LeftRingFingerKnuckleYSensor.tag] = ringFingerPoints.y
                } else {
                    handPosePositionRatioDictionary[RightRingFingerKnuckleXSensor.tag] = ringFingerPoints.x
                    handPosePositionRatioDictionary[RightRingFingerKnuckleYSensor.tag] = ringFingerPoints.y
                }
            }
        }
        if let middleFingerPoints = middleFingerPoints?[.middlePIP] {
            if middleFingerPoints.confidence > minConfidence {
                if isLeft {
                    handPosePositionRatioDictionary[LeftMiddleFingerKnuckleXSensor.tag] = middleFingerPoints.x
                    handPosePositionRatioDictionary[LeftMiddleFingerKnuckleYSensor.tag] = middleFingerPoints.y
                } else {
                    handPosePositionRatioDictionary[RightMiddleFingerKnuckleXSensor.tag] = middleFingerPoints.x
                    handPosePositionRatioDictionary[RightMiddleFingerKnuckleYSensor.tag] = middleFingerPoints.y
                }
            }
        }
        if let indexKnuckle = indexPoints?[.indexPIP] {
            if indexKnuckle.confidence > minConfidence {
                if isLeft {
                    handPosePositionRatioDictionary[LeftIndexKnuckleXSensor.tag] = indexKnuckle.x
                    handPosePositionRatioDictionary[LeftIndexKnuckleYSensor.tag] = indexKnuckle.y
                } else {
                    handPosePositionRatioDictionary[RightIndexKnuckleXSensor.tag] = indexKnuckle.x
                    handPosePositionRatioDictionary[RightIndexKnuckleYSensor.tag] = indexKnuckle.y
                }
            }
        }
        if let thumbKnuckle = thumbPoints?[.thumbIP] {
            if thumbKnuckle.confidence > minConfidence {
                if isLeft {
                    handPosePositionRatioDictionary[LeftThumbKnuckleXSensor.tag] = thumbKnuckle.x
                    handPosePositionRatioDictionary[LeftThumbKnuckleYSensor.tag] = thumbKnuckle.y
                } else {
                    handPosePositionRatioDictionary[RightThumbKnuckleXSensor.tag] = thumbKnuckle.x
                    handPosePositionRatioDictionary[RightThumbKnuckleYSensor.tag] = thumbKnuckle.y
                }
            }
        }
    }

    func removeRightHandPoses() {
        for rightHandPose in self.handPosePositionRatioDictionary.filter({ $0.key.starts(with: "RIGHT") }) {
            self.handPosePositionRatioDictionary.removeValue(forKey: rightHandPose.key)
        }
    }

    func removeLeftHandPoses() {
        for leftHandPose in self.handPosePositionRatioDictionary.filter({ $0.key.starts(with: "LEFT") }) {
            self.handPosePositionRatioDictionary.removeValue(forKey: leftHandPose.key)
        }
    }
}
