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

#import "SensorHandlerTests.h"
#import "SensorHandler.h"
#import <CoreMotion/CoreMotion.h>
#include "TargetConditionals.h"

@implementation SensorHandlerTests


#if !(TARGET_IPHONE_SIMULATOR)
- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{    
    [super tearDown];
}


- (void)test_gyroActive
{
    SensorHandler* sensorHandler = [SensorHandler sharedSensorHandler];

    CMMotionManager* motionManager = [sensorHandler valueForKey:@"motionManager"];
    [sensorHandler rotationRate];
    STAssertTrue([motionManager isGyroActive], @"Gyro should be active!");
}

- (void)test_gyroX
{
    SensorHandler* sensorHandler = [SensorHandler sharedSensorHandler];
    
    BOOL isNotZero = [sensorHandler rotationRate].x != 0.0f;
    STAssertTrue(isNotZero, @"It's very unlikely that x is really zero!");
}


- (void)test_gyroY
{
    SensorHandler* sensorHandler = [SensorHandler sharedSensorHandler];
    
    BOOL isNotZero = [sensorHandler rotationRate].y != 0.0f;
    STAssertTrue(isNotZero, @"It's very unlikely that y is really zero!");
}

- (void)test_gyroZ
{
    SensorHandler* sensorHandler = [SensorHandler sharedSensorHandler];
    
    BOOL isNotZero = [sensorHandler rotationRate].y != 0.0f;
    STAssertTrue(isNotZero, @"It's very unlikely that z is really zero!");
}


- (void)test_accelerometerActive
{
    SensorHandler* sensorHandler = [SensorHandler sharedSensorHandler];
    
    CMMotionManager* motionManager = [sensorHandler valueForKey:@"motionManager"];
    [sensorHandler acceleration];
    STAssertTrue([motionManager isAccelerometerActive], @"Acceleration should be active!");
}

- (void)test_MagnetometerActive
{
    SensorHandler* sensorHandler = [SensorHandler sharedSensorHandler];
    
    CMMotionManager* motionManager = [sensorHandler valueForKey:@"motionManager"];
    [sensorHandler magneticField];
    STAssertTrue([motionManager isMagnetometerActive], @"Magnetometer should be active!");
}

- (void)test_magX
{
    SensorHandler* sensorHandler = [SensorHandler sharedSensorHandler];
    
    BOOL isNotZero = [sensorHandler magneticField].x != 0.0f;
    STAssertTrue(isNotZero, @"It's very unlikely that x is really zero!");
}


- (void)test_magY
{
    SensorHandler* sensorHandler = [SensorHandler sharedSensorHandler];
    
    BOOL isNotZero = [sensorHandler magneticField].y != 0.0f;
    STAssertTrue(isNotZero, @"It's very unlikely that y is really zero!");
}

- (void)test_magZ
{
    SensorHandler* sensorHandler = [SensorHandler sharedSensorHandler];
    
    BOOL isNotZero = [sensorHandler magneticField].y != 0.0f;
    STAssertTrue(isNotZero, @"It's very unlikely that z is really zero!");
}



-(void)test_stopSensors
{
    SensorHandler* sensorHandler = [SensorHandler sharedSensorHandler];
    
    CMMotionManager* motionManager = [sensorHandler valueForKey:@"motionManager"];
    
    [sensorHandler acceleration];
    STAssertTrue([motionManager isAccelerometerActive], @"Acceleration should be active!");
    
    [sensorHandler rotationRate];
    STAssertTrue([motionManager isGyroActive], @"Gyro should be active!");
    
    [sensorHandler magneticField];
    STAssertTrue([motionManager isMagnetometerActive], @"Magnetometer should be active!");
    
    [sensorHandler stopSensors];
    
    STAssertFalse([motionManager isAccelerometerActive], @"Magnetometer should not be active!");
    STAssertFalse([motionManager isGyroActive], @"Magnetometer should not be active!");
    STAssertFalse([motionManager isMagnetometerActive], @"Magnetometer should not be active!");
}





#endif

@end
