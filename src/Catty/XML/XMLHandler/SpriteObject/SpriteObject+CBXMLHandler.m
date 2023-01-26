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

#import "SpriteObject+CBXMLHandler.h"
#import "UserDataContainer+CBXMLHandler.h"
#import "GDataXMLElement+CustomExtensions.h"
#import "CBXMLValidator.h"
#import "Look+CBXMLHandler.h"
#import "Sound+CBXMLHandler.h"
#import "Script+CBXMLHandler.h"
#import "CBXMLParserContext.h"
#import "CBXMLSerializerContext.h"
#import "CBXMLParserHelper.h"
#import "CBXMLSerializerHelper.h"
#import "CBXMLPositionStack.h"
#import "UserList+CBXMLHandler.h"

@implementation SpriteObject (CBXMLHandler)

#pragma mark - Parsing
+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLParserContext*)context
{
    [XMLError exceptionIfNil:xmlElement message:@"The rootElement nil"];
    if (! [xmlElement.name isEqualToString:@"object"] && ![xmlElement.name isEqualToString:@"pointedObject"] && ! [xmlElement.name isEqualToString:@"destinationSprite"]) {
        [XMLError exceptionIfString:xmlElement.name
                 isNotEqualToString:@"object"
                            message:@"The name of the rootElement is '%@' but should be '%@'",
         xmlElement.name, @"object, pointedObject or destinationSprite"];
    }

    NSArray *attributes = [xmlElement attributes];
    GDataXMLNode *attribute = nil;
    if (context.languageVersion <= 0.991) {
        [XMLError exceptionIf:[attributes count] notEquals:1
        message:@"Parsed name-attribute of object is invalid or empty!"];
        attribute = [attributes firstObject];
    } else {
        if ([attributes count] == 1) {
            attribute = [attributes firstObject];
        } else if ([attributes count] == 2) {
            attribute = [attributes lastObject];
        } else {
            [XMLError exceptionWithMessage:@"Parsed name-attribute of object is invalid or empty!"];
        }
    }

    SpriteObject *spriteObject = [self new];
    context.spriteObject = spriteObject; // update context!
    
    GDataXMLElement *referencedObjectElement = nil;
    // check if normal or pointed object
    if ([attribute.name isEqualToString:@"name"]) {
        // case: it's a normal object
        spriteObject.name = [attribute stringValue];
    } else if ([attribute.name isEqualToString:@"reference"]) {
        // case: it's a pointed object or a destinationSprite
        NSString *xPath = [attribute stringValue];
        referencedObjectElement = [xmlElement singleNodeForCatrobatXPath:xPath];
        if ([referencedObjectElement.name isEqualToString:@"object"]) {
            [XMLError exceptionIfNode:referencedObjectElement isNilOrNodeNameNotEquals:@"object"];
        } else if([referencedObjectElement.name isEqualToString:@"destinationSprite"]) {
            [XMLError exceptionIfNode:referencedObjectElement isNilOrNodeNameNotEquals:@"destinationSprite"];
        } else {
            [XMLError exceptionIfNode:referencedObjectElement isNilOrNodeNameNotEquals:@"pointedObject"];
        }
        GDataXMLNode *nameAttribute = [referencedObjectElement attributeForName:@"name"];
        [XMLError exceptionIfNil:nameAttribute message:@"PointedObject must contain a name attribute"];
        spriteObject.name = [nameAttribute stringValue];
        xmlElement = referencedObjectElement;
    } else {
        [XMLError exceptionWithMessage:@"Unsupported attribute: %@!", attribute.name];
    }
    [XMLError exceptionIfNil:spriteObject.name message:@"SpriteObject must contain a name"];

    // sprite object could (!) already exist in spriteObjectList or pointedSpriteObjectList at this point!
    SpriteObject *alreadyExistingSpriteObject = [CBXMLParserHelper findSpriteObjectInArray:context.spriteObjectList
                                                                                  withName:spriteObject.name];
    if (alreadyExistingSpriteObject) {
        return alreadyExistingSpriteObject;
    }
    SpriteObject *alreadyExistingPointedSpriteObject = [CBXMLParserHelper findSpriteObjectInArray:context.pointedSpriteObjectList
                                                                                         withName:spriteObject.name];
    if (alreadyExistingPointedSpriteObject) {
        [context.spriteObjectList addObject:spriteObject];
        return alreadyExistingPointedSpriteObject;
    }

    // IMPORTANT: DO NOT CHANGE ORDER HERE!
    [context.spriteObjectList addObject:spriteObject];
    
    spriteObject.userData = [[UserDataContainer class] parseForSpriteObject:xmlElement withContext:context];
    spriteObject.lookList = [self parseAndCreateLooks:xmlElement withContext:context];
    spriteObject.soundList = [self parseAndCreateSounds:xmlElement withContext:context];
    spriteObject.scriptList = [self parseAndCreateScripts:xmlElement withContext:context];
    return spriteObject;
}

