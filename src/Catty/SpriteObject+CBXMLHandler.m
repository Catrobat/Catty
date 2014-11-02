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
#import "GDataXMLNode+CustomExtensions.h"
#import "CBXMLValidator.h"
#import "SpriteObject.h"
#import "Look+CBXMLHandler.h"
#import "Sound+CBXMLHandler.h"
#import "Script+CBXMLHandler.h"

@implementation SpriteObject (CBXMLHandler)

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(id)context
{
    [XMLError exceptionIfNode:xmlElement isNilOrNodeNameNotEquals:@"object"];
    NSArray *attributes = [xmlElement attributes];
    [XMLError exceptionIf:[attributes count] notEquals:1
                  message:@"Parsed name-attribute of object is invalid or empty!"];
    
    SpriteObject *spriteObject = [SpriteObject new];
    GDataXMLNode *attribute = [attributes firstObject];
    GDataXMLElement *pointedObjectElement = nil;
    // check if normal or pointed object
    if ([attribute.name isEqualToString:@"name"]) {
        spriteObject.name = [attribute stringValue];
    } else if ([attribute.name isEqualToString:@"reference"]) {
        NSString *xPath = [attribute stringValue];
        pointedObjectElement = [xmlElement singleNodeForCatrobatXPath:xPath error:nil];
        [XMLError exceptionIfNode:pointedObjectElement isNilOrNodeNameNotEquals:@"pointedObject"];
        GDataXMLNode *nameAttribute = [pointedObjectElement attributeForName:@"name"];
        [XMLError exceptionIfNil:nameAttribute message:@"PointedObject must contain a name attribute"];
        spriteObject.name = [nameAttribute stringValue];
    } else {
        [XMLError exceptionWithMessage:@"Unsupported attribute: %@!", attribute.name];
    }
    NSLog(@"<object name=\"%@\">", spriteObject.name);
    
    spriteObject.lookList = [[self class] parseAndCreateLooks:(pointedObjectElement ? pointedObjectElement : xmlElement)];
    spriteObject.soundList = [[self class] parseAndCreateSounds:(pointedObjectElement ? pointedObjectElement : xmlElement)];
    spriteObject.scriptList = [[self class] parseAndCreateScripts:(pointedObjectElement ? pointedObjectElement : xmlElement)];
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
        // TODO: ask team if we should return nil or an empty NSMutableArray in this case!!
        return nil;
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
{
    NSArray *scriptListElements = [objectElement elementsForName:@"scriptList"];
    [XMLError exceptionIf:[scriptListElements count] notEquals:1 message:@"No scriptList given!"];
    
    NSArray *scriptElements = [[scriptListElements firstObject] children];
    if (! [scriptElements count]) {
        // TODO: ask team if we should return nil or an empty NSMutableArray in this case!!
        return nil;
    }
    
    NSMutableArray *scriptList = [NSMutableArray arrayWithCapacity:[scriptElements count]];
    for (GDataXMLElement *scriptElement in scriptElements) {
        Script *script = [Script parseFromElement:scriptElement withContext:nil];
        [XMLError exceptionIfNil:script message:@"Unable to parse script..."];
        [scriptList addObject:script];
    }
    return scriptList;
}

@end
