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

@testable import Pocket_Code

final class VisualDetectionManagerMock: VisualDetectionManager {

    var isAvailable = true
    var isStarted = false

    override func start() {
        isStarted = true
    }

    override func stop() {
        isStarted = false
        self.faceDetectionEnabled = false
        self.handPoseDetectionEnabled = false
        self.bodyPoseDetectionEnabled = false
        self.textRecognitionEnabled = false
        self.objectRecognitionEnabled = false
    }

    override func available() -> Bool {
        isAvailable
    }

    func setAllEyeSensorValueRatios(to value: Double) {
        self.faceLandmarkPositionRatioDictionary[LeftEyeInnerXSensor.tag] = value
        self.faceLandmarkPositionRatioDictionary[LeftEyeInnerYSensor.tag] = value
        self.faceLandmarkPositionRatioDictionary[LeftEyeCenterXSensor.tag] = value
        self.faceLandmarkPositionRatioDictionary[LeftEyeCenterYSensor.tag] = value
        self.faceLandmarkPositionRatioDictionary[LeftEyeOuterXSensor.tag] = value
        self.faceLandmarkPositionRatioDictionary[LeftEyeOuterYSensor.tag] = value

        self.faceLandmarkPositionRatioDictionary[RightEyeInnerXSensor.tag] = value
        self.faceLandmarkPositionRatioDictionary[RightEyeInnerYSensor.tag] = value
        self.faceLandmarkPositionRatioDictionary[RightEyeCenterXSensor.tag] = value
        self.faceLandmarkPositionRatioDictionary[RightEyeCenterYSensor.tag] = value
        self.faceLandmarkPositionRatioDictionary[RightEyeOuterXSensor.tag] = value
        self.faceLandmarkPositionRatioDictionary[RightEyeOuterYSensor.tag] = value
    }

    func setAllEyebrowSensorValueRatios(to value: Double) {
        self.faceLandmarkPositionRatioDictionary[LeftEyebrowInnerXSensor.tag] = value
        self.faceLandmarkPositionRatioDictionary[LeftEyebrowInnerYSensor.tag] = value
        self.faceLandmarkPositionRatioDictionary[LeftEyebrowCenterXSensor.tag] = value
        self.faceLandmarkPositionRatioDictionary[LeftEyebrowCenterYSensor.tag] = value
        self.faceLandmarkPositionRatioDictionary[LeftEyebrowOuterXSensor.tag] = value
        self.faceLandmarkPositionRatioDictionary[LeftEyebrowOuterYSensor.tag] = value

        self.faceLandmarkPositionRatioDictionary[RightEyebrowInnerXSensor.tag] = value
        self.faceLandmarkPositionRatioDictionary[RightEyebrowInnerYSensor.tag] = value
        self.faceLandmarkPositionRatioDictionary[RightEyebrowCenterXSensor.tag] = value
        self.faceLandmarkPositionRatioDictionary[RightEyebrowCenterYSensor.tag] = value
        self.faceLandmarkPositionRatioDictionary[RightEyebrowOuterXSensor.tag] = value
        self.faceLandmarkPositionRatioDictionary[RightEyebrowOuterYSensor.tag] = value
    }

    func setAllEarSensorValueRatios(to value: Double) {
        self.faceLandmarkPositionRatioDictionary[LeftEarXSensor.tag] = value
        self.faceLandmarkPositionRatioDictionary[LeftEarYSensor.tag] = value
        self.faceLandmarkPositionRatioDictionary[RightEarXSensor.tag] = value
        self.faceLandmarkPositionRatioDictionary[RightEarYSensor.tag] = value
    }

    func setAllMouthSensorValueRatios(to value: Double) {
        self.faceLandmarkPositionRatioDictionary[MouthLeftCornerXSensor.tag] = value
        self.faceLandmarkPositionRatioDictionary[MouthLeftCornerYSensor.tag] = value
        self.faceLandmarkPositionRatioDictionary[MouthRightCornerXSensor.tag] = value
        self.faceLandmarkPositionRatioDictionary[MouthRightCornerYSensor.tag] = value
    }

    func setAllShoulderSensorValueRatios(to value: Double) {
        self.bodyPosePositionRatioDictionary[LeftShoulderXSensor.tag] = value
        self.bodyPosePositionRatioDictionary[LeftShoulderYSensor.tag] = value
        self.bodyPosePositionRatioDictionary[RightShoulderXSensor.tag] = value
        self.bodyPosePositionRatioDictionary[RightShoulderYSensor.tag] = value
    }

    func setAllElbowSensorValueRatios(to value: Double) {
        self.bodyPosePositionRatioDictionary[LeftElbowXSensor.tag] = value
        self.bodyPosePositionRatioDictionary[LeftElbowYSensor.tag] = value
        self.bodyPosePositionRatioDictionary[RightElbowXSensor.tag] = value
        self.bodyPosePositionRatioDictionary[RightElbowYSensor.tag] = value
    }

