/**
 *  Copyright (C) 2010-2015 The Catrobat Team
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
#import "VariablesContainer.h"
#import "CBXMLValidator.h"
#import "OrderedMapTable.h"
#import "CBXMLParserHelper.h"
#import "SpriteObject+CBXMLHandler.h"
#import "UserVariable+CBXMLHandler.h"
#import "CBXMLContext.h"
#import "CBXMLSerializerHelper.h"
#import "CBXMLPositionStack.h"
#import "OrderedDictionary.h"

@implementation VariablesContainer (CBXMLHandler)

#pragma mark - Parsing
+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLContext*)context
{
    NSArray *variablesElements = [xmlElement elementsForName:@"variables"];
    [XMLError exceptionIf:[variablesElements count] notEquals:1 message:@"Too many variable-elements given!"];
    GDataXMLElement *variablesElement = [variablesElements firstObject];
    VariablesContainer *varContainer = [VariablesContainer new];

    NSArray *programVarListElements = [variablesElement elementsForName:@"programVariableList"];
    if ([programVarListElements count]) {
        [XMLError exceptionIf:[programVarListElements count] notEquals:1
                      message:@"Too many programVariableList-elements!"];
        GDataXMLElement *programVarListElement = [programVarListElements firstObject];
        varContainer.programVariableList = [[self class] parseAndCreateProgramVariables:programVarListElement];
        context.programVariableList = varContainer.programVariableList;
    }

    NSArray *objectVarListElements = [variablesElement elementsForName:@"objectVariableList"];
    if ([objectVarListElements count]) {
        [XMLError exceptionIf:[objectVarListElements count] notEquals:1 message:@"Too many objectVariableList-elements!"];
        GDataXMLElement *objectVarListElement = [objectVarListElements firstObject];
        NSMutableDictionary *spriteObjectElementMap = [NSMutableDictionary dictionary];
        NSMutableDictionary *objectVariableMap = [[self class] parseAndCreateObjectVariables:objectVarListElement
                                                                        spriteObjectElements:spriteObjectElementMap];
        context.spriteObjectNameVariableList = objectVariableMap; // needed to correctly parse SpriteObjects

        // create ordered map table and parse all those SpriteObjects that contain objectUserVariable(s)
        OrderedMapTable *objectVariableList = [OrderedMapTable weakToStrongObjectsMapTable];
        for (NSString *spriteObjectName in objectVariableMap) {
            GDataXMLElement *xmlElement = [spriteObjectElementMap objectForKey:spriteObjectName];
            [XMLError exceptionIfNil:xmlElement message:@"Xml element for SpriteObject missing. This \
             should never happen!"];
            SpriteObject *spriteObject = [SpriteObject parseFromElement:xmlElement withContext:context];
            [XMLError exceptionIfNil:spriteObject message:@"Unable to parse SpriteObject!"];
            [objectVariableList setObject:[objectVariableMap objectForKey:spriteObjectName]
                                   forKey:spriteObject];
        }
        varContainer.objectVariableList = objectVariableList;
    }
    return varContainer;
}

+ (OrderedDictionary*)parseAndCreateObjectVariables:(GDataXMLElement*)objectVarListElement
                                 spriteObjectElements:(NSMutableDictionary*)spriteObjectElementMap
{
    NSArray *entries = [objectVarListElement children];
    OrderedDictionary *objectVariableMap = [[OrderedDictionary alloc] initWithCapacity:[entries count]];
    NSUInteger index = 0;
    for (GDataXMLElement *entry in entries) {
        [XMLError exceptionIfNode:entry isNilOrNodeNameNotEquals:@"entry"];
        NSArray *objectElements = [entry elementsForName:@"object"];
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
        [objectVariableMap insertObject:[[self class] parseUserVariablesList:[listElement children]]
                                 forKey:spriteObjectName
                                atIndex:index];
        ++index;
    }
    return objectVariableMap;
}

+ (NSMutableArray*)parseAndCreateProgramVariables:(GDataXMLElement*)programVarListElement
{
    return [[self class] parseUserVariablesList:[programVarListElement children]];
}

+ (NSMutableArray*)parseUserVariablesList:(NSArray*)userVariablesListElements
{
    NSMutableArray *userVariablesList = [NSMutableArray arrayWithCapacity:[userVariablesListElements count]];
    for (GDataXMLElement *userVariableElement in userVariablesListElements) {
        [XMLError exceptionIfNode:userVariableElement isNilOrNodeNameNotEquals:@"userVariable"];
        UserVariable *userVariable = [UserVariable parseFromElement:userVariableElement withContext:nil];
        [XMLError exceptionIfNil:userVariable message:@"Unable to parse user variable..."];
        
        if ([CBXMLParserHelper findUserVariableInArray:userVariablesList withName:userVariable.name]) {
            [XMLError exceptionWithMessage:@"An userVariable-entry of the same UserVariable already \
             exists. This should never happen!"];
        }
        [userVariablesList addObject:userVariable];
    }
    return userVariablesList;
}

#pragma mark - Serialization
- (GDataXMLElement*)xmlElementWithContext:(CBXMLContext*)context
{
    GDataXMLElement *xmlElement = [GDataXMLElement elementWithName:@"variables" context:context];
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

    GDataXMLElement *programVariableListXmlElement = [GDataXMLElement elementWithName:@"programVariableList"
                                                                              context:context];
    for (id variable in self.programVariableList) {
        [XMLError exceptionIf:[variable isKindOfClass:[UserVariable class]] equals:NO
                      message:@"Invalid user variable instance given"];
        GDataXMLElement *userVariableXmlElement = [(UserVariable*)variable xmlElementWithContext:context];
        [programVariableListXmlElement addChild:userVariableXmlElement context:context];
    }
    [xmlElement addChild:programVariableListXmlElement context:context];

    //  Unused at the moment => TODO: implement this after Catroid has decided to officially use this feature!
    //    GDataXMLElement *userBrickVariableListXmlElement = [GDataXMLElement elementWithName:@"userBrickVariableList"
    //                                                                                context:context];
    //    [xmlElement addChild:userBrickVariableListXmlElement context:context];

    return xmlElement;
}

@end
