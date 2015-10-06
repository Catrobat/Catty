/**
 *  Copyright (C) 2010-2015 The Catrobat Team
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

#import "LoopEndBrick+CBXMLHandler.h"
#import "GDataXMLElement+CustomExtensions.h"
#import "CBXMLValidator.h"
#import "CBXMLParser.h"
#import "CBXMLParserContext.h"
#import "CBXMLSerializerContext.h"
#import "CBXMLOpenedNestingBricksStack.h"
#import "ForeverBrick.h"
#import "RepeatBrick.h"
#import "CBXMLParserHelper.h"
#import "CBXMLSerializerHelper.h"

@implementation LoopEndBrick (CBXMLHandler)

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContextForLanguageVersion093:(CBXMLParserContext*)context
{
    [CBXMLParserHelper validateXMLElement:xmlElement forNumberOfChildNodes:0];
    LoopEndBrick *loopEndBrick = [self new];
    
    // pop opening nesting brick from stack
    Brick *openingNestingBrick = [context.openedNestingBricksStack popAndCloseTopMostNestingBrick];
    if ((! [openingNestingBrick isKindOfClass:[LoopBeginBrick class]])) {
        [XMLError exceptionWithMessage:@"Unexpected closing of nesting brick: expected LoopBeginBrick but \
         got %@", NSStringFromClass([openingNestingBrick class])];
    }
    loopEndBrick.loopBeginBrick = (LoopBeginBrick*)openingNestingBrick;
    LoopBeginBrick *loopBeginBrick = (LoopBeginBrick*)openingNestingBrick;
    loopBeginBrick.loopEndBrick = loopEndBrick;
    return loopEndBrick;
}

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContextForLanguageVersion095:(CBXMLParserContext*)context
{
    return [self parseFromElement:xmlElement withContextForLanguageVersion093:context];
}

- (GDataXMLElement*)xmlElementWithContext:(CBXMLSerializerContext*)context
{
    NSUInteger indexOfBrick = [CBXMLSerializerHelper indexOfElement:self inArray:context.brickList];
    GDataXMLElement *brick = [GDataXMLElement elementWithName:@"brick" xPathIndex:(indexOfBrick+1) context:context];

    // pop opening nesting brick from stack
    Brick *openingNestingBrick = [context.openedNestingBricksStack popAndCloseTopMostNestingBrick];
    if ((! [openingNestingBrick isKindOfClass:[LoopBeginBrick class]])) {
        [XMLError exceptionWithMessage:@"Unexpected closing of nesting brick: expected LoopBeginBrick but \
         got %@", NSStringFromClass([openingNestingBrick class])];
    }
    LoopBeginBrick *loopBeginBrick = (LoopBeginBrick*)openingNestingBrick;
    if (self.loopBeginBrick != loopBeginBrick) {
        [XMLError exceptionWithMessage:@"LoopEndBrick contains no or a reference to other loopBeginBrick"];
    }
    if (loopBeginBrick.loopEndBrick != self) {
        [XMLError exceptionWithMessage:@"LoopBeginBrick contains no or a reference to other loopEndBrick"];
    }

    NSString *brickXmlElementTypeName = nil;
    if ([loopBeginBrick isKindOfClass:[ForeverBrick class]]) {
        brickXmlElementTypeName = @"LoopEndlessBrick";
    } else if ([loopBeginBrick isKindOfClass:[RepeatBrick class]]) {
        brickXmlElementTypeName = @"LoopEndBrick";
    } else {
        [XMLError exceptionWithMessage:@"Found unsupported referenced LoopBeginBrick brick type in LoopEndBrick"];
    }
    [brick addAttribute:[GDataXMLElement attributeWithName:@"type" escapedStringValue:brickXmlElementTypeName]];
    return brick;
}

@end
