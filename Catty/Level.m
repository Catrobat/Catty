//
//  Level.m
//  Catty
//
//  Created by Mattias Rauter on 17.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Level.h"

@implementation Level

@synthesize name = _name;
@synthesize version = _version;
@synthesize resolution = _resolution;
@synthesize spritesArray = _spritesArray;
@synthesize startScriptsArray = _startScriptsArray;
@synthesize whenScriptsArray = _whenScriptsArray;

- (NSString*)description 
{
    NSMutableString *ret = [[NSMutableString alloc] init];
    [ret appendString:@"Level description\n"];
    [ret appendFormat:@"Name: %@\n", self.name];
    [ret appendFormat:@"Version: %f\n", self.version];
    
    return [[NSString alloc] initWithString:ret];
}

@end
