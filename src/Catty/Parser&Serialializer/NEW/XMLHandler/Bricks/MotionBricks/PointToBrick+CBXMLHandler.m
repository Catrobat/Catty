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

#import "PointToBrick+CBXMLHandler.h"
#import "CBXMLValidator.h"
#import "GDataXMLElement+CustomExtensions.h"
#import "SpriteObject+CBXMLHandler.h"
#import "CBXMLParserHelper.h"
#import "CBXMLContext.h"
#import "CBXMLParserHelper.h"
#import "CBXMLSerializerHelper.h"

@implementation PointToBrick (CBXMLHandler)

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLContext*)context
{
    [CBXMLParserHelper validateXMLElement:xmlElement forNumberOfChildNodes:1];
    GDataXMLElement *pointedObjectElement = [xmlElement childWithElementName:@"pointedObject"];
    [XMLError exceptionIfNil:pointedObjectElement message:@"No pointedObject element found..."];
    
    // check if pointed sprite object already exists in context (e.g. already created by other PointToBrick)
    SpriteObject *spriteObject = [SpriteObject parseFromElement:pointedObjectElement withContext:context];
    SpriteObject *alreadyExistantSpriteObject = [CBXMLParserHelper findSpriteObjectInArray:context.pointedSpriteObjectList
                                                                                  withName:spriteObject.name];
    if (alreadyExistantSpriteObject) {
        spriteObject = alreadyExistantSpriteObject;
    } else {
        [context.pointedSpriteObjectList addObject:spriteObject];
    }
    
    PointToBrick *pointToBrick = [self new];
    pointToBrick.pointedObject = spriteObject;
    return pointToBrick;
}

- (GDataXMLElement*)xmlElementWithContext:(CBXMLContext*)context
{
    GDataXMLElement *xmlElement = [GDataXMLNode elementWithName:@"brick"];
    [xmlElement addAttribute:[GDataXMLNode elementWithName:@"type" stringValue:@"PointToBrick"]];
    [XMLError exceptionIfNil:self.pointedObject message:@"No sprite object given in PointToBrick"];
    [XMLError exceptionIfNil:self.object message:@"Missing reference to brick's sprite object"];

    // check if pointedObject has been already serialized
    NSUInteger indexOfPointedObject = [CBXMLSerializerHelper indexOfElement:self.pointedObject
                                                                    inArray:context.spriteObjectList];
    NSUInteger indexOfSpriteObject = [CBXMLSerializerHelper indexOfElement:self.object
                                                                   inArray:context.spriteObjectList];
    [XMLError exceptionIf:indexOfPointedObject equals:NSNotFound message:@"Pointed object does not exist in spriteObject list"];
    [XMLError exceptionIf:indexOfSpriteObject equals:NSNotFound message:@"Sprite object does not exist in spriteObject list"];

    GDataXMLElement *pointedObjectXmlElement = [GDataXMLElement elementWithName:@"pointedObject"];
    if ([CBXMLSerializerHelper indexOfElement:self.object inArray:context.pointedSpriteObjectList] == NSNotFound) {
        // not serialized yet
        GDataXMLElement *objectXmlElement = [self.pointedObject xmlElementWithContext:context];
        GDataXMLNode *nameAttribute = [objectXmlElement attributeForName:@"name"];
        [XMLError exceptionIfNil:nameAttribute message:@"No name attribute in object! This should never happen!!"];
        [pointedObjectXmlElement addAttribute:nameAttribute];
        NSArray *children = [objectXmlElement children];
        for (GDataXMLElement *child in children) {
            [pointedObjectXmlElement addChild:child];
        }
        [xmlElement addChild:pointedObjectXmlElement];
        [context.pointedSpriteObjectList addObject:self.pointedObject];
    } else {
        // already serialized
        NSString *refPath = [CBXMLSerializerHelper relativeXPathToObject:self.pointedObject
                                                            inObjectList:context.spriteObjectList
                                                       programXmlElement:context.programXmlElement
                                          absoluteXPathOfCurrentPosition:<#(NSString *)#>];
        [pointedObjectXmlElement addAttribute:[GDataXMLNode elementWithName:@"reference" stringValue:refPath]];
        [xmlElement addChild:pointedObjectXmlElement];
    }
    return xmlElement;
}

@end
