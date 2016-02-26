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

#import "ShowTextBrick.h"
#import "Formula.h"
#import "UserVariable.h"
#import "Program.h"
#import "VariablesContainer.h"
#import "Script.h"

@implementation ShowTextBrick

- (Formula*)formulaForLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    if(paramNumber == 0)
        return self.xFormula;
    else if(paramNumber == 1)
        return self.yFormula;
    
    return nil;
}

- (void)setFormula:(Formula*)formula forLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    if(paramNumber == 0)
        self.xFormula = formula;
    else if(paramNumber == 1)
        self.yFormula = formula;
}

- (UserVariable*)variableForLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    return self.userVariable;
}

- (void)setVariable:(UserVariable*)variable forLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    self.userVariable = variable;
}

- (NSArray*)getFormulas
{
    return @[self.xFormula,self.yFormula];
}

- (void)setDefaultValuesForObject:(SpriteObject*)spriteObject
{
    self.xFormula = [[Formula alloc] initWithZero];
    self.yFormula = [[Formula alloc] initWithZero];
    if(spriteObject) {
        NSArray *variables = [spriteObject.program.variables allVariablesForObject:spriteObject];
        if([variables count] > 0)
            self.userVariable = [variables objectAtIndex:0];
        else
            self.userVariable = nil;
    }
}

- (NSString*)brickTitle
{
    return kLocalizedShowVariable;
}

#pragma mark - Description
- (NSString*)description
{
    double result = [self.xFormula interpretDoubleForSprite:self.script.object];
    double result1 = [self.yFormula interpretDoubleForSprite:self.script.object];
    return [NSString stringWithFormat:@"Show Variable Brick: Uservariable: %@, toX: %f toY: %f", self.userVariable, result,result1];
}

- (BOOL)isEqualToBrick:(Brick*)brick
{
    if (! [self.userVariable isEqualToUserVariable:((ShowTextBrick*)brick).userVariable])
        return NO;
    if (! [self.xFormula isEqualToFormula:((ShowTextBrick*)brick).xFormula])
        return NO;
    if (! [self.yFormula isEqualToFormula:((ShowTextBrick*)brick).yFormula])
        return NO;
    return YES;
}

#pragma mark - Resources
- (NSInteger)getRequiredResources
{
    return [self.xFormula getRequiredResources]|[self.yFormula getRequiredResources];
}

@end
