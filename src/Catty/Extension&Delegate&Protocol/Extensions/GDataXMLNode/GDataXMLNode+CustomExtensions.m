/**
 *  Copyright (C) 2010-2017 The Catrobat Team
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

#import "GDataXMLNode+CustomExtensions.h"

@implementation GDataXMLNode (CustomExtensions)

- (BOOL)isEqualToNode:(GDataXMLNode*)node
{
    if (! [self.decodedStringValue isEqualToString:node.decodedStringValue]) {
        NSDebug(@"GDataXMLNodes not equal: string values are not equal (%@ != %@)!", self.stringValue, node.stringValue);
        return false;
    }
    return true;
}

- (NSArray*)childrenWithoutComments
{
    NSMutableArray *children = [NSMutableArray new];
    for (GDataXMLNode *child in self.children) {
        if (child.XMLNode->type != XML_COMMENT_NODE)
            [children addObject:child];
    }
    return children;
}

- (NSString*)decodedStringValue
{
    return [[self class] decodedStringForString:self.stringValue];
}

- (NSString*)decodedName
{
    return [[self class] decodedStringForString:self.name];
}

+ (NSString*)decodedStringForString:(NSString*)xmlString
{
    xmlString = [xmlString stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    xmlString = [xmlString stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    xmlString = [xmlString stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    xmlString = [xmlString stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    xmlString = [xmlString stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
    return xmlString;
}

@end
