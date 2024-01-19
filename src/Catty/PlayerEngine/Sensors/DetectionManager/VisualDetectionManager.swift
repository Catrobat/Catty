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

class VisualDetectionManager: NSObject, VisualDetectionManagerProtocol, AVCaptureVideoDataOutputSampleBufferDelegate {

    static let maxFaceCount = 2
    static let maxHandCount = 2
    static let undefinedLanguage = "und"

    var isFaceDetected = [false, false]
    var facePositionXRatio: [Double?] = [nil, nil]
    var facePositionYRatio: [Double?] = [nil, nil]
    var faceSizeRatio: [Double?] = [nil, nil]
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

    let minConfidence: Float = 0.3

    private var session: AVCaptureSession?
    private var videoDataOuput: AVCaptureVideoDataOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?

    private var objectRecognitionModel: VNCoreMLModel?
    private var bodyPoseDetectionModel: VNCoreMLModel?
    private var stage: Stage?
    var normalizedSize = CGSize(width: 1.0, height: 1.0)

    var faceDetectionEnabled = false
    var handPoseDetectionEnabled = false
    var bodyPoseDetectionEnabled = false
    var textRecognitionEnabled = false
    var objectRecognitionEnabled = false

    var previousFaceObservations: [VNFaceObservation]?

    func setStage(_ stage: Stage?) {
        self.stage = stage
    }

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
        if let videoDataOutputConnection = videoDataOutputConnection {
            videoDataOutputConnection.isEnabled = true
            if videoDataOutputConnection.isVideoOrientationSupported {
                if Project.lastUsed().header.landscapeMode {
                    videoDataOutputConnection.videoOrientation = .landscapeRight
                } else {
                    videoDataOutputConnection.videoOrientation = .portrait
                }
            }
        }
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
                    print("Could not load object detection model!")
                }
            }
        }

        if #unavailable(iOS 14.0) {
            if bodyPoseDetectionEnabled {
                if let bodyPoseDetectionModelURL = Bundle.main.url(forResource: "PoseNet", withExtension: "mlmodelc") {
                    do {
                        bodyPoseDetectionModel = try VNCoreMLModel(for: MLModel(contentsOf: bodyPoseDetectionModelURL))
                    } catch {
                        print("Could not load pose detection model!")
                    }
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

    func cropVideoBuffer(inputBuffer: CVPixelBuffer, isLandscape: Bool) -> CVPixelBuffer {
        CVPixelBufferLockBaseAddress(inputBuffer, .readOnly)
        guard let baseAddress = CVPixelBufferGetBaseAddress(inputBuffer) else { return inputBuffer }
        let baseAddressStart = baseAddress.assumingMemoryBound(to: UInt8.self)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(inputBuffer)
        let pixelFormat = CVPixelBufferGetPixelFormatType(inputBuffer)
        let pixelBufferWidth = CGFloat(CVPixelBufferGetWidth(inputBuffer))
        let pixelBufferHeight = CGFloat(CVPixelBufferGetHeight(inputBuffer))
        guard let stageWidth = self.stage?.frame.width else { return inputBuffer }
        guard let stageHeight = self.stage?.frame.height else { return inputBuffer }
        var newBuffer: CVPixelBuffer!
        var croppedWidth = pixelBufferWidth
        var croppedHeight = pixelBufferHeight
        var cropX = 0
        var cropY = 0

        if isLandscape {
            croppedHeight = pixelBufferWidth / stageWidth * pixelBufferHeight

            cropY = Int((pixelBufferHeight - CGFloat(croppedHeight)) / 2.0)
        } else {
            croppedWidth = pixelBufferHeight / stageHeight * pixelBufferWidth

            cropX = Int((pixelBufferWidth - CGFloat(croppedWidth)) / 2.0)
            if cropX % 2 != 0 {
                cropX += 1
            }
        }

        let cropStartOffset = Int(CGFloat(cropX) * (CGFloat(bytesPerRow) / pixelBufferWidth) + CGFloat(cropY) * CGFloat(bytesPerRow))

        let options = [
          kCVPixelBufferCGImageCompatibilityKey: true,
          kCVPixelBufferCGBitmapContextCompatibilityKey: true,
          kCVPixelBufferWidthKey: croppedWidth,
          kCVPixelBufferHeightKey: croppedHeight
        ] as [CFString: Any]

        CVPixelBufferCreateWithBytes(kCFAllocatorDefault,
                                     Int(croppedWidth),
                                     Int(croppedHeight),
                                     pixelFormat,
                                     &baseAddressStart[cropStartOffset],
                                     Int(bytesPerRow),
                                     nil,
                                     nil,
                                     options as CFDictionary,
                                     &newBuffer)

        CVPixelBufferUnlockBaseAddress(inputBuffer, .readOnly)
        return newBuffer
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let isLandscape = Project.lastUsed().header.landscapeMode
        if connection.isVideoOrientationSupported && !isLandscape && connection.videoOrientation != .portrait {
            connection.videoOrientation = .portrait
            return
        }

        if connection.isVideoOrientationSupported && isLandscape && connection.videoOrientation != .landscapeRight {
            connection.videoOrientation = .landscapeRight
            return
        }

        let newBuffer = self.cropVideoBuffer(inputBuffer: pixelBuffer, isLandscape: isLandscape)

        var orientation = CGImagePropertyOrientation.up
        if cameraPosition() == .front {
            orientation = .upMirrored
        }

        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: newBuffer, orientation: orientation, options: [:])
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

        if bodyPoseDetectionEnabled {
            if #available(iOS 14.0, *) {
                let humanBodyPoseRequest = VNDetectHumanBodyPoseRequest { request, _ in
                    if let bodyPoseObservation = request.results as? [VNHumanBodyPoseObservation] {
                        DispatchQueue.main.async {
                            self.handleHumanBodyPoseObservations(bodyPoseObservation)
                        }
                    }
                }
                detectionRequests.append(humanBodyPoseRequest)
            } else {
                if let bodyPoseDetectionModel = bodyPoseDetectionModel {
                    let bodyPoseDetectionRequest = VNCoreMLRequest(model: bodyPoseDetectionModel) { request, _ in
                        if let bodyPoseObservations = request.results as? [VNCoreMLFeatureValueObservation] {
                            self.handleHumanBodyPoseObservations(bodyPoseObservations)
                        }
                    }
                    bodyPoseDetectionRequest.imageCropAndScaleOption = .scaleFill
                    detectionRequests.append(bodyPoseDetectionRequest)
                }
            }
        }

        if #available(iOS 14.0, *) {
            if handPoseDetectionEnabled {
                let humanHandPoseRequest = VNDetectHumanHandPoseRequest { request, _ in
                    if let handPoseObservations = request.results as? [VNHumanHandPoseObservation] {
                        DispatchQueue.main.async {
                            self.handleHumanHandPoseObservations(handPoseObservations)
                        }
                    }
                }
                humanHandPoseRequest.maximumHandCount = VisualDetectionManager.maxHandCount
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

    func cameraPosition() -> AVCaptureDevice.Position {
        (CameraPreviewHandler.shared()?.getCameraPosition())!
    }

    private func camera(for cameraPosition: AVCaptureDevice.Position) -> AVCaptureDevice? {
        AVCaptureDevice.DiscoverySession.init(deviceTypes: [SpriteKitDefines.avCaptureDeviceType], mediaType: .video, position: cameraPosition).devices.first
    }
}
