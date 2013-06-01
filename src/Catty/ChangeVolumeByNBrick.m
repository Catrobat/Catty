//
//  ChangeVolumeByBrick.m
//  Catty
//
//  Created by Dominik Ziegler on 9/27/12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "ChangeVolumeByNBrick.h"
#import "Formula.h"


@implementation Changevolumebynbrick


@synthesize volume  = _volume;



-(void)performFromScript:(Script*)script
{
    NSDebug(@"Performing: %@", self.description);
    
    double volume = [self.volume interpretDoubleForSprite:self.object];
    
    [self.object changeVolumeInPercent:volume];
}


#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"Change Volume by: %f%%)", [self.volume interpretDoubleForSprite:self.object]/100.0f];
}




@end
