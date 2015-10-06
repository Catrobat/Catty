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

#import "PhiroMotorStopBrick.h"

@implementation PhiroMotorStopBrick
- (NSString*)brickTitle
{
    return kLocalizedStopPhiroMotor;
}

- (SKAction*)action
{
    return [SKAction runBlock:[self actionBlock]];
}

- (dispatch_block_t)actionBlock
{
    return ^{
        switch (self.motor) {
            case MotorLeft:
                //                phiro.stopLeftMotor(speedValue);
                break;
            case MotorRight:
                //                phiro.stopRightMotor(speedValue);
                break;
            case MotorBoth:
                //                phiro.stopRightMotor(speedValue);
                //                phiro.stopLeftMotor(speedValue);
                break;
        }

    };
}



#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"Stop Phiro Motor (Motor: %u)", self.motor];
}

- (BOOL)isEqualToBrick:(Brick*)brick
{
    if(self.motor ==((PhiroMotorStopBrick*)brick).motor)
        return YES;
    return NO;
}

- (Motor)motorForLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    return self.motor;
}

- (void)setMotor:(Motor)motor forLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    if(motor)
        self.motor = motor;
}

#pragma mark - Default values
- (void)setDefaultValuesForObject:(SpriteObject*)spriteObject
{
    self.motor = MotorBoth;
}

@end
