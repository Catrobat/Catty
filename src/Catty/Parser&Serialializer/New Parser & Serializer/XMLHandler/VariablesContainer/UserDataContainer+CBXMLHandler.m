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

#import "UserDataContainer+CBXMLHandler.h"
#import "GDataXMLElement+CustomExtensions.h"
#import "CBXMLValidator.h"
#import "OrderedMapTable.h"
#import "CBXMLParserHelper.h"
#import "SpriteObject+CBXMLHandler.h"
#import "UserVariable+CBXMLHandler.h"
#import "UserList+CBXMLHandler.h"
#import "CBXMLParserContext.h"
#import "CBXMLSerializerContext.h"
#import "CBXMLSerializerHelper.h"
#import "CBXMLPositionStack.h"
#import "OrderedDictionary.h"

@implementation UserDataContainer (CBXMLHandler)

#pragma mark - Parsing
+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLParserContext *)context
{
    return [self parseFromElement:xmlElement withObjectElement:nil andContext:context];
}

+ (instancetype)parseForSpriteObject:(GDataXMLElement*)objectXmlElement withContext:(CBXMLParserContext*)context
{
    return [self parseFromElement:context.rootElement withObjectElement:objectXmlElement andContext:context];
}

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withObjectElement:(GDataXMLElement*)objectXmlElement andContext:(CBXMLParserContext*)context
{
    NSString *rootElementName = context.languageVersion == 0.93f ? @"variables" : @"data";
    
    NSArray *variablesElements = [xmlElement elementsForName:rootElementName];
    [XMLError exceptionIf:[variablesElements count] notEquals:1 message:@"Too many %@-elements given!", rootElementName];
    GDataXMLElement *variablesElement = [variablesElements firstObject];
    UserDataContainer *varContainer = [[UserDataContainer alloc] init];
    
    if (objectXmlElement != nil) {
        
         for (UserVariable* variable in [[self class] parseAndCreateObjectVariables:variablesElement withObjectElement:objectXmlElement andContext:context]) {
          [varContainer addVariable: variable];
         }
         for (UserList* list in [[self class] parseAndCreateObjectLists:variablesElement withObjectElement:objectXmlElement andContext:context]) {
             [varContainer addList: list];
         }
    } else {
         for (UserVariable* variable in [[self class] parseAndCreateProjectVariables:variablesElement withContext:context]) {
          [varContainer addVariable: variable];
         }
        context.programVariableList = [[NSMutableArray alloc] initWithArray: varContainer.variables];
        

         for (UserList* list in [[self class] parseAndCreateProjectLists:variablesElement withContext:context]) {
             [varContainer addList: list];
         }
        context.programListOfLists = [[NSMutableArray alloc] initWithArray: varContainer.lists];
    }
    
    return varContainer;
}

+ (NSMutableArray<UserVariable*>*)parseAndCreateObjectVariables:(GDataXMLElement*)variablesElement withObjectElement:(GDataXMLElement*)objectXmlElement andContext:(CBXMLParserContext*)context
{
    NSMutableArray<UserVariable*>* userVariables = [[NSMutableArray alloc] init];
    NSArray *objectVarListElements = [variablesElement elementsForName:@"objectVariableList"];
    
    if (![objectVarListElements count]) {
        return userVariables;
    }
    
    [XMLError exceptionIf:[objectVarListElements count] notEquals:1 message:@"Too many objectVariableList-elements!"];
    GDataXMLElement *objectVarListElement = [objectVarListElements firstObject];
    
    NSArray *entries = [objectVarListElement children];
    
    for (GDataXMLElement *entry in entries) {
        [XMLError exceptionIfNode:entry isNilOrNodeNameNotEquals:@"entry"];
        NSArray *objectElements = [entry elementsForName:@"object"];
        
        if ([objectElements count] != 1) {
            // Work-around for broken XML (e.g. for project 4705)
            continue;
        }
        
        [XMLError exceptionIf:[objectElements count] notEquals:1 message:@"Too many object-elements given!"];
        GDataXMLElement *objectElement = [objectElements firstObject];

        // if object contains a reference then jump to the (referenced) object definition
        if ([CBXMLParserHelper isReferenceElement:objectElement]) {
            GDataXMLNode *referenceAttribute = [objectElement attributeForName:@"reference"];
            NSString *xPath = [referenceAttribute stringValue];
            objectElement = [objectElement singleNodeForCatrobatXPath:xPath];
            [XMLError exceptionIfNil:objectElement message:@"Invalid reference in object. No or too many objects found!"];
        }
        
        if ([[objectElement stringValue] isEqualToString:[objectXmlElement stringValue]]) {
            NSArray *listElements = [entry elementsForName:@"list"];
            GDataXMLElement *listElement = [listElements firstObject];
            return [[self class] parseUserVariablesList:[listElement children] withContext:context];
        }
    }
    return userVariables;
}

