/**
 *  Copyright (C) 2010-2017 The Catrobat Team
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

#import "PlaceAtBrick.h"
#import "Script.h"

@implementation PlaceAtBrick

- (Formula*)formulaForLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    if(paramNumber == 0)
        return self.xPosition;
    else if(paramNumber == 1)
        return self.yPosition;
    
    return nil;
}

- (void)setFormula:(Formula*)formula forLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    if(paramNumber == 0)
        self.xPosition = formula;
    else if(paramNumber == 1)
        self.yPosition = formula;
}

- (NSArray*)getFormulas
{
    return @[self.xPosition,self.yPosition];
}

- (BOOL)allowsStringFormula
{
    return NO;
}

- (void)setDefaultValuesForObject:(SpriteObject*)spriteObject
{
    self.xPosition = [[Formula alloc] initWithInteger:100];
    self.yPosition = [[Formula alloc] initWithInteger:200];
}

- (NSString*)brickTitle
{
    return [kLocalizedPlaceAt
            stringByAppendingString:[@"\n"
            stringByAppendingString:[kLocalizedXLabel
            stringByAppendingString:[@"%@ "
            stringByAppendingString:[kLocalizedYLabel
            stringByAppendingString:@"%@"]]]]];
}

#pragma mark - Description
- (NSString*)description
{
    double xPosition = [self.xPosition interpretDoubleForSprite:self.script.object];
    double yPosition = [self.yPosition interpretDoubleForSprite:self.script.object];
    return [NSString stringWithFormat:@"PlaceAt (Position: %f/%f)", xPosition, yPosition];
}

#pragma mark - Resources
- (NSInteger)getRequiredResources
{
    return [self.xPosition getRequiredResources]|[self.yPosition getRequiredResources];
}

@end
