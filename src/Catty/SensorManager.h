//
//  SensorManager.h
//  Catty
//
//  Created by Dominik Ziegler on 6/4/13.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    X_ACCELERATION,
    Y_ACCELERATION,
    Z_ACCELERATION,
    COMPASS_DIRECTION,
    X_INCLINATION,
    Y_INCLINATION,
    LOOK_X,
    LOOK_Y,
    LOOK_GHOSTEFFECT,
    LOOK_BRIGHTNESS,
    LOOK_SIZE,
    LOOK_ROTATION,
    LOOK_LAYER,
} Sensor;


@interface SensorManager : NSObject

+ (Sensor) sensorForString:(NSString*)sensor;

+ (NSString*) stringForSensor:(Sensor)sensor;

+(BOOL) isLookSensor:(Sensor)sensor;


@end
