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
    @available(iOS 14.0, *)
    func handleHumanBodyPoseObservations(_ bodyPoseObservations: [VNHumanBodyPoseObservation]) {
        guard !bodyPoseObservations.isEmpty, let bodyPoseObservation = bodyPoseObservations.first else {
           resetBodyPoses()
           return
        }
        if let neck = try? bodyPoseObservation.recognizedPoint(.neck) {
           if neck.confidence > minConfidence {
               bodyPosePositionRatioDictionary[NeckXSensor.tag] = neck.x
               bodyPosePositionRatioDictionary[NeckYSensor.tag] = neck.y
           }
        }
        if let leftShoulder = try? bodyPoseObservation.recognizedPoint(.leftShoulder) {
           if leftShoulder.confidence > minConfidence {
               bodyPosePositionRatioDictionary[LeftShoulderXSensor.tag] = leftShoulder.x
               bodyPosePositionRatioDictionary[LeftShoulderYSensor.tag] = leftShoulder.y
           }
        }
        if let rightShoulder = try? bodyPoseObservation.recognizedPoint(.rightShoulder) {
           if rightShoulder.confidence > minConfidence {
               bodyPosePositionRatioDictionary[RightShoulderXSensor.tag] = rightShoulder.x
               bodyPosePositionRatioDictionary[RightShoulderYSensor.tag] = rightShoulder.y
           }
        }
        if let leftElbow = try? bodyPoseObservation.recognizedPoint(.leftElbow) {
           if leftElbow.confidence > minConfidence {
               bodyPosePositionRatioDictionary[LeftElbowXSensor.tag] = leftElbow.x
               bodyPosePositionRatioDictionary[LeftElbowYSensor.tag] = leftElbow.y
           }
        }
        if let rightElbow = try? bodyPoseObservation.recognizedPoint(.rightElbow) {
           if rightElbow.confidence > minConfidence {
               bodyPosePositionRatioDictionary[RightElbowXSensor.tag] = rightElbow.x
               bodyPosePositionRatioDictionary[RightElbowYSensor.tag] = rightElbow.y
           }
        }
        if let leftWrist = try? bodyPoseObservation.recognizedPoint(.leftWrist) {
           if leftWrist.confidence > minConfidence {
               bodyPosePositionRatioDictionary[LeftWristXSensor.tag] = leftWrist.x
               bodyPosePositionRatioDictionary[LeftWristYSensor.tag] = leftWrist.y
           }
        }
        if let rightWrist = try? bodyPoseObservation.recognizedPoint(.rightWrist) {
           if rightWrist.confidence > minConfidence {
               bodyPosePositionRatioDictionary[RightWristXSensor.tag] = rightWrist.x
               bodyPosePositionRatioDictionary[RightWristYSensor.tag] = rightWrist.y
           }
        }
        if let leftHip = try? bodyPoseObservation.recognizedPoint(.leftHip) {
            if leftHip.confidence > minConfidence {
                bodyPosePositionRatioDictionary[LeftHipXSensor.tag] = leftHip.x
                bodyPosePositionRatioDictionary[LeftHipYSensor.tag] = leftHip.y
            }
        }
        if let rightHip = try? bodyPoseObservation.recognizedPoint(.rightHip) {
            if rightHip.confidence > minConfidence {
                bodyPosePositionRatioDictionary[RightHipXSensor.tag] = rightHip.x
                bodyPosePositionRatioDictionary[RightHipYSensor.tag] = rightHip.y
            }
        }
        if let leftKnee = try? bodyPoseObservation.recognizedPoint(.leftKnee) {
            if leftKnee.confidence > minConfidence {
                bodyPosePositionRatioDictionary[LeftKneeXSensor.tag] = leftKnee.x
                bodyPosePositionRatioDictionary[LeftKneeYSensor.tag] = leftKnee.y
            }
        }
        if let rightKnee = try? bodyPoseObservation.recognizedPoint(.rightKnee) {
            if rightKnee.confidence > minConfidence {
                bodyPosePositionRatioDictionary[RightKneeXSensor.tag] = rightKnee.x
                bodyPosePositionRatioDictionary[RightKneeYSensor.tag] = rightKnee.y
            }
        }
        if let leftAnkle = try? bodyPoseObservation.recognizedPoint(.leftAnkle) {
            if leftAnkle.confidence > minConfidence {
                bodyPosePositionRatioDictionary[LeftAnkleXSensor.tag] = leftAnkle.x
                bodyPosePositionRatioDictionary[LeftAnkleYSensor.tag] = leftAnkle.y
            }
        }
        if let rightAnkle = try? bodyPoseObservation.recognizedPoint(.rightAnkle) {
            if rightAnkle.confidence > minConfidence {
                bodyPosePositionRatioDictionary[RightAnkleXSensor.tag] = rightAnkle.x
                bodyPosePositionRatioDictionary[RightAnkleYSensor.tag] = rightAnkle.y
            }
        }
    }

    func handleHumanBodyPoseObservations(_ bodyPoseObservations: [VNCoreMLFeatureValueObservation]) {
        let heatMaps = bodyPoseObservations[PoseNetModel.OutputIndex.heatmaps.rawValue].featureValue.multiArrayValue
        let offsets = bodyPoseObservations[PoseNetModel.OutputIndex.offsets.rawValue].featureValue.multiArrayValue
        if let heatMaps = heatMaps, let offsets = offsets {
            let featureCount = heatMaps.shape[0].intValue
            var keyPointArray = [(Int, Int)](repeating: (0, 0), count: featureCount)
            for keyPointIndex in 0..<featureCount {
                var maxValueKeypoint = heatMaps[[keyPointIndex, 0, 0] as [NSNumber]].doubleValue
                for yIndex in 0..<heatMaps.shape[1].intValue {
                    for xIndex in 0..<heatMaps.shape[2].intValue {
                        let currentHeatMapValue = heatMaps[[keyPointIndex, yIndex, xIndex] as [NSNumber]].doubleValue
                        if currentHeatMapValue > maxValueKeypoint {
                            maxValueKeypoint = currentHeatMapValue
                            keyPointArray[keyPointIndex] = (yIndex, xIndex)
                        }
                    }
                }
            }

            let (yLeftShoulder, xLeftShoulder) = keyPointArray[PoseNetModel.Features.leftShoulder.rawValue]
            let leftShoulderConfidence = heatMaps[[PoseNetModel.Features.leftShoulder.rawValue, yLeftShoulder, xLeftShoulder] as [NSNumber]].floatValue
            if leftShoulderConfidence > minConfidence {
                let yOffsetLeftShoulder = offsets[[PoseNetModel.Features.leftShoulder.rawValue, yLeftShoulder, xLeftShoulder] as [NSNumber]].doubleValue
                let xOffsetLeftShoulder = offsets[[featureCount + PoseNetModel.Features.leftShoulder.rawValue, yLeftShoulder, xLeftShoulder] as [NSNumber]].doubleValue

                DispatchQueue.main.async {
                    self.bodyPosePositionRatioDictionary[LeftShoulderYSensor.tag] = 1.0 - (Double(yLeftShoulder) * PoseNetModel.stride + yOffsetLeftShoulder) / PoseNetModel.inputDimension
                    self.bodyPosePositionRatioDictionary[LeftShoulderXSensor.tag] = (Double(xLeftShoulder) * PoseNetModel.stride + xOffsetLeftShoulder) / PoseNetModel.inputDimension
                }
            } else {
                DispatchQueue.main.async {
                    self.bodyPosePositionRatioDictionary.removeValue(forKey: LeftShoulderYSensor.tag)
                    self.bodyPosePositionRatioDictionary.removeValue(forKey: LeftShoulderXSensor.tag)
                }
            }

            let (yRightShoulder, xRightShoulder) = keyPointArray[PoseNetModel.Features.rightShoulder.rawValue]
            let rightShoulderConfidence = heatMaps[[PoseNetModel.Features.rightShoulder.rawValue, yRightShoulder, xRightShoulder] as [NSNumber]].floatValue
            if  rightShoulderConfidence > minConfidence {
                let yOffsetRightShoulder = offsets[[PoseNetModel.Features.rightShoulder.rawValue, yRightShoulder, xRightShoulder] as [NSNumber]].doubleValue
                let xOffsetRightShoulder = offsets[[featureCount + PoseNetModel.Features.rightShoulder.rawValue, yRightShoulder, xRightShoulder] as [NSNumber]].doubleValue

                DispatchQueue.main.async {
                    self.bodyPosePositionRatioDictionary[RightShoulderYSensor.tag] = 1.0 - (Double(yRightShoulder) * PoseNetModel.stride + yOffsetRightShoulder) / PoseNetModel.inputDimension
                    self.bodyPosePositionRatioDictionary[RightShoulderXSensor.tag] = (Double(xRightShoulder) * PoseNetModel.stride + xOffsetRightShoulder) / PoseNetModel.inputDimension
                }
            } else {
                DispatchQueue.main.async {
                    self.bodyPosePositionRatioDictionary.removeValue(forKey: RightShoulderYSensor.tag)
                    self.bodyPosePositionRatioDictionary.removeValue(forKey: RightShoulderXSensor.tag)
                }
            }

            let (yLeftElbow, xLeftElbow) = keyPointArray[PoseNetModel.Features.leftElbow.rawValue]
            let leftElbowConfidence = heatMaps[[PoseNetModel.Features.leftElbow.rawValue, yLeftElbow, xLeftElbow] as [NSNumber]].floatValue
            if leftElbowConfidence > minConfidence {
                let yOffsetLeftElbow = offsets[[PoseNetModel.Features.leftElbow.rawValue, yLeftElbow, xLeftElbow] as [NSNumber]].doubleValue
                let xOffsetLeftElbow = offsets[[featureCount + PoseNetModel.Features.leftElbow.rawValue, yLeftElbow, xLeftElbow] as [NSNumber]].doubleValue

                DispatchQueue.main.async {
                    self.bodyPosePositionRatioDictionary[LeftElbowYSensor.tag] = 1.0 - (Double(yLeftElbow) * PoseNetModel.stride + yOffsetLeftElbow) / PoseNetModel.inputDimension
                    self.bodyPosePositionRatioDictionary[LeftElbowXSensor.tag] = (Double(xLeftElbow) * PoseNetModel.stride + xOffsetLeftElbow) / PoseNetModel.inputDimension
                }
            } else {
                DispatchQueue.main.async {
                    self.bodyPosePositionRatioDictionary.removeValue(forKey: LeftElbowYSensor.tag)
                    self.bodyPosePositionRatioDictionary.removeValue(forKey: LeftElbowXSensor.tag)
                }
            }

            let (yRightElbow, xRightElbow) = keyPointArray[PoseNetModel.Features.rightElbow.rawValue]
            let rightElbowConfidence = heatMaps[[PoseNetModel.Features.rightElbow.rawValue, yRightElbow, xRightElbow] as [NSNumber]].floatValue
            if rightElbowConfidence > minConfidence {
                let yOffsetRightElbow = offsets[[PoseNetModel.Features.rightElbow.rawValue, yRightElbow, xRightElbow] as [NSNumber]].doubleValue
                let xOffsetRightElbow = offsets[[featureCount + PoseNetModel.Features.rightElbow.rawValue, yRightElbow, xRightElbow] as [NSNumber]].doubleValue

                DispatchQueue.main.async {
                    self.bodyPosePositionRatioDictionary[RightElbowYSensor.tag] = 1.0 - (Double(yRightElbow) * PoseNetModel.stride + yOffsetRightElbow) / PoseNetModel.inputDimension
                    self.bodyPosePositionRatioDictionary[RightElbowXSensor.tag] = (Double(xRightElbow) * PoseNetModel.stride + xOffsetRightElbow) / PoseNetModel.inputDimension
                }
            } else {
                DispatchQueue.main.async {
                    self.bodyPosePositionRatioDictionary.removeValue(forKey: RightElbowYSensor.tag)
                    self.bodyPosePositionRatioDictionary.removeValue(forKey: RightElbowXSensor.tag)
                }
            }

            let (yLeftWrist, xLeftWrist) = keyPointArray[PoseNetModel.Features.leftWrist.rawValue]
            let leftWristConfidence = heatMaps[[PoseNetModel.Features.leftWrist.rawValue, yLeftWrist, xLeftWrist] as [NSNumber]].floatValue
            if leftWristConfidence > minConfidence {
                let yOffsetLeftWrist = offsets[[PoseNetModel.Features.leftWrist.rawValue, yLeftWrist, xLeftWrist] as [NSNumber]].doubleValue
                let xOffsetLeftWrist = offsets[[featureCount + PoseNetModel.Features.leftWrist.rawValue, yLeftWrist, xLeftWrist] as [NSNumber]].doubleValue

                DispatchQueue.main.async {
                    self.bodyPosePositionRatioDictionary[LeftWristYSensor.tag] = 1.0 - (Double(yLeftWrist) * PoseNetModel.stride + yOffsetLeftWrist) / PoseNetModel.inputDimension
                    self.bodyPosePositionRatioDictionary[LeftWristXSensor.tag] = (Double(xLeftWrist) * PoseNetModel.stride + xOffsetLeftWrist) / PoseNetModel.inputDimension
                }
            } else {
                DispatchQueue.main.async {
                    self.bodyPosePositionRatioDictionary.removeValue(forKey: LeftWristYSensor.tag)
                    self.bodyPosePositionRatioDictionary.removeValue(forKey: LeftWristXSensor.tag)
                }
            }

            let (yRightWrist, xRightWrist) = keyPointArray[PoseNetModel.Features.rightWrist.rawValue]
            let rightWristConfidence = heatMaps[[PoseNetModel.Features.rightWrist.rawValue, yRightWrist, xRightWrist] as [NSNumber]].floatValue
            if rightWristConfidence > minConfidence {
                let yOffsetRightWrist = offsets[[PoseNetModel.Features.rightWrist.rawValue, yRightWrist, xRightWrist] as [NSNumber]].doubleValue
                let xOffsetRightWrist = offsets[[featureCount + PoseNetModel.Features.rightWrist.rawValue, yRightWrist, xRightWrist] as [NSNumber]].doubleValue

                DispatchQueue.main.async {
                    self.bodyPosePositionRatioDictionary[RightWristYSensor.tag] = 1.0 - (Double(yRightWrist) * PoseNetModel.stride + yOffsetRightWrist) / PoseNetModel.inputDimension
                    self.bodyPosePositionRatioDictionary[RightWristXSensor.tag] = (Double(xRightWrist) * PoseNetModel.stride + xOffsetRightWrist) / PoseNetModel.inputDimension
                }
            } else {
                DispatchQueue.main.async {
                    self.bodyPosePositionRatioDictionary.removeValue(forKey: RightWristYSensor.tag)
                    self.bodyPosePositionRatioDictionary.removeValue(forKey: RightWristXSensor.tag)
                }
            }

            let (yLeftHip, xLeftHip) = keyPointArray[PoseNetModel.Features.leftHip.rawValue]
            let leftHipConfidence = heatMaps[[PoseNetModel.Features.leftHip.rawValue, yLeftHip, xLeftHip] as [NSNumber]].floatValue
            if leftHipConfidence > minConfidence {
                let yOffsetLeftHip = offsets[[PoseNetModel.Features.leftHip.rawValue, yLeftHip, xLeftHip] as [NSNumber]].doubleValue
                let xOffsetLeftHip = offsets[[featureCount + PoseNetModel.Features.leftHip.rawValue, yLeftHip, xLeftHip] as [NSNumber]].doubleValue

                DispatchQueue.main.async {
                    self.bodyPosePositionRatioDictionary[LeftHipYSensor.tag] = 1.0 - (Double(yLeftHip) * PoseNetModel.stride + yOffsetLeftHip) / PoseNetModel.inputDimension
                    self.bodyPosePositionRatioDictionary[LeftHipXSensor.tag] = (Double(xLeftHip) * PoseNetModel.stride + xOffsetLeftHip) / PoseNetModel.inputDimension
                }
            } else {
                DispatchQueue.main.async {
                    self.bodyPosePositionRatioDictionary.removeValue(forKey: LeftHipYSensor.tag)
                    self.bodyPosePositionRatioDictionary.removeValue(forKey: LeftHipXSensor.tag)
                }
            }

            let (yRightHip, xRightHip) = keyPointArray[PoseNetModel.Features.rightHip.rawValue]
            let rightHipConfidence = heatMaps[[PoseNetModel.Features.rightHip.rawValue, yRightHip, xRightHip] as [NSNumber]].floatValue
            if rightHipConfidence > minConfidence {
                let yOffsetRightHip = offsets[[PoseNetModel.Features.rightHip.rawValue, yRightHip, xRightHip] as [NSNumber]].doubleValue
                let xOffsetRightHip = offsets[[featureCount + PoseNetModel.Features.rightHip.rawValue, yRightHip, xRightHip] as [NSNumber]].doubleValue

                DispatchQueue.main.async {
                    self.bodyPosePositionRatioDictionary[RightHipYSensor.tag] = 1.0 - (Double(yRightHip) * PoseNetModel.stride + yOffsetRightHip) / PoseNetModel.inputDimension
                    self.bodyPosePositionRatioDictionary[RightHipXSensor.tag] = (Double(xRightHip) * PoseNetModel.stride + xOffsetRightHip) / PoseNetModel.inputDimension
                }
            } else {
                DispatchQueue.main.async {
                    self.bodyPosePositionRatioDictionary.removeValue(forKey: RightHipYSensor.tag)
                    self.bodyPosePositionRatioDictionary.removeValue(forKey: RightHipXSensor.tag)
                }
            }

            let (yLeftKnee, xLeftKnee) = keyPointArray[PoseNetModel.Features.leftKnee.rawValue]
            let leftKneeConfidence = heatMaps[[PoseNetModel.Features.leftKnee.rawValue, yLeftKnee, xLeftKnee] as [NSNumber]].floatValue
            if leftKneeConfidence > minConfidence {
                let yOffsetLeftKnee = offsets[[PoseNetModel.Features.leftKnee.rawValue, yLeftKnee, xLeftKnee] as [NSNumber]].doubleValue
                let xOffsetLeftKnee = offsets[[featureCount + PoseNetModel.Features.leftKnee.rawValue, yLeftKnee, xLeftKnee] as [NSNumber]].doubleValue

                DispatchQueue.main.async {
                    self.bodyPosePositionRatioDictionary[LeftKneeYSensor.tag] = 1.0 - (Double(yLeftKnee) * PoseNetModel.stride + yOffsetLeftKnee) / PoseNetModel.inputDimension
                    self.bodyPosePositionRatioDictionary[LeftKneeXSensor.tag] = (Double(xLeftKnee) * PoseNetModel.stride + xOffsetLeftKnee) / PoseNetModel.inputDimension
                }
            } else {
                DispatchQueue.main.async {
                    self.bodyPosePositionRatioDictionary.removeValue(forKey: LeftKneeYSensor.tag)
                    self.bodyPosePositionRatioDictionary.removeValue(forKey: LeftKneeXSensor.tag)
                }
            }

            let (yRightKnee, xRightKnee) = keyPointArray[PoseNetModel.Features.rightKnee.rawValue]
            let rightKneeConfidence = heatMaps[[PoseNetModel.Features.rightKnee.rawValue, yRightKnee, xRightKnee] as [NSNumber]].floatValue
            if rightKneeConfidence > minConfidence {
                let yOffsetRightKnee = offsets[[PoseNetModel.Features.rightKnee.rawValue, yRightKnee, xRightKnee] as [NSNumber]].doubleValue
                let xOffsetRightKnee = offsets[[featureCount + PoseNetModel.Features.rightKnee.rawValue, yRightKnee, xRightKnee] as [NSNumber]].doubleValue

                DispatchQueue.main.async {
                    self.bodyPosePositionRatioDictionary[RightKneeYSensor.tag] = 1.0 - (Double(yRightKnee) * PoseNetModel.stride + yOffsetRightKnee) / PoseNetModel.inputDimension
                    self.bodyPosePositionRatioDictionary[RightKneeXSensor.tag] = (Double(xRightKnee) * PoseNetModel.stride + xOffsetRightKnee) / PoseNetModel.inputDimension
                }
            } else {
                DispatchQueue.main.async {
                    self.bodyPosePositionRatioDictionary.removeValue(forKey: RightKneeYSensor.tag)
                    self.bodyPosePositionRatioDictionary.removeValue(forKey: RightKneeXSensor.tag)
                }
            }

            let (yLeftAnkle, xLeftAnkle) = keyPointArray[PoseNetModel.Features.leftAnkle.rawValue]
            let leftAnkleConfidence = heatMaps[[PoseNetModel.Features.leftAnkle.rawValue, yLeftAnkle, xLeftAnkle] as [NSNumber]].floatValue
            if leftAnkleConfidence > minConfidence {
                let yOffsetLeftAnkle = offsets[[PoseNetModel.Features.leftAnkle.rawValue, yLeftAnkle, xLeftAnkle] as [NSNumber]].doubleValue
                let xOffsetLeftAnkle = offsets[[featureCount + PoseNetModel.Features.leftAnkle.rawValue, yLeftAnkle, xLeftAnkle] as [NSNumber]].doubleValue

                DispatchQueue.main.async {
                    self.bodyPosePositionRatioDictionary[LeftAnkleYSensor.tag] = 1.0 - (Double(yLeftAnkle) * PoseNetModel.stride + yOffsetLeftAnkle) / PoseNetModel.inputDimension
                    self.bodyPosePositionRatioDictionary[LeftAnkleXSensor.tag] = (Double(xLeftAnkle) * PoseNetModel.stride + xOffsetLeftAnkle) / PoseNetModel.inputDimension
                }
            } else {
                DispatchQueue.main.async {
                    self.bodyPosePositionRatioDictionary.removeValue(forKey: LeftAnkleYSensor.tag)
                    self.bodyPosePositionRatioDictionary.removeValue(forKey: LeftAnkleXSensor.tag)
                }
            }

            let (yRightAnkle, xRightAnkle) = keyPointArray[PoseNetModel.Features.rightAnkle.rawValue]
            let rightAnkleConfidence = heatMaps[[PoseNetModel.Features.rightAnkle.rawValue, yRightAnkle, xRightAnkle] as [NSNumber]].floatValue
            if rightAnkleConfidence > minConfidence {
                let yOffsetRightAnkle = offsets[[PoseNetModel.Features.rightAnkle.rawValue, yRightAnkle, xRightAnkle] as [NSNumber]].doubleValue
                let xOffsetRightAnkle = offsets[[featureCount + PoseNetModel.Features.rightAnkle.rawValue, yRightAnkle, xRightAnkle] as [NSNumber]].doubleValue

                DispatchQueue.main.async {
                    self.bodyPosePositionRatioDictionary[RightAnkleYSensor.tag] = 1.0 - (Double(yRightAnkle) * PoseNetModel.stride + yOffsetRightAnkle) / PoseNetModel.inputDimension
                    self.bodyPosePositionRatioDictionary[RightAnkleXSensor.tag] = (Double(xRightAnkle) * PoseNetModel.stride + xOffsetRightAnkle) / PoseNetModel.inputDimension
                }
            } else {
                DispatchQueue.main.async {
                    self.bodyPosePositionRatioDictionary.removeValue(forKey: RightAnkleYSensor.tag)
                    self.bodyPosePositionRatioDictionary.removeValue(forKey: RightAnkleXSensor.tag)
                }
            }
        }
    }
}