+ (NSMutableArray*)parseAndCreateLooks:(GDataXMLElement*)objectElement withContext:(CBXMLParserContext*)context
{
    NSArray *lookListElements = [objectElement elementsForName:@"lookList"];
    [XMLError exceptionIf:[lookListElements count] notEquals:1 message:@"No lookList given!"];
    
    NSArray *lookElements = [[lookListElements firstObject] children];
    if (! [lookElements count]) {
        return [NSMutableArray array];
    }
    
    NSMutableArray *lookList = [NSMutableArray arrayWithCapacity:[lookElements count]];
    for (GDataXMLElement *lookElement in lookElements) {
        Look *look = [context parseFromElement:lookElement withClass:[Look class]];
        [XMLError exceptionIfNil:look message:@"Unable to parse look..."];
        [lookList addObject:look];
    }
    return lookList;
}

+ (NSMutableArray*)parseAndCreateSounds:(GDataXMLElement*)objectElement withContext:(CBXMLParserContext*)context
{
    NSArray *soundListElements = [objectElement elementsForName:@"soundList"];
    [XMLError exceptionIf:[soundListElements count] notEquals:1 message:@"No soundList given!"];
    
    NSArray *soundElements = [[soundListElements firstObject] children];
    if (! [soundElements count]) {
        return [NSMutableArray array];
    }

    NSMutableArray *soundList = [NSMutableArray arrayWithCapacity:[soundElements count]];
    for (GDataXMLElement *soundElement in soundElements) {
        Sound *sound = [context parseFromElement:soundElement withClass:[Sound class]];
        [XMLError exceptionIfNil:sound message:@"Unable to parse sound..."];
        [soundList addObject:sound];
    }
    return soundList;
}

+ (NSMutableArray*)parseAndCreateScripts:(GDataXMLElement*)objectElement
                             withContext:(CBXMLParserContext*)context
{
    NSArray *scriptListElements = [objectElement elementsForName:@"scriptList"];
    [XMLError exceptionIf:[scriptListElements count] notEquals:1 message:@"No scriptList given!"];

    NSArray *scriptElements = [[scriptListElements firstObject] children];
    if (! [scriptElements count]) {
        return [NSMutableArray array];
    }

    NSMutableArray *scriptList = [NSMutableArray arrayWithCapacity:[scriptElements count]];
    for (GDataXMLElement *scriptElement in scriptElements) {
        Script *script = [context parseFromElement:scriptElement withClass:[Script class]];
        [XMLError exceptionIfNil:script message:@"Unable to parse script..."];
        [scriptList addObject:script];
    }
    return scriptList;
}

#pragma mark - Serialization
- (GDataXMLElement*)xmlElementWithContext:(CBXMLSerializerContext*)context
{
    return [self xmlElementWithContext:context asPointedObject:NO asGoToObject:NO];
}

