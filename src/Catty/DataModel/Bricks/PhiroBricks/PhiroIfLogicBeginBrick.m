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

#import "PhiroIfLogicBeginBrick.h"
#import "SensorHandler.h"

@implementation PhiroIfLogicBeginBrick

- (NSString*)brickTitle
{
    return [[kLocalizedPhiroIfLogic stringByAppendingString:@"%@ "] stringByAppendingString:kLocalizedPhiroThenLogic];
}


#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"Move Phiro If Logic (Sensor: %@)", self.sensor];
}

- (BOOL)isEqualToBrick:(Brick*)brick
{
    if(self.sensor !=((PhiroIfLogicBeginBrick*)brick).sensor)
        return NO;
    
    return YES;
}

- (NSString*)sensorForLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    return self.sensor;
}

- (void)setSensor:(NSString*)sensor forLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    if(sensor)
        self.sensor = sensor;
}

-(Sensor)phiroSensor
{
    return [SensorManager sensorForString:self.sensor];
}

- (BOOL)checkCondition
{
    NSDebug(@"Performing: %@", self.description);
    return [[SensorHandler sharedSensorHandler] valueForSensor:[self phiroSensor]];
}

- (void)resetCondition
{
    // nothing to do
}

#pragma mark - Default values
- (void)setDefaultValuesForObject:(SpriteObject*)spriteObject
{
    self.sensor =  [SensorManager stringForSensor:phiro_front_left];
}


-(BOOL)isPhiroBrick
{
    return YES;
}

#pragma mark - Resources
- (NSInteger)getRequiredResources
{
    return kBluetoothPhiro;
}
@end
