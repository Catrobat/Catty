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

#import "CameraPreviewHandler.h"
#import "Pocket_Code-Swift.h"

@interface CameraPreviewHandler()

@property (nonatomic) AVCaptureSession* session;
@property (nonatomic) AVCaptureDevicePosition cameraPosition;
@property (nonatomic) UIView* camView;

@end


@implementation CameraPreviewHandler

NSString* const camAccessibility = @"camLayer";
CALayer* camLayer;
dispatch_queue_t sessionQueue;

static CameraPreviewHandler* shared = nil;

+ (instancetype)shared
{
    @synchronized(self) {
        if (shared == nil) {
            shared = [[[self class] alloc] init];
        }
    }
    return shared;
}

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionWasInterrupted:) name:AVCaptureSessionWasInterruptedNotification object:self.session];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionRuntimeError:) name:AVCaptureSessionRuntimeErrorNotification object:self.session];
        sessionQueue = dispatch_queue_create("org.catrobat.camera.session", DISPATCH_QUEUE_SERIAL);
        [self reset];
    }
    
    return self;
}

- (AVCaptureSession*)getSession
{
    __block AVCaptureSession* ret;
    dispatch_sync(sessionQueue, ^{
        ret = self.session;
    });
    return ret;
}

- (AVCaptureDevicePosition)getCameraPosition
{
    __block AVCaptureDevicePosition ret;
    dispatch_sync(sessionQueue, ^{
        ret = self.cameraPosition;
    });
    return ret;
}

- (void)setCamView:(UIView *)camView
{
    if (camView != nil)
    {
        _camView = camView;
    }
    dispatch_async(sessionQueue, ^{
        if (self.session.running)
        {
            [self _stopCamera];
            [self _startCameraPreview];
        }
    });
}

- (void)switchCameraPositionTo:(AVCaptureDevicePosition)position
{
    dispatch_async(sessionQueue, ^{
        self.cameraPosition = position;
        if (self.session.running)
        {
            [self _stopCamera];
            [self _startCameraPreview];
        }
    });
}


- (void)startCameraPreview
{
    dispatch_async(sessionQueue, ^{
        [self _startCameraPreview];
    });
}

-(void) _startCameraPreview
{
    assert(self.camView);
    dispatch_sync(dispatch_get_main_queue(), ^{
        camLayer = [[CALayer alloc] init];
        camLayer.accessibilityHint = camAccessibility;
        camLayer.frame = self.camView.bounds;
        self.camView.backgroundColor = UIColor.whiteColor;
        [self.camView.layer insertSublayer:camLayer atIndex:0];
    });
    AVCaptureDevice* device = [self getCaptureDevice];
    if (device != nil) {
        [self beginSessionForCaptureDevice:device toLayer:camLayer];
    } else {
        NSLog(@"Requested capture device unavailable");
    }

}

- (AVCaptureDevice *)getCaptureDevice {
    AVCaptureDeviceDiscoverySession *session = [AVCaptureDeviceDiscoverySession
                                               discoverySessionWithDeviceTypes:@[SpriteKitDefines.avCaptureDeviceType]
                                               mediaType:AVMediaTypeVideo
                                               position:AVCaptureDevicePositionUnspecified];
    
    for (AVCaptureDevice *device in session.devices) {
        if ([device position] == self.cameraPosition) {
            return device;
        }
    }
    return nil;
}

- (void)beginSessionForCaptureDevice:(AVCaptureDevice*)device toLayer:(CALayer*)rootLayer
{
    [device lockForConfiguration:nil];

    NSError* err;
    AVCaptureDeviceInput* deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&err];

    if (err != nil) {
        NSLog(@"error: \(err.localizedDescription)");
    }
    
    if (self.session.running) {
        [self.session stopRunning];
    }
    if ([self.session canAddInput:deviceInput]) {
        [self.session addInput:deviceInput];
    }
    AVCaptureVideoDataOutput* videoDataOutput = [AVCaptureVideoDataOutput new];
    videoDataOutput.alwaysDiscardsLateVideoFrames = true;
    if ([self.session canAddOutput:videoDataOutput]){
        [self.session addOutput: videoDataOutput];
    }
    [videoDataOutput connectionWithMediaType:AVMediaTypeVideo].enabled = true;
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        AVCaptureVideoPreviewLayer* previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        rootLayer.masksToBounds = true;
        previewLayer.frame = rootLayer.bounds;
        [rootLayer addSublayer:previewLayer];
    });
    AVCapturePhotoSettings *photosettings = [AVCapturePhotoSettings photoSettings];
    bool torchWasActive = (device.torchMode != 0 || photosettings.flashMode != 0 || device.torchLevel != 0.0 || device.isTorchActive);
    [self.session startRunning];
    if (torchWasActive){
        [device setTorchMode:AVCaptureTorchModeOn];
    }
    [device unlockForConfiguration];
}

- (void)reset
{
    dispatch_async(sessionQueue, ^{
        self.cameraPosition = AVCaptureDevicePositionFront;
        self.session = [[AVCaptureSession alloc] init];
    });
}

- (void)stopCamera
{
    if (camLayer != nil)
    {
        [camLayer removeFromSuperlayer];
    }
    dispatch_async(sessionQueue, ^{
        [self _stopCamera];
    });
}

- (void)_stopCamera
{
    [self.session stopRunning];
    for (AVCaptureDeviceInput* input in self.session.inputs)
    {
        [self.session removeInput:input];
    }
}

#pragma mark Notification handeling

- (void) sessionWasInterrupted:(NSNotification*)notification
{
    AVCaptureSessionInterruptionReason reason = [notification.userInfo[AVCaptureSessionInterruptionReasonKey] integerValue];
    NSLog(@"Capture session was interrupted; reason: %ld", (long)reason);
    if (reason == AVCaptureSessionInterruptionReasonVideoDeviceInUseByAnotherClient){
        NSLog(@"Trying to restart");
        dispatch_async(sessionQueue, ^{
            [self _startCameraPreview];
        });
    }
}

- (void) sessionRuntimeError:(NSNotification*)notification
{
    NSError* error = notification.userInfo[AVCaptureSessionErrorKey];
    NSLog(@"Capture session runtime error: %@", error);
}

@end
