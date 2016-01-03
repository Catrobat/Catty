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

#import "PhiroMotorMoveForwardBrick.h"
#import "Script.h"
#import "PhiroHelper.h"

@implementation PhiroMotorMoveForwardBrick

- (NSString*)brickTitle
{
    return kLocalizedPhiroMoveForward;
}


#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"Move Phiro Motor Forward (Motor: %lu,Speed: %f)", (unsigned long)self.motor,[self.formula interpretDoubleForSprite:self.script.object]];
}

- (BOOL)isEqualToBrick:(Brick*)brick
{
    if(self.motor !=((PhiroMotorMoveForwardBrick*)brick).motor)
        return NO;
    if (![self.formula isEqualToFormula:((PhiroMotorMoveForwardBrick*)brick).formula]) {
        return NO;
    }
    return YES;
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

- (Formula*)formulaForLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    return self.formula;
}

- (void)setFormula:(Formula*)formula forLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    self.formula = formula;
}

- (NSArray*)getFormulas
{
    return @[self.formula];
}

#pragma mark - Default values
- (void)setDefaultValuesForObject:(SpriteObject*)spriteObject
{
    self.motor = [PhiroHelper motorToString:Both];
    self.formula = [[Formula alloc] initWithZero];
}

-(Motor)phiroMotor
{
    return [PhiroHelper stringToMotor:self.motor];
}

#pragma mark - Resources
- (NSInteger)getRequiredResources
{
    return kBluetoothPhiro|[self.formula getRequiredResources];
}
@end
