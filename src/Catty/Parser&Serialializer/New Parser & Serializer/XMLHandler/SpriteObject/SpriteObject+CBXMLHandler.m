/**
 *  Copyright (C) 2010-2016 The Catrobat Team
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
#import "GDataXMLElement+CustomExtensions.h"
#import "CBXMLValidator.h"
#import "SpriteObject.h"
#import "Look+CBXMLHandler.h"
#import "Sound+CBXMLHandler.h"
#import "Script+CBXMLHandler.h"
#import "CBXMLParserContext.h"
#import "CBXMLSerializerContext.h"
#import "CBXMLParserHelper.h"
#import "Script+CBXMLHandler.h"
#import "CBXMLSerializerHelper.h"
#import "CBXMLPositionStack.h"

@implementation SpriteObject (CBXMLHandler)

#pragma mark - Parsing
+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLParserContext*)context
{
    [XMLError exceptionIfNil:xmlElement message:@"The rootElement nil"];
    if (! [xmlElement.name isEqualToString:@"object"] && ![xmlElement.name isEqualToString:@"pointedObject"]) {
        [XMLError exceptionIfString:xmlElement.name
                 isNotEqualToString:@"object"
                            message:@"The name of the rootElement is '%@' but should be '%@'",
         xmlElement.name, @"object or pointedObject"];
    }

    NSArray *attributes = [xmlElement attributes];
    [XMLError exceptionIf:[attributes count] notEquals:1
                  message:@"Parsed name-attribute of object is invalid or empty!"];

    SpriteObject *spriteObject = [self new];
    context.spriteObject = spriteObject; // update context!

    GDataXMLNode *attribute = [attributes firstObject];
    GDataXMLElement *referencedObjectElement = nil;
    // check if normal or pointed object
    if ([attribute.name isEqualToString:@"name"]) {
        // case: it's a normal object
        spriteObject.name = [attribute stringValue];
    } else if ([attribute.name isEqualToString:@"reference"]) {
        // case: it's a pointed object
        NSString *xPath = [attribute stringValue];
        referencedObjectElement = [xmlElement singleNodeForCatrobatXPath:xPath];
        if ([referencedObjectElement.name isEqualToString:@"object"]) {
            [XMLError exceptionIfNode:referencedObjectElement isNilOrNodeNameNotEquals:@"object"];
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
    return [self xmlElementWithContext:context asPointedObject:NO];
}

- (GDataXMLElement*)xmlElementWithContext:(CBXMLSerializerContext*)context asPointedObject:(BOOL)asPointedObject
{
    // update context object
    context.spriteObject = self;

    // generate xml element for sprite object
    GDataXMLElement *xmlElement = nil;
    if (! asPointedObject) {
        NSUInteger indexOfSpriteObject = [CBXMLSerializerHelper indexOfElement:self inArray:context.spriteObjectList];
        xmlElement = [GDataXMLElement elementWithName:@"object" xPathIndex:(indexOfSpriteObject+1) context:context];
    } else {
        xmlElement = [GDataXMLElement elementWithName:@"pointedObject" context:context];
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

    //  Unused at the moment => implement this after Catroid has decided to officially activate this!
    //    GDataXMLElement *userBricksXmlElement = [GDataXMLElement elementWithName:@"userBricks" context:context];
    //    [xmlElement addChild:userBricksXmlElement context:context];
    
    // add pseudo <userBricks/> element to produce a Catroid equivalent XML (unused at the moment)
    [xmlElement addChild:[GDataXMLElement elementWithName:@"userBricks" context:nil]];
    
    // add pseudo <nfcTagList/> element to produce a Catroid equivalent XML (unused at the moment)
    [xmlElement addChild:[GDataXMLElement elementWithName:@"nfcTagList" context:nil]];

    return xmlElement;
}

@end
