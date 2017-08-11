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


#import "SensorHandler.h"
#import <CoreLocation/CoreLocation.h>
#import "Util.h"
#import "Pocket_Code-Swift.h"
#import "FaceDetection.h"
#import "TouchHandler.h"
#import "AppDelegate.h"

#define kSensorUpdateInterval 0.8
#define FACE_DETECTION_DEFAULT_UPDATE_INTERVAL 0.01

#define NOISE_RECOGNIZER_DEFAULT_REFERENCE_PROGRAM 5
#define NOISE_RECOGNIZER_DEFAULT_RANGE 160
#define NOISE_RECOGNIZER_DEFAULT_OFFSET 50
#define NOISE_RECOGNIZER_DEFAULT_UPDATE_INTERVAL 0.05

@interface SensorHandler()

@property (nonatomic,   strong) CMMotionManager* motionManager;
@property (nonatomic,   strong) CLLocationManager* locationManager;
@property (nonatomic,   strong) AVAudioRecorder* recorder;
@property (nonatomic,   strong) NSTimer* loudnessTimer;
@property (nonatomic)           CGFloat loudnessInPercent;
@property (nonatomic,   strong) ArduinoDevice* arduino;
@property (nonatomic,   strong) FaceDetection* faceDetection;
@property (nonatomic,   strong) dispatch_semaphore_t loudnessSemaphore;
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

-(BOOL)locationAvailable
{
    return [CLLocationManager locationServicesEnabled];
}

-(BOOL)compassAvailable
{
    return [CLLocationManager headingAvailable];
}

-(BOOL)accelerometerAvailable
{
    return self.motionManager.accelerometerAvailable;
}

-(BOOL)gyroAvailable
{
    return self.motionManager.gyroAvailable;
}

-(BOOL)magnetometerAvailable
{
    return self.motionManager.magnetometerAvailable;
}

-(BOOL)loudnessAvailable
{
    if (!self.recorder) {
        [self recorderinit];
    }
    if (!self.recorder) {
        return NO;
    }
    [self loudness];
    return YES;
}

