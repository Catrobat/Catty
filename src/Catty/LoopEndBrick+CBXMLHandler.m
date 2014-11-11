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

#import "LoopEndBrick+CBXMLHandler.h"
#import "GDataXMLNode+CustomExtensions.h"
#import "CBXMLValidator.h"
#import "CBXMLParser.h"
#import "CBXMLContext.h"
#import "CBXMLOpenedNestingBricksStack.h"
#import "ForeverBrick+CBXMLHandler.h"

@implementation LoopEndBrick (CBXMLHandler)

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLContext*)context
{
    [XMLError exceptionIf:[xmlElement childCount] notEquals:0 message:@"Too many child nodes found..."];
    
    if(!context) {
        context = [[CBXMLContext alloc] init];
    }
    
    LoopEndBrick *loopEndlessBrick = [self new];
    
    // unregister opening nesting brick on stack
    Brick *openingNestingBrick = [context.openedNestingBricksStack popAndCloseTopMostNestingBrick];
    
    if(![openingNestingBrick isKindOfClass:[ForeverBrick class]]) {
        [XMLError exceptionWithMessage:@"Unexpected closing of nesting brick: expected LoopEndlessBrick but got %@", NSStringFromClass([openingNestingBrick class])];
    }
    
    return loopEndlessBrick;
}

@end
