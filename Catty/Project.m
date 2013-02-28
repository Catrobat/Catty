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

// introspection !!!
//- (NSString *)propertyName:(id)property {
//    unsigned int numIvars = 0;
//    NSString *key = nil;
//    Ivar *ivars = class_copyIvarList([self class], &numIvars);
//    for(int i = 0; i < numIvars; i++) {
//        Ivar thisIvar = ivars[i];
//        if ((object_getIvar(self, thisIvar) == property)) {
//            key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
//            break;
//        }
//    }
//    free(ivars);
//    return key;
//}

//- (NSArray*)rootProperties {
//    NSMutableArray *ret = [[NSMutableArray alloc] init];
//    
//    unsigned int numIvars = 0;
//    Ivar *ivars = class_copyIvarList([self class], &numIvars);
//    for(int i = 0; i < numIvars; i++) {
//        Ivar thisIvar = ivars[i];
//        
//        NSString *propName = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
//        if (![propName isEqualToString:kXMLSkip]) { // skip 'spriteList' (i.e.)
//            [ret addObject:(__bridge id)(thisIvar)];
//        }
//    }
//    free(ivars);
//    return [NSArray arrayWithArray:ret];
//}


@end
