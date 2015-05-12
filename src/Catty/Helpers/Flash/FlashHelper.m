/**
 *  Copyright (C) 2010-2015 The Catrobat Team
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


#import "FlashHelper.h"
#import <AVFoundation/AVFoundation.h>
@interface FlashHelper()

@property (nonatomic, strong) AVCaptureSession* session;


@end


@implementation FlashHelper

static FlashHelper* sharedFlashHandler = nil;

+ (instancetype)sharedFlashHandler
{
    @synchronized(self) {
        if (sharedFlashHandler == nil) {
            sharedFlashHandler = [[[self class] alloc] init];
            sharedFlashHandler.wasTurnedOn = FlashUninitialized;
        }
    }
    return sharedFlashHandler;
}

- (void)turnOn
{
    self.session= [[AVCaptureSession alloc] init];
    
    [self.session beginConfiguration];
    
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if ([device hasTorch] && [device hasFlash]){
        [device lockForConfiguration:nil];
        [device setTorchMode:AVCaptureTorchModeOn];
        [device setFlashMode:AVCaptureFlashModeOn];
        [device unlockForConfiguration];
        
        AVCaptureDeviceInput * flashInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        if (flashInput){
            [self.session addInput:flashInput];
        }
        AVCaptureVideoDataOutput * output = [[AVCaptureVideoDataOutput alloc] init];
        [self.session addOutput:output];
        [self.session commitConfiguration];
        [self.session startRunning];
        sharedFlashHandler.wasTurnedOn = FlashON;
    }

}
    
- (void)turnOff
{
    if (self.session.isRunning) {
        AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        if ([device hasTorch] && [device hasFlash]){
            [device lockForConfiguration:nil];
            [device setTorchMode:AVCaptureTorchModeOff];
            [device setFlashMode:AVCaptureFlashModeOff];
            [device unlockForConfiguration];
            [self.session stopRunning];
            sharedFlashHandler.wasTurnedOn = FlashOFF;
        }
    }
}

- (void)reset
{
    sharedFlashHandler.wasTurnedOn = FlashUninitialized;
}

- (void)pause
{
    if (self.session.isRunning) {
        [self.session stopRunning];
        sharedFlashHandler.wasTurnedOn = FlashOFF;
    }
}

@end
