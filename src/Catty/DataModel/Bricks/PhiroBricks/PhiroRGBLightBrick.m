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

#import "PhiroRGBLightBrick.h"
#import "BrickFormulaProtocol.h"
#import "Script.h"
#import "PhiroHelper.h"

@implementation PhiroRGBLightBrick
- (NSString*)brickTitle
{
    return kLocalizedPhiroRGBLight;
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
- (NSArray*)getFormulas
{
    return @[self.redFormula,self.greenFormula,self.blueFormula];
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

- (BOOL)allowsStringFormula
{
    return NO;
}

- (NSString*)lightForLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    return self.light;
}

- (void)setLight:(NSString*)light forLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    if(light)
        self.light = light;
}

#pragma mark - Default values
- (void)setDefaultValuesForObject:(SpriteObject*)spriteObject
{
    self.light = [PhiroHelper lightToString:LBoth];
    self.redFormula = [[Formula alloc] initWithZero];
    self.greenFormula = [[Formula alloc] initWithZero];
    self.blueFormula = [[Formula alloc] initWithZero];
}

-(Light)phiroLight
{
    return [PhiroHelper stringToLight:self.light];
}

#pragma mark - Resources
- (NSInteger)getRequiredResources
{
    return kBluetoothPhiro|[self.redFormula getRequiredResources]|[self.greenFormula getRequiredResources]|[self.blueFormula getRequiredResources];
}
@end
