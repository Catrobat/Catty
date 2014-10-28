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

#import "Look+CBXMLHandler.h"
#import "GDataXMLNode.h"
#import "Look.h"
#import "CBXMLValidator.h"

@implementation Look (CBXMLHandler)

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(id)context
{
    [XMLError exceptionIfNode:xmlElement isNilOrNodeNameNotEquals:@"look"];
    GDataXMLNode *nameAttribute = [xmlElement attributeForName:@"name"];
    [XMLError exceptionIfNil:nameAttribute message:@"Look must contain a name attribute"];
    Look *look = [[Look alloc] init];
    look.name = [nameAttribute stringValue];
    NSArray *lookChildElements = [xmlElement children];
    [XMLError exceptionIf:[lookChildElements count] notEquals:1
                  message:@"Look must contain a filename child node"];
    GDataXMLNode *fileNameElement = [lookChildElements firstObject];
    [XMLError exceptionIfString:fileNameElement.name isNotEqualToString:@"fileName"
                        message:@"Look contains wrong child node"];
    look.fileName = [fileNameElement stringValue];
    return look;
}


@end
