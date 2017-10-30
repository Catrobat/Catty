/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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

#import "Brick+UserVariable.h"
#import "UserVariable.h"
#import "BrickFormulaProtocol.h"
#import "FormulaElement+UserVariable.h"
#import "SetVariableBrick.h"
#import "ChangeVariableBrick.h"
#import "ShowTextBrick.h"
#import "HideTextBrick.h"
#import "AddItemToUserListBrick.h"

//TODO: uncomment as soon as classes exist
/*
#import "ReplaceItemInUserListBrick.h"
#import "DeleteItemOfUserListBrick.h"
#import "InsertItemIntoUserListBrick.h"
*/

@implementation Brick (UserVariable)

#define BRICK_MAX_LINE_NUMBER 3
#define BRICK_MAX_PARAM_NUMBER 3
- (BOOL)isVarOrListBeingUsed:(UserVariable*)varOrList
{
    if([self conformsToProtocol:@protocol(BrickVariableProtocol)]){
        
        if ([self isKindOfClass:[SetVariableBrick class]]) {
            SetVariableBrick* varBrick = (SetVariableBrick*) self;
            if ([varOrList isEqualToUserVariable:varBrick.userVariable]) {
                return YES;
            }
        } else if ([self isKindOfClass:[ChangeVariableBrick class]]) {
            ChangeVariableBrick* varBrick = (ChangeVariableBrick*) self;
            if ([varOrList isEqualToUserVariable:varBrick.userVariable]) {
                return YES;
            }
        }
        else if ([self isKindOfClass:[ShowTextBrick class]]) {
            ShowTextBrick* varBrick = (ShowTextBrick*) self;
            if ([varOrList isEqualToUserVariable:varBrick.userVariable]) {
                return YES;
            }
        }
        else if ([self isKindOfClass:[HideTextBrick class]]) {
            HideTextBrick* varBrick = (HideTextBrick*) self;
            if ([varOrList isEqualToUserVariable:varBrick.userVariable]) {
                return YES;
            }
        }
    }
    
    if([self conformsToProtocol:@protocol(BrickListProtocol)]){
        
        if ([self isKindOfClass:[AddItemToUserListBrick class]]) {
            AddItemToUserListBrick* listBrick = (AddItemToUserListBrick*) self;
            if ([varOrList isEqualToUserVariable:listBrick.userList]) {
                return YES;
            }
        }
        
        
        // TODO: Implement following bricks, uncomment afterwards
        /*
         else if ([self isKindOfClass:[ReplaceItemInUserListBrick class]]) {
         ReplaceItemInUserListBrick* listBrick = (ReplaceItemInUserListBrick*) self;
         if ([varOrList isEqualToUserVariable:listBrick.userList]) {
         return YES;
         }
         }
         else if ([self isKindOfClass:[DeleteItemOfUserListBrick class]]) {
         DeleteItemOfUserListBrick* listBrick = (DeleteItemOfUserListBrick*) self;
         if ([varOrList isEqualToUserVariable:listBrick.userList]) {
         return YES;
         }
         }
         else if ([self isKindOfClass:[InsertItemIntoUserListBrick class]]) {
         InsertItemIntoUserListBrick* listBrick = (InsertItemIntoUserListBrick*) self;
         if ([varOrList isEqualToUserVariable:listBrick.userList]) {
         return YES;
         }
         }
         */
    }

    if(![self conformsToProtocol:@protocol(BrickFormulaProtocol)])
        return NO;
    
    for(int line = 0; line <= BRICK_MAX_LINE_NUMBER; line++) {
        for(int param = 0; param <= BRICK_MAX_PARAM_NUMBER; param++) {
            id<BrickFormulaProtocol> formulaBrick = (id<BrickFormulaProtocol>)self;
            Formula *formula = [formulaBrick formulaForLineNumber:line andParameterNumber:param];
            if(formula && [formula.formulaTree isVarOrListBeingUsed:varOrList])
                return YES;
        }
    }
    
    return NO;
}

@end
