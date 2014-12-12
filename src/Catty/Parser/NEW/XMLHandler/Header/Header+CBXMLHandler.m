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

#import "Header+CBXMLHandler.h"
#import "GDataXMLNode.h"
#import "CBXMLValidator.h"
#import "CBXMLParserHelper.h"

@implementation Header (CBXMLHandler)

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLContext*)context
{
    [XMLError exceptionIfNil:xmlElement message:@"No xml element given!"];
    Header *header = [self defaultHeader];
    NSArray *headerPropertyNodes = [xmlElement children];
    [XMLError exceptionIf:[headerPropertyNodes count] equals:0 message:@"No parsed properties found in header!"];
    //NSLog(@"<header>");
    
    for (GDataXMLNode *headerPropertyNode in headerPropertyNodes) {
        [XMLError exceptionIfNil:headerPropertyNode message:@"Parsed an empty header entry!"];
        id value = [CBXMLParserHelper valueForHeaderPropertyNode:headerPropertyNode];
        //NSLog(@"<%@>%@</%@>", headerPropertyNode.name, value, headerPropertyNode.name);
        NSString *headerPropertyName = headerPropertyNode.name;
        
        // consider special case: name of property programDescription
        if ([headerPropertyNode.name isEqualToString:@"description"]) {
            headerPropertyName = @"programDescription";
        }
        [header setValue:value forKey:headerPropertyName]; // Note: weak properties are not yet supported!!
    }
    //NSLog(@"</header>");
    return header;
}

@end
