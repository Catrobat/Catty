/**
 *  Copyright (C) 2010-2014 The Catrobat Team
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


#import "SensorHandler.h"
#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>
#import "Util.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>


#define kSensorUpdateInterval 0.8

#define NOISE_RECOGNIZER_DEFAULT_REFERENCE_PROGRAM 5
#define NOISE_RECOGNIZER_DEFAULT_RANGE 160
#define NOISE_RECOGNIZER_DEFAULT_OFFSET 50
#define NOISE_RECOGNIZER_DEFAULT_UPDATE_INTERVAL 0.001

@interface SensorHandler()

@property (nonatomic, strong) CMMotionManager* motionManager;
@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic,strong) AVAudioRecorder* recorder;
@property (nonatomic,strong) NSTimer* programTimer;
@property (nonatomic) CGFloat loudnessInPercent;

@end

@implementation SensorHandler


static SensorHandler* sharedSensorHandler = nil;

+ (instancetype)sharedSensorHandler
{
    @synchronized(self) {
        if (sharedSensorHandler == nil) {
            sharedSensorHandler = [[[self class] alloc] init];
        }
    }
    return sharedSensorHandler;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.motionManager = [[CMMotionManager alloc] init];
        self.locationManager = [[CLLocationManager alloc] init];
    }
    
    return self;
}


- (double)valueForSensor:(Sensor)sensor {
    double result = 0;
    switch (sensor) {
        case X_ACCELERATION: {
            result = [self acceleration].x;
            NSDebug(@"X_ACCELERATION: %f m/s^2", result);
            break;
        }
        case Y_ACCELERATION: {
            result = [self acceleration].y;
            NSDebug(@"Y_ACCELERATION: %f m/s^2", result);
            break;
        }
        case Z_ACCELERATION: {
            result = [self acceleration].z;
            NSDebug(@"Z_ACCELERATION: %f m/s^2", result);
            break;
        }
        case COMPASS_DIRECTION: {
            result = [self direction];            
            break;
        }
        case X_INCLINATION: {
            result = [self xInclination];
            NSDebug(@"X-inclination: %f degrees", result);
            break;
        }
            
        case Y_INCLINATION: {
            result = [self yInclination];
            NSDebug(@"Y-inclination: %f degrees", result);
            break;
        }
        case LOUDNESS: {
            if (!self.recorder) {
                [self recorderinit];
            }
            [self loudness];
            result = self.loudnessInPercent;
            NSDebug(@"Loudness: %f \%", result);
            break;
        }
            
        default:
            abort();
            break;
    }
    
    return result;
}

- (void)stopSensors
{

    if([self.motionManager isAccelerometerActive]) {
        [self.motionManager stopAccelerometerUpdates];
    }
    
    if([self.motionManager isGyroActive]) {
        [self.motionManager stopGyroUpdates];
    }
    
    if([self.motionManager isMagnetometerActive]) {
        [self.motionManager stopMagnetometerUpdates];
    }
    
    [self.locationManager stopUpdatingHeading];
    
    if([self.motionManager isDeviceMotionActive]) {
        [self.motionManager stopDeviceMotionUpdates];
    }
    if(self.recorder)
    {
        [self.recorder stop];
        [self.programTimer invalidate];
        self.programTimer = nil;
        self.recorder = nil;
        
    }

    
}

- (CMRotationRate)rotationRate
{
    if(![self.motionManager isGyroActive])
    {
        [sharedSensorHandler.motionManager startGyroUpdates];
        [NSThread sleepForTimeInterval:kSensorUpdateInterval];
    }
    
    return self.motionManager.gyroData.rotationRate;
}

- (CMAcceleration)acceleration
{
    if(![self.motionManager isAccelerometerActive])
    {
        [sharedSensorHandler.motionManager startAccelerometerUpdates];
        [NSThread sleepForTimeInterval:kSensorUpdateInterval];
    }
    return self.motionManager.accelerometerData.acceleration;
}

- (CMMagneticField)magneticField
{
    if(![self.motionManager isMagnetometerActive])
    {
        [sharedSensorHandler.motionManager startMagnetometerUpdates];
        [NSThread sleepForTimeInterval:kSensorUpdateInterval];
    }
    return self.motionManager.magnetometerData.magneticField;
}

- (double)direction
{
    [self.locationManager startUpdatingHeading];

    double direction = -self.locationManager.heading.trueHeading;
    
    return direction;

}

- (double)xInclination
{
    if(![self.motionManager isDeviceMotionActive]) {
        [self.motionManager startDeviceMotionUpdates];
        [NSThread sleepForTimeInterval:kSensorUpdateInterval];
    }
    double xInclination = -self.motionManager.deviceMotion.attitude.roll;
    
    return [Util radiansToDegree:xInclination];
}

- (double)yInclination
{
    if(![self.motionManager isDeviceMotionActive]) {
        [self.motionManager startDeviceMotionUpdates];
        [NSThread sleepForTimeInterval:kSensorUpdateInterval];
    }
        
    double yInclination = self.motionManager.deviceMotion.attitude.pitch;
    
    yInclination =  [Util radiansToDegree:yInclination];
    
    if(self.acceleration.z > 0) { // Face Down
        if(yInclination < 0.0) {
            yInclination = -180.0f - yInclination;
        }
        else {
            yInclination = 180.0f - yInclination;
        }
        
    }
    return yInclination;
}

- (void)recorderinit
{
    
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithFloat: 44100.0],                 AVSampleRateKey,
                              [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
                              [NSNumber numberWithInt: 0],                         AVNumberOfChannelsKey,
                              [NSNumber numberWithInt: AVAudioQualityMax],         AVEncoderAudioQualityKey,
                              nil];
    
    NSError *error;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:YES error:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    self.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    
    
    if (self.recorder == nil)
        self.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    
    if (self.recorder) {
        [self.recorder prepareToRecord];
        self.recorder.meteringEnabled = TRUE;
    }
}

- (void)loudness
{

   if(!self.recorder.isRecording)
   {
       [self.recorder record];
   }

    self.programTimer = [NSTimer scheduledTimerWithTimeInterval: NOISE_RECOGNIZER_DEFAULT_UPDATE_INTERVAL
                                                         target: self
                                                       selector: @selector(programTimerCallback:)
                                                       userInfo: nil
                                                        repeats: NO];
}


- (void)programTimerCallback:(NSTimer *)timer
{
    [self.recorder updateMeters];
    self.loudnessInPercent = [self decibelToPercent:[self.recorder averagePowerForChannel:0]];
    NSDebug(@"loudness: %f", self.loudnessInPercent);
}

- (CGFloat)decibelToPercent:(CGFloat)decibel
{
    // http://stackoverflow.com/questions/1512131/iphone-avaudioplayer-convert-decibel-level-into-percent
//    CGFloat percent = pow (10, (0.05 * decibel));
    CGFloat percent = pow (10, decibel / 20);
    return percent * 100.0f;
}



@end
