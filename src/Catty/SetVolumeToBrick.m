//
//  SetVolumeToBrick.m
//  Catty
//
//  Created by Dominik Ziegler on 9/27/12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Setvolumetobrick.h"

#import "Formula.h"

@implementation Setvolumetobrick

@synthesize volume = _volume;


-(id)initWithVolumeInPercent:(NSNumber*)volume
{
    abort();
#warning do not use! -- NSNumber changed to Formula
    self = [super init];
    if (self)
    {
        self.volume = volume;
    }
    return self;
}



- (void)performFromScript:(Script *)script
{
    NSDebug(@"Performing: %@", self.description);
    
    double volume = [self.volume interpretDoubleForSprite:self.object];
    
    [self.object setVolumeToInPercent:volume];
}


#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"Set Volume to: %f%%)", [self.volume interpretDoubleForSprite:self.object]];
}


@end
