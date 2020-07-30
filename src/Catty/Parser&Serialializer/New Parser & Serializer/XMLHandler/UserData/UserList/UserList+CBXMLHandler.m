/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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

#import "UserList+CBXMLHandler.h"
#import "GDataXMLElement+CustomExtensions.h"
#import "CBXMLValidator.h"
#import "CBXMLParserHelper.h"
#import "CBXMLParserContext.h"
#import "CBXMLSerializerContext.h"
#import "CBXMLPositionStack.h"
#import "CBXMLSerializerHelper.h"
#import "SpriteObject.h"
#import "Pocket_Code-Swift.h"

@implementation UserList (CBXMLHandler)

#pragma mark - Parsing
+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLParserContext*)context
{
    UserList *userList = nil;
    if ([xmlElement.name  isEqual: @"userList"]){
        userList = [self parseUserList: xmlElement withContext: context];
    } else{
        [XMLError exceptionIfNode:xmlElement isNilOrNodeNameNotEquals:@"userList"];
    }
    return userList;
}


+ (instancetype)parseUserList:(GDataXMLElement*)xmlElement withContext:(CBXMLParserContext*)context
{
    if ([CBXMLParserHelper isReferenceElement:xmlElement]) {
        GDataXMLNode *referenceAttribute = [xmlElement attributeForName:@"reference"];
        NSString *xPath = [referenceAttribute stringValue];
        xmlElement = [xmlElement singleNodeForCatrobatXPath:xPath];
        [XMLError exceptionIfNil:xmlElement message:@"Invalid reference in UserList!"];
    }
    NSString *userListName = [[xmlElement childWithElementName:@"name"] stringValue];
    
    [XMLError exceptionIfNil:userListName message:@"No name for user list given"];
    UserList *userList = nil;
    
    SpriteObject *spriteObject = context.spriteObject;
    if (spriteObject) {
        [XMLError exceptionIfNil:spriteObject.name message:@"Given SpriteObject has no name."];
        for (UserList *userListToCompare in spriteObject.userData.lists) {
            if ([userListToCompare.name isEqualToString:userListName]) {
                return userListToCompare;
            }
        }
    }
    
    userList = [CBXMLParserHelper findUserListInArray:context.programListOfLists withName:userListName];
    
    if (userList) {
        return userList;
    }
    
    // Init new UserList -> this method has been called from VariablesContainer+CBXMLHandler
    userList = [[UserList alloc] initWithName:userListName];
    return userList;
}

#pragma mark - Serialization
- (GDataXMLElement*)xmlElementWithContext:(CBXMLSerializerContext*)context
{
    GDataXMLElement *xmlElement = [GDataXMLElement elementWithName:@"userList" context:context];
    GDataXMLElement *nameElement = [GDataXMLElement elementWithName:@"name" stringValue:self.name
                                                      context:context];
    [xmlElement addChild:nameElement context:context];

    CBXMLPositionStack *currentPositionStack = [context.currentPositionStack mutableCopy];

    // check if userList has been already serialized (e.g. within a SetVariableBrick)
    CBXMLPositionStack *positionStackOfUserList = nil;

    // check whether object variable/list or project variable/list
    if (! [context.project.userData containsList:self]) {
        // it is an object variable/list!
        SpriteObject *spriteObject = context.spriteObject;
        NSMutableDictionary *alreadySerializedLists = [context.spriteObjectNameUserListOfListsPositions objectForKey:spriteObject.name];
        
        if (alreadySerializedLists) {
            positionStackOfUserList = [alreadySerializedLists objectForKey:self.name];
            if (positionStackOfUserList) {
                // already serialized
                [context.currentPositionStack popXmlElementName]; // remove already added userList that contains stringValue!
                GDataXMLElement *xmlElement = [GDataXMLElement elementWithName:@"userList" context:context];
                NSString *refPath = [CBXMLSerializerHelper relativeXPathFromSourcePositionStack:currentPositionStack
                                                                     toDestinationPositionStack:positionStackOfUserList];
                [xmlElement addAttribute:[GDataXMLElement attributeWithName:@"reference" escapedStringValue:refPath]];
                return xmlElement;
            }
        } else {
            alreadySerializedLists = [NSMutableDictionary dictionary];
            [context.spriteObjectNameUserListOfListsPositions setObject:alreadySerializedLists
            forKey:spriteObject.name];
        }
        // save current stack position in context
        [alreadySerializedLists setObject:currentPositionStack forKey:self.name];
        return xmlElement;
    }

    positionStackOfUserList = [context.projectUserListNamePositions objectForKey:self.name];
    
    if (positionStackOfUserList) {
        // already serialized
        [context.currentPositionStack popXmlElementName]; // remove already added userList that contains stringValue!
        GDataXMLElement *xmlElement = [GDataXMLElement elementWithName:@"userList" context:context]; // add new one without stringValue!
        NSString *refPath = [CBXMLSerializerHelper relativeXPathFromSourcePositionStack:currentPositionStack
                                                             toDestinationPositionStack:positionStackOfUserList];
        [xmlElement addAttribute:[GDataXMLElement attributeWithName:@"reference" escapedStringValue:refPath]];
        return xmlElement;
    }
    // save current stack position in context
    [context.projectUserListNamePositions setObject:currentPositionStack forKey:self.name];
    return xmlElement;
}

@end
