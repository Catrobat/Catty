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


#import <Foundation/Foundation.h>
@class SpriteObject;

@interface Header : NSObject

// meta infos
@property (nonatomic, strong) NSString *applicationBuildName;
@property (nonatomic, strong) NSString *applicationBuildNumber;
@property (nonatomic, strong) NSString *applicationName;
@property (nonatomic, strong) NSString *applicationVersion;
@property (nonatomic, strong) NSString *catrobatLanguageVersion;
@property (nonatomic, strong) NSDate   *dateTimeUpload;
@property (nonatomic, strong) NSString *programDescription;
@property (nonatomic, strong) NSString *deviceName;
@property (nonatomic, strong) NSString *mediaLicense;
@property (nonatomic, strong) NSString *platform;
@property (nonatomic, strong) NSString *platformVersion;
@property (nonatomic, strong) NSString *programLicense;
@property (nonatomic, strong) NSString *programName;
@property (nonatomic, strong) NSString *remixOf;
@property (nonatomic, strong) NSNumber *screenHeight;
@property (nonatomic, strong) NSNumber *screenWidth;
@property (nonatomic, strong) NSString *screenMode;

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *userHandle;
@property (nonatomic, strong) NSString *programScreenshotManuallyTaken;
@property (nonatomic, strong) NSString *tags;
@property (nonatomic, assign) NSString *isArduinoProject;

// do not persist following properties
@property (nonatomic, strong) NSString *programID;

+ (instancetype)defaultHeader;

- (void)updateRelevantHeaderInfosBeforeSerialization;

- (BOOL)isEqualToHeader:(Header*)header;

@end
