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


-(id)initWithVolumeInPercent:(NSNumber*)volume
{
    self = [super init];
    if (self)
    {
        self.volume = volume;
    }
    return self;
}



- (void)performFromScript:(Script *)script
{
    NSLog(@"Performing: %@", self.description);
    
    [self.sprite setVolumeTo:self.volume.floatValue/100.0f];
}


#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"Set Volume to: %f%%)", self.volume.floatValue];
}


@end
