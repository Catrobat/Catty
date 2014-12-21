/**
 *  Copyright (C) 2010-2014 The Catrobat Team
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
#import "CBXMLContext.h"
#import "CBXMLParserHelper.h"
#import "Script+CBXMLHandler.h"
#import "CBXMLSerializerHelper.h"

@implementation SpriteObject (CBXMLHandler)

#pragma mark - Parsing
+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLContext*)context
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

    // sprite object could (!) already exist in pointedSpriteObjectList or spriteObjectList at this point!
    SpriteObject *alreadyExistingPointedSpriteObject = [CBXMLParserHelper findSpriteObjectInArray:context.pointedSpriteObjectList
                                                                                         withName:spriteObject.name];
    if (alreadyExistingPointedSpriteObject) {
        return alreadyExistingPointedSpriteObject;
    }
    SpriteObject *alreadyExistingSpriteObject = [CBXMLParserHelper findSpriteObjectInArray:context.spriteObjectList
                                                                                  withName:spriteObject.name];
    if (alreadyExistingSpriteObject) {
        return alreadyExistingSpriteObject;
    }

    spriteObject.lookList = [self parseAndCreateLooks:xmlElement];
    context.lookList = spriteObject.lookList;

    spriteObject.soundList = [self parseAndCreateSounds:xmlElement];
    context.soundList = spriteObject.soundList;

    spriteObject.scriptList = [self parseAndCreateScripts:xmlElement withContext:context AndSpriteObject:spriteObject];
    return spriteObject;
}

+ (NSMutableArray*)parseAndCreateLooks:(GDataXMLElement*)objectElement
{
    NSArray *lookListElements = [objectElement elementsForName:@"lookList"];
    [XMLError exceptionIf:[lookListElements count] notEquals:1 message:@"No lookList given!"];
    
    NSArray *lookElements = [[lookListElements firstObject] children];
    if (! [lookElements count]) {
        // TODO: ask team if we should return nil or an empty NSMutableArray in this case!!
        return nil;
    }
    
    NSMutableArray *lookList = [NSMutableArray arrayWithCapacity:[lookElements count]];
    for (GDataXMLElement *lookElement in lookElements) {
        Look *look = [Look parseFromElement:lookElement withContext:nil];
        [XMLError exceptionIfNil:look message:@"Unable to parse look..."];
        [lookList addObject:look];
    }
    return lookList;
}

+ (NSMutableArray*)parseAndCreateSounds:(GDataXMLElement*)objectElement
{
    NSArray *soundListElements = [objectElement elementsForName:@"soundList"];
    [XMLError exceptionIf:[soundListElements count] notEquals:1 message:@"No soundList given!"];
    
    NSArray *soundElements = [[soundListElements firstObject] children];
    if (! [soundElements count]) {
        return [NSMutableArray array];
    }

    NSMutableArray *soundList = [NSMutableArray arrayWithCapacity:[soundElements count]];
    for (GDataXMLElement *soundElement in soundElements) {
        Sound *sound = [Sound parseFromElement:soundElement withContext:nil];
        [XMLError exceptionIfNil:sound message:@"Unable to parse sound..."];
        [soundList addObject:sound];
    }
    return soundList;
}

+ (NSMutableArray*)parseAndCreateScripts:(GDataXMLElement*)objectElement
                             withContext:(CBXMLContext*)context
                         AndSpriteObject:(SpriteObject*)spriteObject
{
    NSArray *scriptListElements = [objectElement elementsForName:@"scriptList"];
    [XMLError exceptionIf:[scriptListElements count] notEquals:1 message:@"No scriptList given!"];
    
    NSArray *scriptElements = [[scriptListElements firstObject] children];
    if (! [scriptElements count]) {
        return [NSMutableArray array];
    }

    NSMutableArray *scriptList = [NSMutableArray arrayWithCapacity:[scriptElements count]];
    for (GDataXMLElement *scriptElement in scriptElements) {
        Script *script = [Script parseFromElement:scriptElement withContext:context];
        script.object = spriteObject;
        [XMLError exceptionIfNil:script message:@"Unable to parse script..."];
        [scriptList addObject:script];
    }
    return scriptList;
}

#pragma mark - Serialization
- (GDataXMLElement*)xmlElementWithContext:(CBXMLContext*)context
{
    // update context object
    context.lookList = self.lookList;
    context.soundList = self.soundList;

    // generate xml element for sprite object
    GDataXMLElement *xmlElement = [GDataXMLElement elementWithName:@"object" context:context];

    // check if spriteObject has been already serialized within a PointToBrick
    NSUInteger pointedObjectIndex = [CBXMLSerializerHelper indexOfElement:self
                                                                  inArray:context.pointedSpriteObjectList];
    if (pointedObjectIndex != NSNotFound) {
        // already serialized
        SpriteObject *pointedObject = [context.pointedSpriteObjectList objectAtIndex:pointedObjectIndex];
        NSString *refPath = [CBXMLSerializerHelper relativeXPathToPointedObject:pointedObject
                                                           forPointedObjectList:context.pointedSpriteObjectList
                                                                  andObjectList:context.spriteObjectList];
        [xmlElement addAttribute:[GDataXMLElement elementWithName:@"reference" stringValue:refPath context:context]];
        return xmlElement;
    }

    [xmlElement addAttribute:[GDataXMLNode attributeWithName:@"name" stringValue:self.name]];

    GDataXMLElement *lookListXmlElement = [GDataXMLElement elementWithName:@"lookList" context:context];
    for (id look in self.lookList) {
        [XMLError exceptionIf:[look isKindOfClass:[Look class]] equals:NO
                      message:@"Invalid look instance given"];
        [lookListXmlElement addChild:[((Look*)look) xmlElementWithContext:nil]];
    }
    [xmlElement addChild:lookListXmlElement];

    GDataXMLElement *soundListXmlElement = [GDataXMLElement elementWithName:@"soundList" context:context];
    for (id sound in self.soundList) {
        [XMLError exceptionIf:[sound isKindOfClass:[Sound class]] equals:NO
                      message:@"Invalid sound instance given"];
        [soundListXmlElement addChild:[((Sound*)sound) xmlElementWithContext:nil]];
    }
    [xmlElement addChild:soundListXmlElement];

    GDataXMLElement *scriptListXmlElement = [GDataXMLElement elementWithName:@"scriptList" context:context];
    for (id script in self.scriptList) {
        [XMLError exceptionIf:[script isKindOfClass:[Script class]] equals:NO
                      message:@"Invalid script instance given"];
        [scriptListXmlElement addChild:[((Script*)script) xmlElementWithContext:context]];
    }
    [xmlElement addChild:scriptListXmlElement];

    // TODO: implement userBricks here...
    GDataXMLElement *userBricksXmlElement = [GDataXMLElement elementWithName:@"userBricks" context:context];
    [xmlElement addChild:userBricksXmlElement];

    NSLog(@"%@", [xmlElement XMLStringPrettyPrinted:YES]);
    return xmlElement;
}

@end
