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

#import "SensorManager.h"
#import "LanguageTranslationDefines.h"
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
    @"OBJECT_COLOR",
    @"OBJECT_LOOK_NUMBER",
    @"OBJECT_LOOK_NAME",
    @"OBJECT_BACKGROUND_NUMBER",
    @"OBJECT_BACKGROUND_NAME",
    @"OBJECT_SIZE",
    @"OBJECT_ROTATION",
    @"OBJECT_LAYER",
    @"LOUDNESS",
    @"DATE_YEAR",
    @"DATE_MONTH",
    @"DATE_DAY",
    @"DATE_WEEKDAY",
    @"TIME_HOUR",
    @"TIME_MINUTE",
    @"TIME_SECOND",
    @"FACE_DETECTED",
    @"FACE_SIZE",
    @"FACE_POSITION_X",
    @"FACE_POSITION_Y",
    @"front_left",
    @"front_right",
    @"side_left",
    @"side_right",
    @"bottom_left",
    @"bottom_right",
    @"analogPin",
    @"digitalPin"
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
    if([sensor isEqualToString:@"OBJECT_COLOR"]) {
        return OBJECT_COLOR;
    }
    if([sensor isEqualToString:@"OBJECT_LOOK_NUMBER"]) {
        return OBJECT_LOOK_NUMBER;
    }
    if([sensor isEqualToString:@"OBJECT_LOOK_NAME"]) {
        return OBJECT_LOOK_NAME;
    }
    if([sensor isEqualToString:@"OBJECT_BACKGROUND_NUMBER"]) {
        return OBJECT_BACKGROUND_NUMBER;
    }
    if([sensor isEqualToString:@"OBJECT_BACKGROUND_NAME"]) {
        return OBJECT_BACKGROUND_NAME;
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
    if([sensor isEqualToString:@"LOUDNESS"]) {
        return LOUDNESS;
    }
    if([sensor isEqualToString:@"DATE_YEAR"]) {
        return DATE_YEAR;
    }
    if([sensor isEqualToString:@"DATE_MONTH"]) {
        return DATE_MONTH;
    }
    if([sensor isEqualToString:@"DATE_DAY"]) {
        return DATE_DAY;
    }
    if([sensor isEqualToString:@"DATE_WEEKDAY"]) {
        return DATE_WEEKDAY;
    }
    if([sensor isEqualToString:@"TIME_HOUR"]) {
        return TIME_HOUR;
    }
    if([sensor isEqualToString:@"TIME_MINUTE"]) {
        return TIME_MINUTE;
    }
    if([sensor isEqualToString:@"TIME_SECOND"]) {
        return TIME_SECOND;
    }
    if([sensor isEqualToString:@"FACE_DETECTED"]) {
        return FACE_DETECTED;
    }
    if([sensor isEqualToString:@"FACE_SIZE"]) {
        return FACE_SIZE;
    }
    if([sensor isEqualToString:@"FACE_POSITION_X"]) {
        return FACE_POSITION_X;
    }
    if([sensor isEqualToString:@"FACE_POSITION_Y"]) {
        return FACE_POSITION_Y;
    }
    if([sensor isEqualToString:@"front_left"]) {
        return phiro_front_left;
    }
    if([sensor isEqualToString:@"front_right"]) {
        return phiro_front_right;
    }
    if([sensor isEqualToString:@"side_left"]) {
        return phiro_side_left;
    }
    if([sensor isEqualToString:@"side_right"]) {
        return phiro_side_right;
    }
    if([sensor isEqualToString:@"bottom_left"]) {
        return phiro_bottom_left;
    }
    if([sensor isEqualToString:@"bottom_right"]) {
        return phiro_bottom_right;
    }
    if([sensor isEqualToString:@"analogPin"]) {
        return arduino_analogPin;
    }
    if([sensor isEqualToString:@"digitalPin"]) {
        return arduino_digitalPin;
    }
    
//    NSError(@"Unknown Sensor: %@", sensor);
    
    return -1;
}

+ (NSString*)stringForSensor:(Sensor)sensor
{
        if (((NSInteger) sensor-900) < ((NSInteger)(sizeof(sensorStringArray) / sizeof(Sensor))) && ((NSInteger) sensor-900) >= 0)
        {
            return sensorStringArray[sensor-900];
        }else{
            return @"";
        }

}

