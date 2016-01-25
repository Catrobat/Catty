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

#import "Header+CBXMLHandler.h"
#import "GDataXMLElement+CustomExtensions.h"
#import "CBXMLValidator.h"
#import "CBXMLParserHelper.h"
#import "CatrobatLanguageDefines.h"
#import "CBXMLSerializer.h"
#import "CBXMLPropertyMapping.h"
#import "CBXMLParserContext.h"
#import "Util.h"

@implementation Header (CBXMLHandler)

#pragma mark - Header properties
+ (NSMutableArray*)headerPropertiesForLanguageVersion093
{
    return [NSMutableArray arrayWithObjects:
            [[CBXMLPropertyMapping alloc] initWithClassPropertyName:@"applicationBuildName"],
            [[CBXMLPropertyMapping alloc] initWithClassPropertyName:@"applicationBuildNumber"],
            [[CBXMLPropertyMapping alloc] initWithClassPropertyName:@"applicationName"],
            [[CBXMLPropertyMapping alloc] initWithClassPropertyName:@"applicationVersion"],
            [[CBXMLPropertyMapping alloc] initWithClassPropertyName:@"catrobatLanguageVersion"],
            [[CBXMLPropertyMapping alloc] initWithClassPropertyName:@"dateTimeUpload"],
            [[CBXMLPropertyMapping alloc] initWithClassPropertyName:@"programDescription"
                                                  andXMLElementName:@"description"],
            [[CBXMLPropertyMapping alloc] initWithClassPropertyName:@"deviceName"],
            [[CBXMLPropertyMapping alloc] initWithClassPropertyName:@"mediaLicense"],
            [[CBXMLPropertyMapping alloc] initWithClassPropertyName:@"platform"],
            [[CBXMLPropertyMapping alloc] initWithClassPropertyName:@"platformVersion"],
            [[CBXMLPropertyMapping alloc] initWithClassPropertyName:@"programLicense"],
            [[CBXMLPropertyMapping alloc] initWithClassPropertyName:@"programName"],
            [[CBXMLPropertyMapping alloc] initWithClassPropertyName:@"remixOf"],
            [[CBXMLPropertyMapping alloc] initWithClassPropertyName:@"screenHeight"],
            [[CBXMLPropertyMapping alloc] initWithClassPropertyName:@"screenMode"],
            [[CBXMLPropertyMapping alloc] initWithClassPropertyName:@"screenWidth"],
            [[CBXMLPropertyMapping alloc] initWithClassPropertyName:@"tags"],
            [[CBXMLPropertyMapping alloc] initWithClassPropertyName:@"url"],
            [[CBXMLPropertyMapping alloc] initWithClassPropertyName:@"userHandle"],
            nil];
}

+ (NSMutableArray*)headerPropertiesForLanguageVersion095
{
    NSMutableArray *headerProperties = [self headerPropertiesForLanguageVersion093];
    [headerProperties addObject:[[CBXMLPropertyMapping alloc] initWithClassPropertyName:@"isPhiroProProject"]];
    return headerProperties;
}

+ (NSMutableArray*)headerPropertiesForLanguageVersion097
{
    return [self headerPropertiesForLanguageVersion093];
}

