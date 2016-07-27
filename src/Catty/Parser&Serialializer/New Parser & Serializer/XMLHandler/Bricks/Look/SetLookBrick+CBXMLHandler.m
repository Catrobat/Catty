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

#import "SetLookBrick+CBXMLHandler.h"
#import "CBXMLValidator.h"
#import "GDataXMLElement+CustomExtensions.h"
#import "Look+CBXMLHandler.h"
#import "CBXMLParserContext.h"
#import "CBXMLSerializerContext.h"
#import "CBXMLParserHelper.h"
#import "CBXMLSerializerHelper.h"

@implementation SetLookBrick (CBXMLHandler)

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLParserContext*)context
{
    SetLookBrick *setLookBrick = [self new];
    if([xmlElement childCount] == 0) {
        return setLookBrick;
    }
    
    [CBXMLParserHelper validateXMLElement:xmlElement forNumberOfChildNodes:1];
    
    GDataXMLElement *lookElement = [[xmlElement children] firstObject];
    NSMutableArray *lookList = context.spriteObject.lookList;

    Look *look = nil;
    if ([CBXMLParserHelper isReferenceElement:lookElement]) {
        GDataXMLNode *referenceAttribute = [lookElement attributeForName:@"reference"];
        NSString *xPath = [referenceAttribute stringValue];
        lookElement = [lookElement singleNodeForCatrobatXPath:xPath];
        [XMLError exceptionIfNil:lookElement message:@"Invalid reference in SetLookBrick. No or too many looks found!"];
        GDataXMLNode *nameAttribute = [lookElement attributeForName:@"name"];
        [XMLError exceptionIfNil:nameAttribute message:@"Look element does not contain a name attribute!"];
        look = [CBXMLParserHelper findLookInArray:lookList withName:[nameAttribute stringValue]];
        [XMLError exceptionIfNil:look message:@"Fatal error: no look found in list, but should already exist!"];
    } else {
        // OMG!! a look has been defined within the brick element...
        look = [context parseFromElement:xmlElement withClass:[Look class]];
        [XMLError exceptionIfNil:look message:@"Unable to parse look..."];
        [lookList addObject:look];
    }
    setLookBrick.look = look;
    return setLookBrick;
}

- (GDataXMLElement*)xmlElementWithContext:(CBXMLSerializerContext*)context
{
    NSUInteger indexOfBrick = [CBXMLSerializerHelper indexOfElement:self inArray:context.brickList];
    GDataXMLElement *brick = [GDataXMLElement elementWithName:@"brick" xPathIndex:(indexOfBrick+1) context:context];
    [brick addAttribute:[GDataXMLElement attributeWithName:@"type" escapedStringValue:@"SetLookBrick"]];
    if (self.look) {
        if([CBXMLSerializerHelper indexOfElement:self.look inArray:context.spriteObject.lookList] == NSNotFound) {
            self.look = nil;
        } else {
            GDataXMLElement *referenceXMLElement = [GDataXMLElement elementWithName:@"look" context:context];
            NSString *refPath = [CBXMLSerializerHelper relativeXPathToLook:self.look inLookList:context.spriteObject.lookList];
            [referenceXMLElement addAttribute:[GDataXMLElement attributeWithName:@"reference" escapedStringValue:refPath]];
            [brick addChild:referenceXMLElement context:context];
        }
    }
    return brick;
}

@end