- (GDataXMLElement*)xmlElementWithContext:(CBXMLSerializerContext*)context asPointedObject:(BOOL)asPointedObject asGoToObject:(BOOL)asGoToObject
{
    SpriteObject *previousObject = context.spriteObject;
    [context.soundNamePositions removeAllObjects];
    
    // update context object
    context.spriteObject = self;

    // generate xml element for sprite object
    GDataXMLElement *xmlElement = nil;
    if (! asPointedObject && !asGoToObject) {
        NSUInteger indexOfSpriteObject = [CBXMLSerializerHelper indexOfElement:self inArray:context.spriteObjectList];
        xmlElement = [GDataXMLElement elementWithName:@"object" xPathIndex:(indexOfSpriteObject+1) context:context];
    } else {
        NSString* elementName = asGoToObject ? @"destinationSprite" : @"pointedObject";
        xmlElement = [GDataXMLElement elementWithName:elementName context:context];
    }

    CBXMLPositionStack *currentPositionStack = [context.currentPositionStack mutableCopy];

    // check if spriteObject has been already serialized (e.g. within a PointToBrick)
    CBXMLPositionStack *positionStackOfSpriteObject = context.spriteObjectNamePositions[self.name];
    if (positionStackOfSpriteObject) {
        // already serialized
        NSString *refPath = [CBXMLSerializerHelper relativeXPathFromSourcePositionStack:currentPositionStack
                                                             toDestinationPositionStack:positionStackOfSpriteObject];
        [xmlElement addAttribute:[GDataXMLElement attributeWithName:@"reference" escapedStringValue:refPath]];
        return xmlElement;
    }

    // save current stack position in context
    context.spriteObjectNamePositions[self.name] = currentPositionStack;

    [xmlElement addAttribute:[GDataXMLElement attributeWithName:@"type" escapedStringValue:@"SingleSprite"]];
    [xmlElement addAttribute:[GDataXMLElement attributeWithName:@"name" escapedStringValue:self.name]];

    GDataXMLElement *lookListXmlElement = [GDataXMLElement elementWithName:@"lookList" context:context];
        for (id look in self.lookList) {
        [XMLError exceptionIf:[look isKindOfClass:[Look class]] equals:NO
                      message:@"Invalid look instance given"];
        [lookListXmlElement addChild:[((Look*)look) xmlElementWithContext:context] context:context];
    }
    [xmlElement addChild:lookListXmlElement context:context];
    
    GDataXMLElement *soundListXmlElement = [GDataXMLElement elementWithName:@"soundList" context:context];
    for (id sound in self.soundList) {
        [XMLError exceptionIf:[sound isKindOfClass:[Sound class]] equals:NO
                      message:@"Invalid sound instance given"];
        [soundListXmlElement addChild:[((Sound*)sound) xmlElementWithContext:context] context:context];
    }
    [xmlElement addChild:soundListXmlElement context:context];
    
    GDataXMLElement *scriptListXmlElement = [GDataXMLElement elementWithName:@"scriptList" context:context];
    for (id script in self.scriptList) {
        [XMLError exceptionIf:[script isKindOfClass:[Script class]] equals:NO
                      message:@"Invalid script instance given"];
        [scriptListXmlElement addChild:[((Script*)script) xmlElementWithContext:context] context:context];
    }
    [xmlElement addChild:scriptListXmlElement context:context];
    
    // add pseudo <nfcTagList/> element to produce a Catroid equivalent XML (unused at the moment)
    [xmlElement addChild:[GDataXMLElement elementWithName:@"nfcTagList" context:nil]];
    
    //------------------
    // User Variables
    //------------------
    GDataXMLElement *userVariableListXmlElement = [GDataXMLElement elementWithName:@"userVariables"
                                                                              context:context];
    for (UserVariable *variable in self.userData.variables) {
        GDataXMLElement *userVariableXmlElement = [variable xmlElementWithContext:context];
        [userVariableListXmlElement addChild:userVariableXmlElement context:context];
    }
    [xmlElement addChild:userVariableListXmlElement context:context];
    
    //------------------
    // User Lists
    //------------------
    GDataXMLElement *userListListXmlElement = [GDataXMLElement elementWithName:@"userLists"
                                                                              context:context];
    for (UserList *list in self.userData.lists) {
        GDataXMLElement *userListXmlElement = [list xmlElementWithContext:context];
        [userListListXmlElement addChild:userListXmlElement context:context];
    }
    [xmlElement addChild:userListListXmlElement context:context];
    
    
    if (asPointedObject) {
        context.spriteObject = previousObject;
    }

    return xmlElement;
}

@end