#pragma mark - Parsing
+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement
withContextForLanguageVersion093:(CBXMLParserContext*)context
{
    [XMLError exceptionIfNil:xmlElement message:@"No xml element given!"];
    Header *header = [self defaultHeader];
    NSArray *headerProperties = [self headerPropertiesForLanguageVersion093];
    [XMLError exceptionIf:[[xmlElement children] count] notEquals:[headerProperties count]
                  message:@"Invalid number of header properties in XML!"];

    for (CBXMLPropertyMapping *headerProperty in headerProperties) {
        GDataXMLElement *headerPropertyNode = [xmlElement childWithElementName:headerProperty.xmlElementName];
        [XMLError exceptionIfNil:headerPropertyNode message:@"No XML property named %@ in header!",
         headerProperty.xmlElementName];
        id value = [CBXMLParserHelper valueForHeaderProperty:headerProperty.classPropertyName
                                                  andXMLNode:headerPropertyNode];
        // Note: weak properties are not yet supported!!
        [header setValue:value forKey:headerProperty.classPropertyName];
    }
    return header;
}

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement
withContextForLanguageVersion095:(CBXMLParserContext*)context
{
    [XMLError exceptionIfNil:xmlElement message:@"No xml element given!"];
    Header *header = [self defaultHeader];
    NSArray *headerProperties = context.languageVersion == 0.97f ? [self headerPropertiesForLanguageVersion097] : [self headerPropertiesForLanguageVersion095];
    
    [XMLError exceptionIf:[[xmlElement children] count] notEquals:[headerProperties count]
                  message:@"Invalid number of header properties in XML!"];

    for (CBXMLPropertyMapping *headerProperty in headerProperties) {
        
        // ignore isPhiroProProject property
        if ([headerProperty.xmlElementName isEqualToString:@"isPhiroProProject"] && context.languageVersion < 0.97f) {
            continue;
        }

        GDataXMLElement *headerPropertyNode = [xmlElement childWithElementName:headerProperty.xmlElementName];
        [XMLError exceptionIfNil:headerPropertyNode message:@"No XML property named %@ in header!",
         headerProperty.xmlElementName];
        id value = [CBXMLParserHelper valueForHeaderProperty:headerProperty.classPropertyName
                                                  andXMLNode:headerPropertyNode];
        // Note: weak properties are not yet supported!!
        [header setValue:value forKey:headerProperty.classPropertyName];
    }
    return header;
}

#pragma mark - Serialization
- (GDataXMLElement*)xmlElementWithContext:(CBXMLSerializerContext*)context
{
    if (! [Util activateTestMode:NO]) {
        [self updateRelevantHeaderInfosBeforeSerialization];
    }
    GDataXMLElement *headerXMLElement = [GDataXMLElement elementWithName:@"header" context:context];
    [headerXMLElement addChild:[GDataXMLElement elementWithName:@"applicationBuildName"
                                                    stringValue:self.applicationBuildName
                                                        context:context]
                       context:context];
    [headerXMLElement addChild:[GDataXMLElement elementWithName:@"applicationBuildNumber"
                                                    stringValue:self.applicationBuildNumber
                                                        context:context]
                       context:context];
    [headerXMLElement addChild:[GDataXMLElement elementWithName:@"applicationName"
                                                    stringValue:self.applicationName
                                                        context:context]
                       context:context];
    [headerXMLElement addChild:[GDataXMLElement elementWithName:@"applicationVersion"
                                                    stringValue:self.applicationVersion
                                                        context:context]
                       context:context];
    [headerXMLElement addChild:[GDataXMLElement elementWithName:@"catrobatLanguageVersion"
                                                    stringValue:kCBXMLSerializerLanguageVersion
                                                        context:context]
                       context:context];
    
    NSString *dateTimeUploadString = (self.dateTimeUpload
                                   ? [[[self class] headerDateFormatter] stringFromDate:self.dateTimeUpload]
                                   : nil);
    [headerXMLElement addChild:[GDataXMLElement elementWithName:@"dateTimeUpload"
                                                    stringValue:dateTimeUploadString
                                                        context:context]
                       context:context];
    [headerXMLElement addChild:[GDataXMLElement elementWithName:@"description"
                                                    stringValue:self.programDescription
                                                        context:context]
                       context:context];
    [headerXMLElement addChild:[GDataXMLElement elementWithName:@"deviceName"
                                                    stringValue:self.deviceName
                                                        context:context]
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
                                                    stringValue:[self.screenHeight stringValue]
                                                        context:context]
                       context:context];
    [headerXMLElement addChild:[GDataXMLElement elementWithName:@"screenMode"
                                                    stringValue:self.screenMode context:context]
                       context:context];
    [headerXMLElement addChild:[GDataXMLElement elementWithName:@"screenWidth"
                                                    stringValue:[self.screenWidth stringValue]
                                                        context:context]
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
