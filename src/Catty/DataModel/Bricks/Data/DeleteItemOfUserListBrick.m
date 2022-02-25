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

#import "Pocket_Code-Swift.h"
#import "DeleteItemOfUserListBrick.h"
#import "Formula.h"
#import "Project.h"
#import "Script.h"

@implementation DeleteItemOfUserListBrick

- (kBrickCategoryType)category
{
    return kDataBrick;
}

- (Formula*)formulaForLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    return self.listFormula;
}

- (void)setFormula:(Formula*)formula forLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    self.listFormula = formula;
}

- (UserList*)listForLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    return self.userList;
}

- (void)setList:(UserList*)list forLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
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
        NSArray *lists = [UserDataContainer objectAndProjectListsForObject:spriteObject];
        if([lists count] > 0)
            self.userList = [lists objectAtIndex:0];
        else
            self.userList = nil;
    }
}

- (BOOL)allowsStringFormula
{
    return YES;
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"Delete Item From User List Brick: Userlist: %@", self.userList];
}

- (BOOL)isEqualToBrick:(Brick*)brick
{
    if (! [self.userList isEqual:((DeleteItemOfUserListBrick*)brick).userList])
        return NO;
    if (! [self.listFormula isEqualToFormula:((DeleteItemOfUserListBrick*)brick).listFormula])
        return NO;
    return YES;
}

#pragma mark - Resources
- (NSInteger)getRequiredResources
{
    return [self.listFormula getRequiredResources];
}

@end
