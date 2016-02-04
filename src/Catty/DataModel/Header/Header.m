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

- (void)updateRelevantHeaderInfosBeforeSerialization
{
    // needed to update headers in catrobat programs that have not been
    // created on this device (e.g. downloaded programs...)
    self.applicationBuildName = [Util appBuildName];
    self.applicationBuildNumber = [Util appBuildVersion];
    self.applicationName = [Util appName];
    self.applicationVersion = [Util appVersion];
    self.applicationVersion = [Util appVersion];
    self.deviceName = [Util deviceName];
    self.mediaLicense = [Util catrobatMediaLicense]; // always use most recent license!
    self.platform = [Util platformName];
    self.platformVersion = [Util platformVersion];
    self.programLicense = [Util catrobatProgramLicense]; // always use most recent license!

    // now, this becomes a remixed version
    // ... but URL must be valid ...
    if (self.url && ([self.url hasPrefix:@"http://"] || [self.url hasPrefix:@"https://"])) {
        self.remixOf = self.url;
    }

    // invalidate all web fields (current user now becomes the creator of this remix!)
    self.tags = nil;
    self.userHandle = nil;
}

- (BOOL)isEqualToHeader:(Header*)header
{
    if (! [self.applicationName isEqualToString:header.applicationName])
        return NO;
    if (! [self.programDescription isEqualToString:header.programDescription])
        return NO;
    if (! [self.mediaLicense isEqualToString:header.mediaLicense])
        return NO;
    if (! [self.programLicense isEqualToString:header.programLicense])
        return NO;
    if (! [self.programName isEqualToString:header.programName])
        return NO;
    if (! [self.screenHeight isEqualToNumber:header.screenHeight])
        return NO;
    if (! [self.screenWidth isEqualToNumber:header.screenWidth])
        return NO;
    if (! [self.screenMode isEqualToString:header.screenMode])
        return NO;
    if (! [self.url isEqualToString:header.url])
        return NO;
    return YES;
}

@end
