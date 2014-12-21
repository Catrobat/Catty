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

#import "Header.h"
#import "GDataXMLElement+CustomExtensions.h"
#import "Util.h"
#import "CatrobatLanguageDefines.h"

@implementation Header

+ (instancetype)defaultHeader
{
    Header *header = [self new];
    header.applicationBuildName = [Util appBuildName];
    header.applicationBuildNumber = [Util appBuildVersion];
    header.applicationName = [Util appName];
    header.applicationVersion = [Util appVersion];
    header.catrobatLanguageVersion = [Util catrobatLanguageVersion];
    header.dateTimeUpload = nil;
    header.programDescription = nil;
    header.deviceName = [Util deviceName];
    header.mediaLicense = [Util catrobatMediaLicense];
    header.platform = [Util platformName];
    header.platformVersion = [Util platformVersion];
    header.programLicense = [Util catrobatProgramLicense];
    header.programName = nil;
    header.remixOf = nil;
    header.screenHeight = @([Util screenHeight]);
    header.screenWidth = @([Util screenWidth]);
    header.screenMode = kCatrobatHeaderScreenModeStretch;
    header.url = nil;
    header.userHandle = nil;
    header.programScreenshotManuallyTaken = kCatrobatHeaderProgramScreenshotDefaultValue;
    header.tags = nil;
    header.programID = nil;
    return header;
}

// TODO move to ser
#define kCBXMLSerializerLanguageVersion @"0.93"

- (GDataXMLElement*)toXML
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

- (BOOL)isEqualToHeader:(Header*)header
{
    if(![self.applicationName isEqualToString:header.applicationName])
        return NO;
    if(![self.programDescription isEqualToString:header.programDescription])
        return NO;
    if(![self.mediaLicense isEqualToString:header.mediaLicense])
        return NO;
    if(![self.programLicense isEqualToString:header.programLicense])
        return NO;
    if(![self.programName isEqualToString:header.programName])
        return NO;
    if(![self.remixOf isEqualToString:header.remixOf])
        return NO;
    if(![self.screenHeight isEqualToNumber:header.screenHeight])
        return NO;
    if(![self.screenWidth isEqualToNumber:header.screenWidth])
        return NO;
    if(![self.screenMode isEqualToString:header.screenMode])
        return NO;
    if(![self.tags isEqualToString:header.tags])
        return NO;
    if(![self.url isEqualToString:header.url])
        return NO;
    if(![self.userHandle isEqualToString:header.userHandle])
        return NO;
    
    return YES;
}

@end
