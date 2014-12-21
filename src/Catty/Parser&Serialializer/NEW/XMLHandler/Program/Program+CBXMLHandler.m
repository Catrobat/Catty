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

#import "Program+CBXMLHandler.h"
#import "GDataXMLNode.h"
#import "CBXMLValidator.h"
#import "VariablesContainer+CBXMLHandler.h"
#import "SpriteObject+CBXMLHandler.h"
#import "CBXMLContext.h"
#import "Header+CBXMLHandler.h"
#import "OrderedMapTable.h"
#import "Script.h"
#import "Brick.h"
#import "PointToBrick.h"

@implementation Program (CBXMLHandler)

#pragma mark - Parsing
+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLContext*)context
{
    [XMLError exceptionIfNode:xmlElement isNilOrNodeNameNotEquals:@"program"];
    Program *program = [Program new];
    NSArray *headerNodes = [xmlElement elementsForName:@"header"];
    [XMLError exceptionIf:[headerNodes count] notEquals:1 message:@"Invalid header given!"];
    program.header = [self parseAndCreateHeaderFromElement:[headerNodes objectAtIndex:0]];
    program.objectList = [self parseAndCreateObjectsFromElement:xmlElement withContext:context];
    program.variables = [self parseAndCreateVariablesFromElement:xmlElement withContext:context];
    return program;
}

#pragma mark Header parsing
+ (Header*)parseAndCreateHeaderFromElement:(GDataXMLElement*)programElement
{
    return [Header parseFromElement:programElement withContext:nil];
}

#pragma mark Object parsing
+ (NSMutableArray*)parseAndCreateObjectsFromElement:(GDataXMLElement*)programElement
                                        withContext:(CBXMLContext*)context
{
    NSArray *objectListElements = [programElement elementsForName:@"objectList"];
    [XMLError exceptionIf:[objectListElements count] notEquals:1 message:@"No objectList given!"];
    NSArray *objectElements = [[objectListElements firstObject] children];
    [XMLError exceptionIf:[objectListElements count] equals:0
                  message:@"No objects in objectList, but there must exist at least 1 object (background)!!"];
    NSLog(@"<objectList>");
    NSMutableArray *objectList = [NSMutableArray arrayWithCapacity:[objectElements count]];
    context.spriteObjectList = objectList;
    for (GDataXMLElement *objectElement in objectElements) {
        SpriteObject *spriteObject = [SpriteObject parseFromElement:objectElement withContext:context];
        if (spriteObject != nil)
            [objectList addObject:spriteObject];
    }
    // sanity check => check if all objects from context are in objectList
    for (SpriteObject *pointedObjectInContext in context.pointedSpriteObjectList) {
        BOOL found = NO;
        for (SpriteObject *spriteObject in objectList) {
            if ([pointedObjectInContext.name isEqualToString:spriteObject.name])
                found = YES;
        }
        [XMLError exceptionIf:found equals:NO message:@"Pointed object with name %@ not found in object list!", pointedObjectInContext.name];
    }
    NSLog(@"</objectList>");
    return objectList;
}

#pragma mark Variable parsing
+ (VariablesContainer*)parseAndCreateVariablesFromElement:(GDataXMLElement*)programElement
                                              withContext:(CBXMLContext*)context
{
    return [VariablesContainer parseFromElement:programElement withContext:context];
}

#pragma mark - Serialization
- (GDataXMLElement*)xmlElementWithContext:(CBXMLContext*)context
{
    // IMPORTANT: find all pointedObjects and move them to the end of the spriteObject list
    NSUInteger index = 0;
    NSMutableArray *allPointedObjectRefs = [self.objectList mutableCopy];
    for (id object in self.objectList) {
        [XMLError exceptionIf:[object isKindOfClass:[SpriteObject class]] equals:NO
                      message:@"Invalid sprite object instance given"];

        NSMutableArray *pointedObjectRefs = [NSMutableArray array];
        for (id objectToCompare in self.objectList) {
            [XMLError exceptionIf:[objectToCompare isKindOfClass:[SpriteObject class]] equals:NO
                          message:@"Invalid sprite object instance given"];
            for (id script in ((SpriteObject*)objectToCompare).scriptList) {
                [XMLError exceptionIf:[script isKindOfClass:[Script class]] equals:NO
                              message:@"Invalid script instance given"];
                for (id brick in ((Script*)script).brickList) {
                    [XMLError exceptionIf:[brick isKindOfClass:[Brick class]] equals:NO
                                  message:@"Invalid brick instance given"];
                    if ([brick isKindOfClass:[PointToBrick class]] && (((PointToBrick*)brick).pointedObject == object)) {
                        [pointedObjectRefs addObject:objectToCompare];
                    }
                }
            }
        }
        [allPointedObjectRefs addObject:pointedObjectRefs];
        ++index;
    }

    GDataXMLElement *xmlElement = [GDataXMLNode elementWithName:@"program"];
    context.spriteObjectList = self.objectList;
    [xmlElement addChild:[self.header xmlElementWithContext:context]];

    GDataXMLElement *objectListXmlElement = [GDataXMLNode elementWithName:@"objectList"];
    for (id object in self.objectList) {
        [XMLError exceptionIf:[object isKindOfClass:[SpriteObject class]] equals:NO
                      message:@"Invalid sprite object instance given"];
        [objectListXmlElement addChild:[((SpriteObject*)object) xmlElementWithContext:context]];
    }
    [xmlElement addChild:objectListXmlElement];

    if (self.variables) {
        [xmlElement addChild:[self.variables xmlElementWithContext:context]];
    }
    return xmlElement;
}

@end
