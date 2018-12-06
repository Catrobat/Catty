/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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

    // TODO: remove Singleton
    public static let shared = FaceDetectionManager()

    var isFaceDetected: Bool = false
    var facePositionX: Double?
    var facePositionY: Double?
    var faceSize: CGRect?

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

        videoDataOuput.connection(with: .video)?.isEnabled = true
        self.videoDataOuput = videoDataOuput

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.backgroundColor = UIColor.black.cgColor
        previewLayer.videoGravity = .resizeAspect
        previewLayer.isHidden = true
        self.previewLayer = previewLayer

        let detectorOptions = [ CIDetectorAccuracy: CIDetectorAccuracyLow]
        self.faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: detectorOptions)

        session.startRunning()
    }

    func stop() {
        self.reset()
        self.session?.stopRunning()
        self.session = nil
        self.faceDetector = nil
        self.videoDataOuput = nil
        self.previewLayer?.removeFromSuperlayer()
        self.previewLayer = nil
    }

    func available() -> Bool {
        guard let _ = CameraPreviewHandler.shared().getSession(),
            let device = camera(for: cameraPosition()),
            let _ = try? AVCaptureDeviceInput(device: device) else { return false }

        return true
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let ciImage = CIImage(cvImageBuffer: pixelBuffer)
        let imageOptions = [ CIDetectorImageOrientation: exifOrientation(currentDeviceOrientation: UIDevice.current.orientation)]

        guard let features = self.faceDetector?.features(in: ciImage, options: imageOptions) else { return }

        var isFaceDetected = false

        for feature in features where (feature.type == CIFeatureTypeFace) {
            isFaceDetected = true
            self.facePositionX = Double(feature.bounds.origin.x)
            self.facePositionY = Double(feature.bounds.origin.y)
            self.faceSize = feature.bounds
        }

        self.isFaceDetected = isFaceDetected
    }

    func reset() {
        self.isFaceDetected = false
        self.facePositionX = nil
        self.facePositionY = nil
        self.faceSize = nil
    }

    private func camera(for cameraPosition: AVCaptureDevice.Position) -> AVCaptureDevice? {
        for device in AVCaptureDevice.devices(for: .video) where (device.position == cameraPosition) {
            return device
        }
        return nil
    }

    private func cameraPosition() -> AVCaptureDevice.Position {
        return CameraPreviewHandler.shared().cameraPosition
    }

    private func exifOrientation(currentDeviceOrientation: UIDeviceOrientation) -> Int {
        /* kCGImagePropertyOrientation values
         The intended display orientation of the image. If present, this key is a CFNumber value with the same value as defined
         by the TIFF and EXIF specifications -- see enumeration of integer constants.
         The value specified where the origin (0,0) of the image is located. If not present, a value of 1 is assumed.

         used when calling featuresInImage: options: The value for this key is an integer NSNumber from 1..8 as found in kCGImagePropertyOrientation.
         If present, the detection will be done based on that orientation but the coordinates in the returned features will still be based on those of the image. */

        enum ExifOrientation: Int {
            case topLeft = 1 //   1  =  0th row is at the top, and 0th column is on the left (THE DEFAULT).
            case topRight = 2 //   2  =  0th row is at the top, and 0th column is on the right.
            case bottomRight = 3 //   3  =  0th row is at the bottom, and 0th column is on the right.
            case bottomLeft = 4 //   4  =  0th row is at the bottom, and 0th column is on the left.
            case leftTop = 5 //   5  =  0th row is on the left, and 0th column is the top.
            case rightTop = 6 //   6  =  0th row is on the right, and 0th column is the top.
            case rightBottom = 7 //   7  =  0th row is on the right, and 0th column is the bottom.
            case leftBottom = 8  //   8  =  0th row is on the left, and 0th column is the bottom.
        }

        switch currentDeviceOrientation {
        case .portraitUpsideDown:
            return ExifOrientation.leftBottom.rawValue
        case .landscapeLeft:
            return cameraPosition() == .front ? ExifOrientation.bottomRight.rawValue: ExifOrientation.topLeft.rawValue
        case .landscapeRight:
            return cameraPosition() == .front ? ExifOrientation.topLeft.rawValue: ExifOrientation.bottomRight.rawValue
        default:
            return ExifOrientation.rightTop.rawValue
        }
    }
}
