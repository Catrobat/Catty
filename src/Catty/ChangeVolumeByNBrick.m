//
//  ChangeVolumeByBrick.m
//  Catty
//
//  Created by Dominik Ziegler on 9/27/12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "ChangeVolumeByNBrick.h"

@implementation Changevolumebynbrick


@synthesize volume  = _volume;



-(void)performFromScript:(Script*)script
{
    NSLog(@"Performing: %@", self.description);
    
    [self.object changeVolumeInPercent:self.volume.floatValue];
}


#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"Change Volume by: %f%%)", self.volume.floatValue/100.0f];
}




@end
