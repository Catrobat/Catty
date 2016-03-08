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

#import "HideTextBrick.h"
#import "Formula.h"
#import "UserVariable.h"
#import "Program.h"
#import "VariablesContainer.h"
#import "Script.h"

@implementation HideTextBrick


- (UserVariable*)variableForLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    return self.userVariable;
}

- (void)setVariable:(UserVariable*)variable forLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    self.userVariable = variable;
}


- (void)setDefaultValuesForObject:(SpriteObject*)spriteObject
{
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
    return kLocalizedHideVariable;
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"Hide Variable Brick: Uservariable: %@", self.userVariable];
}

- (BOOL)isEqualToBrick:(Brick*)brick
{
    if (! [self.userVariable isEqualToUserVariable:((HideTextBrick*)brick).userVariable])
        return NO;
    return YES;
}

@end
