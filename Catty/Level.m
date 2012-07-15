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
@synthesize version = _version;
@synthesize resolution = _resolution;
@synthesize spritesArray = _spritesArray;
@synthesize startScriptsArray = _startScriptsArray;
@synthesize whenScriptsArray = _whenScriptsArray;
@synthesize screenResolution = _screenResolution;
@synthesize versionName = _versionName;

- (NSString*)description 
{
    NSMutableString *ret = [[NSMutableString alloc] init];
    [ret appendString:@"Level description\n"];
    [ret appendFormat:@"Name: %@\n", self.name];
    [ret appendFormat:@"Version: %f\n", self.version];
    [ret appendFormat:@"Resolution: [%f, %f] (x, y)\n", self.resolution.width, self.resolution.height];
    
    NSInteger index = 1;
    if ([self.startScriptsArray count] > 0)
    {
        [ret appendString:@"Start scripts: \n"];
        for (Script *script in self.startScriptsArray)
        {
            [ret appendFormat:@"\t (%d) %@", index++, script];
        }
    }
    else 
    {
        [ret appendString:@"Start scipts: None\n"];
    }
    
    
    index = 1;
    if ([self.whenScriptsArray count] > 0)
    {
        [ret appendString:@"When scripts: \n"];
        for (Script *script in self.whenScriptsArray)
        {
            [ret appendFormat:@"\t (%d) %@", index++, script];
        }
    }
    else 
    {
        [ret appendString:@"When scipts: None\n"];
    }
    
    return [[NSString alloc] initWithString:ret];
}

@end