+ (NSMutableArray<UserList*>*)parseAndCreateObjectLists:(GDataXMLElement*)variablesElement withObjectElement:(GDataXMLElement*)objectXmlElement andContext:(CBXMLParserContext*)context
{
    NSMutableArray<UserList*>* userLists = [[NSMutableArray alloc] init];
    NSArray *objectListOfListsElements = [variablesElement elementsForName:@"objectListOfList"];
    
    if (![objectListOfListsElements count]) {
        return userLists;
    }
    
    [XMLError exceptionIf:[objectListOfListsElements count] notEquals:1 message:@"Too many objectListOfList-elements!"];
    GDataXMLElement *objectListOfListsElement = [objectListOfListsElements firstObject];
    
    NSArray *entries = [objectListOfListsElement children];
    
    for (GDataXMLElement *entry in entries) {
        [XMLError exceptionIfNode:entry isNilOrNodeNameNotEquals:@"entry"];
        NSArray *objectElements = [entry elementsForName:@"object"];
        
        if ([objectElements count] != 1) {
            // Work-around for broken XML (e.g. for project 4705)
            continue;
        }
        
        [XMLError exceptionIf:[objectElements count] notEquals:1 message:@"Too many object-elements given!"];
        GDataXMLElement *objectElement = [objectElements firstObject];
        
        // if object contains a reference then jump to the (referenced) object definition
        if ([CBXMLParserHelper isReferenceElement:objectElement]) {
            GDataXMLNode *referenceAttribute = [objectElement attributeForName:@"reference"];
            NSString *xPath = [referenceAttribute stringValue];
            objectElement = [objectElement singleNodeForCatrobatXPath:xPath];
            [XMLError exceptionIfNil:objectElement message:@"Invalid reference in object. No or too many objects found!"];
        }
        
        if ([[objectElement stringValue] isEqualToString:[objectXmlElement stringValue]]) {
            NSArray *listElements = [entry elementsForName:@"list"];
            GDataXMLElement *listElement = [listElements firstObject];
            return [[self class] parseUserListOfLists:[listElement children] withContext:context];
        }
    }
    return userLists;
}

+ (NSMutableArray*)parseAndCreateProjectVariables:(GDataXMLElement*)variablesElement withContext:(CBXMLParserContext*)context
{
    NSArray *projectVarListElements = [variablesElement elementsForName:@"programVariableList"];
    if (![projectVarListElements count]) {
        return [NSMutableArray new];
    }
    
    [XMLError exceptionIf:[projectVarListElements count] notEquals:1 message:@"Too many programVariableList-elements!"];
    GDataXMLElement *projectVarListElement = [projectVarListElements firstObject];
    
    return [[self class] parseUserVariablesList:[projectVarListElement children] withContext:context];
}

+ (NSMutableArray*)parseAndCreateProjectLists:(GDataXMLElement*)variablesElement withContext:(CBXMLParserContext*)context
{
    NSArray *programListOfListsElements = [variablesElement elementsForName:@"programListOfLists"];
    if (![programListOfListsElements count]) {
        return [NSMutableArray new];
    }
    
    [XMLError exceptionIf:[programListOfListsElements count] notEquals:1 message:@"Too many programListOfLists-elements!"];
    GDataXMLElement *programListOfListsElement = [programListOfListsElements firstObject];
    
    return [[self class] parseUserListOfLists:[programListOfListsElement children] withContext:context];
}

