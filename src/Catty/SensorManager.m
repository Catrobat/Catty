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

#import "SensorManager.h"

@implementation SensorManager

NSString * const sensorStringArray[] = {
    @"X_ACCELERATION",
    @"Y_ACCELERATION",
    @"Z_ACCELERATION",
    @"COMPASS_DIRECTION",
    @"X_INCLINATION",
    @"Y_INCLINATION",
    @"LOOK_X",
    @"LOOK_Y",
    @"LOOK_GHOSTEFFECT",
    @"LOOK_BRIGHTNESS",
    @"LOOK_SIZE",
    @"LOOK_ROTATION",
    @"LOOK_LAYER",
};



+(Sensor) sensorForString:(NSString*)sensor
{
    if([sensor isEqualToString:@"X_ACCELERATION"]) {
        return X_ACCELERATION;
    }
    if([sensor isEqualToString:@"Y_ACCELERATION"]) {
        return Y_ACCELERATION;
    }
    if([sensor isEqualToString:@"Z_ACCELERATION"]) {
        return Z_ACCELERATION;
    }
    if([sensor isEqualToString:@"COMPASS_DIRECTION"]) {
        return COMPASS_DIRECTION;
    }
    if([sensor isEqualToString:@"X_INCLINATION"]) {
        return X_INCLINATION;
    }
    if([sensor isEqualToString:@"Y_INCLINATION"]) {
        return Y_INCLINATION;
    }
    if([sensor isEqualToString:@"LOOK_X"]) {
        return LOOK_X;
    }
    if([sensor isEqualToString:@"LOOK_Y"]) {
        return LOOK_Y;
    }
    if([sensor isEqualToString:@"LOOK_GHOSTEFFECT"]) {
        return LOOK_GHOSTEFFECT;
    }
    if([sensor isEqualToString:@"LOOK_BRIGHTNESS"]) {
        return LOOK_BRIGHTNESS;
    }
    if([sensor isEqualToString:@"LOOK_SIZE"]) {
        return LOOK_SIZE;
    }
    if([sensor isEqualToString:@"LOOK_ROTATION"]) {
        return LOOK_ROTATION;
    }
    if([sensor isEqualToString:@"LOOK_LAYER"]) {
        return LOOK_LAYER;
    }
    
    return -1;
}

+ (NSString*) stringForSensor:(Sensor)sensor
{
    if(sensor < sizeof(sensorStringArray) / sizeof(Sensor))
        return sensorStringArray[sensor];
    
    return @"Unknown Sensor";
}

+(BOOL) isLookSensor:(Sensor)sensor
{
    if(sensor >= LOOK_X && sensor <= LOOK_Y) {
        return YES;
    }
    return NO;
}


@end
