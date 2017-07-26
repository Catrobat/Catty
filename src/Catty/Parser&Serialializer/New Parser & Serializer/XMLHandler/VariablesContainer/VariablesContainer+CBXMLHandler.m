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

    NSArray *programVarListElements = [variablesElement elementsForName:@"programVariableList"];
    if ([programVarListElements count]) {
        [XMLError exceptionIf:[programVarListElements count] notEquals:1
                      message:@"Too many programVariableList-elements!"];
        GDataXMLElement *programVarListElement = [programVarListElements firstObject];
        varContainer.programVariableList = [self parseProgramVariableListFromElement:programVarListElement withContext:context];
        context.programVariableList = varContainer.programVariableList;
    }

    NSArray *objectVarListElements = [variablesElement elementsForName:@"objectVariableList"];
    if ([objectVarListElements count]) {
        [XMLError exceptionIf:[objectVarListElements count] notEquals:1 message:@"Too many objectVariableList-elements!"];
        GDataXMLElement *objectVarListElement = [objectVarListElements firstObject];
        
        varContainer.objectVariableList = [self parseObjectVariableListFromElement:objectVarListElement withContext:context];
    }
    
    context.variables = varContainer;
    return varContainer;
}

+ (NSMutableArray<UserVariable *> *)parseProgramVariableListFromElement:(GDataXMLElement *)programVariableListElement
                                                            withContext:(CBXMLParserContext *)context {
    [XMLError exceptionIfString:programVariableListElement.name
             isNotEqualToString:@"programVariableList"
                        message:@"programVariableList element is expected"];
    
    return [self parseUserVariablesList:[programVariableListElement children] withContext:context];
}

+ (OrderedMapTable *)parseObjectVariableListFromElement:(GDataXMLElement *)objectVariableListElement
                                            withContext:(CBXMLParserContext *)context {
    [XMLError exceptionIfString:objectVariableListElement.name
             isNotEqualToString:@"objectVariableList"
                        message:@"objectVariableList element is expected"];
    
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

#pragma mark - Serialization
- (GDataXMLElement*)xmlElementWithContext:(CBXMLSerializerContext*)context
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Shouldn't serialize VariablesContainer class"
                                 userInfo:nil];
}


@end
