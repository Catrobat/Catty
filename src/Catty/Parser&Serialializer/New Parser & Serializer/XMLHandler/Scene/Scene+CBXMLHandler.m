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

#import "Scene+CBXMLHandler.h"
#import "CBXMLValidator.h"
#import "GDataXMLElement+CustomExtensions.h"
#import "CBXMLParserContext.h"
#import "SpriteObject+CBXMLHandler.h"
#import "OrderedMapTable.h"
#import "Program+CBXMLHandler.h"
#import "CBXMLParserHelper.h"
#import "CBXMLSerializerContext.h"
#import "CBXMLPositionStack.h"
#import "CBXMLSerializerHelper.h"
#import "UserVariable+CBXMLHandler.h"
#import "OrderedDictionary.h"
#import "NSArray+CustomExtension.h"

NSString *const kSceneElementName = @"scene";
NSString *const kNameElementName = @"name";
NSString *const kObjectListElementName = @"objectList";
NSString *const kDataElementName = @"data";
NSString *const kObjectListOfListElementName = @"objectListOfList";
NSString *const kObjectVariableListElementName = @"objectVariableList";
NSString *const kUserBrickVariableListElementName = @"userBrickVariableList";
NSString *const kOriginalWidthElementName = @"originalWidth";
NSString *const kOriginalHeightElementName = @"originalHeight";

@implementation Scene (CBXMLHandler)

+ (instancetype)parseFromElement:(GDataXMLElement *)xmlElement withContext:(CBXMLParserContext *)context {
    NSParameterAssert(xmlElement);
    NSParameterAssert([xmlElement.name isEqualToString:kSceneElementName]);
    NSParameterAssert(context);
    [context.objectVariableList removeAllObjects];
    [context.spriteObjectList removeAllObjects];
    [context.pointedSpriteObjectList removeAllObjects];
    [context.spriteObjectNameVariableList removeAllObjects];
    [context.formulaVariableNameList removeAllObjects];
    
    NSString *name = [self parseNameFromSceneElement:xmlElement];
    OrderedMapTable *objectVariableList = [self parseObjectVariableListFromSceneElement:xmlElement withContext:context];
    
    context.objectVariableList = [objectVariableList mutableCopy];
    
    NSMutableArray<SpriteObject *> *objectList = [self parseObjectListFromSceneElement:xmlElement withContext:context];
    NSString *originalWidth = [self parseOriginalWidthFromSceneElement:xmlElement];
    NSString *originalHeight = [self parseOriginalHeightFromSceneElement:xmlElement];
    
    return [[Scene alloc] initWithName:name
                            objectList:objectList
                    objectVariableList:objectVariableList
                         originalWidth:originalWidth
                        originalHeight:originalHeight];
}

+ (NSString *)parseNameFromSceneElement:(GDataXMLElement *)sceneElement {
    GDataXMLElement *nameElement = [CBXMLParserHelper onlyChildOfElement:sceneElement withName:kNameElementName];
    return nameElement.stringValue;
}

+ (NSMutableArray<SpriteObject *> *)parseObjectListFromSceneElement:(GDataXMLElement *)sceneElement
                                                        withContext:(CBXMLParserContext *)context {
    GDataXMLElement *objectListElement = [CBXMLParserHelper onlyChildOfElement:sceneElement withName:kObjectListElementName];
    
    return [Program parseObjectListFromElement:objectListElement withContext:context];
}

