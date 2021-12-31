/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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

class FaceDetectionManager: NSObject, FaceDetectionManagerProtocol, AVCaptureVideoDataOutputSampleBufferDelegate {

    var isFaceDetected = false
    var facePositionRatioFromLeft: Double?
    var facePositionRatioFromBottom: Double?
    var faceSizeRatio: Double?
    var faceDetectionFrameSize: CGSize?

    private var session: AVCaptureSession?
    private var videoDataOuput: AVCaptureVideoDataOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var faceDetector: CIDetector?

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

        let detectorOptions = [ CIDetectorAccuracy: CIDetectorAccuracyLow ]

        DispatchQueue.main.async {
            self.faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: detectorOptions)
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
        self.faceDetector = nil
        self.videoDataOuput?.connection(with: .video)?.isEnabled = false
        self.videoDataOuput = nil
        self.previewLayer?.removeFromSuperlayer()
        self.previewLayer = nil
    }

    func reset() {
        self.isFaceDetected = false
        self.facePositionRatioFromLeft = nil
        self.facePositionRatioFromBottom = nil
        self.faceSizeRatio = nil
        self.faceDetectionFrameSize = nil
    }

    func available() -> Bool {
        guard let _ = CameraPreviewHandler.shared().getSession(),
            let device = camera(for: cameraPosition()),
            let _ = try? AVCaptureDeviceInput(device: device) else { return false }

        return true
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        if connection.isVideoOrientationSupported {
            connection.videoOrientation = .portrait
        }

        let ciImage = CIImage(cvImageBuffer: pixelBuffer)
        guard let features = self.faceDetector?.features(in: ciImage) else { return }

        captureFace(for: features, in: ciImage.extent)
    }

    func captureFace(for features: [CIFeature], in imageDimensions: CGRect) {
        var isFaceDetected = false

        for feature in features where (feature.type == CIFeatureTypeFace) {
            isFaceDetected = true

            let featureCenterX = feature.bounds.origin.x + feature.bounds.width / 2
            let featureCenterY = feature.bounds.origin.y + feature.bounds.height / 2

            self.faceDetectionFrameSize = imageDimensions.size
            self.faceSizeRatio = Double(feature.bounds.width) / Double(imageDimensions.width)
            self.facePositionRatioFromBottom = Double(featureCenterY / imageDimensions.height)

            var ratioFromLeft = Double(featureCenterX / imageDimensions.width)
            if cameraPosition() == .front {
                ratioFromLeft = 1 - ratioFromLeft
            }
            self.facePositionRatioFromLeft = ratioFromLeft
        }

        self.isFaceDetected = isFaceDetected
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
