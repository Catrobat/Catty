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

#import "SpriteObjectCBXMLNodeParser.h"
#import "GDataXMLNode.h"
#import "CBXMLValidator.h"
#import "SpriteObject.h"

@implementation SpriteObjectCBXMLNodeParser

- (id)parseFromElement:(GDataXMLElement*)xmlElement
{
    [CBXMLValidator exceptionIfNil:xmlElement message:@"Parsed an empty object entry!"];
    [NSString stringWithFormat:@"test"];

    NSArray *attributes = [xmlElement attributes];
    if ([attributes count] != 1) {
        [NSException raise:@"InvalidObjectException"
                    format:@"Parsed name-attribute of object is invalid or empty!"];
    }

    SpriteObject *spriteObject = [[SpriteObject alloc] init];
    GDataXMLNode *attribute = [attributes firstObject];
    GDataXMLElement *pointedObjectElement = nil;
    // check if normal or pointed object
    if ([attribute.name isEqualToString:@"name"]) {
        spriteObject.name = [attribute stringValue];
    } else if ([attribute.name isEqualToString:@"reference"]) {
        NSString *xPath = [attribute stringValue];
        NSArray *queriedObjects = [xmlElement nodesForXPath:xPath error:nil];
        if ([queriedObjects count] != 1) {
            [NSException raise:@"InvalidObjectException"
                        format:@"Invalid reference in object. No or too many pointed objects found!"];
        }
        pointedObjectElement = [queriedObjects firstObject];
        GDataXMLNode *nameAttribute = [pointedObjectElement attributeForName:@"name"];
        if (! nameAttribute) {
            [NSException raise:@"InvalidObjectException"
                        format:@"PointedObject must contain a name attribute"];
        }
        spriteObject.name = [nameAttribute stringValue];
    } else {
        [NSException raise:@"InvalidObjectException" format:@"Unsupported attribute: %@!", attribute.name];
    }
    NSLog(@"<object name=\"%@\">", spriteObject.name);

    // TODO: support for WEAK (!) properties required here!!
    spriteObject.lookList = [self parseAndCreateLooks:(pointedObjectElement ? pointedObjectElement : xmlElement)];
    spriteObject.soundList = [self parseAndCreateSounds:(pointedObjectElement ? pointedObjectElement : xmlElement)];
    // TODO: implement this...
    //        spriteObject.scriptList = [self parseAndCreateSounds:(pointedObjectElement ? pointedObjectElement : objectElement)];
    return spriteObject;
}

- (NSMutableArray*)parseAndCreateLooks:(GDataXMLElement*)objectElement
{
    NSArray *lookListElements = [objectElement elementsForName:@"lookList"];
    if ([lookListElements count] != 1) {
        [NSException raise:@"InvalidObjectException" format:@"No lookList given!"];
    }
    
    NSArray *lookElements = [[lookListElements firstObject] children];
    if (! [lookElements count]) {
        return nil;
    }

    NSMutableArray *lookList = [NSMutableArray arrayWithCapacity:[lookElements count]];
//    for (GDataXMLElement *lookElement in lookElements) {
//        Look *look = [[Look alloc] init];
//        GDataXMLNode *nameAttribute = [lookElement attributeForName:@"name"];
//        if (! nameAttribute) {
//            [NSException raise:@"InvalidObjectException"
//                        format:@"Look must contain a name attribute"];
//        }
//        look.name = [nameAttribute stringValue];
//        NSArray *lookChildElements = [lookElement children];
//        if ([lookChildElements count] != 1) {
//            [NSException raise:@"InvalidObjectException"
//                        format:@"Look must contain a filename child node"];
//        }
//        GDataXMLNode *fileNameElement = [lookChildElements firstObject];
//        if (! [fileNameElement.name isEqualToString:@"fileName"]) {
//            [NSException raise:@"InvalidObjectException"
//                        format:@"Look contains wrong child node"];
//        }
//        look.fileName = [fileNameElement stringValue];
//    }
    return lookList;
}

- (NSMutableArray*)parseAndCreateSounds:(GDataXMLElement*)objectElement
{
    NSArray *soundListElements = [objectElement elementsForName:@"soundList"];
    // TODO: increase readability, use macros for such sanity checks...
    if ([soundListElements count] != 1) {
        [NSException raise:@"InvalidObjectException" format:@"No soundList given!"];
    }

    NSArray *soundElements = [[soundListElements firstObject] children];
    if (! [soundElements count]) {
        return nil;
    }

    NSMutableArray *soundList = [NSMutableArray arrayWithCapacity:[soundElements count]];
//    for (GDataXMLElement *soundElement in soundElements) {
//        Sound *sound = [[Sound alloc] init];
//        NSArray *soundChildElements = [soundElement children];
//        if ([soundChildElements count] != 2) {
//            [NSException raise:@"InvalidObjectException"
//                        format:@"Sound must contain two child nodes"];
//        }
//        
//        GDataXMLNode *nameChildNode = [soundChildElements firstObject];
//        GDataXMLNode *fileNameChildNode = [soundChildElements lastObject];
//        
//        // swap values (if needed)
//        if ([fileNameChildNode.name isEqualToString:@"name"] && [nameChildNode.name isEqualToString:@"fileName"]) {
//            nameChildNode = fileNameChildNode;
//            fileNameChildNode = nameChildNode;
//        }
//        
//        if ((! [nameChildNode.name isEqualToString:@"name"]) || (! [fileNameChildNode.name isEqualToString:@"fileName"])) {
//            [NSException raise:@"InvalidObjectException"
//                        format:@"Sound must contains wrong child node(s)"];
//        }
//        sound.name = [nameChildNode stringValue];
//        sound.fileName = [fileNameChildNode stringValue];
//    }
    return soundList;
}

@end
