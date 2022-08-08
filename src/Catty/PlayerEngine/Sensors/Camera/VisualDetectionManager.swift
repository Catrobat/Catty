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
import NaturalLanguage
import Vision

class VisualDetectionManager: NSObject, VisualDetectionManagerProtocol, AVCaptureVideoDataOutputSampleBufferDelegate {

    static let maxFaceCount = 2
    static let maxHandCount = 2
    static let undefinedLanguage = "und"

    var isFaceDetected = [false, false]
    var facePositionXRatio: [Double?] = [nil, nil]
    var facePositionYRatio: [Double?] = [nil, nil]
    var faceSizeRatio: [Double?] = [nil, nil]
    var visualDetectionFrameSize: CGSize?
    var faceLandmarkPositionRatioDictionary: [String: Double] = [:]
    var bodyPosePositionRatioDictionary: [String: Double] = [:]
    var handPosePositionRatioDictionary: [String: Double] = [:]
    var textFromCamera: String?
    var textBlocksNumber: Int?
    var textBlockPosition: [CGPoint] = []
    var textBlockSizeRatio: [Double] = []
    var textBlockFromCamera: [String] = []
    var textBlockLanguageCode: [String] = []
    var objectRecognitions: [VNRecognizedObjectObservation] = []

    let minConfidence: Float = 0.5

    private var session: AVCaptureSession?
    private var videoDataOuput: AVCaptureVideoDataOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?

    private var objectRecognitionModel: VNCoreMLModel?

    var faceDetectionEnabled = false
    var handPoseDetectionEnabled = false
    var bodyPoseDetectionEnabled = false
    var textRecognitionEnabled = false
    var objectRecognitionEnabled = false

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

        if objectRecognitionEnabled {
            if let objectRecognitionModelURL = Bundle.main.url(forResource: "YOLOv3Tiny", withExtension: "mlmodelc") {
                do {
                    objectRecognitionModel = try VNCoreMLModel(for: MLModel(contentsOf: objectRecognitionModelURL))
                } catch {
                    NSLog("Could not load object detection model!")
                }
            }
        }

