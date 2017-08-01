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

#import <Foundation/Foundation.h>

typedef enum {
    X_ACCELERATION = 900,
    Y_ACCELERATION,
    Z_ACCELERATION,
    COMPASS_DIRECTION,
    X_INCLINATION,
    Y_INCLINATION,
    LATITUDE,
    LONGITUDE,
    LOCATION_ACCURACY,
    ALTITUDE,
    OBJECT_X,
    OBJECT_Y,
    OBJECT_GHOSTEFFECT,
    OBJECT_BRIGHTNESS,
    OBJECT_COLOR,
    OBJECT_LOOK_NUMBER,
    OBJECT_LOOK_NAME,
    OBJECT_BACKGROUND_NUMBER,
    OBJECT_BACKGROUND_NAME,
    OBJECT_SIZE,
    OBJECT_ROTATION,
    OBJECT_LAYER,
    LOUDNESS,
    DATE_YEAR,
    DATE_MONTH,
    DATE_DAY,
    DATE_WEEKDAY,
    TIME_HOUR,
    TIME_MINUTE,
    TIME_SECOND,
    FACE_DETECTED,
    FACE_SIZE,
    FACE_POSITION_X,
    FACE_POSITION_Y,
    phiro_front_left,
    phiro_front_right,
    phiro_side_left,
    phiro_side_right,
    phiro_bottom_left,
    phiro_bottom_right,
    arduino_analogPin,
    arduino_digitalPin
} Sensor;

@interface SensorManager : NSObject

+ (Sensor) sensorForString:(NSString*)sensor;

+ (NSString*) stringForSensor:(Sensor)sensor;

+ (BOOL) isObjectSensor:(Sensor)sensor;

+ (BOOL) isStringSensor:(Sensor)sensor;

+ (NSString *)getExternName:(NSString *)sensorName;


@end
