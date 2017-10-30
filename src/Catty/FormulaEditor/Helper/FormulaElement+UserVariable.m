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

#import "FormulaElement+UserVariable.h"
#import "UserVariable.h"

@implementation FormulaElement (UserVariable)

- (BOOL)isVarOrListBeingUsed:(UserVariable*)varOrList
{
    if(!varOrList.isList && self.type == USER_VARIABLE && [self.value isEqualToString:varOrList.name])
        return YES;
    if(varOrList.isList && self.type == USER_LIST && [self.value isEqualToString:varOrList.name])
        return YES;
    if(self.rightChild && [self.rightChild isVarOrListBeingUsed:varOrList])
        return YES;
    if(self.leftChild && [self.leftChild isVarOrListBeingUsed:varOrList])
        return YES;
    return NO;
}

@end
