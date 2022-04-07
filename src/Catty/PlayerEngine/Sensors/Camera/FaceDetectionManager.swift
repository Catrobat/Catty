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

class FaceDetectionManager: NSObject, FaceDetectionManagerProtocol, AVCaptureVideoDataOutputSampleBufferDelegate {

    static let maxFaceCount = 2

    var isFaceDetected = [false, false]
    var facePositionRatioFromLeft: [Double?] = [nil, nil]
    var facePositionRatioFromBottom: [Double?] = [nil, nil]
    var faceSizeRatio: [Double?] = [nil, nil]
    var faceDetectionFrameSize: CGSize?

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
        self.facePositionRatioFromLeft = [nil, nil]
        self.facePositionRatioFromBottom = [nil, nil]
        self.faceSizeRatio = [nil, nil]
        self.faceDetectionFrameSize = nil
        self.previousFaceObservations = nil
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
        self.faceDetectionFrameSize = imageSize

        if connection.isVideoOrientationSupported {
            connection.videoOrientation = .portrait
        }

        var orientation = CGImagePropertyOrientation.up
        if cameraPosition() == .front {
            orientation = .upMirrored
        }

        let faceDetectionRequest = VNDetectFaceRectanglesRequest { request, _ in
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
        guard !faceObservations.isEmpty else {
            reset()
            return
        }

        var currentFaceObservations = faceObservations
        var isFaceDetected = [false, false]
        let facesDetected = min(currentFaceObservations.count, FaceDetectionManager.maxFaceCount)

        if previousFaceObservations == nil {
            previousFaceObservations = Array(currentFaceObservations[..<facesDetected])
        } else {
            for previousFaceIndex in 0..<FaceDetectionManager.maxFaceCount {
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
            self.facePositionRatioFromLeft[faceIndex] = faceObservation.boundingBox.origin.x + faceObservation.boundingBox.width / 2
            self.facePositionRatioFromBottom[faceIndex] = faceObservation.boundingBox.origin.y + faceObservation.boundingBox.height / 2
            self.faceSizeRatio[faceIndex] = max(faceObservation.boundingBox.width, faceObservation.boundingBox.height)
            isFaceDetected[faceIndex] = true
        }
        self.isFaceDetected = isFaceDetected
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
