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
import Vision

class VisualDetectionManager: NSObject, VisualDetectionManagerProtocol, AVCaptureVideoDataOutputSampleBufferDelegate {

    static let maxFaceCount = 2

    var isFaceDetected = [false, false]
    var facePositionXRatio: [Double?] = [nil, nil]
    var facePositionYRatio: [Double?] = [nil, nil]
    var faceSizeRatio: [Double?] = [nil, nil]
    var visualDetectionFrameSize: CGSize?
    var faceLandmarkPositionRatioDictionary: [String: Double] = [:]

    private var session: AVCaptureSession?
    private var videoDataOuput: AVCaptureVideoDataOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?

    var previousFaceObservations: [VNFaceObservation]?

    func start() {
        self.reset()

        self.session = CameraPreviewHandler.shared().getSession()

        guard let session = self.session,
            let device = camera(for: cameraPosition()),
            let deviceInput = try? AVCaptureDeviceInput(device: device)
            else { return }

        if session.isRunning {
            session.stopRunning()
        }

        if session.canAddInput(deviceInput) {
            session.addInput(deviceInput)
        }

        let videoDataOuput = AVCaptureVideoDataOutput()
        videoDataOuput.videoSettings = [ kCVPixelBufferPixelFormatTypeKey: kCMPixelFormat_32BGRA ] as [String: Any]
        videoDataOuput.alwaysDiscardsLateVideoFrames = true

        // create a serial dispatch queue used for the sample buffer delegate
        // a serial dispatch queue must be used to guarantee that video frames will be delivered in order
        // see the header doc for setSampleBufferDelegate:queue: for more information
        let serialQueue = DispatchQueue(label: "VideoDataOutputQueue")
        videoDataOuput.setSampleBufferDelegate(self, queue: serialQueue)

        if session.canAddOutput(videoDataOuput) {
            self.session?.addOutput(videoDataOuput)
        }

        let videoDataOutputConnection = videoDataOuput.connection(with: .video)
        videoDataOutputConnection?.isEnabled = true
        self.videoDataOuput = videoDataOuput

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.backgroundColor = UIColor.black.cgColor
        previewLayer.videoGravity = .resizeAspect
        previewLayer.isHidden = true
        self.previewLayer = previewLayer

        DispatchQueue.main.async {
            session.startRunning()
        }
    }

