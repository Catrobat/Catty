/**
 *  Copyright (C) 2010-2015 The Catrobat Team
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
#import "GDataXMLElement+CustomExtensions.h"
#import "CBXMLValidator.h"
#import "CBXMLParserHelper.h"
#import "CatrobatLanguageDefines.h"
#import "CBXMLSerializer.h"

@implementation Header (CBXMLHandler)

#pragma mark - Parsing
+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContextForLanguageVersion093:(CBXMLParserContext*)context
{
    [XMLError exceptionIfNil:xmlElement message:@"No xml element given!"];
    Header *header = [self defaultHeader];
    NSArray *headerPropertyNodes = [xmlElement children];
    [XMLError exceptionIf:[headerPropertyNodes count] equals:0 message:@"No parsed properties found in header!"];
    
    for (GDataXMLNode *headerPropertyNode in headerPropertyNodes) {
        [XMLError exceptionIfNil:headerPropertyNode message:@"Parsed an empty header entry!"];
        id value = [CBXMLParserHelper valueForHeaderPropertyNode:headerPropertyNode];
        NSString *headerPropertyName = headerPropertyNode.name;

        // consider special case: name of property programDescription
        if ([headerPropertyNode.name isEqualToString:@"description"]) {
            headerPropertyName = @"programDescription";
        }
        [header setValue:value forKey:headerPropertyName]; // Note: weak properties are not yet supported!!
    }
    return header;
}

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContextForLanguageVersion095:(CBXMLParserContext*)context
{
    return [self parseFromElement:xmlElement withContextForLanguageVersion093:context];
}

#pragma mark - Serialization
- (GDataXMLElement*)xmlElementWithContext:(CBXMLSerializerContext*)context
{
    GDataXMLElement *headerXMLElement = [GDataXMLElement elementWithName:@"header" context:context];
    [headerXMLElement addChild:[GDataXMLElement elementWithName:@"applicationBuildName"
                                                    stringValue:self.applicationBuildName context:context]
                       context:context];
    [headerXMLElement addChild:[GDataXMLElement elementWithName:@"applicationBuildNumber"
                                                    stringValue:self.applicationBuildNumber context:context]
                       context:context];
    [headerXMLElement addChild:[GDataXMLElement elementWithName:@"applicationName"
                                                    stringValue:self.applicationName context:context]
                       context:context];
    [headerXMLElement addChild:[GDataXMLElement elementWithName:@"applicationVersion"
                                                    stringValue:self.applicationVersion context:context]
                       context:context];
    [headerXMLElement addChild:[GDataXMLElement elementWithName:@"catrobatLanguageVersion"
                                                    stringValue:kCBXMLSerializerLanguageVersion context:context]
                       context:context];
    [headerXMLElement addChild:[GDataXMLElement elementWithName:@"dateTimeUpload"
                                                    stringValue:(self.dateTimeUpload ? [[[self class] headerDateFormatter] stringFromDate:self.dateTimeUpload]
                                                                 : nil)
                                                        context:context] context:context];
    [headerXMLElement addChild:[GDataXMLElement elementWithName:@"description"
                                                    stringValue:self.programDescription context:context]
                       context:context];
    [headerXMLElement addChild:[GDataXMLElement elementWithName:@"deviceName"
                                                    stringValue:self.deviceName context:context]
                       context:context];
    [headerXMLElement addChild:[GDataXMLElement elementWithName:@"mediaLicense"
                                                    stringValue:self.mediaLicense context:context]
                       context:context];
    [headerXMLElement addChild:[GDataXMLElement elementWithName:@"platform"
                                                    stringValue:self.platform context:context]
                       context:context];
    [headerXMLElement addChild:[GDataXMLElement elementWithName:@"platformVersion"
                                                    stringValue:self.platformVersion context:context]
                       context:context];
    [headerXMLElement addChild:[GDataXMLElement elementWithName:@"programLicense"
                                                    stringValue:self.programLicense context:context]
                       context:context];
    [headerXMLElement addChild:[GDataXMLElement elementWithName:@"programName"
                                                    stringValue:self.programName context:context]
                       context:context];
    [headerXMLElement addChild:[GDataXMLElement elementWithName:@"remixOf"
                                                    stringValue:self.remixOf context:context]
                       context:context];
    [headerXMLElement addChild:[GDataXMLElement elementWithName:@"screenHeight"
                                                    stringValue:[self.screenHeight stringValue] context:context]
                       context:context];
    [headerXMLElement addChild:[GDataXMLElement elementWithName:@"screenMode"
                                                    stringValue:self.screenMode context:context]
                       context:context];
    [headerXMLElement addChild:[GDataXMLElement elementWithName:@"screenWidth"
                                                    stringValue:[self.screenWidth stringValue] context:context]
                       context:context];
    [headerXMLElement addChild:[GDataXMLElement elementWithName:@"tags"
                                                    stringValue:self.tags context:context]
                       context:context];
    [headerXMLElement addChild:[GDataXMLElement elementWithName:@"url"
                                                    stringValue:self.url context:context]
                       context:context];
    [headerXMLElement addChild:[GDataXMLElement elementWithName:@"userHandle"
                                                    stringValue:self.userHandle context:context]
                       context:context];
    return headerXMLElement;
}

#pragma mark - Helpers
static NSDateFormatter *headerDateFormatter = nil;
+ (NSDateFormatter*)headerDateFormatter
{
    if (! headerDateFormatter) {
        headerDateFormatter = [NSDateFormatter new];
        [headerDateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        [headerDateFormatter setDateFormat:kCatrobatHeaderDateTimeFormat];
    }
    return headerDateFormatter;
}

@end
