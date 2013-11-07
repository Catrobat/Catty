/**
 *  Copyright (C) 2010-2013 The Catrobat Team
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

@implementation Header

@synthesize applicationBuildName    = _applicationBuildName;
@synthesize applicationBuildNumber  = _applicationBuildNumber;
@synthesize applicationName         = _applicationName;
@synthesize applicationVersion      = _applicationVersion;
@synthesize catrobatLanguageVersion = _catrobatLanguageVersion;
@synthesize dateTimeUpload          = _dateTimeUpload;
@synthesize description             = _description;
@synthesize deviceName              = _deviceName;
@synthesize mediaLicense            = _mediaLicense;
@synthesize platform                = _platform;
@synthesize platformVersion         = _platformVersion;
@synthesize programLicense          = _programLicense;
@synthesize programName             = _programName;
@synthesize remixOf                 = _remixOf;
@synthesize screenHeight            = _screenHeight;
@synthesize screenWidth             = _screenWidth;
@synthesize url                     = _url;
@synthesize userHandle              = _userHandle;
@synthesize programScreenshotManuallyTaken = _programScreenshotManuallyTaken;
@synthesize tags                    = _tags;

- (NSString*)persist
{
  // TODO: INFO: this is just an ugly hack. Maybe we are using a XML framework or write our own classes for XML-nodes, etc.
  NSMutableString *header = [NSMutableString stringWithString:@"<header>"];
  [header appendFormat:@"\n  <applicationBuildName>%@</applicationBuildName>", (self.applicationBuildName ? self.applicationBuildName : @"")];
  [header appendFormat:@"\n  <applicationBuildNumber>%@</applicationBuildNumber>", self.applicationBuildNumber];
  [header appendFormat:@"\n  <applicationName>%@</applicationName>", self.applicationName];
  [header appendFormat:@"\n  <applicationVersion>%@</applicationVersion>", self.applicationVersion];
  [header appendFormat:@"\n  <catrobatLanguageVersion>%@</catrobatLanguageVersion>", self.catrobatLanguageVersion];
  [header appendFormat:@"\n  <dateTimeUpload>%@</dateTimeUpload>", @""]; // FIXME which date format??!!
  [header appendFormat:@"\n  <description>%@</description>", self.description];
  [header appendFormat:@"\n  <deviceName>%@</deviceName>", self.deviceName];
  [header appendFormat:@"\n  <mediaLicense>%@</mediaLicense>", (self.mediaLicense ? self.mediaLicense : @"")];
  [header appendFormat:@"\n  <platform>%@</platform>", self.platform];
  [header appendFormat:@"\n  <platformVersion>%@</platformVersion>", self.platformVersion];
  [header appendFormat:@"\n  <programLicense>%@</programLicense>", (self.programLicense ? self.programLicense : @"")];
  [header appendFormat:@"\n  <programName>%@</programName>", self.programName];
  [header appendFormat:@"\n  <programScreenshotManuallyTaken>%@</programScreenshotManuallyTaken>", (self.programScreenshotManuallyTaken ? @"true" : @"false")];
  [header appendFormat:@"\n  <remixOf>%@</remixOf>", (self.remixOf ? self.remixOf : @"")];
  [header appendFormat:@"\n  <screenHeight>%@</screenHeight>", self.screenHeight];
  [header appendFormat:@"\n  <screenWidth>%@</screenWidth>", self.screenWidth];
  [header appendFormat:@"\n  <tags>%@</tags>", (self.tags ? self.tags : @"")];
  [header appendFormat:@"\n  <url>%@</url>", (self.url ? self.url : @"")];
  [header appendFormat:@"\n  <userHandle>%@</userHandle>", (self.userHandle ? self.userHandle : @"")];
  [header appendString:@"</header>"];
  return header;
}

@end
