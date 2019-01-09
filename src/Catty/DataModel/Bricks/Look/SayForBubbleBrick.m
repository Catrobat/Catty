/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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

#import "SayForBubbleBrick.h"
#import "Script.h"
#import "NSString+CatrobatNSStringExtensions.h"

@implementation SayForBubbleBrick

- (id)init
{
    self = [super init];
    if(self) {
    }
    return self;
}

- (NSString*)brickTitle
{
    NSString* localizedSecond = [self.intFormula isSingularNumber] ? kLocalizedSecond : kLocalizedSeconds;
    return [[[[kLocalizedSay stringByAppendingString:@"%@\n"] stringByAppendingString:kLocalizedFor] stringByAppendingString:@"%@"] stringByAppendingString:localizedSecond];
}

- (BOOL)allowsStringFormula
{
    return YES;
}

- (void)setDefaultValuesForObject:(SpriteObject*)spriteObject
{
    self.stringFormula = [[Formula new] initWithString:kLocalizedHello];
    self.intFormula = [[Formula new] initWithInteger:1];
}

-(BOOL)isDisabledForBackground
{
    return YES;
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"Say: %@ for %@ seconds", self.stringFormula, self.intFormula];
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
