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

#import "IfThenLogicEndBrick+CBXMLHandler.h"
#import "GDataXMLElement+CustomExtensions.h"
#import "CBXMLValidator.h"
#import "CBXMLParserContext.h"
#import "CBXMLSerializerContext.h"
#import "CBXMLOpenedNestingBricksStack.h"
#import "CBXMLParserHelper.h"
#import "IfThenLogicBeginBrick.h"
#import "IfLogicElseBrick.h"
#import "CBXMLSerializerHelper.h"

@implementation IfThenLogicEndBrick (CBXMLHandler)

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLParserContext*)context
{
    [CBXMLParserHelper validateXMLElement:xmlElement forNumberOfChildNodes:0];
    IfThenLogicEndBrick *ifLogicEndBrick = [self new];
    
    // pop opening nesting brick from stack
    Brick *openingNestingBrick = [context.openedNestingBricksStack popAndCloseTopMostNestingBrick];
    if ([openingNestingBrick isKindOfClass:[IfThenLogicBeginBrick class]]) {
        IfThenLogicBeginBrick *ifLogicBeginBrick = (IfThenLogicBeginBrick*)openingNestingBrick;
        ifLogicBeginBrick.ifEndBrick = ifLogicEndBrick;
        ifLogicEndBrick.ifBeginBrick = ifLogicBeginBrick;
    } else if ([openingNestingBrick isKindOfClass:[IfLogicElseBrick class]]) {
        [XMLError exceptionWithMessage:@"Unexpected ifElseBrick. IfThenLogicBeginBrick does not have else condition."];
    } else {
        [XMLError exceptionWithMessage:@"Unexpected closing of nesting brick: expected IfLogicBeginBrick or \
         IfLogicElseBrick but got %@", NSStringFromClass([openingNestingBrick class])];
    }
    return ifLogicEndBrick;
}

- (GDataXMLElement*)xmlElementWithContext:(CBXMLSerializerContext*)context
{
    NSUInteger indexOfBrick = [CBXMLSerializerHelper indexOfElement:self inArray:context.brickList];
    GDataXMLElement *brick = [GDataXMLElement elementWithName:@"brick" xPathIndex:(indexOfBrick+1) context:context];
    [brick addAttribute:[GDataXMLElement attributeWithName:@"type" escapedStringValue:@"IfThenLogicEndBrick"]];
    
    // pop opening nesting brick from stack
    Brick *openingNestingBrick = [context.openedNestingBricksStack popAndCloseTopMostNestingBrick];
    if ([openingNestingBrick isKindOfClass:[IfThenLogicBeginBrick class]]) {
        IfThenLogicBeginBrick *ifLogicBeginBrick = (IfThenLogicBeginBrick*)openingNestingBrick;
        if (ifLogicBeginBrick.ifEndBrick != self) {
            [XMLError exceptionWithMessage:@"IfLogicBeginBrick contains a reference to an ifEndBrick that \
             is not equal to current IfLogicEndBrick"];
        }
        if (self.ifBeginBrick != ifLogicBeginBrick) {
            [XMLError exceptionWithMessage:@"IfLogicEndBrick must not contain a reference to an ifElseBrick at this point"];
        }
    } else if ([openingNestingBrick isKindOfClass:[IfLogicElseBrick class]]) {
        [XMLError exceptionWithMessage:@"Unexpected ifElseBrick. IfThenLogicBeginBrick does not have else condition."];
    } else {
        [XMLError exceptionWithMessage:@"Unexpected closing of nesting brick: expected IfLogicBeginBrick or \
         IfLogicElseBrick but got %@", NSStringFromClass([openingNestingBrick class])];
    }
    return brick;
}

@end
