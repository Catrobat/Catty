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

protocol VisualDetectionManagerProtocol {

    var isFaceDetected: [Bool] { get }
    var facePositionXRatio: [Double?] { get }
    var facePositionYRatio: [Double?] { get }
    var faceSizeRatio: [Double?] { get }
    var visualDetectionFrameSize: CGSize? { get }
    var faceLandmarkPositionRatioDictionary: [String: Double] { get }
    var bodyPosePositionRatioDictionary: [String: Double] { get }
    var handPosePositionRatioDictionary: [String: Double] { get }
    var textFromCamera: String? { get }
    var textBlocksNumber: Int? { get }
    var textBlockPosition: [CGPoint] { get }
    var textBlockSizeRatio: [Double] { get }
    var textBlockFromCamera: [String] { get }
    var textBlockLanguageCode: [String] { get }

    func start()
    func startFaceDetection()
    func startHandPoseDetection()
    func startBodyPoseDetection()
    func startTextRecognition()

    func stop()

    func reset()
    func resetFaceDetection()
    func resetBodyPoses()

    func available() -> Bool
}
