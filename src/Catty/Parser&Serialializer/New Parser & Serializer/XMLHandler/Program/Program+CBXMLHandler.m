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

#import "Program+CBXMLHandler.h"
#import "GDataXMLElement+CustomExtensions.h"
#import "CBXMLValidator.h"
#import "SpriteObject+CBXMLHandler.h"
#import "CBXMLParserContext.h"
#import "CBXMLSerializerContext.h"
#import "Header+CBXMLHandler.h"
#import "Script.h"
#import "BrickFormulaProtocol.h"
#import "OrderedMapTable.h"
#import "CBXMLParserHelper.h"
#import "Scene+CBXMLHandler.h"
#import "UserVariable+CBXMLHandler.h"
#import "OrderedDictionary.h"
#import "NSArray+CustomExtension.h"

@implementation Program (CBXMLHandler)

#pragma mark - Parsing
+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLParserContext*)context
{
    [XMLError exceptionIfNode:xmlElement isNilOrNodeNameNotEquals:@"program"];
    [XMLError exceptionIfNil:context message:@"No context given!"];
    
    GDataXMLElement *headerElement = [CBXMLParserHelper onlyChildOfElement:xmlElement withName:@"header"];
    Header *header = [self parseAndCreateHeaderFromElement:headerElement withContext:context];
    
    NSArray<Scene *> *scenes;
    NSArray<UserVariable *> *programVariableList;
    
    if (context.languageVersion <= 0.991) {
        NSString *variablesWrapperElementName = context.languageVersion == 0.93f ? @"variables" : @"data";
        GDataXMLElement *variablesWrapperElement = [CBXMLParserHelper onlyChildOfElement:xmlElement withName:variablesWrapperElementName];
        
        GDataXMLElement *programVariableListElement = [CBXMLParserHelper onlyChildOfElement:variablesWrapperElement withName:@"programVariableList"];
        programVariableList = [self parseProgramVariableListFromElement:programVariableListElement withContext:context];
        
        context.programVariableList = [programVariableList mutableCopy];
        
        GDataXMLElement *objectVariableListElement = [CBXMLParserHelper onlyChildOfElement:variablesWrapperElement withName:@"objectVariableList"];
        OrderedMapTable *objectVariableList = [self parseObjectVariableListFromElement:objectVariableListElement withContext:context];
        
        context.objectVariableList = [objectVariableList mutableCopy];
        
        GDataXMLElement *objectListElement = [CBXMLParserHelper onlyChildOfElement:xmlElement withName:@"objectList"];
        NSArray<SpriteObject *> *objectList = [self parseObjectListFromElement:objectListElement withContext:context];
        
        [self addMissingVariablesToObjectVariableList:objectVariableList withContext:context];
        
        scenes = [NSArray arrayWithObject:[[Scene alloc] initWithName:@"Scene 1"
                                                                   objectList:[objectList mutableCopy]
                                                           objectVariableList:objectVariableList
                                                                originalWidth:[header.screenWidth stringValue]
                                                               originalHeight:[header.screenHeight stringValue]]];
    } else {
        GDataXMLElement *programVariableListElement = [CBXMLParserHelper onlyChildOfElement:xmlElement withName:@"programVariableList"];
        programVariableList = [self parseProgramVariableListFromElement:programVariableListElement
                                                                                  withContext:context];
        
        context.programVariableList = [programVariableList mutableCopy];
        
        GDataXMLElement *scenesElement = [CBXMLParserHelper onlyChildOfElement:xmlElement withName:@"scenes"];
        scenes = [self parseScenesFromElement:scenesElement withContext:context];
    }
    
    return [[Program alloc] initWithHeader:header scenes:scenes programVariableList:programVariableList];
}

#pragma mark Header parsing
+ (Header*)parseAndCreateHeaderFromElement:(GDataXMLElement*)headerElement withContext:(CBXMLParserContext*)context
{
    return [context parseFromElement:headerElement withClass:[Header class]];
}

+ (NSMutableArray<SpriteObject *> *)parseObjectListFromElement:(GDataXMLElement *)objectListElement
                                                   withContext:(CBXMLParserContext *)context {
    NSParameterAssert([objectListElement.name isEqualToString:@"objectList"]);
    NSParameterAssert(context);
    
    NSArray *objectElements = [objectListElement children];
    [XMLError exceptionIf:[objectElements count] equals:0
                  message:@"No objects in objectList, but there must exist at least 1 object (background)!!"];
    
    NSMutableArray<SpriteObject *> *objectList = [NSMutableArray arrayWithCapacity:[objectElements count]];
    for (GDataXMLElement *objectElement in objectElements) {
        SpriteObject *spriteObject = [context parseFromElement:objectElement
                                                     withClass:[SpriteObject class]];
        [XMLError exceptionIfNil:spriteObject message:@"Unable to parse SpriteObject!"];
        [objectList addObject:spriteObject];
    }

    // sanity check => check if both objectLists are equal
    [XMLError exceptionIf:[objectList count] notEquals:[context.spriteObjectList count]
                  message:@"Both SpriteObjectLists must be identical!"];
    for (SpriteObject *spriteObject in objectList) {
        BOOL found = NO;
        for (SpriteObject *spriteObjectToCompare in context.spriteObjectList) {
            if (spriteObjectToCompare == spriteObject) {
                found = YES;
                break;
            }
        }
        [XMLError exceptionIf:found equals:NO message:@"Both SpriteObjectLists must be equal!"];
    }

    // sanity check => check if objectList in context contains all objects
    for (SpriteObject *pointedObjectInContext in context.pointedSpriteObjectList) {
        BOOL found = NO;
        for (SpriteObject *spriteObject in objectList) {
            if (pointedObjectInContext == spriteObject)
                found = YES;
        }
        [XMLError exceptionIf:found equals:NO
                      message:@"Pointed object with name %@ not found in object list!",
         pointedObjectInContext.name];
    }
    return objectList;
}

