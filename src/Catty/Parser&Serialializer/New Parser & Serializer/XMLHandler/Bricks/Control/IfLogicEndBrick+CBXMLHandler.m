/**
 *  Copyright (C) 2010-2016 The Catrobat Team
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

#import "IfLogicEndBrick+CBXMLHandler.h"
#import "GDataXMLElement+CustomExtensions.h"
#import "CBXMLValidator.h"
#import "CBXMLParser.h"
#import "CBXMLParserContext.h"
#import "CBXMLSerializerContext.h"
#import "CBXMLOpenedNestingBricksStack.h"
#import "CBXMLParserHelper.h"
#import "IfLogicBeginBrick.h"
#import "IfLogicElseBrick.h"
#import "CBXMLSerializerHelper.h"

@implementation IfLogicEndBrick (CBXMLHandler)

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContextForLanguageVersion093:(CBXMLParserContext*)context
{
    [CBXMLParserHelper validateXMLElement:xmlElement forNumberOfChildNodes:0];
    IfLogicEndBrick *ifLogicEndBrick = [self new];
    
    // pop opening nesting brick from stack
    Brick *openingNestingBrick = [context.openedNestingBricksStack popAndCloseTopMostNestingBrick];
    if ([openingNestingBrick isKindOfClass:[IfLogicBeginBrick class]]) {
        IfLogicBeginBrick *ifLogicBeginBrick = (IfLogicBeginBrick*)openingNestingBrick;
        if (ifLogicBeginBrick.ifElseBrick) {
            [XMLError exceptionWithMessage:@"IfLogicBeginBrick contains a reference to an ifElseBrick that \
             is not at the top of the CBXMLOpenedNestingBricksStack"];
        }
        ifLogicBeginBrick.ifEndBrick = ifLogicEndBrick;
        ifLogicEndBrick.ifBeginBrick = ifLogicBeginBrick;
    } else if ([openingNestingBrick isKindOfClass:[IfLogicElseBrick class]]) {
        IfLogicElseBrick *ifLogicElseBrick = (IfLogicElseBrick*)openingNestingBrick;
        [XMLError exceptionIfNil:ifLogicElseBrick.ifBeginBrick
                         message:@"IfLogicElseBrick contains no reference to an ifBeginBrick"];
        [XMLError exceptionIf:[ifLogicElseBrick.ifBeginBrick isKindOfClass:[IfLogicBeginBrick class]] equals:NO
                      message:@"Invalid reference class type for ifBeginBrick in ifLogicElseBrick given"];
        
        IfLogicBeginBrick *ifLogicBeginBrick = ifLogicElseBrick.ifBeginBrick;
        if ((! ifLogicBeginBrick.ifElseBrick) || (ifLogicBeginBrick.ifElseBrick != ifLogicElseBrick)) {
            [XMLError exceptionWithMessage:@"IfLogicBeginBrick contains no or a reference to other ifElseBrick"];
        }
        
        // add references to ifEndBrick in ifLogicBeginBrick and ifLogicElseBrick
        ifLogicBeginBrick.ifEndBrick = ifLogicEndBrick;
        ifLogicElseBrick.ifEndBrick = ifLogicEndBrick;
        
        // add references in ifEndBrick
        ifLogicEndBrick.ifBeginBrick = ifLogicBeginBrick;
        ifLogicEndBrick.ifElseBrick = ifLogicElseBrick;
    } else {
        [XMLError exceptionWithMessage:@"Unexpected closing of nesting brick: expected IfLogicBeginBrick or \
         IfLogicElseBrick but got %@", NSStringFromClass([openingNestingBrick class])];
    }
    return ifLogicEndBrick;
}

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContextForLanguageVersion095:(CBXMLParserContext*)context
{
    return [self parseFromElement:xmlElement withContextForLanguageVersion093:context];
}

- (GDataXMLElement*)xmlElementWithContext:(CBXMLSerializerContext*)context
{
    NSUInteger indexOfBrick = [CBXMLSerializerHelper indexOfElement:self inArray:context.brickList];
    GDataXMLElement *brick = [GDataXMLElement elementWithName:@"brick" xPathIndex:(indexOfBrick+1) context:context];
    [brick addAttribute:[GDataXMLElement attributeWithName:@"type" escapedStringValue:@"IfLogicEndBrick"]];

    // pop opening nesting brick from stack
    Brick *openingNestingBrick = [context.openedNestingBricksStack popAndCloseTopMostNestingBrick];
    if ([openingNestingBrick isKindOfClass:[IfLogicBeginBrick class]]) {
        IfLogicBeginBrick *ifLogicBeginBrick = (IfLogicBeginBrick*)openingNestingBrick;
        [XMLError exceptionIfNil:ifLogicBeginBrick.ifElseBrick message:@"IfLogicBeginBrick contains a \
         reference to an ifElseBrick that is not at the top of the CBXMLOpenedNestingBricksStack"];
        [XMLError exceptionIfNil:self.ifElseBrick message:@"IfLogicEndBrick contains a reference to an \
         ifElseBrick that is not at the top of the CBXMLOpenedNestingBricksStack"];
        if (ifLogicBeginBrick.ifEndBrick != self) {
            [XMLError exceptionWithMessage:@"IfLogicBeginBrick contains a reference to an ifEndBrick that \
             is not equal to current IfLogicEndBrick"];
        }
        if (self.ifBeginBrick != ifLogicBeginBrick) {
            [XMLError exceptionWithMessage:@"IfLogicEndBrick must not contain a reference to an ifElseBrick at this point"];
        }
    } else if ([openingNestingBrick isKindOfClass:[IfLogicElseBrick class]]) {
        IfLogicElseBrick *ifLogicElseBrick = (IfLogicElseBrick*)openingNestingBrick;
        [XMLError exceptionIfNil:ifLogicElseBrick.ifBeginBrick
                         message:@"IfLogicElseBrick contains no reference to an ifBeginBrick"];
        [XMLError exceptionIf:[ifLogicElseBrick.ifBeginBrick isKindOfClass:[IfLogicBeginBrick class]] equals:NO
                      message:@"Invalid reference class type for ifBeginBrick in ifLogicElseBrick given"];
        [XMLError exceptionIfNil:ifLogicElseBrick.ifEndBrick
                         message:@"IfLogicElseBrick contains no reference to an ifEndBrick"];
        [XMLError exceptionIf:[ifLogicElseBrick.ifEndBrick isKindOfClass:[IfLogicEndBrick class]] equals:NO
                      message:@"Invalid reference class type for ifEndBrick in ifLogicElseBrick given"];
        IfLogicBeginBrick *ifLogicBeginBrick = ifLogicElseBrick.ifBeginBrick;
        if (ifLogicBeginBrick.ifElseBrick != ifLogicElseBrick) {
            [XMLError exceptionWithMessage:@"IfLogicBeginBrick contains no or a reference to other ifElseBrick"];
        }
        if (ifLogicBeginBrick.ifEndBrick != self) {
            [XMLError exceptionWithMessage:@"IfLogicBeginBrick contains no or a reference to other ifEndBrick"];
        }
        if (ifLogicElseBrick.ifEndBrick != self) {
            [XMLError exceptionWithMessage:@"IfLogicElseBrick contains no or a reference to other ifEndBrick"];
        }
        if (self.ifBeginBrick != ifLogicBeginBrick) {
            [XMLError exceptionWithMessage:@"IfLogicEndBrick contains no or a reference to other ifBeginBrick"];
        }
        if (self.ifElseBrick != ifLogicElseBrick) {
            [XMLError exceptionWithMessage:@"IfLogicEndBrick contains no or a reference to other ifElseBrick"];
        }
    } else {
        [XMLError exceptionWithMessage:@"Unexpected closing of nesting brick: expected IfLogicBeginBrick or \
         IfLogicElseBrick but got %@", NSStringFromClass([openingNestingBrick class])];
    }
    return brick;
}

@end
