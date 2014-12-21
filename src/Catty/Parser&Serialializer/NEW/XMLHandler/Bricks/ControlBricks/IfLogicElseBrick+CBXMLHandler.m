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

#import "IfLogicElseBrick+CBXMLHandler.h"
#import "GDataXMLElement+CustomExtensions.h"
#import "CBXMLValidator.h"
#import "CBXMLParser.h"
#import "CBXMLContext.h"
#import "CBXMLOpenedNestingBricksStack.h"
#import "CBXMLParserHelper.h"
#import "IfLogicBeginBrick.h"
#import "CBXMLSerializerHelper.h"

@implementation IfLogicElseBrick (CBXMLHandler)

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLContext*)context
{
    [CBXMLParserHelper validateXMLElement:xmlElement forNumberOfChildNodes:0];
    IfLogicElseBrick *ifLogicElseBrick = [self new];
    
    // pop opening nesting brick from stack
    Brick *openingNestingBrick = [context.openedNestingBricksStack popAndCloseTopMostNestingBrick];
    if (! [openingNestingBrick isKindOfClass:[IfLogicBeginBrick class]]) {
        [XMLError exceptionWithMessage:@"Unexpected closing of nesting brick: expected IfLogicBeginBrick but got %@", NSStringFromClass([openingNestingBrick class])];
    }
    IfLogicBeginBrick *ifLogicBeginBrick = (IfLogicBeginBrick*)openingNestingBrick;
    ifLogicBeginBrick.ifElseBrick = ifLogicElseBrick;
    ifLogicElseBrick.ifBeginBrick = ifLogicBeginBrick;
    
    // add opening nesting brick on stack
    [context.openedNestingBricksStack pushAndOpenNestingBrick:ifLogicElseBrick];
    return ifLogicElseBrick;
}

- (GDataXMLElement*)xmlElementWithContext:(CBXMLContext*)context
{
    NSUInteger indexOfBrick = [CBXMLSerializerHelper indexOfElement:self inArray:context.brickList];
    GDataXMLElement *brick = [GDataXMLElement elementWithName:@"brick" xPathIndex:(indexOfBrick+1) context:context];
    [brick addAttribute:[GDataXMLNode attributeWithName:@"type" stringValue:@"IfLogicElseBrick"]];

    // pop opening nesting brick from stack
    Brick *openingNestingBrick = [context.openedNestingBricksStack popAndCloseTopMostNestingBrick];
    if (! [openingNestingBrick isKindOfClass:[IfLogicBeginBrick class]]) {
        [XMLError exceptionWithMessage:@"Unexpected closing of nesting brick: expected IfLogicBeginBrick but got %@", NSStringFromClass([openingNestingBrick class])];
    }
    if (((IfLogicBeginBrick*)openingNestingBrick).ifElseBrick != self) {
        [XMLError exceptionWithMessage:@"IfLogicBeginBrick has reference to other else-brick %@",
         NSStringFromClass([openingNestingBrick class])];
    }
    
    // add opening nesting brick on stack
    [context.openedNestingBricksStack pushAndOpenNestingBrick:self];
    return brick;
}

@end
