/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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

#import "ReplaceItemInUserListBrick+CBXMLHandler.h"
#import "CBXMLValidator.h"
#import "GDataXMLElement+CustomExtensions.h"
#import "GDataXMLNode+CustomExtensions.h"
#import "Formula+CBXMLHandler.h"
#import "UserList+CBXMLHandler.h"
#import "CBXMLParser.h"
#import "CBXMLParserContext.h"
#import "CBXMLSerializerContext.h"
#import "CBXMLParserHelper.h"
#import "CBXMLSerializerHelper.h"
#import "Pocket_Code-Swift.h"

@implementation ReplaceItemInUserListBrick (CBXMLHandler)

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLParserContext*)context
{
    GDataXMLElement *userListElement = nil;
    
    [CBXMLParserHelper validateXMLElement:xmlElement forFormulaListWithTotalNumberOfFormulas:2];
    
    userListElement = [xmlElement childWithElementName:@"userList"];
    
    Formula *formula = [CBXMLParserHelper formulaInXMLElement:xmlElement forCategoryName:@"REPLACE_ITEM_IN_USERLIST_VALUE" withContext:context];
    Formula *index = [CBXMLParserHelper formulaInXMLElement:xmlElement forCategoryName:@"REPLACE_ITEM_IN_USERLIST_INDEX" withContext:context];
    
    [XMLError exceptionIfNil:formula message:@"No formula element found..."];
    
    ReplaceItemInUserListBrick *replaceItemInUserListBrick = [self new];
    replaceItemInUserListBrick.elementFormula = formula;
    replaceItemInUserListBrick.index = index;
    
    
    if (userListElement != nil) {
        UserList *userList = [context parseFromElement:userListElement withClass:[UserList class]];
        [XMLError exceptionIfNil:userList message:@"Unable to parse userList..."];
        replaceItemInUserListBrick.userList = userList;
    }
    
    return replaceItemInUserListBrick;
}

- (GDataXMLElement*)xmlElementWithContext:(CBXMLSerializerContext*)context
{
    GDataXMLElement *brick = [super xmlElementForBrickType:@"ReplaceItemInUserListBrick" withContext:context];
    GDataXMLElement *formulaList = [GDataXMLElement elementWithName:@"formulaList" context:context];
    GDataXMLElement *formula = [self.elementFormula xmlElementWithContext:context];
    GDataXMLElement *index = [self.index xmlElementWithContext:context];
    
    [formula addAttribute:[GDataXMLElement attributeWithName:@"category" escapedStringValue:@"REPLACE_ITEM_IN_USERLIST_VALUE"]];
    [index addAttribute:[GDataXMLElement attributeWithName:@"category" escapedStringValue:@"REPLACE_ITEM_IN_USERLIST_INDEX"]];
    
    [formulaList addChild:formula context:context];
    [formulaList addChild:index context:context];
    
    [brick addChild:formulaList context:context];
    
    if (self.userList)
        [brick addChild:[self.userList xmlElementWithContext:context] context:context];
    return brick;
}

@end