+ (NSMutableArray*)parseUserVariablesList:(NSArray*)userVariablesListElements withContext:(CBXMLParserContext*)context
{
    NSMutableArray *userVariablesList = [NSMutableArray arrayWithCapacity:[userVariablesListElements count]];
    for (GDataXMLElement *userVariableElement in userVariablesListElements) {
        [XMLError exceptionIfNode:userVariableElement isNilOrNodeNameNotEquals:@"userVariable"];
        UserVariable *userVariable = [context parseFromElement:userVariableElement withClass:[UserVariable class]];
        [XMLError exceptionIfNil:userVariable message:@"Unable to parse user variable..."];
        
        if([userVariable.name length] > 0) {
            if ([CBXMLParserHelper findUserVariableInArray:userVariablesList withName:userVariable.name]) {
                [XMLError exceptionWithMessage:@"A userVariable-entry of the same UserVariable already \
                 exists. This should never happen!"];
            }
            [userVariablesList addObject:userVariable];
        }
    }
    return userVariablesList;
}

+ (NSMutableArray*)parseUserListOfLists:(NSArray*)userListOfListsElements withContext:(CBXMLParserContext*)context
{
    NSMutableArray *userListOfLists = [NSMutableArray arrayWithCapacity:[userListOfListsElements count]];
    for (GDataXMLElement *userListElement in userListOfListsElements) {
        [XMLError exceptionIfNode:userListElement isNilOrNodeNameNotEquals:@"userList"];
        UserList *userList = [context parseFromElement:userListElement withClass:[UserList class]];
        [XMLError exceptionIfNil:userList message:@"Unable to parse user list..."];
        
        if([userList.name length] > 0) {
            if ([CBXMLParserHelper findUserListInArray:userListOfLists withName:userList.name]) {
                [XMLError exceptionWithMessage:@"A userList-entry of the same UserList already \
                 exists. This should never happen!"];
            }
            [userListOfLists addObject:userList];
        }
    }
    return userListOfLists;
}

