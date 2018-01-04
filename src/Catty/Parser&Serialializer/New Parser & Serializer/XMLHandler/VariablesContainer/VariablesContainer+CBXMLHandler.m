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

#import "VariablesContainer+CBXMLHandler.h"
#import "GDataXMLElement+CustomExtensions.h"
#import "CBXMLValidator.h"
#import "OrderedMapTable.h"
#import "CBXMLParserHelper.h"
#import "SpriteObject+CBXMLHandler.h"
#import "UserVariable+CBXMLHandler.h"
#import "CBXMLParserContext.h"
#import "CBXMLSerializerContext.h"
#import "CBXMLSerializerHelper.h"
#import "CBXMLPositionStack.h"
#import "OrderedDictionary.h"

@implementation VariablesContainer (CBXMLHandler)

#pragma mark - Parsing
+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLParserContext *)context
{
    if (context.languageVersion == 0.93f) {
        return [self parseFromElement:xmlElement withContext:context andRootElementName:@"variables"];
    }
    
    return [self parseFromElement:xmlElement withContext:context andRootElementName:@"data"];
}

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLParserContext *)context andRootElementName:(NSString*)elementName
{
    NSArray *variablesElements = [xmlElement elementsForName:elementName];
    [XMLError exceptionIf:[variablesElements count] notEquals:1 message:@"Too many %@-elements given!", elementName];
    GDataXMLElement *variablesElement = [variablesElements firstObject];
    VariablesContainer *varContainer = [VariablesContainer new];
    
    
    
    //------------------
    // Program Variables
    //------------------
    NSArray *programVarListElements = [variablesElement elementsForName:@"programVariableList"];
    if ([programVarListElements count]) {
        [XMLError exceptionIf:[programVarListElements count] notEquals:1
                      message:@"Too many programVariableList-elements!"];
        GDataXMLElement *programVarListElement = [programVarListElements firstObject];
        varContainer.programVariableList = [[self class] parseAndCreateProgramVariables:programVarListElement withContext:context];
        context.programVariableList = varContainer.programVariableList;
    }
    
    
    
    //------------------
    // Program Lists
    //------------------
    NSArray *programListOfListsElements = [variablesElement elementsForName:@"programListOfLists"];
    if ([programListOfListsElements count]) {
        [XMLError exceptionIf:[programListOfListsElements count] notEquals:1
                      message:@"Too many programListOfLists-elements!"];
        GDataXMLElement *programListOfListsElement = [programListOfListsElements firstObject];
        varContainer.programListOfLists = [[self class] parseAndCreateProgramLists:programListOfListsElement withContext:context];
        context.programListOfLists = varContainer.programListOfLists;
    }
    
    
    
    
    //------------------
    // Object Variables
    //------------------
    NSMutableDictionary *objectVariableMap = nil;
    NSMutableDictionary *spriteObjectElementMapVar = [NSMutableDictionary dictionary];
    NSArray *objectVarListElements = [variablesElement elementsForName:@"objectVariableList"];
    if ([objectVarListElements count]) {
        [XMLError exceptionIf:[objectVarListElements count] notEquals:1 message:@"Too many objectVariableList-elements!"];
        GDataXMLElement *objectVarListElement = [objectVarListElements firstObject];
        objectVariableMap = [[self class] parseAndCreateObjectVariables:objectVarListElement
                                                   spriteObjectElements:spriteObjectElementMapVar
                                                            withContext:context];
        context.spriteObjectNameVariableList = objectVariableMap; // needed to correctly parse SpriteObjects
    }
    
    //------------------
    // Object Lists
    //------------------
    NSMutableDictionary *objectListMap = nil;
    NSMutableDictionary *spriteObjectElementMapList = [NSMutableDictionary dictionary];
    NSArray *objectListOfListsElements = [variablesElement elementsForName:@"objectListOfList"];
    if ([objectListOfListsElements count]) {
        [XMLError exceptionIf:[objectListOfListsElements count] notEquals:1 message:@"Too many objectVariableList-elements!"];
        GDataXMLElement *objectListOfListsElement = [objectListOfListsElements firstObject];
        objectListMap = [[self class] parseAndCreateObjectLists:objectListOfListsElement
                                           spriteObjectElements:spriteObjectElementMapList
                                                    withContext:context];
        context.spriteObjectNameListOfLists = objectListMap; // needed to correctly parse SpriteObjects
    }
    
    
    
    // create ordered map table and parse all those SpriteObjects that contain objectUserVariable(s)
    OrderedMapTable *objectVariableList = [OrderedMapTable weakToStrongObjectsMapTable];
    for (NSString *spriteObjectName in objectVariableMap) {
        GDataXMLElement *xmlElement = [spriteObjectElementMapVar objectForKey:spriteObjectName];
        [XMLError exceptionIfNil:xmlElement message:@"Xml element for SpriteObject missing. This \
         should never happen!"];
        SpriteObject *spriteObject = [context parseFromElement:xmlElement withClass:[SpriteObject class]];
        [XMLError exceptionIfNil:spriteObject message:@"Unable to parse SpriteObject!"];
        [objectVariableList setObject:[objectVariableMap objectForKey:spriteObjectName]
                               forKey:spriteObject];
    }
    varContainer.objectVariableList = objectVariableList;
    
    // create ordered map table and parse all those SpriteObjects that contain objectUserVariable(s)
    OrderedMapTable *objectListOfLists = [OrderedMapTable weakToStrongObjectsMapTable];
    for (NSString *spriteObjectName in objectListMap) {
        GDataXMLElement *xmlElement = [spriteObjectElementMapList objectForKey:spriteObjectName];
        [XMLError exceptionIfNil:xmlElement message:@"Xml element for SpriteObject missing. This \
         should never happen!"];
        SpriteObject *spriteObject = [context parseFromElement:xmlElement withClass:[SpriteObject class]];
        [XMLError exceptionIfNil:spriteObject message:@"Unable to parse SpriteObject!"];
        [objectListOfLists setObject:[objectListMap objectForKey:spriteObjectName]
                              forKey:spriteObject];
    }
    varContainer.objectListOfLists = objectListOfLists;
    
    
    
    context.variables = varContainer;
    return varContainer;
}