- (double)valueForSensor:(Sensor)sensor {
    double result = 0;
    NSDateComponents *components;
    switch (sensor) {
        case DATE_YEAR:
            components = [[NSCalendar currentCalendar] components: NSCalendarUnitYear fromDate:[NSDate date]];
            result = [components year];
            break;
        case DATE_MONTH:
            components = [[NSCalendar currentCalendar] components: NSCalendarUnitMonth fromDate:[NSDate date]];
            result = [components month];
            break;
        case DATE_DAY:
            components = [[NSCalendar currentCalendar] components: NSCalendarUnitDay fromDate:[NSDate date]];
            result = [components day];
            break;
        case DATE_WEEKDAY:
            components = [[NSCalendar currentCalendar] components: NSCalendarUnitWeekday fromDate:[NSDate date]];
            result = [components weekday];
            break;
        case TIME_HOUR:
            components = [[NSCalendar currentCalendar] components: NSCalendarUnitHour fromDate:[NSDate date]];
            result = [components hour];
            break;
        case TIME_MINUTE:
            components = [[NSCalendar currentCalendar] components: NSCalendarUnitMinute fromDate:[NSDate date]];
            result = [components minute];
            break;
        case TIME_SECOND:
            components = [[NSCalendar currentCalendar] components: NSCalendarUnitSecond fromDate:[NSDate date]];
            result = [components second];
            break;    
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
        case LATITUDE: {
            result = [self latitude];
            break;
        }
        case LONGITUDE: {
            result = [self longitude];
            break;
        }
        case LOCATION_ACCURACY: {
            result = [self location_accuracy];
            break;
        }
        case ALTITUDE: {
            result = [self altitude];
            break;
        }
        case FINGER_TOUCHED: {
            result = [[TouchHandler shared] screenIsTouched];
            break;
        }
        case FINGER_X: {
            result = [[TouchHandler shared] getPositionInSceneForTouchNumber:0].x;
            break;
        }
        case FINGER_Y: {
            result = [[TouchHandler shared] getPositionInSceneForTouchNumber:0].y;
            break;
        }
        case LAST_FINGER_INDEX: {
            result = [TouchHandler shared].numberOfTouches;
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
            if (!self.loudnessTimer.isValid) {
                [self loudness];
            }
//            self.loudnessSemaphore = dispatch_semaphore_create(0);
//            dispatch_semaphore_wait(self.loudnessSemaphore, dispatch_time(DISPATCH_TIME_NOW, 0.0075 * NSEC_PER_SEC));
            result = self.loudnessInPercent;
            NSDebug(@"Loudness: %f %%", result);
            break;
        }
        case FACE_DETECTED: {
            if (!self.faceDetection.session.isRunning) {
                [self.faceDetection startFaceDetection];
                [NSThread sleepForTimeInterval:FACE_DETECTION_DEFAULT_UPDATE_INTERVAL];
            }
            result = self.faceDetection.isFaceDetected;
//            [self.faceDetection pauseFaceDetection];
            NSDebug(@"FACE_DETECTED: %f %%", result);
            break;
        }
        case FACE_SIZE: {
            if (!self.faceDetection.session.isRunning) {
                [self.faceDetection startFaceDetection];
                [NSThread sleepForTimeInterval:FACE_DETECTION_DEFAULT_UPDATE_INTERVAL];
            }
//            [self.faceDetection pauseFaceDetection];
            result = [self checkFaceSize:self.faceDetection.faceSize.size];
            NSDebug(@"FACE_SIZE: %f %%", result);
            break;
        }
        case FACE_POSITION_X: {
            if (!self.faceDetection.session.isRunning) {
                [self.faceDetection startFaceDetection];
                [NSThread sleepForTimeInterval:FACE_DETECTION_DEFAULT_UPDATE_INTERVAL];
            }
            result = self.faceDetection.facePositionX;
//            [self.faceDetection pauseFaceDetection];
            NSDebug(@"FACE_POSITION_X: %f %%", result);
            break;
        }
        case FACE_POSITION_Y: {
            if (!self.faceDetection.session.isRunning) {
                [self.faceDetection startFaceDetection];
                [NSThread sleepForTimeInterval:FACE_DETECTION_DEFAULT_UPDATE_INTERVAL];
            }
            result = self.faceDetection.facePositionY;
//            [self.faceDetection pauseFaceDetection];
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
            
        case arduino_analogPin:

            if ([[BluetoothService sharedInstance] getSensorArduino]) {
                result = [[[BluetoothService sharedInstance] getSensorArduino] getAnalogPin:sensor-arduino_analogPin];
            }
            break;
        case arduino_digitalPin:

            if ([[BluetoothService sharedInstance] getSensorArduino]) {
                result = [[[BluetoothService sharedInstance] getSensorArduino] getDigitalArduinoPin:sensor-arduino_digitalPin];
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
    [self.locationManager stopUpdatingLocation];
    
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
        [self.loudnessTimer invalidate];
        self.loudnessTimer = nil;
        self.recorder = nil;
    }
    [[TouchHandler shared] stopTrackingTouches];
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
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingHeading];

    double direction = -self.locationManager.heading.magneticHeading;
    return direction;
}

- (double)latitude
{
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];

    double latitude = self.locationManager.location.coordinate.latitude;
    return latitude;
}

- (double)longitude
{
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
    
    double longitude = self.locationManager.location.coordinate.longitude;
    return longitude;
}

- (double)location_accuracy
{
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
    
    double accuracy = self.locationManager.location.horizontalAccuracy;
    return accuracy;
}

- (double)altitude
{
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
    
    double altitude = self.locationManager.location.altitude;
    return altitude;
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

    self.loudnessTimer = [NSTimer scheduledTimerWithTimeInterval: NOISE_RECOGNIZER_DEFAULT_UPDATE_INTERVAL
                                                         target: self
                                                       selector: @selector(programTimerCallback:)
                                                       userInfo: nil
                                                        repeats: YES];
}


- (void)programTimerCallback:(NSTimer *)timer
{
    [self.recorder updateMeters];
    self.loudnessInPercent = [self decibelToPercent:[self.recorder averagePowerForChannel:0]];
//    dispatch_semaphore_signal(self.loudnessSemaphore);
//    [self.recorder pause];
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
    [self.faceDetection startFaceDetection];
}

-(double)checkFaceSize:(CGSize)faceSize
{
    if (faceSize.width < [Util screenWidth] && faceSize.height < [Util screenHeight]) {
        return (faceSize.width * faceSize.height) / ([Util screenWidth]*[Util screenHeight]) * 100;
    } else {
        return ([Util screenWidth]*[Util screenHeight]) / (faceSize.width * faceSize.height) * 100;
    }
}

@end
