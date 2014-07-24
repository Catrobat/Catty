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
#import "GDataXMLNode.h"

@implementation Header

// TODO: check this and remove that, not needed any more...
//@synthesize applicationBuildName    = _applicationBuildName;
//@synthesize applicationBuildNumber  = _applicationBuildNumber;
//@synthesize applicationName         = _applicationName;
//@synthesize applicationVersion      = _applicationVersion;
//@synthesize catrobatLanguageVersion = _catrobatLanguageVersion;
//@synthesize dateTimeUpload          = _dateTimeUpload;
//@synthesize description             = _description;
//@synthesize deviceName              = _deviceName;
//@synthesize mediaLicense            = _mediaLicense;
//@synthesize platform                = _platform;
//@synthesize platformVersion         = _platformVersion;
//@synthesize programLicense          = _programLicense;
//@synthesize programName             = _programName;
//@synthesize remixOf                 = _remixOf;
//@synthesize screenHeight            = _screenHeight;
//@synthesize screenWidth             = _screenWidth;
//@synthesize screenMode              = _screenMode;
//@synthesize url                     = _url;
//@synthesize userHandle              = _userHandle;
//@synthesize programScreenshotManuallyTaken = _programScreenshotManuallyTaken;
//@synthesize tags                    = _tags;

- (GDataXMLElement*)toXML
{
  GDataXMLElement *headerXMLElement = [GDataXMLNode elementWithName:@"header"];
  [headerXMLElement addChild:[GDataXMLNode elementWithName:@"applicationBuildName" stringValue:(self.applicationBuildName ? self.applicationBuildName : @"")]];
  [headerXMLElement addChild:[GDataXMLNode elementWithName:@"applicationBuildNumber" stringValue:self.applicationBuildNumber]];
  [headerXMLElement addChild:[GDataXMLNode elementWithName:@"applicationName" stringValue:self.applicationName]];
  [headerXMLElement addChild:[GDataXMLNode elementWithName:@"applicationVersion" stringValue:self.applicationVersion]];
  [headerXMLElement addChild:[GDataXMLNode elementWithName:@"catrobatLanguageVersion" stringValue:self.catrobatLanguageVersion]];
  [headerXMLElement addChild:[GDataXMLNode elementWithName:@"dateTimeUpload" stringValue:@""]]; // FIXME which date format??!!
  [headerXMLElement addChild:[GDataXMLNode elementWithName:@"description" stringValue:self.description]];
  [headerXMLElement addChild:[GDataXMLNode elementWithName:@"deviceName" stringValue:self.deviceName]];
  [headerXMLElement addChild:[GDataXMLNode elementWithName:@"mediaLicense" stringValue:(self.mediaLicense ? self.mediaLicense : @"")]];
  [headerXMLElement addChild:[GDataXMLNode elementWithName:@"platform" stringValue:self.platform]];
  [headerXMLElement addChild:[GDataXMLNode elementWithName:@"platformVersion" stringValue:self.platformVersion]];
  [headerXMLElement addChild:[GDataXMLNode elementWithName:@"programLicense" stringValue:(self.programLicense ? self.programLicense : @"")]];
  [headerXMLElement addChild:[GDataXMLNode elementWithName:@"programName" stringValue:self.programName]];
  [headerXMLElement addChild:[GDataXMLNode elementWithName:@"programScreenshotManuallyTaken" stringValue:(self.programScreenshotManuallyTaken ? @"true" : @"false")]];
  [headerXMLElement addChild:[GDataXMLNode elementWithName:@"remixOf" stringValue:(self.remixOf ? self.remixOf : @"")]];
  [headerXMLElement addChild:[GDataXMLNode elementWithName:@"screenHeight" stringValue:[self.screenHeight stringValue]]];
  [headerXMLElement addChild:[GDataXMLNode elementWithName:@"screenWidth" stringValue:[self.screenWidth stringValue]]];
  [headerXMLElement addChild:[GDataXMLNode elementWithName:@"screenMode" stringValue:self.screenMode]];
  [headerXMLElement addChild:[GDataXMLNode elementWithName:@"tags" stringValue:(self.tags ? self.tags : @"")]];
  [headerXMLElement addChild:[GDataXMLNode elementWithName:@"url" stringValue:(self.url ? self.url : @"")]];
  [headerXMLElement addChild:[GDataXMLNode elementWithName:@"userHandle" stringValue:(self.userHandle ? self.userHandle : @"")]];
  return headerXMLElement;
}

@end
