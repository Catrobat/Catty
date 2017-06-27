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
#import "VariablesContainer+CBXMLHandler.h"
#import "SpriteObject+CBXMLHandler.h"
#import "CBXMLParserContext.h"
#import "CBXMLSerializerContext.h"
#import "Header+CBXMLHandler.h"
#import "Script.h"
#import "BrickFormulaProtocol.h"
#import "OrderedMapTable.h"

@implementation Program (CBXMLHandler)

#pragma mark - Parsing
+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLParserContext*)context
{
    [XMLError exceptionIfNode:xmlElement isNilOrNodeNameNotEquals:@"program"];
    [XMLError exceptionIfNil:context message:@"No context given!"];
    Program *program = [Program new];
    // IMPORTANT: DO NOT CHANGE ORDER HERE!!
    program.header = [self parseAndCreateHeaderFromElement:xmlElement withContext:context];
    program.variables = [self parseAndCreateVariablesFromElement:xmlElement withContext:context];
    program.objectList = [self parseAndCreateObjectsFromElement:xmlElement withContext:context];
    
    [self addMissingVariablesAndListsToVariablesContainer:program.variables withContext:context];
    return program;
}

#pragma mark Header parsing
+ (Header*)parseAndCreateHeaderFromElement:(GDataXMLElement*)programElement
                               withContext:(CBXMLParserContext*)context
{
    NSArray *headerNodes = [programElement elementsForName:@"header"];
    [XMLError exceptionIf:[headerNodes count] notEquals:1 message:@"Invalid header given!"];
    return [context parseFromElement:[headerNodes objectAtIndex:0] withClass:[Header class]];
}

#pragma mark Object parsing
+ (NSMutableArray*)parseAndCreateObjectsFromElement:(GDataXMLElement*)programElement
                                        withContext:(CBXMLParserContext*)context
{
    NSArray *objectListElements = [programElement elementsForName:@"objectList"];
    [XMLError exceptionIf:[objectListElements count] notEquals:1 message:@"No objectList given!"];
    NSArray *objectElements = [[objectListElements firstObject] children];
    [XMLError exceptionIf:[objectListElements count] equals:0
                  message:@"No objects in objectList, but there must exist "\
                          "at least 1 object (background)!!"];
    NSMutableArray *objectList = [NSMutableArray arrayWithCapacity:[objectElements count]];
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

#pragma mark Variable parsing
+ (VariablesContainer*)parseAndCreateVariablesFromElement:(GDataXMLElement*)programElement
                                              withContext:(CBXMLParserContext*)context
{
    return [context parseFromElement:programElement withClass:[VariablesContainer class]];
}

+ (void)addMissingVariablesAndListsToVariablesContainer:(VariablesContainer*)varAndListContainer
                                    withContext:(CBXMLParserContext*)context
{
    for(NSString *objectName in context.formulaVariableNameList) {
        NSArray *variableList = [context.formulaVariableNameList objectForKey:objectName];
         SpriteObject *object = [self getSpriteObject:objectName withContext:context];
        if(!object) {
            NSWarn(@"SpriteObject with name %@ is not found in object list", objectName);
            return;
        }
        
        for(NSString *variableName in variableList) {
            if(![varAndListContainer getUserVariableNamed:variableName forSpriteObject:object]) {
                NSMutableArray *objectVariableList = [varAndListContainer.objectVariableList
                                                      objectForKey:object];
                if(!objectVariableList)
                    objectVariableList = [NSMutableArray new];
                UserVariable *userVariable = [UserVariable new];
                userVariable.name = variableName;
                userVariable.isList = false;
                [objectVariableList addObject:userVariable];
                [varAndListContainer.objectVariableList setObject:objectVariableList forKey:object];
                NSDebug(@"Added UserVariable with name %@ to global object "\
                        "variable list with object %@", variableName, object.name);
            }
        }
    }
    
    for(NSString *objectName in context.formulaListNameList) {
        NSArray *listOfLists = [context.formulaListNameList objectForKey:objectName];
        SpriteObject *object = [self getSpriteObject:objectName withContext:context];
        
        if(!object) {
            NSWarn(@"SpriteObject with name %@ is not found in object list", objectName);
            return;
        }
        
        for(NSString *listName in listOfLists) {
            if(![varAndListContainer getUserListNamed:listName forSpriteObject:object]) {
                NSMutableArray *objectListOfLists = [varAndListContainer.objectListOfLists
                                                     objectForKey:object];
                if(!objectListOfLists)
                    objectListOfLists = [NSMutableArray new];
                UserVariable *userList = [UserVariable new];
                userList.name = listName;
                userList.isList = true;
                [objectListOfLists addObject:userList];
                [varAndListContainer.objectListOfLists setObject:objectListOfLists forKey:object];
                NSDebug(@"Added a user list with name %@ to global object "\
                        "list of lists with object %@", listName, object.name);
            }
        }
    }
}

+ (SpriteObject *)getSpriteObject:(NSString*)spriteName withContext:(CBXMLParserContext*)context
{
    SpriteObject *object = nil;
    for(SpriteObject *spriteObject in context.spriteObjectList) {
        if([spriteObject.name isEqualToString:spriteName]) {
            object = spriteObject;
            break;
        }
    }
    
    return object;
}



#pragma mark - Serialization
- (GDataXMLElement*)xmlElementWithContext:(CBXMLSerializerContext*)context
{
    // update context object
    context.spriteObjectList = self.objectList;
    context.variables = self.variables;

    // generate xml element for program
    GDataXMLElement *xmlElement = [GDataXMLElement elementWithName:@"program" context:context];
    [xmlElement addChild:[self.header xmlElementWithContext:context] context:context];

    GDataXMLElement *objectListXmlElement = [GDataXMLElement elementWithName:@"objectList"
                                                                     context:context];
    for (id object in self.objectList) {
        [XMLError exceptionIf:[object isKindOfClass:[SpriteObject class]] equals:NO
                      message:@"Invalid sprite object instance given"];
        [objectListXmlElement addChild:[((SpriteObject*)object) xmlElementWithContext:context]
                               context:context];
    }
    [xmlElement addChild:objectListXmlElement context:context];

    if (self.variables) {
        [xmlElement addChild:[self.variables xmlElementWithContext:context] context:context];
    }

    // add pseudo <settings/> element to produce a Catroid equivalent XML (unused at the moment)
    [xmlElement addChild:[GDataXMLElement elementWithName:@"settings" context:nil]];
    return xmlElement;
}

@end
