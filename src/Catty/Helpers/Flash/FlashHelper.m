/**
 *  Copyright (C) 2010-2016 The Catrobat Team
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
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) dispatch_queue_t flashQueue;
@end

@implementation FlashHelper

static FlashHelper *sharedFlashHandler = nil;

#pragma mark - Getters and Setters
- (dispatch_queue_t)flashQueue
{
    if (! _flashQueue) {
        _flashQueue = dispatch_queue_create("org.catrobat.flash.queue", DISPATCH_QUEUE_SERIAL);
    }
    return _flashQueue;
}

#pragma mark - Singleton
+ (instancetype)sharedFlashHandler
{
    @synchronized(self) {
        if (sharedFlashHandler == nil) {
            sharedFlashHandler = [[self class] new];
            sharedFlashHandler.wasTurnedOn = FlashUninitialized;
        }
    }
    return sharedFlashHandler;
}
#pragma mark - API
- (void)turnOn
{
    [self toggleFlash:FlashON];
}
    
- (void)turnOff
{
    [self toggleFlash:FlashOFF];
}

- (void)reset
{
    [self toggleFlash:FlashUninitialized];
}

- (void)pause
{
    [self toggleFlash:FlashPause];
}

- (void)resume
{
    [self toggleFlash:FlashResume];
}


#pragma mark - Helper

- (void)toggleFlash:(NSInteger)toggle
{
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(self.flashQueue, ^{

        if ((toggle == FlashON && weakSelf.wasTurnedOn != FlashPause && sharedFlashHandler.wasTurnedOn != FlashON) || toggle == FlashResume) {
            if ([self isAvailable]){
                AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];

                [device lockForConfiguration:nil];
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
                [device unlockForConfiguration];
                sharedFlashHandler.wasTurnedOn = FlashON;
            }
        } else if (toggle == FlashOFF || toggle == FlashPause || toggle == FlashUninitialized) {
            if ([self isAvailable]){
                AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
                
                [device lockForConfiguration:nil];
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
                [device unlockForConfiguration];
            }
            if (toggle != FlashPause) {
                sharedFlashHandler.wasTurnedOn = toggle;
            }
        }
    });
 
}

-(BOOL)isAvailable
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if ([device hasTorch] && [device hasFlash]){
        return YES;
    }
    return NO;
}

@end