+ (BOOL)isObjectSensor:(Sensor)sensor
{
    return (sensor >= OBJECT_X && sensor <= OBJECT_LAYER) ? YES : NO;
}

+ (BOOL)isStringSensor:(Sensor)sensor
{
    return (sensor == OBJECT_LOOK_NAME || sensor == OBJECT_BACKGROUND_NAME) ? YES : NO;
}

+ (BOOL)isArduinoSensor:(Sensor)sensor
{
    return (sensor >= arduino_analogPin && sensor <= arduino_digitalPin) ? YES : NO;
}
+ (NSString *)getExternName:(NSString *)sensorName
{
    Sensor sensor = [self sensorForString:sensorName];
    NSString *name;
    switch (sensor) {
        case DATE_YEAR:
            name = kUIFESensorDateYear;
            break;
        case DATE_MONTH:
            name = kUIFESensorDateMonth;
            break;
        case DATE_DAY:
            name = kUIFESensorDateDay;
            break;
        case DATE_WEEKDAY:
            name = kUIFESensorDateWeekday;
            break;
        case TIME_HOUR:
            name = kUIFESensorTimeHour;
            break;
        case TIME_MINUTE:
            name = kUIFESensorTimeMinute;
            break;
        case TIME_SECOND:
            name = kUIFESensorTimeSecond;
            break;
        case COMPASS_DIRECTION:
            name = kUIFESensorCompass;
            break;
        case LOUDNESS:
            name = kUIFESensorLoudness;
            break;
        case OBJECT_BRIGHTNESS:
            name = kUIFEObjectBrightness;
            break;
        case OBJECT_COLOR:
            name = kUIFEObjectColor;
            break;
        case OBJECT_LOOK_NUMBER:
            name = kUIFEObjectLookNumber;
            break;
        case OBJECT_LOOK_NAME:
            name = kUIFEObjectLookName;
            break;
        case OBJECT_BACKGROUND_NUMBER:
            name = kUIFEObjectBackgroundNumber;
            break;
        case OBJECT_BACKGROUND_NAME:
            name = kUIFEObjectBackgroundName;
            break;
        case OBJECT_GHOSTEFFECT:
            name = kUIFEObjectTransparency;
            break;
        case OBJECT_LAYER:
            name = kUIFEObjectLayer;
            break;
        case OBJECT_ROTATION:
            name = kUIFEObjectDirection;
            break;
        case OBJECT_SIZE:
            name = kUIFEObjectSize;
            break;
        case OBJECT_X:
            name = kUIFEObjectPositionX;
            break;
        case OBJECT_Y:
            name = kUIFEObjectPositionY;
            break;
        case X_ACCELERATION:
            name = kUIFESensorAccelerationX;
            break;
        case X_INCLINATION:
            name = kUIFESensorInclinationX;
            break;
        case Y_ACCELERATION:
            name = kUIFESensorAccelerationY;
            break;
        case Y_INCLINATION:
            name = kUIFESensorInclinationY;
            break;
        case Z_ACCELERATION:
            name = kUIFESensorAccelerationZ;
            break;
        case FACE_DETECTED:
            name = kUIFESensorFaceDetected;
            break;
        case FACE_SIZE:
            name = kUIFESensorFaceSize;
            break;
        case FACE_POSITION_X:
            name = kUIFESensorFaceX;
            break;
        case FACE_POSITION_Y:
            name = kUIFESensorFaceY;
            break;
        case phiro_front_left:
            name = kUIFESensorPhiroFrontLeft;
            break;
        case phiro_front_right:
            name = kUIFESensorPhiroFrontRight;
            break;
        case phiro_bottom_left:
            name = kUIFESensorPhiroBottomLeft;
            break;
        case phiro_bottom_right:
            name = kUIFESensorPhiroBottomRight;
            break;
        case phiro_side_left:
            name = kUIFESensorPhiroSideLeft;
            break;
        case phiro_side_right:
            name = kUIFESensorPhiroSideRight;
            break;
        case arduino_analogPin:
            name = kUIFESensorArduinoAnalog;
            break;
        case arduino_digitalPin:
            name = kUIFESensorArduinoDigital;
            break;
        default:
            break;
    }
    
    return name;
}

@end
