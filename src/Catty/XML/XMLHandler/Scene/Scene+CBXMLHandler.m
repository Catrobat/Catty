/**
 *  Copyright (C) 2010-2023 The Catrobat Team
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
#import "GDataXMLElement+CustomExtensions.h"
#import "CBXMLValidator.h"
#import "CBXMLParserHelper.h"
#import "CBXMLParserContext.h"
#import "CBXMLSerializerContext.h"
#import "CBXMLPositionStack.h"
#import "CBXMLSerializerHelper.h"
#import "SpriteObject.h"
#import "UserDataContainer+CBXMLHandler.h"
#import "Pocket_Code-Swift.h"

@implementation Scene (CBXMLHandler)

#pragma mark - Parsing
+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLParserContext*)context
{
    Scene *scene = nil;
    if ([xmlElement.name  isEqual: @"scene"]){
        context.currentSceneElement = xmlElement;
        scene = [self parseScene: xmlElement withContext: context];
    } else{
        [XMLError exceptionIfNode:xmlElement isNilOrNodeNameNotEquals:@"scene"];
    }
    context.currentSceneElement = nil;
    return scene;
}


+ (instancetype)parseScene:(GDataXMLElement*)xmlElement withContext:(CBXMLParserContext*)context
{
    NSString *sceneName = [[xmlElement childWithElementName:@"name"] stringValue];
    [XMLError exceptionIfNil:sceneName message:@"No name for Scene given"];
    
    NSMutableArray *objectList = [self parseAndCreateObjectsFromElement:xmlElement withContext:context];
    [XMLError exceptionIfNil:objectList message:@"Unable to parse objectList!"];
    
    Scene *scene = [[Scene alloc] initWithName:sceneName];
    for (SpriteObject *object in objectList){
        [scene addObject:object];
    }
    
    return scene;
}


#pragma mark Object parsing
+ (NSMutableArray*)parseAndCreateObjectsFromElement:(GDataXMLElement*)projectElement
                                        withContext:(CBXMLParserContext*)context
{
    NSArray *objectListElements = [projectElement elementsForName:@"objectList"];
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


#pragma mark - Serialization
- (GDataXMLElement *)xmlElementWithContext:(CBXMLSerializerContext *)context {
    context.spriteObjectList = [[NSMutableArray alloc] initWithArray:self.objects];
    
    NSUInteger indexOfScene = [CBXMLSerializerHelper indexOfElement:self inArray:context.sceneList];
    GDataXMLElement *sceneXmlElement = [GDataXMLElement elementWithName:@"scene" xPathIndex:(indexOfScene+1) context:context];
    
    GDataXMLElement *nameXmlElement = [GDataXMLElement elementWithName:@"name" stringValue:self.name context:context];
    
    [sceneXmlElement addChild:nameXmlElement context:context];
    
    GDataXMLElement *objectListXmlElement = [self xmlElementForObjectListWithContext:context];
    [sceneXmlElement addChild:objectListXmlElement context:context];
    
    return sceneXmlElement;
}

- (GDataXMLElement *)xmlElementForObjectListWithContext:(CBXMLSerializerContext *)context
{
    GDataXMLElement *objectListXmlElement = [GDataXMLElement elementWithName:@"objectList" context:context];
    for (id object in self.objects) {
        [XMLError exceptionIf:[object isKindOfClass:[SpriteObject class]] equals:NO
                      message:@"Invalid sprite object instance given"];
        [objectListXmlElement addChild:[((SpriteObject*)object) xmlElementWithContext:context]
                               context:context];
    }
    return objectListXmlElement;
}

@end
