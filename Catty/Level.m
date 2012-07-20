//
//  CattyAppDelegate.m
//  Catty
//
//  Created by Christof Stromberger on 07.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Level.h"
#import "Script.h"

@implementation Level

@synthesize name = _name;
@synthesize resolution = _resolution;
@synthesize spritesArray = _spritesArray;
@synthesize screenResolution = _screenResolution;
@synthesize versionName = _versionName;
@synthesize versionCode = _versionCode;

- (NSString*)description 
{
    NSMutableString *ret = [[NSMutableString alloc] init];
    [ret appendString:@"Level description\n"];
    [ret appendFormat:@"Name: %@\n", self.name];
    [ret appendFormat:@"VersionName: %@\n", self.versionName];
    [ret appendFormat:@"VersionCode: %@\n", self.versionCode];
    [ret appendFormat:@"Resolution: TODO [%f, %f] (x, y)\n", self.resolution.width, self.resolution.height];
    
    //[ret appendString:self.spritesArray.description];
    
    return [[NSString alloc] initWithString:ret];
}

@end
