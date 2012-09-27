//
//  SetVolumeToBrick.m
//  Catty
//
//  Created by Dominik Ziegler on 9/27/12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "SetVolumeToBrick.h"

@implementation SetVolumeToBrick

@synthesize volume = _volume;


-(id)initWithVolumeInPercent:(float)volume
{
    self = [super init];
    if (self)
    {
        self.volume = volume;
    }
    return self;
}



- (void)performOnSprite:(Sprite *)sprite
{
    NSLog(@"Performing: %@", self.description);
    
    [sprite setVolumeTo:_volume/100.0f];
}


#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"Set Volume to: %f%%)", _volume];
}


@end
