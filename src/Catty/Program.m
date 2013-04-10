//
//  CattyAppDelegate.m
//  Catty
//
//  Created by Christof Stromberger on 07.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Program.h"
#import "Script.h"
#import <objc/runtime.h>
#import <Foundation/NSObjCRuntime.h>

@implementation Program

@synthesize objectList = _objectList;
@synthesize variables = _variables;

#pragma mark - Custom getter and setter
- (NSMutableArray*)spritesList {
    if (_objectList == nil)
        _objectList = [[NSMutableArray alloc] init];
    return _objectList;
}

- (NSMutableArray*)variables {
    if (_variables == nil) {
        _variables = [[NSMutableArray alloc] init];
    }
    return _variables;
}


- (NSString*)debug {
    NSMutableString *ret = [[NSMutableString alloc] init];
    [ret appendFormat:@"\n----------------- PROGRAM --------------------\n"];
    /*[ret appendFormat:@"Application Build Name: %@\n", self.applicationBuildName];
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
    [ret appendFormat:@"User Handle: %@\n", self.userHandle];*/
    [ret appendFormat:@"----------------------------------------------\n"];
    
    return [NSString stringWithString:ret];
}



@end
