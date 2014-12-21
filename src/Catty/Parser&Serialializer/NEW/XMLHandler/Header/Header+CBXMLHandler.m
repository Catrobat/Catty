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
#import "GDataXMLElement+CustomExtensions.h"
#import "CBXMLValidator.h"
#import "CBXMLParserHelper.h"
#import "CatrobatLanguageDefines.h"
#import "CBXMLSerializer.h"

@implementation Header (CBXMLHandler)

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLContext*)context
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

- (GDataXMLElement*)xmlElementWithContext:(CBXMLContext*)context
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormatter setDateFormat:kCatrobatHeaderDateTimeFormat];
    
    GDataXMLElement *headerXMLElement = [GDataXMLElement elementWithName:@"header"];
    [headerXMLElement addChild:[GDataXMLElement elementWithName:@"applicationBuildName"
                                         optionalStringValue:self.applicationBuildName]];
    [headerXMLElement addChild:[GDataXMLElement elementWithName:@"applicationBuildNumber"
                                         optionalStringValue:self.applicationBuildNumber]];
    [headerXMLElement addChild:[GDataXMLElement elementWithName:@"applicationName"
                                         optionalStringValue:self.applicationName]];
    [headerXMLElement addChild:[GDataXMLElement elementWithName:@"applicationVersion"
                                         optionalStringValue:self.applicationVersion]];
    [headerXMLElement addChild:[GDataXMLElement elementWithName:@"catrobatLanguageVersion"
                                         optionalStringValue:kCBXMLSerializerLanguageVersion]];
    [headerXMLElement addChild:[GDataXMLElement elementWithName:@"dateTimeUpload"
                                         optionalStringValue:(self.dateTimeUpload ? [dateFormatter stringFromDate:self.dateTimeUpload] : nil)]];
    [headerXMLElement addChild:[GDataXMLElement elementWithName:@"description"
                                         optionalStringValue:self.programDescription]];
    [headerXMLElement addChild:[GDataXMLElement elementWithName:@"deviceName"
                                         optionalStringValue:self.deviceName]];
    [headerXMLElement addChild:[GDataXMLElement elementWithName:@"mediaLicense"
                                         optionalStringValue:self.mediaLicense]];
    [headerXMLElement addChild:[GDataXMLElement elementWithName:@"platform"
                                         optionalStringValue:self.platform]];
    [headerXMLElement addChild:[GDataXMLElement elementWithName:@"platformVersion"
                                         optionalStringValue:self.platformVersion]];
    [headerXMLElement addChild:[GDataXMLElement elementWithName:@"programLicense"
                                         optionalStringValue:self.programLicense]];
    [headerXMLElement addChild:[GDataXMLElement elementWithName:@"programName"
                                         optionalStringValue:self.programName]];
    [headerXMLElement addChild:[GDataXMLElement elementWithName:@"remixOf"
                                         optionalStringValue:self.remixOf]];
    [headerXMLElement addChild:[GDataXMLElement elementWithName:@"screenHeight"
                                         optionalStringValue:[self.screenHeight stringValue]]];
    [headerXMLElement addChild:[GDataXMLElement elementWithName:@"screenWidth"
                                         optionalStringValue:[self.screenWidth stringValue]]];
    [headerXMLElement addChild:[GDataXMLElement elementWithName:@"screenMode"
                                         optionalStringValue:self.screenMode]];
    [headerXMLElement addChild:[GDataXMLElement elementWithName:@"tags"
                                         optionalStringValue:self.tags]];
    [headerXMLElement addChild:[GDataXMLElement elementWithName:@"url"
                                         optionalStringValue:self.url]];
    [headerXMLElement addChild:[GDataXMLElement elementWithName:@"userHandle"
                                         optionalStringValue:self.userHandle]];
    return headerXMLElement;
}

@end
