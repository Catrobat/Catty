//
//  SensorManager.m
//  Catty
//
//  Created by Dominik Ziegler on 6/4/13.
//
//

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
