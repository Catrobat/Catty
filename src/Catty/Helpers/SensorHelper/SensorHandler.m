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


#import "SensorHandler.h"
#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>
#import "Util.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "Pocket_Code-Swift.h"
#import "FaceDetection.h"


#define kSensorUpdateInterval 0.8
#define FACE_DETECTION_DEFAULT_UPDATE_INTERVAL 0.05

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
@property (nonatomic,strong) ArduinoDevice* arduino;
@property (nonatomic,strong)FaceDetection* faceDetection;
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
        [self checkIfSensorsAreAvailable];
    }
    
    return self;
}

-(void)checkIfSensorsAreAvailable
{
    NSString *notAvailable = @"";
    if (![CLLocationManager headingAvailable]) {
        NSDebug(@"NOT AVAILABLE:heading");
        notAvailable = [NSString stringWithFormat:@"%@",kLocalizedSensorCompass];
    }
    if (!self.motionManager.accelerometerAvailable) {
        NSDebug(@"NOT AVAILABLE:Accelerometer");
        if ([notAvailable isEqual: @""]) {
            notAvailable = [NSString stringWithFormat:@"%@",kLocalizedSensorAcceleration];
        } else {
            notAvailable = [NSString stringWithFormat:@"%@,%@",notAvailable,kLocalizedSensorAcceleration];
        }
        
    }
    if (!self.motionManager.gyroAvailable) {
        NSDebug(@"NOT AVAILABLE:Gyro");
        if ([notAvailable isEqual: @""]) {
            notAvailable = [NSString stringWithFormat:@"%@",kLocalizedSensorRotation];
        } else {
            notAvailable = [NSString stringWithFormat:@"%@,%@",notAvailable,kLocalizedSensorRotation];
        }
    }
    if (!self.motionManager.magnetometerAvailable) {
        NSDebug(@"NOT AVAILABLE:Magnet");
        if ([notAvailable isEqual: @""]) {
            notAvailable = [NSString stringWithFormat:@"%@",kLocalizedSensorMagnetic];
        } else {
            notAvailable = [NSString stringWithFormat:@"%@,%@",notAvailable,kLocalizedSensorMagnetic];
        }
    }
    if (![notAvailable isEqual: @""]) {
        notAvailable = [NSString stringWithFormat:@"%@ %@",notAvailable,kLocalizedNotAvailable];
        [Util alertWithText:notAvailable];
    }
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
            [self.recorder pause];
            NSDebug(@"Loudness: %f %%", result);
            break;
        }
        case FACE_DETECTED: {
            if (!self.faceDetection) {
                [self faceDetectionInit];
            }
            [self.faceDetection startFaceDetection];
            [NSThread sleepForTimeInterval:FACE_DETECTION_DEFAULT_UPDATE_INTERVAL];
            result = self.faceDetection.isFaceDetected;
            [self.faceDetection pauseFaceDetection];
            NSDebug(@"FACE_DETECTED: %f %%", result);
            break;
        }
        case FACE_SIZE: {
            if (!self.faceDetection) {
                [self faceDetectionInit];
            }
            [self.faceDetection startFaceDetection];
            [NSThread sleepForTimeInterval:FACE_DETECTION_DEFAULT_UPDATE_INTERVAL];
            //result = self.faceDetection.faceSize;
            [self.faceDetection pauseFaceDetection];
            result = self.faceDetection.faceSize.size.width; // TODO: SIZE?!
            NSDebug(@"FACE_SIZE: %f %%", result);
            break;
        }
        case FACE_POSITION_X: {
            if (!self.faceDetection) {
                [self faceDetectionInit];
            }
            [self.faceDetection startFaceDetection];
            [NSThread sleepForTimeInterval:FACE_DETECTION_DEFAULT_UPDATE_INTERVAL];
            result = self.faceDetection.facePositionX;
            [self.faceDetection pauseFaceDetection];
            NSDebug(@"FACE_POSITION_X: %f %%", result);
            break;
        }
        case FACE_POSITION_Y: {
            if (!self.faceDetection) {
                [self faceDetectionInit];
            }
            [self.faceDetection startFaceDetection];
            [NSThread sleepForTimeInterval:FACE_DETECTION_DEFAULT_UPDATE_INTERVAL];
            result = self.faceDetection.facePositionY;
            [self.faceDetection pauseFaceDetection];
            NSDebug(@"FACE_POSITION_Y: %f %%", result);
            break;
        }

            
        case phiro_front_left:
        case phiro_front_right:
        case phiro_side_left:
        case phiro_side_right:
        case phiro_bottom_left:
        case phiro_bottom_right:
        {
            if ([[BluetoothService sharedInstance] getSensorPhiro]) {
                result = [[[BluetoothService sharedInstance] getSensorPhiro] getSensorValue:sensor-phiro_side_right];
            }
            break;
        }
            
        case arduino_analogPin0:
        case arduino_analogPin1:
        case arduino_analogPin2:
        case arduino_analogPin3:
        case arduino_analogPin4:
        case arduino_analogPin5:
            if ([[BluetoothService sharedInstance] getSensorArduino]) {
                result = [[[BluetoothService sharedInstance] getSensorArduino] getAnalogArduinoPin:sensor-arduino_analogPin0];
            }
            break;
        case arduino_digitalPin0:
        case arduino_digitalPin1:
        case arduino_digitalPin2:
        case arduino_digitalPin3:
        case arduino_digitalPin4:
        case arduino_digitalPin5:
        case arduino_digitalPin6:
        case arduino_digitalPin7:
        case arduino_digitalPin8:
        case arduino_digitalPin9:
        case arduino_digitalPin10:
        case arduino_digitalPin11:
        case arduino_digitalPin12:
        case arduino_digitalPin13:
            if ([[BluetoothService sharedInstance] getSensorArduino]) {
                result = [[[BluetoothService sharedInstance] getSensorArduino] getDigitalArduinoPin:sensor-arduino_digitalPin0];
            }
            break;
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
    if (self.faceDetection) {
        [self.faceDetection stopFaceDetection];
        self.faceDetection = nil;
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

    double direction = -self.locationManager.heading.magneticHeading;
    return direction;
}

- (double)xInclination
{
    if(![self.motionManager isDeviceMotionActive]) {
        [self.motionManager startDeviceMotionUpdates];
        [NSThread sleepForTimeInterval:kSensorUpdateInterval];
    }
    double xInclination = -self.motionManager.deviceMotion.attitude.roll * 4;
    
    return [Util radiansToDegree:xInclination];
}

- (double)yInclination
{
    if(![self.motionManager isDeviceMotionActive]) {
        [self.motionManager startDeviceMotionUpdates];
        [NSThread sleepForTimeInterval:kSensorUpdateInterval];
    }
        
    double yInclination = self.motionManager.deviceMotion.attitude.pitch * 4;
    
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
    CGFloat percent = (CGFloat)pow (10, decibel / 20.0f);
    return percent * 100.0f;
}

-(void)faceDetectionInit
{
    self.faceDetection = [[FaceDetection alloc] init];
}



@end
