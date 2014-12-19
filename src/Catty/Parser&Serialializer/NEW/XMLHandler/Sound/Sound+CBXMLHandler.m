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

#import "Sound+CBXMLHandler.h"
#import "GDataXMLNode.h"
#import "CBXMLValidator.h"

@implementation Sound (CBXMLHandler)

#pragma mark - Parsing
+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(id)context
{
    [XMLError exceptionIfNode:xmlElement isNilOrNodeNameNotEquals:@"sound"];
    Sound *sound = [self new];
    NSArray *soundChildElements = [xmlElement children];
    [XMLError exceptionIf:[soundChildElements count] notEquals:2 message:@"Sound must contain two child nodes"];

    GDataXMLNode *nameChildNode = [soundChildElements firstObject];
    GDataXMLNode *fileNameChildNode = [soundChildElements lastObject];

    // swap values (if needed)
    GDataXMLNode *tempChildNode = nil;
    if ([fileNameChildNode.name isEqualToString:@"name"] && [nameChildNode.name isEqualToString:@"fileName"]) {
        tempChildNode = nameChildNode;
        nameChildNode = fileNameChildNode;
        fileNameChildNode = tempChildNode;
    }

    [XMLError exceptionIfString:nameChildNode.name isNotEqualToString:@"name" message:@"Sound contains wrong child node(s)"];
    [XMLError exceptionIfString:fileNameChildNode.name isNotEqualToString:@"fileName" message:@"Sound contains wrong child node(s)"];
    sound.name = [nameChildNode stringValue];
    sound.fileName = [fileNameChildNode stringValue];
    return sound;
}

#pragma mark - Serialization
- (GDataXMLElement*)xmlElementWithContext:(CBXMLContext*)context
{
    GDataXMLElement *xmlElement = [GDataXMLNode elementWithName:@"sound"];
    [xmlElement addChild:[GDataXMLElement elementWithName:@"fileName" stringValue:self.fileName]];
    [xmlElement addChild:[GDataXMLElement elementWithName:@"name" stringValue:self.name]];
    return xmlElement;
}

@end
