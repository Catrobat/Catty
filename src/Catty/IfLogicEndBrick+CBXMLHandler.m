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

#import "IfLogicEndBrick+CBXMLHandler.h"
#import "GDataXMLNode+CustomExtensions.h"
#import "CBXMLValidator.h"
#import "CBXMLParser.h"
#import "CBXMLContext.h"
#import "CBXMLOpenedNestingBricksStack.h"
#import "CBXMLParserHelper.h"
#import "IfLogicBeginBrick.h"
#import "IfLogicElseBrick.h"

@implementation IfLogicEndBrick (CBXMLHandler)

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLContext*)context
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
        [XMLError exceptionWithMessage:@"Unexpected closing of nesting brick: expected IfLogicBeginBrick but got %@", NSStringFromClass([openingNestingBrick class])];
    }
    return ifLogicEndBrick;
}

- (GDataXMLElement*)xmlElement
{
    GDataXMLElement *brick = [GDataXMLNode elementWithName:@"brick"];
    [brick addAttribute:[GDataXMLNode elementWithName:@"type" stringValue:@"IfLogicEndBrick"]];
    return brick;
}

@end