+ (OrderedDictionary*)parseAndCreateObjectVariables:(GDataXMLElement*)objectVarListElement spriteObjectElements:(NSMutableDictionary*)spriteObjectElementMap withContext:(CBXMLParserContext*)context
{
    NSArray *entries = [objectVarListElement children];
    OrderedDictionary *objectVariableMap = [[OrderedDictionary alloc] initWithCapacity:[entries count]];
    NSUInteger index = 0;
    for (GDataXMLElement *entry in entries) {
        [XMLError exceptionIfNode:entry isNilOrNodeNameNotEquals:@"entry"];
        NSArray *objectElements = [entry elementsForName:@"object"];
        
        if ([objectElements count] != 1) {
            // Work-around for broken XML (e.g. for program 4705)
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

        // extract sprite object name out of sprite object definition
        GDataXMLNode *nameAttribute = [objectElement attributeForName:@"name"];
        [XMLError exceptionIfNil:nameAttribute message:@"Object element does not contain a name attribute!"];
        NSString *spriteObjectName = [nameAttribute stringValue];
        [spriteObjectElementMap setObject:objectElement forKey:spriteObjectName];

        // check if that SpriteObject has been already parsed some time before
        if ([objectVariableMap objectForKey:spriteObjectName]) {
            [XMLError exceptionWithMessage:@"An objectVariable-entry for same \
             SpriteObject already exists. This should never happen!"];
        }

        // create all user variables of this sprite object
        NSArray *listElements = [entry elementsForName:@"list"];
        GDataXMLElement *listElement = [listElements firstObject];
        [objectVariableMap insertObject:[[self class] parseUserVariablesList:[listElement children] withContext:context]
                                 forKey:spriteObjectName
                                atIndex:index];
        ++index;
    }
    return objectVariableMap;
}

+ (OrderedDictionary*)parseAndCreateObjectLists:(GDataXMLElement*)objectListOfListsElement spriteObjectElements:(NSMutableDictionary*)spriteObjectElementMap withContext:(CBXMLParserContext*)context
{
    NSArray *entries = [objectListOfListsElement children];
    OrderedDictionary *objectListMap = [[OrderedDictionary alloc] initWithCapacity:[entries count]];
    NSUInteger index = 0;
    for (GDataXMLElement *entry in entries) {
        [XMLError exceptionIfNode:entry isNilOrNodeNameNotEquals:@"entry"];
        NSArray *objectElements = [entry elementsForName:@"object"];
        
        if ([objectElements count] != 1) {
            // Work-around for broken XML (e.g. for program 4705)
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
        
        // extract sprite object name out of sprite object definition
        GDataXMLNode *nameAttribute = [objectElement attributeForName:@"name"];
        [XMLError exceptionIfNil:nameAttribute message:@"Object element does not contain a name attribute!"];
        NSString *spriteObjectName = [nameAttribute stringValue];
        [spriteObjectElementMap setObject:objectElement forKey:spriteObjectName];
        
        // check if that SpriteObject has been already parsed some time before
        if ([objectListMap objectForKey:spriteObjectName]) {
            [XMLError exceptionWithMessage:@"An objectList-entry for same \
             SpriteObject already exists. This should never happen!"];
        }
        
        // create all user lists of this sprite object
        NSArray *listElements = [entry elementsForName:@"list"];
        GDataXMLElement *listElement = [listElements firstObject];
        [objectListMap insertObject:[[self class] parseUserListOfLists:[listElement children] withContext:context]
                                 forKey:spriteObjectName
                                atIndex:index];
        ++index;
    }
    return objectListMap;
}

+ (NSMutableArray*)parseAndCreateProgramVariables:(GDataXMLElement*)programVarListElement withContext:(CBXMLParserContext*)context
{
    return [[self class] parseUserVariablesList:[programVarListElement children] withContext:context];
}

+ (NSMutableArray*)parseAndCreateProgramLists:(GDataXMLElement*)programListOfListsElement withContext:(CBXMLParserContext*)context
{
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
        UserVariable *userList = [context parseFromElement:userListElement withClass:[UserVariable class]];
        [XMLError exceptionIfNil:userList message:@"Unable to parse user list..."];
        
        if([userList.name length] > 0) {
            if ([CBXMLParserHelper findUserVariableInArray:userListOfLists withName:userList.name]) {
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
    NSUInteger totalNumOfObjectLists = [self.objectListOfLists count];
    
    for (NSUInteger index = 0; index < totalNumOfObjectLists; ++index) {
        id spriteObject = [self.objectListOfLists keyAtIndex:index];
        [XMLError exceptionIf:[spriteObject isKindOfClass:[SpriteObject class]] equals:NO
                      message:@"Instance in objectListOfLists at index: %lu is no SpriteObject", (unsigned long)index];
        if (![context.spriteObjectList containsObject:spriteObject]) {
            NSWarn(@"Error while serializing object list for object '%@': object does not exists!", ((SpriteObject*)spriteObject).name);
            continue;
        }
        
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
        NSArray *lists = [self.objectListOfLists objectAtIndex:index];
        for (id list in lists) {
            [XMLError exceptionIf:[list isKindOfClass:[UserVariable class]] equals:NO
                          message:@"Invalid user variable instance given"];
            GDataXMLElement *userListXmlElement = [(UserVariable*)list xmlElementWithContext:context];
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
    NSUInteger totalNumOfObjectVariables = [self.objectVariableList count];

    for (NSUInteger index = 0; index < totalNumOfObjectVariables; ++index) {
        id spriteObject = [self.objectVariableList keyAtIndex:index];
        [XMLError exceptionIf:[spriteObject isKindOfClass:[SpriteObject class]] equals:NO
                      message:@"Instance in objectVariableList at index: %lu is no SpriteObject", (unsigned long)index];
        if (![context.spriteObjectList containsObject:spriteObject]) {
            NSWarn(@"Error while serializing object variable for object '%@': object does not exists!", ((SpriteObject*)spriteObject).name);
            continue;
        }
        
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
        NSArray *variables = [self.objectVariableList objectAtIndex:index];
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
    // Program Lists
    //------------------
    GDataXMLElement *programListOfListsXmlElement = [GDataXMLElement elementWithName:@"programListOfLists"
                                                                              context:context];
    for (id list in self.programListOfLists) {
        [XMLError exceptionIf:[list isKindOfClass:[UserVariable class]] equals:NO
                      message:@"Invalid user list instance given"];
        GDataXMLElement *userListXmlElement = [(UserVariable*)list xmlElementWithContext:context];
        [programListOfListsXmlElement addChild:userListXmlElement context:context];
    }
    [xmlElement addChild:programListOfListsXmlElement context:context];

    
    
    
    //------------------
    // Program Variables
    //------------------
    GDataXMLElement *programVariableListXmlElement = [GDataXMLElement elementWithName:@"programVariableList"
                                                                              context:context];
    for (id variable in self.programVariableList) {
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
