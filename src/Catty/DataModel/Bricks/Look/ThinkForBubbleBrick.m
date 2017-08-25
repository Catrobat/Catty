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

#import "ThinkForBubbleBrick.h"
#import "NSString+CatrobatNSStringExtensions.h"

@implementation ThinkForBubbleBrick

- (id)init
{
    self = [super init];
    if(self) {
    }
    return self;
}

- (NSString*)brickTitle
{
    NSString* secondsString = (int)self.intFormula.formulaTree.value == 1 ? kLocalizedSecond : kLocalizedSeconds;
    return [[[[kLocalizedThink stringByAppendingString:@"%@\n"] stringByAppendingString:kLocalizedFor] stringByAppendingString:@"%@"] stringByAppendingString:secondsString];
}

- (BOOL)allowsStringFormula
{
    return YES;
}

- (void)setDefaultValuesForObject:(SpriteObject*)spriteObject
{
    Formula *speakFormula = [Formula new];
    FormulaElement *formulaElement = [FormulaElement new];
    formulaElement.type = STRING;
    formulaElement.value = kLocalizedHmmmm;
    speakFormula.formulaTree = formulaElement;
    self.stringFormula = speakFormula;
    
    Formula *timeFormula = [Formula new];
    FormulaElement *timeFormulaElement = [FormulaElement new];
    formulaElement.type = NUMBER;
    formulaElement.value = @"1.0";
    timeFormula.formulaTree = timeFormulaElement;
    self.intFormula = timeFormula;
}

-(BOOL)isDisabledForBackground
{
    return YES;
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
