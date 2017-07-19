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

#import "InsertItemIntoUserListBrick+CBXMLHandler.h"
#import "CBXMLValidator.h"
#import "GDataXMLElement+CustomExtensions.h"
#import "GDataXMLNode+CustomExtensions.h"
#import "Formula+CBXMLHandler.h"
#import "UserVariable+CBXMLHandler.h"
#import "CBXMLParser.h"
#import "CBXMLParserContext.h"
#import "CBXMLSerializerContext.h"
#import "CBXMLParserHelper.h"
#import "CBXMLSerializerHelper.h"

@implementation InsertItemIntoUserListBrick (CBXMLHandler)

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLParserContext*)context
{
    GDataXMLElement *userListElement = nil;
    
    [CBXMLParserHelper validateXMLElement:xmlElement forFormulaListWithTotalNumberOfFormulas:2];
    
    userListElement = [xmlElement childWithElementName:@"userList"];

    Formula *formula = [CBXMLParserHelper formulaInXMLElement:xmlElement forCategoryName:@"INSERT_ITEM_INTO_USERLIST_VALUE" withContext:context];
    Formula *index = [CBXMLParserHelper formulaInXMLElement:xmlElement forCategoryName:@"INSERT_ITEM_INTO_USERLIST_INDEX" withContext:context];

    [XMLError exceptionIfNil:formula message:@"No formula element found..."];
    
    InsertItemIntoUserListBrick *insertItemIntoUserListBrick = [self new];
    insertItemIntoUserListBrick.elementFormula = formula;
    insertItemIntoUserListBrick.index = index;

    
    if (userListElement != nil) {
        UserVariable *userList = [context parseFromElement:userListElement withClass:[UserVariable class]];
        [XMLError exceptionIfNil:userList message:@"Unable to parse userList..."];
        insertItemIntoUserListBrick.userList = userList;
    }
    
    return insertItemIntoUserListBrick;
}

- (GDataXMLElement*)xmlElementWithContext:(CBXMLSerializerContext*)context
{
    NSUInteger indexOfBrick = [CBXMLSerializerHelper indexOfElement:self inArray:context.brickList];
    GDataXMLElement *brick = [GDataXMLElement elementWithName:@"brick" xPathIndex:(indexOfBrick+1) context:context];
    [brick addAttribute:[GDataXMLElement attributeWithName:@"type" escapedStringValue:@"InsertItemIntoUserListBrick"]];
    GDataXMLElement *formulaList = [GDataXMLElement elementWithName:@"formulaList" context:context];
    GDataXMLElement *formula = [self.elementFormula xmlElementWithContext:context];
    GDataXMLElement *index = [self.index xmlElementWithContext:context];

    [index addAttribute:[GDataXMLElement attributeWithName:@"category" escapedStringValue:@"INSERT_ITEM_INTO_USERLIST_INDEX"]];
    [formula addAttribute:[GDataXMLElement attributeWithName:@"category" escapedStringValue:@"INSERT_ITEM_INTO_USERLIST_VALUE"]];

    [formulaList addChild:index context:context];
    [formulaList addChild:formula context:context];

    [brick addChild:formulaList context:context];

    if (self.userList)
        [brick addChild:[self.userList xmlElementWithContext:context] context:context];
    return brick;
}

@end
