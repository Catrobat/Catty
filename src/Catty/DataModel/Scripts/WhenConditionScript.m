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

#import "WhenConditionScript.h"
#import "Util.h"

@implementation WhenConditionScript

- (NSString*)brickTitle
{
    return [[kLocalizedWhen stringByAppendingString:@"%@ "] stringByAppendingString:kLocalizedBecomesTrue];
}

- (BOOL)checkCondition
{
    NSDebug(@"Performing: %@", self.description);
    return [self.whenCondition interpretBOOLForSprite:self.object];
}

- (Formula*)formulaForLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    return self.whenCondition;
}

- (NSArray*)conditions
{
    return [self getFormulas];
}

- (NSArray*)getFormulas
{
    return @[self.whenCondition];
}

- (void)setFormula:(Formula*)formula forLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    self.whenCondition = formula;
}

- (BOOL)allowsStringFormula
{
    return NO;
}

- (void)setDefaultValuesForObject:(SpriteObject*)spriteObject
{
    FormulaElement *formulaElement = [[FormulaElement alloc] initWithElementType:OPERATOR
                                                                           value:[Operators getName:SMALLER_THAN]
                                                                       leftChild:[[FormulaElement alloc]
                                                                                  initWithElementType:NUMBER
                                                                                  value:@"1.0" leftChild:nil
                                                                                  rightChild:nil parent:nil]
                                                                      rightChild:[[FormulaElement alloc]
                                                                                  initWithElementType:NUMBER
                                                                                  value:@"2.0" leftChild:nil
                                                                                  rightChild:nil parent:nil]
                                                                          parent:nil];
    self.whenCondition = [[Formula alloc] initWithFormulaElement:formulaElement];
}


#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"Run script When %@ true", self.whenCondition];
}


#pragma mark - Resources
- (NSInteger)getRequiredResources
{
    return [self.whenCondition getRequiredResources];
}

@end
