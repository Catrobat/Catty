/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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
#import "CBXMLParserContext.h"
#import "CBXMLSerializerContext.h"
#import "CBXMLSerializerHelper.h"
#import "CBXMLPositionStack.h"
#import "Script.h"

@implementation PointToBrick (CBXMLHandler)

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLParserContext*)context
{
    if([xmlElement childCount] > 1) {
        [XMLError exceptionWithMessage:@"Too many child nodes found... (0 or 1 expected, actual %lu)", (unsigned long)[xmlElement childCount]];
    }
    
    PointToBrick *pointToBrick = [self new];
    
    if([xmlElement childCount] == 1) {
        [CBXMLParserHelper validateXMLElement:xmlElement forNumberOfChildNodes:1];
        GDataXMLElement *pointedObjectElement = [xmlElement childWithElementName:@"pointedObject"];
        [XMLError exceptionIfNil:pointedObjectElement message:@"No pointedObject element found..."];
    
        // check if pointed sprite object already exists in context (e.g. already created by other PointToBrick)
        CBXMLParserContext *newContext = [context mutableCopy]; // IMPORTANT: copy context!!!
        SpriteObject *spriteObject = [newContext parseFromElement:pointedObjectElement withClass:[SpriteObject class]];
        context.spriteObjectList = newContext.spriteObjectList;
        context.pointedSpriteObjectList = newContext.pointedSpriteObjectList;

        SpriteObject *alreadyExistantSpriteObject = [CBXMLParserHelper findSpriteObjectInArray:context.pointedSpriteObjectList
                                                                                      withName:spriteObject.name];
        if (alreadyExistantSpriteObject) {
            spriteObject = alreadyExistantSpriteObject;
        } else {
            [context.pointedSpriteObjectList addObject:spriteObject];
        }

        pointToBrick.pointedObject = spriteObject;
    }

    return pointToBrick;
}

- (GDataXMLElement*)xmlElementWithContext:(CBXMLSerializerContext*)context
{
    NSUInteger indexOfBrick = [CBXMLSerializerHelper indexOfElement:self inArray:context.brickList];
    GDataXMLElement *brick = [GDataXMLElement elementWithName:@"brick" xPathIndex:(indexOfBrick+1) context:context];
    [brick addAttribute:[GDataXMLElement attributeWithName:@"type" escapedStringValue:@"PointToBrick"]];

    [XMLError exceptionIfNil:self.pointedObject message:@"No sprite object given in PointToBrick"];
    [XMLError exceptionIfNil:self.script.object message:@"Missing reference to brick's sprite object"];
    
    if(self.pointedObject != self.script.object) {
        // check if pointedObject has been already serialized
        NSUInteger indexOfPointedObject = [CBXMLSerializerHelper indexOfElement:self.pointedObject
                                                                inArray:context.spriteObjectList];
        NSUInteger indexOfSpriteObject = [CBXMLSerializerHelper indexOfElement:self.script.object
                                                               inArray:context.spriteObjectList];
        [XMLError exceptionIf:indexOfPointedObject equals:NSNotFound message:@"Pointed object does not exist in spriteObject list"];
        [XMLError exceptionIf:indexOfSpriteObject equals:NSNotFound message:@"Sprite object does not exist in spriteObject list"];

        // check if spriteObject has been already serialized
        CBXMLPositionStack *positionStackOfSpriteObject = context.spriteObjectNamePositions[self.pointedObject.name];
        if (positionStackOfSpriteObject) {
            // already serialized
            GDataXMLElement *pointedObjectXmlElement = [GDataXMLElement elementWithName:@"pointedObject" context:context];
            CBXMLPositionStack *currentPositionStack = [context.currentPositionStack mutableCopy];

            NSString *refPath = [CBXMLSerializerHelper relativeXPathFromSourcePositionStack:currentPositionStack
                                                         toDestinationPositionStack:positionStackOfSpriteObject];
            [pointedObjectXmlElement addAttribute:[GDataXMLElement attributeWithName:@"reference" escapedStringValue:refPath]];
            [brick addChild:pointedObjectXmlElement context:context];
        } else {
            // not serialized yet
            CBXMLSerializerContext *newContext = [context mutableCopy]; // IMPORTANT: copy context!!!
            newContext.currentPositionStack = context.currentPositionStack; // but position stacks must remain the same!
            GDataXMLElement *pointedObjectXmlElement = [self.pointedObject xmlElementWithContext:newContext asPointedObject:YES];
            context.spriteObjectNamePositions = newContext.spriteObjectNamePositions;
            context.spriteObjectNameUserVariableListPositions = newContext.spriteObjectNameUserVariableListPositions;
            context.programUserVariableNamePositions = newContext.programUserVariableNamePositions;
            context.pointedSpriteObjectList = newContext.pointedSpriteObjectList;
            [brick addChild:pointedObjectXmlElement context:context];
            [context.pointedSpriteObjectList addObject:self.pointedObject];
        }
    }
    return brick;
}

@end
