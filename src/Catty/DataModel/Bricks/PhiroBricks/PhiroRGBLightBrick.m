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

#import "PhiroRGBLightBrick.h"
#import "BrickFormulaProtocol.h"
#import "Script.h"

@implementation PhiroRGBLightBrick
- (NSString*)brickTitle
{
    return kLocalizedPhiroRGBLight;
}

- (SKAction*)action
{
    return [SKAction runBlock:[self actionBlock]];
}

- (dispatch_block_t)actionBlock
{
    return ^{
        
//        CGFloat redValue = [self getFormulaValue:self.redFormula];
//        CGFloat greenValue = [self getFormulaValue:self.greenFormula];
//        CGFloat blueValue = [self getFormulaValue:self.blueFormula];
        
        
        switch (self.light) {
            case LightLeft:
                //          		phiro.setLeftRGBLightColor(redValue, greenValue, blueValue);
                break;
            case LightRight:
                //                phiro.setRightRGBLightColor(redValue, greenValue, blueValue);
                break;
            case LightBoth:
                //          		phiro.setLeftRGBLightColor(redValue, greenValue, blueValue);
                //                phiro.setRightRGBLightColor(redValue, greenValue, blueValue);
                break;
        }
    };
}


-(CGFloat)getFormulaValue:(Formula*)formula
{
    CGFloat rgbValue = [formula interpretDoubleForSprite:self.script.object];
    if (rgbValue < MIN_VALUE) {
        rgbValue = MIN_VALUE;
    } else if (rgbValue > MAX_VALUE) {
        rgbValue = MAX_VALUE;
    }
    
    return rgbValue;
}
#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"Set Phiro Light (R: G: B:"];
}

- (BOOL)isEqualToBrick:(Brick*)brick
{
    if(self.redFormula !=((PhiroRGBLightBrick*)brick).redFormula)
        return NO;
    if(self.greenFormula !=((PhiroRGBLightBrick*)brick).greenFormula)
        return NO;
    if(self.blueFormula !=((PhiroRGBLightBrick*)brick).blueFormula)
        return NO;
    return YES;
}
- (Formula*)formulaForLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    if (lineNumber == 2 && paramNumber == 0) {
        return self.redFormula;
    }
    if (lineNumber == 2 && paramNumber == 1) {
        return self.greenFormula;
    }
    if (lineNumber == 2 && paramNumber == 2) {
        return self.blueFormula;
    }
    
    return nil;
}

- (void)setFormula:(Formula*)formula forLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    if (lineNumber == 2 && paramNumber == 0) {
        self.redFormula = formula;
    }
    if (lineNumber == 2 && paramNumber == 1) {
        self.greenFormula = formula;
    }
    if (lineNumber == 2 && paramNumber == 2) {
        self.blueFormula = formula;
    }
}
- (Light)lightForLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    return self.light;
}

- (void)setLight:(Light)light forLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    if(light)
        self.light = light;
}

#pragma mark - Default values
- (void)setDefaultValuesForObject:(SpriteObject*)spriteObject
{
    self.redFormula = [[Formula alloc] initWithZero];
    self.greenFormula = [[Formula alloc] initWithZero];
    self.blueFormula = [[Formula alloc] initWithZero];
}
@end
