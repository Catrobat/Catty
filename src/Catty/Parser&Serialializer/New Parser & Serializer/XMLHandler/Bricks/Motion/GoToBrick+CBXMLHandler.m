/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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

#import "GoToBrick+CBXMLHandler.h"
#import "CBXMLValidator.h"
#import "GDataXMLElement+CustomExtensions.h"
#import "GDataXMLNode+CustomExtensions.h"
#import "SpriteObject+CBXMLHandler.h"
#import "CBXMLParserHelper.h"
#import "CBXMLParserContext.h"
#import "CBXMLSerializerContext.h"
#import "CBXMLSerializerHelper.h"
#import "CBXMLPositionStack.h"
#import "Script.h"
#import "Pocket_Code-Swift.h"

@implementation GoToBrick (CBXMLHandler)

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLParserContext*)context
{
    NSUInteger childCount = [xmlElement.childrenWithoutCommentsAndCommentedOutTag count];
    if(childCount > 2) {
        [XMLError exceptionWithMessage:@"Too many child nodes found... (1 or 2 expected, actual %lu)", (unsigned long)[xmlElement childCount]];
    }
    
    NSString *brickType = [[xmlElement attributeForName:@"type"] stringValue];
    GoToBrick *goToBrick = [self new];
            
    if([brickType isEqualToString:@"GoToBrick"]) {
        GDataXMLElement *spinnerSelection = [xmlElement childWithElementName:@"spinnerSelection"];
        [XMLError exceptionIfNil:spinnerSelection message:@"GoToBrick element does not contain a spinnerSelection child element!"];
        
        NSString *goToChoice = [spinnerSelection stringValue];
        [XMLError exceptionIfNil:goToChoice message:@"No goToChoice given..."];
        
        int choiceInt = (int)[goToChoice intValue];
        if(choiceInt < kGoToTouchPosition || choiceInt > kGoToOtherSpritePosition) {
            [XMLError exceptionWithMessage:@"Parameter for spinnerSelection is not valid. Must be 80, 81 or 82"];
        }
        
        goToBrick.spinnerSelection = choiceInt;
        
        [CBXMLParserHelper validateXMLElement:xmlElement forNumberOfChildNodes: choiceInt < kGoToOtherSpritePosition ? 1 : 2];
        
        if(choiceInt == kGoToOtherSpritePosition) {
            GDataXMLElement *goToObjectElement = [xmlElement childWithElementName:@"destinationSprite"];
            [XMLError exceptionIfNil:goToObjectElement message:@"No goToObject element found..."];
            
            // check if goTo sprite object already exists in context (e.g. already created by other PointToBrick)
            CBXMLParserContext *newContext = [context mutableCopy]; // IMPORTANT: copy context!!!
            SpriteObject *spriteObject = [newContext parseFromElement:goToObjectElement withClass:[SpriteObject class]];
            context.spriteObjectList = newContext.spriteObjectList;
            context.pointedSpriteObjectList = newContext.pointedSpriteObjectList;

            SpriteObject *alreadyExistantSpriteObject = [CBXMLParserHelper findSpriteObjectInArray:context.spriteObjectList
                                                                                          withName:spriteObject.name];
            if (alreadyExistantSpriteObject) {
                spriteObject = alreadyExistantSpriteObject;
            } else {
                [context.pointedSpriteObjectList addObject:spriteObject];
            }
            
            goToBrick.goToObject = spriteObject;
        }
    } else {
        [XMLError exceptionWithMessage:@"GoToBrick is faulty!"];
    }

    return goToBrick;
}

- (GDataXMLElement*)xmlElementWithContext:(CBXMLSerializerContext*)context
{
    GDataXMLElement *brick = [super xmlElementForBrickType:@"GoToBrick" withContext:context];

    NSUInteger indexOfSpriteObject = [CBXMLSerializerHelper indexOfElement:self.script.object
    inArray:context.spriteObjectList];
    
    [XMLError exceptionIf:indexOfSpriteObject equals:NSNotFound message:@"Sprite object does not exist in spriteObject list"];
    
    if(self.spinnerSelection == kGoToOtherSpritePosition) {
        NSUInteger indexOfGoToObject = [CBXMLSerializerHelper indexOfElement:self.goToObject inArray:context.spriteObjectList];
        [XMLError exceptionIf:indexOfGoToObject equals:NSNotFound message:@"GoTo object does not exist in spriteObject list"];
        
        // check if spriteObject has been already serialized
        CBXMLPositionStack *positionStackOfSpriteObject = context.spriteObjectNamePositions[self.goToObject.name];
        if (positionStackOfSpriteObject) {
            // already serialized
            GDataXMLElement *goToObjectXmlElement = [GDataXMLElement elementWithName:@"destinationSprite" context:context];
            CBXMLPositionStack *currentPositionStack = [context.currentPositionStack mutableCopy];
            
            NSString *refPath = [CBXMLSerializerHelper relativeXPathFromSourcePositionStack:currentPositionStack
                                                         toDestinationPositionStack:positionStackOfSpriteObject];
            [goToObjectXmlElement addAttribute:[GDataXMLElement attributeWithName:@"reference" escapedStringValue:refPath]];
            [brick addChild:goToObjectXmlElement context:context];
        } else {
            // not serialized yet
            CBXMLSerializerContext *newContext = [context mutableCopy]; // IMPORTANT: copy context!!!
            newContext.currentPositionStack = context.currentPositionStack; // but position stacks must remain the same!
            GDataXMLElement *goToObjectXmlElement = [self.goToObject xmlElementWithContext:newContext asPointedObject:NO asGoToObject:YES];
            context.spriteObjectNamePositions = newContext.spriteObjectNamePositions;
            context.spriteObjectNameUserVariableListPositions = newContext.spriteObjectNameUserVariableListPositions;
            context.projectUserVariableNamePositions = newContext.projectUserVariableNamePositions;
            context.pointedSpriteObjectList = newContext.pointedSpriteObjectList;
            [brick addChild:goToObjectXmlElement context:context];
            [context.pointedSpriteObjectList addObject:self.goToObject];
        }
    }
    
    NSString *spinnerSelectionString = [NSString stringWithFormat:@"%i", self.spinnerSelection];
    GDataXMLElement *spinnerSelection = [GDataXMLElement elementWithName:@"spinnerSelection" stringValue:spinnerSelectionString context:context];
    [brick addChild: spinnerSelection context:context];
    
    return brick;
}

@end
