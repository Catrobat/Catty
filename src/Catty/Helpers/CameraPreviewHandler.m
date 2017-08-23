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

#import "CameraPreviewHandler.h"

@interface CameraPreviewHandler()

@property (nonatomic) AVCaptureSession* session;
@property (nonatomic) AVCaptureDevicePosition cameraPosition;
@property (nonatomic) UIView* camView;

@end


@implementation CameraPreviewHandler

NSString* const camAccessibility = @"camLayer";
CALayer* camLayer;

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

+ (void)resetSharedInstance {
    shared = nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.cameraPosition = AVCaptureDevicePositionBack;
        self.session = [[AVCaptureSession alloc] init];
    }
    
    return self;
}

- (void)setCamView:(UIView *)camView
{
    if (camView != nil)
    {
        _camView = camView;
    }
    if ([self.session isRunning])
    {
        [self stopCamera];
        [self startCameraPreview];
    }
}

- (void)switchCameraPositionTo:(AVCaptureDevicePosition)position
{
    self.cameraPosition = position;
    if ([self.session isRunning])
    {
        [self stopCamera];
        [self startCameraPreview];
    }
}


- (void)startCameraPreview
{
    assert(self.camView);
    
    camLayer = [[CALayer alloc] init];
    camLayer.accessibilityHint = camAccessibility;
    camLayer.frame = self.camView.bounds;
    self.camView.backgroundColor = [UIColor whiteColor];
    [self.camView.layer insertSublayer:camLayer atIndex:0];

    AVCaptureDevice* device = [self getCaptureDevice];
    if (device != nil)
    {
        [self beginSessionForCaptureDevice:device toLayer:camLayer];
    } else {
        NSLog(@"Requested capture device unavailable");
    }
}

- (AVCaptureDevice *)getCaptureDevice {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == self.cameraPosition) {
            return device;
        }
    }
    return nil;
}

- (void)beginSessionForCaptureDevice:(AVCaptureDevice*)device toLayer:(CALayer*)rootLayer
{
    NSError* err;
    AVCaptureDeviceInput* deviceInput;
    deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&err];
    if (err != nil)
    {
     NSLog(@"error: \(err.localizedDescription)");
    }
    if ([self.session canAddInput:deviceInput])
    {
        [self.session addInput:deviceInput];
    }
    
    AVCaptureVideoDataOutput* videoDataOutput = [AVCaptureVideoDataOutput new];
    videoDataOutput.alwaysDiscardsLateVideoFrames = true;
    if ([self.session canAddOutput:videoDataOutput]){
        [self.session addOutput: videoDataOutput];
    }
    
    [videoDataOutput connectionWithMediaType:AVMediaTypeVideo].enabled = true;
    
    AVCaptureVideoPreviewLayer* previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    rootLayer.masksToBounds = true;
    previewLayer.frame = rootLayer.bounds;
    [rootLayer addSublayer:previewLayer];
    [self.session startRunning];
}

// clean up AVCapture
- (void)stopCamera
{
    if (camLayer != nil)
    {
        [camLayer removeFromSuperlayer];
    }
    [self.session stopRunning];
    for (AVCaptureDeviceInput* input in self.session.inputs)
    {
        [self.session removeInput:input];
    }
}


@end
