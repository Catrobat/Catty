/**
 *  Copyright (C) 2010-2022 The Catrobat Team
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

#import "ThinkForBubbleBrick.h"
#import "Script.h"

@implementation ThinkForBubbleBrick

- (kBrickCategoryType)category
{
    return kLookBrick;
}

- (BOOL)allowsStringFormula
{
    return YES;
}

- (void)setDefaultValuesForObject:(SpriteObject*)spriteObject
{
    self.stringFormula = [[Formula new] initWithString:kLocalizedHmmmm];
    self.intFormula = [[Formula new] initWithInteger:1];
}

-(BOOL)isDisabledForBackground
{
    return YES;
}

- (Brick*)cloneWithScript:(Script *)script
{
    ThinkForBubbleBrick *clone = [[ThinkForBubbleBrick alloc] init];
    clone.script = script;
    clone.stringFormula = self.stringFormula;
    clone.intFormula = self.intFormula;
    
    return clone;
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"Think: %@ for %@ seconds", self.stringFormula, self.intFormula];
}

-(void)setFormula:(Formula *)formula forLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    if(formula)
    {
        if(lineNumber == 1)
        {
            self.intFormula = formula;
        } else {
            self.stringFormula = formula;
        }
    }
}

- (Formula*)formulaForLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    return lineNumber == 1 ? self.intFormula : self.stringFormula;
}

- (NSArray*)getFormulas
{
    return @[self.stringFormula, self.intFormula];
}

@end
