/**
 *  Copyright (C) 2010-2016 The Catrobat Team
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

#import "PhiroMotorStopBrick.h"
#import "PhiroHelper.h"

@implementation PhiroMotorStopBrick
- (NSString*)brickTitle
{
    return kLocalizedStopPhiroMotor;
}



#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"Stop Phiro Motor (Motor: %lu)", (unsigned long)self.motor];
}

- (BOOL)isEqualToBrick:(Brick*)brick
{
    if(self.motor ==((PhiroMotorStopBrick*)brick).motor)
        return YES;
    return NO;
}

- (NSString*)motorForLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    return self.motor;
}

- (void)setMotor:(NSString*)motor forLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    if(motor)
        self.motor = motor;
}

#pragma mark - Default values
- (void)setDefaultValuesForObject:(SpriteObject*)spriteObject
{
    self.motor = [PhiroHelper motorToString:Both];
}

-(Motor)phiroMotor
{
    return [PhiroHelper stringToMotor:self.motor];
}

#pragma mark - Resources
- (NSInteger)getRequiredResources
{
    return kBluetoothPhiro;
}
@end
