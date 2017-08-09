/**
 *  Copyright (C) 2010-2017 The Catrobat Team
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

extension CameraBrick: CBInstructionProtocol {
    
    
    func instruction() -> CBInstruction {
        
        let choice = self.cameraChoice
        
        var captureDevice : AVCaptureDevice!
        let session = AVCaptureSession()

        
        return CBInstruction.ExecClosure { (context, _) in
            print("Performing: CameraBrick")
            
//            guard let bgObject = self.script.object.program.objectList.firstObject as? SpriteObject,
//                let spriteNode = bgObject.spriteNode
//                else { fatalError("This should never happen!") }
                
            if let scene = self.script.object.spriteNode.scene {
            
                let camView = UIView(frame: (scene.view?.bounds)!)
                camView.accessibilityHint = "camView"
                let camLayer = CALayer()
                camLayer.accessibilityHint = "camLayer"
                camLayer.frame = camView.bounds
            
//                camView.layer.addSublayer(camLayer)
                
//                scene.view?.addSubview(camView)
                scene.view?.layer.insertSublayer(camLayer, atIndex: 0)
            
//                scene.parent.pa
                
                captureDevice = self.setupAVCaptureDevice(forSession: session)
                
                self.beginSessionForCaptureDevice(captureDevice, session: session, toLayer: camLayer)
            }

            
            context.state = .Runnable
        }
    }
    
    func setupAVCaptureDevice(forSession session: AVCaptureSession) -> AVCaptureDevice{
        session.sessionPreset = AVCaptureSessionPreset640x480
        guard let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
//            .defaultDeviceWithDeviceType(AVCaptureDeviceTypeBuiltInDuoCamera,
//                                         mediaType: AVMediaTypeVideo,
//                                         position: .Back) 
            else{
                                                fatalError("No capture device!")
        }
        return device
    }
    
    func beginSessionForCaptureDevice(captureDevice: AVCaptureDevice, session: AVCaptureSession, toLayer rootLayer: CALayer){
        
        var videoDataOutput: AVCaptureVideoDataOutput!
        var previewLayer:AVCaptureVideoPreviewLayer!
        
        var err : NSError? = nil
        var deviceInput:AVCaptureDeviceInput?
        do {
            deviceInput = try AVCaptureDeviceInput(device: captureDevice)
        } catch let error as NSError {
            err = error
            deviceInput = nil
        }
        if err != nil {
            print("error: \(err?.localizedDescription)");
        }
        if session.canAddInput(deviceInput){
            session.addInput(deviceInput);
        }
        
        videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.alwaysDiscardsLateVideoFrames=true
        if session.canAddOutput(videoDataOutput){
            session.addOutput(videoDataOutput)
        }

        videoDataOutput.connectionWithMediaType(AVMediaTypeVideo).enabled = true
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.accessibilityHint = "previewLayer"
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspect
        
        rootLayer.masksToBounds = true
        previewLayer.frame = rootLayer.bounds
        rootLayer.addSublayer(previewLayer)
        session.startRunning()
    }
    
    // clean up AVCapture
    func stopCameraForSession(session: AVCaptureSession){
        session.stopRunning()
    }
    
}
