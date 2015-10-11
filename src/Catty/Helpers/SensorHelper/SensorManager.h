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

#import <Foundation/Foundation.h>

typedef enum {
    X_ACCELERATION = 900,
    Y_ACCELERATION,
    Z_ACCELERATION,
    COMPASS_DIRECTION,
    X_INCLINATION,
    Y_INCLINATION,
    OBJECT_X,
    OBJECT_Y,
    OBJECT_GHOSTEFFECT,
    OBJECT_BRIGHTNESS,
    OBJECT_SIZE,
    OBJECT_ROTATION,
    OBJECT_LAYER,
    LOUDNESS,
    FACE_DETECTED,
    FACE_SIZE,
    FACE_POSITION_X,
    FACE_POSITION_Y,
    phiro_side_right,
    phiro_front_right,
    phiro_bottom_right,
    phiro_bottom_left,
    phiro_front_left,
    phiro_side_left,
    arduino_analogPin0,
    arduino_analogPin1,
    arduino_analogPin2,
    arduino_analogPin3,
    arduino_analogPin4,
    arduino_analogPin5,
    arduino_digitalPin0,
    arduino_digitalPin1,
    arduino_digitalPin2,
    arduino_digitalPin3,
    arduino_digitalPin4,
    arduino_digitalPin5,
    arduino_digitalPin6,
    arduino_digitalPin7,
    arduino_digitalPin8,
    arduino_digitalPin9,
    arduino_digitalPin10,
    arduino_digitalPin11,
    arduino_digitalPin12,
    arduino_digitalPin13
} Sensor;

@interface SensorManager : NSObject

+ (Sensor) sensorForString:(NSString*)sensor;

+ (NSString*) stringForSensor:(Sensor)sensor;

+ (BOOL) isObjectSensor:(Sensor)sensor;

+ (NSString *)getExternName:(NSString *)sensorName;


@end
