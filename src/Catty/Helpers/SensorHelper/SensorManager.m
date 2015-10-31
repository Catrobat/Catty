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

#import "SensorManager.h"
#import "LanguageTranslationDefines.h"
@implementation SensorManager
//if sensorStringArray changes -> update TestArray in RequiredResourcesTests
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
    @"LOUDNESS",
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
    @"analogPin0",
    @"analogPin1",
    @"analogPin2",
    @"analogPin3",
    @"analogPin4",
    @"analogPin5",
    @"digitalPin0",
    @"digitalPin1",
    @"digitalPin2",
    @"digitalPin3",
    @"digitalPin4",
    @"digitalPin5",
    @"digitalPin6",
    @"digitalPin7",
    @"digitalPin8",
    @"digitalPin9",
    @"digitalPin10",
    @"digitalPin11",
    @"digitalPin12",
    @"digitalPin13"
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
    if([sensor isEqualToString:@"LOUDNESS"]) {
        return LOUDNESS;
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
    if([sensor isEqualToString:@"analogPin0"]) {
        return arduino_analogPin0;
    }
    if([sensor isEqualToString:@"analogPin1"]) {
        return arduino_analogPin1;
    }
    if([sensor isEqualToString:@"analogPin2"]) {
        return arduino_analogPin2;
    }
    if([sensor isEqualToString:@"analogPin3"]) {
        return arduino_analogPin3;
    }
    if([sensor isEqualToString:@"analogPin4"]) {
        return arduino_analogPin4;
    }
    if([sensor isEqualToString:@"analogPin5"]) {
        return arduino_analogPin5;
    }
    if([sensor isEqualToString:@"digitalPin0"]) {
        return arduino_digitalPin0;
    }
    if([sensor isEqualToString:@"digitalPin1"]) {
        return arduino_digitalPin1;
    }
    if([sensor isEqualToString:@"digitalPin2"]) {
        return arduino_digitalPin2;
    }
    if([sensor isEqualToString:@"digitalPin3"]) {
        return arduino_digitalPin3;
    }
    if([sensor isEqualToString:@"digitalPin4"]) {
        return arduino_digitalPin4;
    }
    if([sensor isEqualToString:@"digitalPin5"]) {
        return arduino_digitalPin5;
    }
    if([sensor isEqualToString:@"digitalPin6"]) {
        return arduino_digitalPin6;
    }
    if([sensor isEqualToString:@"digitalPin7"]) {
        return arduino_digitalPin7;
    }
    if([sensor isEqualToString:@"digitalPin8"]) {
        return arduino_digitalPin8;
    }
    if([sensor isEqualToString:@"digitalPin9"]) {
        return arduino_digitalPin9;
    }
    if([sensor isEqualToString:@"digitalPin10"]) {
        return arduino_digitalPin10;
    }
    if([sensor isEqualToString:@"digitalPin11"]) {
        return arduino_digitalPin11;
    }
    if([sensor isEqualToString:@"digitalPin12"]) {
        return arduino_digitalPin12;
    }
    if([sensor isEqualToString:@"digitalPin13"]) {
        return arduino_digitalPin13;
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
+ (NSString *)getExternName:(NSString *)sensorName
{
    Sensor sensor = [self sensorForString:sensorName];
    NSString *name;
    switch (sensor) {
        case COMPASS_DIRECTION:
            name = kUIFESensorCompass;
            break;
        case LOUDNESS:
            name = kUIFESensorLoudness;
            break;
        case OBJECT_BRIGHTNESS:
            name = kUIFEObjectBrightness;
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
        case arduino_analogPin0:
            name = kUIFESensorArduinoAnalog0;
            break;
        case arduino_analogPin1:
            name = kUIFESensorArduinoAnalog1;
            break;
        case arduino_analogPin2:
            name = kUIFESensorArduinoAnalog2;
            break;
        case arduino_analogPin3:
            name = kUIFESensorArduinoAnalog3;
            break;
        case arduino_analogPin4:
            name = kUIFESensorArduinoAnalog4;
            break;
        case arduino_analogPin5:
            name = kUIFESensorArduinoAnalog5;
            break;
        case arduino_digitalPin0:
            name = kUIFESensorArduinoDigital0;
            break;
        case arduino_digitalPin1:
            name = kUIFESensorArduinoDigital1;
            break;
        case arduino_digitalPin2:
            name = kUIFESensorArduinoDigital2;
            break;
        case arduino_digitalPin3:
            name = kUIFESensorArduinoDigital3;
            break;
        case arduino_digitalPin4:
            name = kUIFESensorArduinoDigital4;
            break;
        case arduino_digitalPin5:
            name = kUIFESensorArduinoDigital5;
            break;
        case arduino_digitalPin6:
            name = kUIFESensorArduinoDigital6;
            break;
        case arduino_digitalPin7:
            name = kUIFESensorArduinoDigital7;
            break;
        case arduino_digitalPin8:
            name = kUIFESensorArduinoDigital8;
            break;
        case arduino_digitalPin9:
            name = kUIFESensorArduinoDigital9;
            break;
        case arduino_digitalPin10:
            name = kUIFESensorArduinoDigital10;
            break;
        case arduino_digitalPin11:
            name = kUIFESensorArduinoDigital11;
            break;
        case arduino_digitalPin12:
            name = kUIFESensorArduinoDigital12;
            break;
        case arduino_digitalPin13:
            name = kUIFESensorArduinoDigital13;
            break;
        default:
            break;
    }
    
    return name;
}

@end
