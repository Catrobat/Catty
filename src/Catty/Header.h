//
//  Header.h
//  Catty
//
//  Created by Christof Stromberger on 28.03.13.
//  Copyright (c) 2013 Graz University of Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Header : NSObject

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
@property (nonatomic, strong) NSNumber *screenHeight;
@property (nonatomic, strong) NSNumber *screenWidth;

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *userHandle;
@property (nonatomic, strong) NSString *programScreenshotManuallyTaken;
@property (nonatomic, strong) NSString *tags;

@end
