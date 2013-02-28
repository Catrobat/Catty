//
//  Level.h
//  Catty
//
//  Created by Mattias Rauter on 17.04.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

// skip properties with this name (i.e. spriteList needs a custom initialization)
#define kXMLSkip @"spriteList"

@interface Project : NSObject

// PROPERTIES
// new xml (version 0.3 of language version)
// ---------------------------------------------------
// meta infos
@property (nonatomic, strong) NSString *applicationBuildName;
@property (nonatomic, strong) NSString *applicationBuildNumber;
@property (nonatomic, strong) NSString *applicationName;
@property (nonatomic, strong) NSString *applicationVersion;
@property (nonatomic, strong) NSString *catrobatLanguageVersion;
@property (nonatomic, strong) NSDate   *dateTimeUpload;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *deviceName;
@property (nonatomic, strong) NSString *mediaLicense;
@property (nonatomic, strong) NSString *platform;
@property (nonatomic, strong) NSString *platformVersion;
@property (nonatomic, strong) NSString *programLicense;
@property (nonatomic, strong) NSString *programName;
@property (nonatomic, strong) NSString *remixOf;
@property (nonatomic, assign) NSNumber *screenHeight;
@property (nonatomic, assign) NSNumber *screenWidth;

@property (nonatomic, strong) NSString *uRL;
@property (nonatomic, strong) NSString *userHandle;

// sprites
@property (nonatomic, strong) NSMutableArray *spriteList;

// METHODS
// ---------------------------------------------------
- (NSString*)debug;

@end