+ (OrderedMapTable *)parseObjectVariableListFromSceneElement:(GDataXMLElement *)sceneElement
                                                 withContext:(CBXMLParserContext *)context {
    GDataXMLElement *dataElement = [CBXMLParserHelper onlyChildOfElement:sceneElement withName:kDataElementName];
    GDataXMLElement *objectVariableListElement = [CBXMLParserHelper onlyChildOfElement:dataElement withName:kObjectVariableListElementName];
    
    NSMutableDictionary *spriteObjectElementMap = [NSMutableDictionary dictionary];
    NSMutableDictionary *objectVariableMap = [self parseAndCreateObjectVariables:objectVariableListElement
                                                            spriteObjectElements:spriteObjectElementMap
                                                                     withContext:context];
    context.spriteObjectNameVariableList = objectVariableMap; // needed to correctly parse SpriteObjects
    
    // create ordered map table and parse all those SpriteObjects that contain objectUserVariable(s)
    OrderedMapTable *objectVariableList = [OrderedMapTable weakToStrongObjectsMapTable];
    for (NSString *spriteObjectName in objectVariableMap) {
        GDataXMLElement *xmlElement = [spriteObjectElementMap objectForKey:spriteObjectName];
        [XMLError exceptionIfNil:xmlElement message:@"Xml element for SpriteObject missing. This should never happen!"];
        
        SpriteObject *spriteObject = [context parseFromElement:xmlElement withClass:[SpriteObject class]];
        [XMLError exceptionIfNil:spriteObject message:@"Unable to parse SpriteObject!"];
        
        [objectVariableList setObject:[objectVariableMap objectForKey:spriteObjectName]
                               forKey:spriteObject];
    }
    return objectVariableList;
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

+ (NSMutableArray*)parseUserVariablesList:(NSArray*)userVariablesListElements withContext:(CBXMLParserContext*)context
{
    NSMutableArray *userVariablesList = [NSMutableArray arrayWithCapacity:[userVariablesListElements count]];
    for (GDataXMLElement *userVariableElement in userVariablesListElements) {
        [XMLError exceptionIfNode:userVariableElement isNilOrNodeNameNotEquals:@"userVariable"];
        UserVariable *userVariable = [context parseFromElement:userVariableElement withClass:[UserVariable class]];
        [XMLError exceptionIfNil:userVariable message:@"Unable to parse user variable..."];
        
        if([userVariable.name length] > 0) {
            if ([CBXMLParserHelper findUserVariableInArray:userVariablesList withName:userVariable.name]) {
                [XMLError exceptionWithMessage:@"An userVariable-entry of the same UserVariable already \
                 exists. This should never happen!"];
            }
            [userVariablesList addObject:userVariable];
        }
    }
    return userVariablesList;
}

+ (NSString *)parseOriginalWidthFromSceneElement:(GDataXMLElement *)sceneElement {
    GDataXMLElement *originalWidthElement = [CBXMLParserHelper onlyChildOfElement:sceneElement withName:kOriginalWidthElementName];
    return originalWidthElement.stringValue;
}

+ (NSString *)parseOriginalHeightFromSceneElement:(GDataXMLElement *)sceneElement {
    GDataXMLElement *originalHeightElement = [CBXMLParserHelper onlyChildOfElement:sceneElement withName:kOriginalHeightElementName];
    return originalHeightElement.stringValue;
}

- (GDataXMLElement *)xmlElementWithContext:(CBXMLSerializerContext *)context {
    context.spriteObjectList = [self.objectList mutableCopy];
    context.objectVariableList = [self.objectVariableList mutableCopy];
    [context.spriteObjectNamePositions removeAllObjects];
    [context.pointedSpriteObjectList removeAllObjects];
    [context.spriteObjectNameUserVariableListPositions removeAllObjects];
    
    GDataXMLElement *sceneElement = [GDataXMLElement elementWithName:kSceneElementName context:context];
    
    [sceneElement addChild:[self nameElementWithContext:context] context:context];
    [sceneElement addChild:[self objectListElementWithContext:context] context:context];
    [sceneElement addChild:[self dataElementWithContext:context] context:context];
    [sceneElement addChild:[self originalWidthElementWithContext:context] context:context];
    [sceneElement addChild:[self originalHeightElementWithContext:context] context:context];
    
    return sceneElement;
}

- (GDataXMLElement *)nameElementWithContext:(CBXMLSerializerContext *)context {
    GDataXMLElement *nameElement = [GDataXMLElement elementWithName:kNameElementName context:context];
    nameElement.stringValue = self.name;
    return nameElement;
}

- (GDataXMLElement *)objectListElementWithContext:(CBXMLSerializerContext *)context {
    GDataXMLElement *objectListElement = [GDataXMLElement elementWithName:@"objectList" context:context];
    
    for (SpriteObject *object in self.objectList) {
        [objectListElement addChild:[object xmlElementWithContext:context] context:context];
    }
    
    return objectListElement;
}

- (GDataXMLElement *)dataElementWithContext:(CBXMLSerializerContext *)context {
    GDataXMLElement *dataElement = [GDataXMLElement elementWithName:kDataElementName context:context];
    
    // add pseudo element to produce a Catroid equivalent XML (unused at the moment)
    [dataElement addChild:[GDataXMLElement elementWithName:kObjectListOfListElementName context:context] context:context];

    [dataElement addChild:[self objectVariableListElementWithContext:context] context:context];
    
    // add pseudo element to produce a Catroid equivalent XML (unused at the moment)
    [dataElement addChild:[GDataXMLElement elementWithName:kUserBrickVariableListElementName context:context] context:context];
    
    return dataElement;
}

- (GDataXMLElement *)objectVariableListElementWithContext:(CBXMLSerializerContext *)context {
    GDataXMLElement *objectVariableListElement = [GDataXMLElement elementWithName:kObjectVariableListElementName context:context];
    NSUInteger objectVariableCount = [self.objectVariableList count];
    
    for (NSUInteger index = 0; index < objectVariableCount; ++index) {
        SpriteObject *spriteObject = [self.objectVariableList keyAtIndex:index];
        [XMLError exceptionIfNil:spriteObject
                      message:@"Instance in objectVariableList at index: %lu is no SpriteObject", (unsigned long)index];
        if (![context.spriteObjectList containsObject:spriteObject]) {
            NSWarn(@"Error while serializing object variable for object '%@': object does not exists!", spriteObject.name);
            continue;
        }
        
        GDataXMLElement *entryElement = [GDataXMLElement elementWithName:@"entry" context:context];
        GDataXMLElement *entryToObjectReferenceElement = [GDataXMLElement elementWithName:@"object" context:context];
        
        CBXMLPositionStack *positionStackOfSpriteObject = context.spriteObjectNamePositions[spriteObject.name];
        CBXMLPositionStack *currentPositionStack = [context.currentPositionStack mutableCopy];
        
        NSString *refPath = [CBXMLSerializerHelper relativeXPathFromSourcePositionStack:currentPositionStack
                                                             toDestinationPositionStack:positionStackOfSpriteObject];
        [entryToObjectReferenceElement addAttribute:[GDataXMLElement attributeWithName:@"reference"
                                                                           stringValue:refPath]];
        
        [entryElement addChild:entryToObjectReferenceElement context:context];
        
        GDataXMLElement *listElement = [GDataXMLElement elementWithName:@"list" context:context];
        NSArray *variables = [self.objectVariableList objectAtIndex:index];
        for (id variable in variables) {
            [XMLError exceptionIf:[variable isKindOfClass:[UserVariable class]] equals:NO
                          message:@"Invalid user variable instance given"];
            
            GDataXMLElement *userVariableElement = [(UserVariable*)variable xmlElementWithContext:context];
            [listElement addChild:userVariableElement context:context];
        }
        
        [entryElement addChild:listElement context:context];
        [objectVariableListElement addChild:entryElement context:context];
    }
    
    return objectVariableListElement;
}

- (GDataXMLElement *)originalWidthElementWithContext:(CBXMLSerializerContext *)context {
    GDataXMLElement *originalWidthElement = [GDataXMLElement elementWithName:kOriginalWidthElementName context:context];
    originalWidthElement.stringValue = self.originalWidth;
    return originalWidthElement;
}

- (GDataXMLElement *)originalHeightElementWithContext:(CBXMLSerializerContext *)context {
    GDataXMLElement *originalHeightElement = [GDataXMLElement elementWithName:kOriginalHeightElementName context:context];
    originalHeightElement.stringValue = self.originalHeight;
    return originalHeightElement;
}

@end