    func stop() {
        self.reset()

        if let inputs = self.session?.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                self.session?.removeInput(input)
            }
        }
        if let outputs = self.session?.outputs as? [AVCaptureVideoDataOutput] {
            for output in outputs {
                self.session?.removeOutput(output)
            }
        }

        self.session?.stopRunning()
        self.session = nil
        self.videoDataOuput?.connection(with: .video)?.isEnabled = false
        self.videoDataOuput = nil
        self.previewLayer?.removeFromSuperlayer()
        self.previewLayer = nil
    }

    func reset() {
        self.isFaceDetected = [false, false]
        self.facePositionXRatio = [nil, nil]
        self.facePositionYRatio = [nil, nil]
        self.faceSizeRatio = [nil, nil]
        self.visualDetectionFrameSize = nil
        self.previousFaceObservations = nil
        self.faceLandmarkPositionRatioDictionary.removeAll()
    }

    func available() -> Bool {
        guard let _ = CameraPreviewHandler.shared().getSession(),
            let device = camera(for: cameraPosition()),
            let _ = try? AVCaptureDeviceInput(device: device) else { return false }

        return true
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let imageSize = CGSize(width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
        DispatchQueue.main.async {
            self.visualDetectionFrameSize = imageSize
        }

        if connection.isVideoOrientationSupported {
            connection.videoOrientation = .portrait
        }

        var orientation = CGImagePropertyOrientation.up
        if cameraPosition() == .front {
            orientation = .upMirrored
        }

        let faceDetectionRequest = VNDetectFaceLandmarksRequest { request, _ in
            if let faceObservations = request.results as? [VNFaceObservation] {
                DispatchQueue.main.async {
                    self.handleDetectedFaceObservations(faceObservations)
                }
            }
        }

        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: orientation, options: [:])

        do {
            try imageRequestHandler.perform([faceDetectionRequest])
        } catch let error as NSError {
            print(error)
        }
    }

    func handleDetectedFaceObservations(_ faceObservations: [VNFaceObservation]) {
        guard self.visualDetectionFrameSize != nil && !faceObservations.isEmpty  else {
            reset()
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
        self.faceLandmarkPositionRatioDictionary[NoseXSensor.tag] = nose.pointsInImage(imageSize: self.visualDetectionFrameSize!)[nose.pointCount / 2].x / self.visualDetectionFrameSize!.width
        self.faceLandmarkPositionRatioDictionary[NoseYSensor.tag] = nose.pointsInImage(imageSize: self.visualDetectionFrameSize!)[nose.pointCount / 2].y / self.visualDetectionFrameSize!.height
    }

    func handleEyeLandmark(_ eye: VNFaceLandmarkRegion2D, isLeft: Bool) {
        if isLeft {
            self.faceLandmarkPositionRatioDictionary[LeftEyeInnerXSensor.tag] =
                eye.pointsInImage(imageSize: self.visualDetectionFrameSize!)[eye.pointCount / 2].x / self.visualDetectionFrameSize!.width
            self.faceLandmarkPositionRatioDictionary[LeftEyeInnerYSensor.tag] =
                eye.pointsInImage(imageSize: self.visualDetectionFrameSize!)[eye.pointCount / 2].y / self.visualDetectionFrameSize!.height

            self.faceLandmarkPositionRatioDictionary[LeftEyeOuterXSensor.tag] =
                eye.pointsInImage(imageSize: self.visualDetectionFrameSize!)[0].x / self.visualDetectionFrameSize!.width
            self.faceLandmarkPositionRatioDictionary[LeftEyeOuterYSensor.tag] =
                eye.pointsInImage(imageSize: self.visualDetectionFrameSize!)[0].y / self.visualDetectionFrameSize!.height
        } else {
            self.faceLandmarkPositionRatioDictionary[RightEyeInnerXSensor.tag] =
                eye.pointsInImage(imageSize: self.visualDetectionFrameSize!)[eye.pointCount / 2].x / self.visualDetectionFrameSize!.width
            self.faceLandmarkPositionRatioDictionary[RightEyeInnerYSensor.tag] =
                eye.pointsInImage(imageSize: self.visualDetectionFrameSize!)[eye.pointCount / 2].y / self.visualDetectionFrameSize!.height

            self.faceLandmarkPositionRatioDictionary[RightEyeOuterXSensor.tag] = eye.pointsInImage(imageSize: self.visualDetectionFrameSize!)[0].x / self.visualDetectionFrameSize!.width
            self.faceLandmarkPositionRatioDictionary[RightEyeOuterYSensor.tag] = eye.pointsInImage(imageSize: self.visualDetectionFrameSize!)[0].y / self.visualDetectionFrameSize!.height
        }
    }

    func handlePupilLandmark(_ pupil: VNFaceLandmarkRegion2D, isLeft: Bool) {
        if isLeft {
            self.faceLandmarkPositionRatioDictionary[LeftEyeCenterXSensor.tag] = pupil.pointsInImage(imageSize: self.visualDetectionFrameSize!)[0].x / self.visualDetectionFrameSize!.width
            self.faceLandmarkPositionRatioDictionary[LeftEyeCenterYSensor.tag] = pupil.pointsInImage(imageSize: self.visualDetectionFrameSize!)[0].y / self.visualDetectionFrameSize!.height
        } else {
            self.faceLandmarkPositionRatioDictionary[RightEyeCenterXSensor.tag] = pupil.pointsInImage(imageSize: self.visualDetectionFrameSize!)[0].x / self.visualDetectionFrameSize!.width
            self.faceLandmarkPositionRatioDictionary[RightEyeCenterYSensor.tag] = pupil.pointsInImage(imageSize: self.visualDetectionFrameSize!)[0].y / self.visualDetectionFrameSize!.height
        }
    }

    func handleFaceContourLandmark(_ faceContour: VNFaceLandmarkRegion2D, faceBoundingBox: CGRect) {
        self.faceLandmarkPositionRatioDictionary[LeftEarXSensor.tag] =
            faceContour.pointsInImage(imageSize: self.visualDetectionFrameSize!)[faceContour.pointCount - 2].x / self.visualDetectionFrameSize!.width
        self.faceLandmarkPositionRatioDictionary[LeftEarYSensor.tag] =
            faceContour.pointsInImage(imageSize: self.visualDetectionFrameSize!)[faceContour.pointCount - 2].y / self.visualDetectionFrameSize!.height

        self.faceLandmarkPositionRatioDictionary[RightEarXSensor.tag] =
            faceContour.pointsInImage(imageSize: self.visualDetectionFrameSize!)[1].x / self.visualDetectionFrameSize!.width
        self.faceLandmarkPositionRatioDictionary[RightEarYSensor.tag] =
            faceContour.pointsInImage(imageSize: self.visualDetectionFrameSize!)[1].y / self.visualDetectionFrameSize!.height

        calculateHeadTop()
    }

    func handleOuterLipsLandmark(_ outerLips: VNFaceLandmarkRegion2D) {
        self.faceLandmarkPositionRatioDictionary[MouthLeftCornerXSensor.tag] = outerLips.pointsInImage(imageSize: self.visualDetectionFrameSize!)[0].x / self.visualDetectionFrameSize!.width
        self.faceLandmarkPositionRatioDictionary[MouthLeftCornerYSensor.tag] = outerLips.pointsInImage(imageSize: self.visualDetectionFrameSize!)[0].y / self.visualDetectionFrameSize!.height

        self.faceLandmarkPositionRatioDictionary[MouthRightCornerXSensor.tag] =
            outerLips.pointsInImage(imageSize: self.visualDetectionFrameSize!)[outerLips.pointCount / 2].x / self.visualDetectionFrameSize!.width
        self.faceLandmarkPositionRatioDictionary[MouthRightCornerYSensor.tag] =
            outerLips.pointsInImage(imageSize: self.visualDetectionFrameSize!)[outerLips.pointCount / 2].y / self.visualDetectionFrameSize!.height
    }

    func handleEyebrowLandmark(_ eyebrow: VNFaceLandmarkRegion2D, isLeft: Bool) {
        if isLeft {
            self.faceLandmarkPositionRatioDictionary[LeftEyebrowInnerXSensor.tag] =
                eyebrow.pointsInImage(imageSize: self.visualDetectionFrameSize!)[eyebrow.pointCount / 2].x / self.visualDetectionFrameSize!.width
            self.faceLandmarkPositionRatioDictionary[LeftEyebrowInnerYSensor.tag] =
                eyebrow.pointsInImage(imageSize: self.visualDetectionFrameSize!)[eyebrow.pointCount / 2].y / self.visualDetectionFrameSize!.height

            self.faceLandmarkPositionRatioDictionary[LeftEyebrowCenterXSensor.tag] =
                eyebrow.pointsInImage(imageSize: self.visualDetectionFrameSize!)[eyebrow.pointCount / 4].x / self.visualDetectionFrameSize!.width
            self.faceLandmarkPositionRatioDictionary[LeftEyebrowCenterYSensor.tag] =
                eyebrow.pointsInImage(imageSize: self.visualDetectionFrameSize!)[eyebrow.pointCount / 4].y / self.visualDetectionFrameSize!.height

            self.faceLandmarkPositionRatioDictionary[LeftEyebrowOuterXSensor.tag] = eyebrow.pointsInImage(imageSize: self.visualDetectionFrameSize!)[0].x / self.visualDetectionFrameSize!.width
            self.faceLandmarkPositionRatioDictionary[LeftEyebrowOuterYSensor.tag] = eyebrow.pointsInImage(imageSize: self.visualDetectionFrameSize!)[0].y / self.visualDetectionFrameSize!.height
        } else {
            self.faceLandmarkPositionRatioDictionary[RightEyebrowInnerXSensor.tag] =
                eyebrow.pointsInImage(imageSize: self.visualDetectionFrameSize!)[eyebrow.pointCount / 2].x / self.visualDetectionFrameSize!.width
            self.faceLandmarkPositionRatioDictionary[RightEyebrowInnerYSensor.tag] =
                eyebrow.pointsInImage(imageSize: self.visualDetectionFrameSize!)[eyebrow.pointCount / 2].y / self.visualDetectionFrameSize!.height

            self.faceLandmarkPositionRatioDictionary[RightEyebrowCenterXSensor.tag] =
                eyebrow.pointsInImage(imageSize: self.visualDetectionFrameSize!)[eyebrow.pointCount / 4].x / self.visualDetectionFrameSize!.width
            self.faceLandmarkPositionRatioDictionary[RightEyebrowCenterYSensor.tag] =
                eyebrow.pointsInImage(imageSize: self.visualDetectionFrameSize!)[eyebrow.pointCount / 4].y / self.visualDetectionFrameSize!.height

            self.faceLandmarkPositionRatioDictionary[RightEyebrowOuterXSensor.tag] = eyebrow.pointsInImage(imageSize: self.visualDetectionFrameSize!)[0].x / self.visualDetectionFrameSize!.width
            self.faceLandmarkPositionRatioDictionary[RightEyebrowOuterYSensor.tag] = eyebrow.pointsInImage(imageSize: self.visualDetectionFrameSize!)[0].y / self.visualDetectionFrameSize!.height
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

    func cameraPosition() -> AVCaptureDevice.Position {
        (CameraPreviewHandler.shared()?.getCameraPosition())!
    }

    private func camera(for cameraPosition: AVCaptureDevice.Position) -> AVCaptureDevice? {
        for device in AVCaptureDevice.DiscoverySession.init(deviceTypes: [SpriteKitDefines.avCaptureDeviceType], mediaType: .video, position: cameraPosition).devices {
            return device
        }
        return nil
    }
}