        DispatchQueue.main.async {
            session.startRunning()
        }
    }

    func startFaceDetection() {
        self.faceDetectionEnabled = true
    }

    func startHandPoseDetection() {
        self.handPoseDetectionEnabled = true
    }

    func startBodyPoseDetection() {
        self.bodyPoseDetectionEnabled = true
    }

    func startTextRecognition() {
        self.textRecognitionEnabled = true
    }

    func startObjectRecognition() {
        self.objectRecognitionEnabled = true
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

        self.faceDetectionEnabled = false
        self.handPoseDetectionEnabled = false
        self.bodyPoseDetectionEnabled = false
        self.textRecognitionEnabled = false
        self.objectRecognitionEnabled = false
    }

    func reset() {
        self.resetFaceDetection()
        self.resetBodyPoses()
        self.resetHandPoses()
        self.resetTextRecogntion()
        self.resetObjectRecognition()
        self.visualDetectionFrameSize = nil
    }

    func resetFaceDetection() {
        self.isFaceDetected = [false, false]
        self.facePositionXRatio = [nil, nil]
        self.facePositionYRatio = [nil, nil]
        self.faceSizeRatio = [nil, nil]
        self.previousFaceObservations = nil
        self.faceLandmarkPositionRatioDictionary.removeAll()
    }

    func resetBodyPoses() {
        self.bodyPosePositionRatioDictionary.removeAll()
    }

    func resetHandPoses() {
        self.handPosePositionRatioDictionary.removeAll()
    }

    func resetTextRecogntion() {
        self.textFromCamera = nil
        self.textBlocksNumber = nil
        self.textBlockPosition.removeAll()
        self.textBlockSizeRatio.removeAll()
        self.textBlockFromCamera.removeAll()
        self.textBlockLanguageCode.removeAll()
    }

    func resetObjectRecognition() {
        self.objectRecognitions.removeAll()
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

        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: orientation, options: [:])
        var detectionRequests: [VNRequest] = []

        if faceDetectionEnabled {
            let faceDetectionRequest = VNDetectFaceLandmarksRequest { request, _ in
                if let faceObservations = request.results as? [VNFaceObservation] {
                    DispatchQueue.main.async {
                        self.handleDetectedFaceObservations(faceObservations)
                    }
                }
            }
            detectionRequests.append(faceDetectionRequest)
        }

        if #available(iOS 13.0, *) {
            if textRecognitionEnabled {
                let textDetectionRequest = VNRecognizeTextRequest { request, _ in
                    if let textObservations = request.results as? [VNRecognizedTextObservation] {
                        DispatchQueue.main.async {
                            self.handleTextObservations(textObservations)
                        }
                    }
                }
                detectionRequests.append(textDetectionRequest)
            }
        }

        if #available(iOS 14.0, *) {
            if bodyPoseDetectionEnabled {
                let humanBodyPoseRequest = VNDetectHumanBodyPoseRequest { request, _ in
                    if let bodyPoseObservation = request.results as? [VNHumanBodyPoseObservation] {
                        DispatchQueue.main.async {
                            self.handleHumanBodyPoseObservations(bodyPoseObservation)
                        }
                    }
                }
                detectionRequests.append(humanBodyPoseRequest)
            }
            if handPoseDetectionEnabled {
                let humanHandPoseRequest = VNDetectHumanHandPoseRequest { request, _ in
                    if let handPoseObservations = request.results as? [VNHumanHandPoseObservation] {
                        DispatchQueue.main.async {
                            self.handleHumanHandPoseObservations(handPoseObservations)
                        }
                    }
                }
                detectionRequests.append(humanHandPoseRequest)
            }
        }

        if objectRecognitionEnabled {
            if let objectRecognitionModel = objectRecognitionModel {
                let objectRecognitionRequest = VNCoreMLRequest(model: objectRecognitionModel) { request, _ in
                    if let objectObservations = request.results as? [VNRecognizedObjectObservation] {
                        DispatchQueue.main.async {
                            self.handleDetectedObjectObservations(objectObservations)
                        }
                    }
                }
                detectionRequests.append(objectRecognitionRequest)
            }
        }

        do {
            try imageRequestHandler.perform(detectionRequests)
        } catch let error as NSError {
            print(error)
        }
    }

    func handleDetectedFaceObservations(_ faceObservations: [VNFaceObservation]) {
        guard self.visualDetectionFrameSize != nil && !faceObservations.isEmpty  else {
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

    @available(iOS 13.0, *)
    func handleTextObservations(_ textObservations: [VNRecognizedTextObservation]) {
        guard self.visualDetectionFrameSize != nil && !textObservations.isEmpty  else {
            resetTextRecogntion()
            return
        }

        let topCanditateTextObservations = textObservations.filter({ $0.topCandidates(1).first != nil && $0.topCandidates(1).first!.string.isNotEmpty })

        textBlocksNumber = topCanditateTextObservations.count
        textBlockPosition = topCanditateTextObservations.map({ CGPoint(x: $0.boundingBox.origin.x + $0.boundingBox.width / 2,
                                                                       y: $0.boundingBox.origin.y + $0.boundingBox.height / 2) })
        textBlockSizeRatio = topCanditateTextObservations.map({ max($0.boundingBox.width, $0.boundingBox.height) })

        textBlockFromCamera = topCanditateTextObservations.map({ $0.topCandidates(1).first!.string })
        textFromCamera = textBlockFromCamera.joined(separator: " ")

        textBlockLanguageCode = textBlockFromCamera.map({ detectedLanguage(for: $0) ?? VisualDetectionManager.undefinedLanguage })
    }

    func detectedLanguage(for string: String) -> String? {
        let recognizer = NLLanguageRecognizer()
        recognizer.languageConstraints = [NLLanguage.english, NLLanguage.french, NLLanguage.italian, NLLanguage.german,
                                          NLLanguage.spanish, NLLanguage.portuguese, NLLanguage.simplifiedChinese, NLLanguage.traditionalChinese]
        recognizer.processString(string)
        guard let languageCode = recognizer.dominantLanguage?.rawValue else { return nil }
        return languageCode
    }

    @available(iOS 14.0, *)
    func handleHumanBodyPoseObservations(_ bodyPoseObservations: [VNHumanBodyPoseObservation]) {
        guard self.visualDetectionFrameSize != nil && !bodyPoseObservations.isEmpty, let bodyPoseObservation = bodyPoseObservations.first else {
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

    @available(iOS 14.0, *)
    func handleHumanHandPoseObservations(_ handPoseObservations: [VNHumanHandPoseObservation]) {
        guard self.visualDetectionFrameSize != nil && !handPoseObservations.isEmpty else {
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

    @available(iOS 14.0, *)
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

    func handleDetectedObjectObservations(_ objectObservations: [VNRecognizedObjectObservation]) {
        resetObjectRecognition()
        self.objectRecognitions.append(contentsOf: objectObservations.filter { $0.confidence > minConfidence })
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
