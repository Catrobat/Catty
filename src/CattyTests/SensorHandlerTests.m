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

#import <XCTest/XCTest.h>
#import <CoreMotion/CoreMotion.h>
#import "SensorHandler.h"
#import "SensorManager.h"

@interface SensorHandlerTests : XCTestCase

@end

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


- (void)testGyroActive
{
    SensorHandler* sensorHandler = [SensorHandler sharedSensorHandler];

    CMMotionManager* motionManager = [sensorHandler valueForKey:@"motionManager"];
    [sensorHandler rotationRate];
    XCTAssertTrue([motionManager isGyroActive], @"Gyro should be active!");
}

- (void)testGyroX
{
    SensorHandler* sensorHandler = [SensorHandler sharedSensorHandler];
    
    BOOL isNotZero = [sensorHandler rotationRate].x != 0.0f;
    XCTAssertTrue(isNotZero, @"It's very unlikely that x is really zero!");
}


- (void)testGyroY
{
    SensorHandler* sensorHandler = [SensorHandler sharedSensorHandler];
    
    BOOL isNotZero = [sensorHandler rotationRate].y != 0.0f;
    XCTAssertTrue(isNotZero, @"It's very unlikely that y is really zero!");
}

- (void)testGyroZ
{
    SensorHandler* sensorHandler = [SensorHandler sharedSensorHandler];
    
    BOOL isNotZero = [sensorHandler rotationRate].y != 0.0f;
    XCTAssertTrue(isNotZero, @"It's very unlikely that z is really zero!");
}


- (void)testAccelerometerActive
{
    SensorHandler* sensorHandler = [SensorHandler sharedSensorHandler];
    
    CMMotionManager* motionManager = [sensorHandler valueForKey:@"motionManager"];
    [sensorHandler acceleration];
    XCTAssertTrue([motionManager isAccelerometerActive], @"Acceleration should be active!");
}

- (void)testMagnetometerActive
{
    SensorHandler* sensorHandler = [SensorHandler sharedSensorHandler];
    
    CMMotionManager* motionManager = [sensorHandler valueForKey:@"motionManager"];
    [sensorHandler magneticField];
    XCTAssertTrue([motionManager isMagnetometerActive], @"Magnetometer should be active!");
}

- (void)testMagX
{
    SensorHandler* sensorHandler = [SensorHandler sharedSensorHandler];
    
    BOOL isNotZero = [sensorHandler magneticField].x != 0.0f;
    XCTAssertTrue(isNotZero, @"It's very unlikely that x is really zero!");
}


- (void)testMagY
{
    SensorHandler* sensorHandler = [SensorHandler sharedSensorHandler];
    
    BOOL isNotZero = [sensorHandler magneticField].y != 0.0f;
    XCTAssertTrue(isNotZero, @"It's very unlikely that y is really zero!");
}

- (void)testMagZ
{
    SensorHandler* sensorHandler = [SensorHandler sharedSensorHandler];
    
    BOOL isNotZero = [sensorHandler magneticField].y != 0.0f;
    XCTAssertTrue(isNotZero, @"It's very unlikely that z is really zero!");
}

-(void)testValueForSensor
{
    SensorHandler* sensorHandler = [SensorHandler sharedSensorHandler];
    for (int sensor = X_ACCELERATION; sensor < OBJECT_X; sensor++) {
        BOOL isNotZero = [sensorHandler valueForSensor:sensor] != 0.0;
        XCTAssertTrue(isNotZero, @"It's very unlikely that the sensor (%@) really returned zero!", [SensorManager stringForSensor:sensor]);
    }
    
}

-(void)testStopSensors
{
    SensorHandler* sensorHandler = [SensorHandler sharedSensorHandler];
    
    CMMotionManager* motionManager = [sensorHandler valueForKey:@"motionManager"];
    
    [sensorHandler acceleration];
    XCTAssertTrue([motionManager isAccelerometerActive], @"Acceleration should be active!");
    
    [sensorHandler rotationRate];
    XCTAssertTrue([motionManager isGyroActive], @"Gyro should be active!");
    
    [sensorHandler magneticField];
    XCTAssertTrue([motionManager isMagnetometerActive], @"Magnetometer should be active!");
    
    [sensorHandler stopSensors];
    
    XCTAssertFalse([motionManager isAccelerometerActive], @"Magnetometer should not be active!");
    XCTAssertFalse([motionManager isGyroActive], @"Magnetometer should not be active!");
    XCTAssertFalse([motionManager isMagnetometerActive], @"Magnetometer should not be active!");
}

#endif

@end
