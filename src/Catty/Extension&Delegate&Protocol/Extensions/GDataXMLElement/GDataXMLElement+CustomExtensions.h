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

#import "GDataXMLNode.h"

@class CBXMLContext;

@interface GDataXMLElement (CustomExtensions)

// little HACK to activate pretty printed XML, unfortunatelly GDataXMLNode does not support this by default
// More details for this: http://stackoverflow.com/questions/6403083/ios-xml-pretty-print
- (NSString*)XMLStringPrettyPrinted:(BOOL)isPrettyPrinted;
- (NSString*)XMLRootElementAsString;
- (GDataXMLElement*)childWithElementName:(NSString*)elementName;
- (GDataXMLElement*)childWithElementName:(NSString*)elementName
                     containingAttribute:(NSString*)attributeName
                               withValue:(NSString*)attributeValue;
- (GDataXMLElement*)singleNodeForCatrobatXPath:(NSString*)catrobatXPath;
+ (GDataXMLElement*)elementWithName:(NSString*)name context:(CBXMLContext*)context;
+ (GDataXMLElement*)elementWithName:(NSString*)name xPathIndex:(NSUInteger)xPathIndex
                            context:(CBXMLContext*)context;
+ (GDataXMLElement*)elementWithName:(NSString*)name stringValue:(NSString*)value
                            context:(CBXMLContext*)context;
+ (GDataXMLElement*)elementWithName:(NSString*)name xPathIndex:(NSUInteger)xPathIndex
                        stringValue:(NSString*)value context:(CBXMLContext*)context;

- (void)addChild:(GDataXMLNode*)child context:(CBXMLContext*)context;

@end
