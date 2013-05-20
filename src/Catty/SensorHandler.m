/**
 *  Copyright (C) 2010-2013 The Catrobat Team
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

#define kSensorUpdateInterval 0.8

@interface SensorHandler()

@property (nonatomic, strong) CMMotionManager* motionManager;

@end


@implementation SensorHandler

static SensorHandler* sharedSensorHandler = nil;


+ (SensorHandler *) sharedSensorHandler {
    
    @synchronized(self) {
        if (sharedSensorHandler == nil) {
            sharedSensorHandler = [[SensorHandler alloc] init];
        }
    }
        
    return sharedSensorHandler;
}


- (id)init
{
    self = [super init];
    if (self) {
        self.motionManager = [[CMMotionManager alloc] init];       
    }
    
    return self;
}


-(double) getValueForSensor:(Sensor)sensor {
    double result = 0;
    
    switch (sensor) {
        case X_ACCELERATION: {
            abort();
            break;
        }
        case Y_ACCELERATION: {
            abort();
            break;
        }
        case Z_ACCELERATION: {
            abort();
            break;
        }
        case COMPASS_DIRECTION: {            
            CMMagneticField magneticField = [self magneticField];
            double x = magneticField.x;
            double y = magneticField.y;
            double z = magneticField.z;
            
            if (y > 0) result = 90.0 - atan(x/y)*180.0/M_PI;
            if (y < 0) result = 270.0 - atan(x/y)*180.0/M_PI;
            if (y == 0 && x < 0) result = 180.0;
            if (y == 0 && x > 0) result = 0.0;
            
            break;
        }
        case X_INCLINATION: {
            double x = [self acceleration].x;       // range -180° to +180°...TODO
            result = -(90.0f*x);
            NSLog(@"X-inclination: %f degrees", result);
            break;
        }
            
        case Y_INCLINATION: {
            double y = [self acceleration].y;
            result = -(90.0f*y);
            NSLog(@"Y-inclination: %f degrees", result);
            break;
        }
            
        default:
            abort();
            break;
    }
    
    return result;
}




- (void) stopSensors
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
        
}

- (CMRotationRate) rotationRate
{
    if(![self.motionManager isGyroActive])
    {
        [sharedSensorHandler.motionManager startGyroUpdates];
        [NSThread sleepForTimeInterval:kSensorUpdateInterval];
    }
    
    return self.motionManager.gyroData.rotationRate;
}

- (CMAcceleration) acceleration
{
    if(![self.motionManager isAccelerometerActive])
    {
        [sharedSensorHandler.motionManager startAccelerometerUpdates];
        [NSThread sleepForTimeInterval:kSensorUpdateInterval];
    }
    return self.motionManager.accelerometerData.acceleration;
}

- (CMMagneticField) magneticField
{
    if(![self.motionManager isMagnetometerActive])
    {
        [sharedSensorHandler.motionManager startMagnetometerUpdates];
        [NSThread sleepForTimeInterval:kSensorUpdateInterval];
    }
    return self.motionManager.magnetometerData.magneticField;
}






@end
