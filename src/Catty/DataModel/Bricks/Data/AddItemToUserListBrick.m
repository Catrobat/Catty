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

#import "AddItemToUserListBrick.h"
#import "Formula.h"
#import "UserVariable.h"
#import "Project.h"
#import "VariablesContainer.h"
#import "Script.h"

@implementation AddItemToUserListBrick

- (Formula*)formulaForLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    return self.listFormula;
}

- (void)setFormula:(Formula*)formula forLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    self.listFormula = formula;
}

- (UserVariable*)listForLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    return self.userList;
}

- (void)setList:(UserVariable*)list forLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    self.userList = list;
}

- (NSArray*)getFormulas
{
    return @[self.listFormula];
}

- (void)setDefaultValuesForObject:(SpriteObject*)spriteObject
{
    self.listFormula = [[Formula alloc] initWithInteger:1];
    if(spriteObject) {
        NSArray *lists = [spriteObject.project.variables allListsForObject:spriteObject];
        if([lists count] > 0)
            self.userList = [lists objectAtIndex:0];
        else
            self.userList = nil;
    }
}

- (kBrickCategoryType)category
{
    return kVariableBrick;
}

- (BOOL)allowsStringFormula
{
    return YES;
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"AddItemToUserListBrick (Userlist: %@)", self.userList];
}

- (BOOL)isEqualToBrick:(Brick*)brick
{
    if (! [self.userList isEqualToUserVariable:((AddItemToUserListBrick*)brick).userList])
        return NO;
    if (! [self.listFormula isEqualToFormula:((AddItemToUserListBrick*)brick).listFormula])
        return NO;
    return YES;
}

#pragma mark - Resources
- (NSInteger)getRequiredResources
{
    return [self.listFormula getRequiredResources];
}

@end
