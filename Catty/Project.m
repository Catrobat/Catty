//
//  CattyAppDelegate.m
//  Catty
//
//  Created by Christof Stromberger on 07.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Project.h"
#import "Script.h"
#import <objc/runtime.h>
#import <Foundation/NSObjCRuntime.h>

@implementation Project

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
@synthesize spriteList              = _spriteList;
@synthesize uRL                     = _uRL;
@synthesize userHandle              = _userHandle;

#pragma mark - Custom getter and setter
- (NSMutableArray*)spritesList {
    if (_spriteList == nil)
        _spriteList = [[NSMutableArray alloc] init];
    return _spriteList;
}

- (NSString*)debug {
    NSMutableString *ret = [[NSMutableString alloc] init];
    [ret appendFormat:@"\n----------------- PROJECT --------------------\n"];
    [ret appendFormat:@"Application Build Name: %@\n", self.applicationBuildName];
    [ret appendFormat:@"Application Build Number: %@\n", self.applicationBuildNumber];
    [ret appendFormat:@"Application Name: %@\n", self.applicationName];
    [ret appendFormat:@"Application Version: %@\n", self.applicationVersion];
    [ret appendFormat:@"Catrobat Language Version: %@\n", self.catrobatLanguageVersion];
    [ret appendFormat:@"Date Time Upload: %@\n", self.dateTimeUpload];
    [ret appendFormat:@"Description: %@\n", self.description];
    [ret appendFormat:@"Device Name: %@\n", self.deviceName];
    [ret appendFormat:@"Media License: %@\n", self.mediaLicense];
    [ret appendFormat:@"Platform: %@\n", self.platform];
    [ret appendFormat:@"Platform Version: %@\n", self.platformVersion];
    [ret appendFormat:@"Program License: %@\n", self.programLicense];
    [ret appendFormat:@"Program Name: %@\n", self.programName];
    [ret appendFormat:@"Remix of: %@\n", self.remixOf];
    [ret appendFormat:@"Screen Height: %@\n", self.screenHeight];
    [ret appendFormat:@"Screen Width: %@\n", self.screenWidth];
    [ret appendFormat:@"Sprite List: %@\n", self.spriteList];
    [ret appendFormat:@"URL: %@\n", self.uRL];
    [ret appendFormat:@"User Handle: %@\n", self.userHandle];
    [ret appendFormat:@"----------------------------------------------\n"];
    
    return [NSString stringWithString:ret];
}



@end