    func setAllWristSensorValueRatios(to value: Double) {
        self.bodyPosePositionRatioDictionary[LeftWristXSensor.tag] = value
        self.bodyPosePositionRatioDictionary[LeftWristYSensor.tag] = value
        self.bodyPosePositionRatioDictionary[RightWristXSensor.tag] = value
        self.bodyPosePositionRatioDictionary[RightWristYSensor.tag] = value
    }

    func setAllHipSensorValueRatios(to value: Double) {
        self.bodyPosePositionRatioDictionary[LeftHipXSensor.tag] = value
        self.bodyPosePositionRatioDictionary[LeftHipYSensor.tag] = value
        self.bodyPosePositionRatioDictionary[RightHipXSensor.tag] = value
        self.bodyPosePositionRatioDictionary[RightHipYSensor.tag] = value
    }

    func setAllKneeSensorValueRatios(to value: Double) {
        self.bodyPosePositionRatioDictionary[LeftKneeXSensor.tag] = value
        self.bodyPosePositionRatioDictionary[LeftKneeYSensor.tag] = value
        self.bodyPosePositionRatioDictionary[RightKneeXSensor.tag] = value
        self.bodyPosePositionRatioDictionary[RightKneeYSensor.tag] = value
    }

    func setAllAnkleSensorValueRatios(to value: Double) {
        self.bodyPosePositionRatioDictionary[LeftAnkleXSensor.tag] = value
        self.bodyPosePositionRatioDictionary[LeftAnkleYSensor.tag] = value
        self.bodyPosePositionRatioDictionary[RightAnkleXSensor.tag] = value
        self.bodyPosePositionRatioDictionary[RightAnkleYSensor.tag] = value
    }

    func setAllPinkySensorValueRatios(to value: Double) {
        self.handPosePositionRatioDictionary[LeftPinkyKnuckleXSensor.tag] = value
        self.handPosePositionRatioDictionary[LeftPinkyKnuckleYSensor.tag] = value
        self.handPosePositionRatioDictionary[RightPinkyKnuckleXSensor.tag] = value
        self.handPosePositionRatioDictionary[RightPinkyKnuckleYSensor.tag] = value
    }

    func setAllRingFingerSensorValueRatios(to value: Double) {
        self.handPosePositionRatioDictionary[LeftRingFingerKnuckleXSensor.tag] = value
        self.handPosePositionRatioDictionary[LeftRingFingerKnuckleYSensor.tag] = value
        self.handPosePositionRatioDictionary[RightRingFingerKnuckleXSensor.tag] = value
        self.handPosePositionRatioDictionary[RightRingFingerKnuckleYSensor.tag] = value
    }

    func setAllMiddleFingerSensorValueRatios(to value: Double) {
        self.handPosePositionRatioDictionary[LeftMiddleFingerKnuckleXSensor.tag] = value
        self.handPosePositionRatioDictionary[LeftMiddleFingerKnuckleYSensor.tag] = value
        self.handPosePositionRatioDictionary[RightMiddleFingerKnuckleXSensor.tag] = value
        self.handPosePositionRatioDictionary[RightMiddleFingerKnuckleYSensor.tag] = value
    }

    func setAllIndexSensorValueRatios(to value: Double) {
        self.handPosePositionRatioDictionary[LeftIndexKnuckleXSensor.tag] = value
        self.handPosePositionRatioDictionary[LeftIndexKnuckleYSensor.tag] = value
        self.handPosePositionRatioDictionary[RightIndexKnuckleXSensor.tag] = value
        self.handPosePositionRatioDictionary[RightIndexKnuckleYSensor.tag] = value
    }

    func setAllThumbSensorValueRatios(to value: Double) {
        self.handPosePositionRatioDictionary[LeftThumbKnuckleXSensor.tag] = value
        self.handPosePositionRatioDictionary[LeftThumbKnuckleYSensor.tag] = value
        self.handPosePositionRatioDictionary[RightThumbKnuckleXSensor.tag] = value
        self.handPosePositionRatioDictionary[RightThumbKnuckleYSensor.tag] = value
    }

    func setTextBlockPositionRecognized(at position: CGPoint, withSizeRatio sizeRatio: Double) {
        self.textBlockPosition.append(position)
        self.textBlockSizeRatio.append(sizeRatio)
    }

    func setTextBlockTextRecognized(text: String, language: String) {
        self.textBlockFromCamera.append(text)
        self.textBlockLanguageCode.append(language)
        if self.textFromCamera != nil && self.textBlocksNumber != nil {
            self.textFromCamera!.append(" " + text)
            self.textBlocksNumber! += 1
        } else {
            self.textFromCamera = text
            self.textBlocksNumber = 1
        }
    }

    func addRecognizedObject(label: String, boundingBox: CGRect) {
        self.objectRecognitions.append(VNRecognizedObjectObservationMock(labelMock: label, boundingBoxMock: boundingBox))
    }
}
