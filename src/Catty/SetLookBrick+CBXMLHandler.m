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

#import "SetLookBrick+CBXMLHandler.h"
#import "CBXMLValidator.h"
#import "GDataXMLNode+CustomExtensions.h"
#import "CBXMLParser.h"
#import "Look+CBXMLHandler.h"
#import "CBXMLContext.h"
#import "Formula+CBXMLHandler.h"
#import "CBXMLParserHelper.h"

@implementation SetLookBrick (CBXMLHandler)

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLContext*)context
{
    [CBXMLParserHelper validateXMLElement:xmlElement forNumberOfChildNodes:1];

    GDataXMLElement *lookElement = [[xmlElement children] firstObject];
    NSMutableArray *lookList = context.lookList;

    Look *look = nil;
    if ([CBXMLParser isReferenceElement:lookElement]) {
        GDataXMLNode *referenceAttribute = [lookElement attributeForName:@"reference"];
        NSString *xPath = [referenceAttribute stringValue];
        lookElement = [lookElement singleNodeForCatrobatXPath:xPath];
        [XMLError exceptionIfNil:lookElement message:@"Invalid reference in SetLookBrick. No or too many looks found!"];
        GDataXMLNode *nameAttribute = [lookElement attributeForName:@"name"];
        [XMLError exceptionIfNil:nameAttribute message:@"Look element does not contain a name attribute!"];
        look = [CBXMLParser findLookInArray:lookList withName:[nameAttribute stringValue]];
        [XMLError exceptionIfNil:look message:@"Fatal error: no look found in list, but should already exist!"];
    } else {
        // OMG!! a look has been defined within the brick element...
        look = [Look parseFromElement:xmlElement withContext:nil];
        [XMLError exceptionIfNil:look message:@"Unable to parse look..."];
        [lookList addObject:look];
    }
    SetLookBrick *setLookBrick = [self new];
    setLookBrick.look = look;
    return setLookBrick;
}

@end