#pragma mark - Serialization
- (GDataXMLElement*)xmlElementWithContext:(CBXMLSerializerContext*)context
{
    GDataXMLElement *xmlElement = [GDataXMLElement elementWithName:@"data" context:context];
    
    //------------------
    // Object Lists
    //------------------
    GDataXMLElement *objectListOfListXmlElement = [GDataXMLElement elementWithName:@"objectListOfList" context:context];
    NSUInteger totalNumOfObjectLists = [context.spriteObjectList count];
    
    for (NSUInteger index = 0; index < totalNumOfObjectLists; ++index) {
        id spriteObject = [context.spriteObjectList objectAtIndex: index];
        [XMLError exceptionIf:[spriteObject isKindOfClass:[SpriteObject class]] equals:NO
                      message:@"Instance in objectListOfLists at index: %lu is no SpriteObject", (unsigned long)index];
        if (![context.spriteObjectList containsObject:spriteObject]) {
            NSWarn(@"Error while serializing object list for object '%@': object does not exists!", ((SpriteObject*)spriteObject).name);
            continue;
        }
        
        context.spriteObject = spriteObject;
        
        GDataXMLElement *entryXmlElement = [GDataXMLElement elementWithName:@"entry" context:context];
        GDataXMLElement *entryToObjectReferenceXmlElement = [GDataXMLElement elementWithName:@"object" context:context];
        CBXMLPositionStack *positionStackOfSpriteObject = context.spriteObjectNamePositions[((SpriteObject*)spriteObject).name];
        CBXMLPositionStack *currentPositionStack = [context.currentPositionStack mutableCopy];
        NSString *refPath = [CBXMLSerializerHelper relativeXPathFromSourcePositionStack:currentPositionStack
                                                             toDestinationPositionStack:positionStackOfSpriteObject];
        [entryToObjectReferenceXmlElement addAttribute:[GDataXMLElement attributeWithName:@"reference"
                                                                              stringValue:refPath]];
        [entryXmlElement addChild:entryToObjectReferenceXmlElement context:context];
        
        GDataXMLElement *listXmlElement = [GDataXMLElement elementWithName:@"list" context:context];
        NSArray *lists = ((SpriteObject*)spriteObject).userData.lists;
        for (id list in lists) {
            [XMLError exceptionIf:[list isKindOfClass:[UserList class]] equals:NO
                          message:@"Invalid user List instance given"];
            GDataXMLElement *userListXmlElement = [(UserList*)list xmlElementWithContext:context];
            [listXmlElement addChild:userListXmlElement context:context];
        }
        [entryXmlElement addChild:listXmlElement context:context];
        [objectListOfListXmlElement addChild:entryXmlElement context:context];
    }
    [xmlElement addChild:objectListOfListXmlElement context:context];
    
    //------------------
    // Object Variables
    //------------------
    GDataXMLElement *objectVariableListXmlElement = [GDataXMLElement elementWithName:@"objectVariableList" context:context];
    NSUInteger totalNumOfObjectVariables = [context.spriteObjectList count];
    
    for (NSUInteger index = 0; index < totalNumOfObjectVariables; ++index) {
        id spriteObject = [context.spriteObjectList objectAtIndex: index];
        [XMLError exceptionIf:[spriteObject isKindOfClass:[SpriteObject class]] equals:NO
                      message:@"Instance in objectVariableList at index: %lu is no SpriteObject", (unsigned long)index];
        if (![context.spriteObjectList containsObject:spriteObject]) {
            NSWarn(@"Error while serializing object variable for object '%@': object does not exists!", ((SpriteObject*)spriteObject).name);
            continue;
        }
        
        context.spriteObject = spriteObject;
        
        GDataXMLElement *entryXmlElement = [GDataXMLElement elementWithName:@"entry" context:context];
        GDataXMLElement *entryToObjectReferenceXmlElement = [GDataXMLElement elementWithName:@"object" context:context];
        CBXMLPositionStack *positionStackOfSpriteObject = context.spriteObjectNamePositions[((SpriteObject*)spriteObject).name];
        CBXMLPositionStack *currentPositionStack = [context.currentPositionStack mutableCopy];
        NSString *refPath = [CBXMLSerializerHelper relativeXPathFromSourcePositionStack:currentPositionStack
                                                             toDestinationPositionStack:positionStackOfSpriteObject];
        [entryToObjectReferenceXmlElement addAttribute:[GDataXMLElement attributeWithName:@"reference"
                                                                            stringValue:refPath]];
        [entryXmlElement addChild:entryToObjectReferenceXmlElement context:context];

        GDataXMLElement *listXmlElement = [GDataXMLElement elementWithName:@"list" context:context];
        NSArray *variables = ((SpriteObject*)spriteObject).userData.variables;
        for (id variable in variables) {
            [XMLError exceptionIf:[variable isKindOfClass:[UserVariable class]] equals:NO
                          message:@"Invalid user variable instance given"];
            GDataXMLElement *userVariableXmlElement = [(UserVariable*)variable xmlElementWithContext:context];
            [listXmlElement addChild:userVariableXmlElement context:context];
        }
        [entryXmlElement addChild:listXmlElement context:context];
        [objectVariableListXmlElement addChild:entryXmlElement context:context];
    }
    [xmlElement addChild:objectVariableListXmlElement context:context];

    
    
    
    
    
    //------------------
    // Project Lists
    //------------------
    GDataXMLElement *programListOfListsXmlElement = [GDataXMLElement elementWithName:@"programListOfLists"
                                                                              context:context];
    for (id list in self.lists) {
        [XMLError exceptionIf:[list isKindOfClass:[UserList class]] equals:NO
                      message:@"Invalid user list instance given"];
        GDataXMLElement *userListXmlElement = [(UserList*)list xmlElementWithContext:context];
        [programListOfListsXmlElement addChild:userListXmlElement context:context];
    }
    [xmlElement addChild:programListOfListsXmlElement context:context];

    
    
    
    //------------------
    // Project Variables
    //------------------
    GDataXMLElement *programVariableListXmlElement = [GDataXMLElement elementWithName:@"programVariableList"
                                                                              context:context];
    for (id variable in self.variables) {
        [XMLError exceptionIf:[variable isKindOfClass:[UserVariable class]] equals:NO
                      message:@"Invalid user variable instance given"];
        GDataXMLElement *userVariableXmlElement = [(UserVariable*)variable xmlElementWithContext:context];
        [programVariableListXmlElement addChild:userVariableXmlElement context:context];
    }
    [xmlElement addChild:programVariableListXmlElement context:context];
    
    
    
    
    
    // add pseudo element to produce a Catroid equivalent XML (unused at the moment)
    [xmlElement addChild:[GDataXMLElement elementWithName:@"userBrickVariableList" context:context] context:context];
    
    // TODO implement objectListOfList, programListOfLists and userBrickVariableList

    return xmlElement;
}

@end
