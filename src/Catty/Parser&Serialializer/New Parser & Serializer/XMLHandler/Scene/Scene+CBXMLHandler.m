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
#import "VariablesContainer+CBXMLHandler.h"
#import "Program+CBXMLHandler.h"
#import "CBXMLParserHelper.h"
#import "CBXMLSerializerContext.h"
#import "CBXMLPositionStack.h"
#import "CBXMLSerializerHelper.h"
#import "UserVariable+CBXMLHandler.h"

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
    
    NSString *name = [self parseNameFromSceneElement:xmlElement];
    OrderedMapTable *objectVariableList = [self parseObjectVariableListFromSceneElement:xmlElement withContext:context];
    
    context.variables.objectVariableList = objectVariableList;
    
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
    
    return [VariablesContainer parseObjectVariableListFromElement:objectVariableListElement withContext:context];
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
    context.variables.objectVariableList = self.objectVariableList;
    
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
