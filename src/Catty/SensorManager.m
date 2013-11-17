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
    @"OBJECT_X",
    @"OBJECT_Y",
    @"OBJECT_GHOSTEFFECT",
    @"OBJECT_BRIGHTNESS",
    @"OBJECT_SIZE",
    @"OBJECT_ROTATION",
    @"OBJECT_LAYER",
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
    if([sensor isEqualToString:@"OBJECT_X"]) {
        return OBJECT_X;
    }
    if([sensor isEqualToString:@"OBJECT_Y"]) {
        return OBJECT_Y;
    }
    if([sensor isEqualToString:@"OBJECT_GHOSTEFFECT"]) {
        return OBJECT_GHOSTEFFECT;
    }
    if([sensor isEqualToString:@"OBJECT_BRIGHTNESS"]) {
        return OBJECT_BRIGHTNESS;
    }
    if([sensor isEqualToString:@"OBJECT_SIZE"]) {
        return OBJECT_SIZE;
    }
    if([sensor isEqualToString:@"OBJECT_ROTATION"]) {
        return OBJECT_ROTATION;
    }
    if([sensor isEqualToString:@"OBJECT_LAYER"]) {
        return OBJECT_LAYER;
    }
    if([sensor isEqualToString:@"ENVIRONMENT_SOUND"]) {
        return ENVIRONMENT_SOUND;
    }
    
    NSError(@"Unknown Sensor: %@", sensor);
    
    return -1;
}

+ (NSString*) stringForSensor:(Sensor)sensor
{
    if(sensor < sizeof(sensorStringArray) / sizeof(Sensor))
        return sensorStringArray[sensor];
    
    return @"Unknown Sensor";
}

+(BOOL) isObjectSensor:(Sensor)sensor
{
    return (sensor >= OBJECT_X && sensor <= OBJECT_LAYER) ? YES : NO;
}


@end
