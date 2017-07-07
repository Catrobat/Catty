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
#import "CBXMLParserHelper.h"
#import "Scene+CBXMLHandler.h"
#import "UserVariable+CBXMLHandler.h"

@implementation Program (CBXMLHandler)

#pragma mark - Parsing
+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLParserContext*)context
{
    [XMLError exceptionIfNode:xmlElement isNilOrNodeNameNotEquals:@"program"];
    [XMLError exceptionIfNil:context message:@"No context given!"];
    
    Program *program = [[Program alloc] init];
    program.header = [self parseAndCreateHeaderFromElement:xmlElement withContext:context];
    
    if (context.languageVersion <= 0.991) {
        VariablesContainer *variables = [context parseFromElement:xmlElement withClass:[VariablesContainer class]];
        program.programVariableList = variables.programVariableList;
        
        GDataXMLElement *objectListElement = [CBXMLParserHelper onlyChildOfElement:xmlElement withName:@"objectList"];
        NSArray<SpriteObject *> *objectList = [self parseObjectListFromElement:objectListElement withContext:context];
        
        program.scenes = [NSArray arrayWithObject:[[Scene alloc] initWithName:@"Scene 1"
                                                                   objectList:[objectList mutableCopy]
                                                           objectVariableList:variables.objectVariableList
                                                                originalWidth:[program.header.screenWidth stringValue]
                                                               originalHeight:[program.header.screenHeight stringValue]]];
    } else {
        GDataXMLElement *scenesElement = [CBXMLParserHelper onlyChildOfElement:xmlElement withName:@"scenes"];
        program.scenes = [self parseScenesFromElement:scenesElement withContext:context];
        
        GDataXMLElement *programVariableListElement = [CBXMLParserHelper onlyChildOfElement:xmlElement withName:@"programVariableList"];
        program.programVariableList = [VariablesContainer parseProgramVariableListFromElement:programVariableListElement
                                                                                  withContext:context];
    }
    
    [self addMissingVariablesToVariablesContainer:program.variables withContext:context];
    
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

+ (NSArray<Scene *> *)parseScenesFromElement:(GDataXMLElement *)scenesElement withContext:(CBXMLParserContext *)context {
    NSArray *sceneElements = [scenesElement children];
    NSMutableArray<Scene *> *scenes = [NSMutableArray arrayWithCapacity:sceneElements.count];
    
    for (GDataXMLElement *sceneElement in sceneElements) {
        Scene *scene = [context parseFromElement:sceneElement withClass:[Scene class]];
        [scenes addObject:scene];
    }
    return scenes;
}

+ (void)addMissingVariablesToVariablesContainer:(VariablesContainer*)variablesContainer
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
            if(![variablesContainer getUserVariableNamed:variableName forSpriteObject:object]) {
                NSMutableArray *objectVariableList = [variablesContainer.objectVariableList
                                                      objectForKey:object];
                if(!objectVariableList)
                    objectVariableList = [NSMutableArray new];
                UserVariable *userVariable = [UserVariable new];
                userVariable.name = variableName;
                [objectVariableList addObject:userVariable];
                [variablesContainer.objectVariableList setObject:objectVariableList forKey:object];
                NSDebug(@"Added UserVariable with name %@ to global object "\
                        "variable list with object %@", variableName, object.name);
            }
        }
    }
}

#pragma mark - Serialization
- (GDataXMLElement*)xmlElementWithContext:(CBXMLSerializerContext*)context
{
    context.spriteObjectList = self.objectList;
    context.variables.programVariableList = self.programVariableList;

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