+ (NSMutableArray<UserVariable *> *)parseProgramVariableListFromElement:(GDataXMLElement *)programVariableListElement
                                                            withContext:(CBXMLParserContext *)context {
    return [self parseUserVariablesList:[programVariableListElement children] withContext:context];
}

+ (OrderedMapTable *)parseObjectVariableListFromElement:(GDataXMLElement *)objectVariableListElement
                                            withContext:(CBXMLParserContext *)context {
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


+ (NSArray<Scene *> *)parseScenesFromElement:(GDataXMLElement *)scenesElement withContext:(CBXMLParserContext *)context {
    NSArray *sceneElements = [scenesElement children];
    NSMutableArray<Scene *> *scenes = [NSMutableArray arrayWithCapacity:sceneElements.count];
    
    for (GDataXMLElement *sceneElement in sceneElements) {
        Scene *scene = [context parseFromElement:sceneElement withClass:[Scene class]];
        [self addMissingVariablesToObjectVariableList:scene.objectVariableList withContext:context];
        
        [scenes addObject:scene];
    }
    return scenes;
}

+ (void)addMissingVariablesToObjectVariableList:(OrderedMapTable*)objectVariableList
                                    withContext:(CBXMLParserContext*)context
{
    for(NSString *objectName in context.formulaVariableNameList) {
        NSArray *variableList = [context.formulaVariableNameList objectForKey:objectName];
        SpriteObject *object = nil;
        for(SpriteObject *spriteObject in context.spriteObjectList) {
            if([spriteObject.name isEqualToString:objectName]) {
                object = spriteObject;
                break;
            }
        }
        if(!object) {
            NSWarn(@"SpriteObject with name %@ is not found in object list", objectName);
            return;
        }
        
        for(NSString *variableName in variableList) {
            BOOL isProgramVariable = [context.programVariableList cb_hasAny:^BOOL(UserVariable *item) {
                return [item.name isEqualToString:variableName];
            }];
            BOOL variableExists = [[objectVariableList objectForKey:object] cb_hasAny:^BOOL(UserVariable *item) {
                return [item.name isEqualToString:variableName];
            }];
            
            if(!isProgramVariable && !variableExists) {
                NSMutableArray *objectVariables = [objectVariableList objectForKey:object];
                if(!objectVariables)
                    objectVariables = [NSMutableArray new];
                UserVariable *userVariable = [UserVariable new];
                userVariable.name = variableName;
                [objectVariables addObject:userVariable];
                [objectVariableList setObject:objectVariables forKey:object];
                NSDebug(@"Added UserVariable with name %@ to global object "\
                        "variable list with object %@", variableName, object.name);
            }
        }
    }
}

#pragma mark - Serialization
- (GDataXMLElement*)xmlElementWithContext:(CBXMLSerializerContext*)context
{
    context.programVariableList = [self.programVariableList mutableCopy];

    GDataXMLElement *xmlElement = [GDataXMLElement elementWithName:@"program" context:context];
    
    [xmlElement addChild:[self.header xmlElementWithContext:context] context:context];
    [xmlElement addChild:[self scenesElementWithContext:context] context:context];
    [xmlElement addChild:[self programVariableListElementWithContext:context] context:context];
    
    // add pseudo element to produce a Catroid equivalent XML (unused at the moment)
    [xmlElement addChild:[GDataXMLElement elementWithName:@"programListOfLists" context:context] context:context];

    // add pseudo element to produce a Catroid equivalent XML (unused at the moment)
    [xmlElement addChild:[GDataXMLElement elementWithName:@"settings" context:context] context:context];
    
    return xmlElement;
}

- (GDataXMLElement *)scenesElementWithContext:(CBXMLSerializerContext *)context {
    GDataXMLElement *scenesElement = [GDataXMLElement elementWithName:@"scenes" context:context];
    
    for (Scene *scene in self.scenes) {
        [scenesElement addChild:[scene xmlElementWithContext:context] context:context];
    }
    
    return scenesElement;
}

- (GDataXMLElement *)programVariableListElementWithContext:(CBXMLSerializerContext *)context {
    GDataXMLElement *programVariableListElement = [GDataXMLElement elementWithName:@"programVariableList" context:context];
    
    for (UserVariable *userVariable in self.programVariableList) {
        [programVariableListElement addChild:[userVariable xmlElementWithContext:context] context:context];
    }
    
    return programVariableListElement;
}

@end
