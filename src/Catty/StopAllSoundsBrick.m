//
//  StopAllSoundsBrick.m
//  Catty
//
//  Created by Dominik Ziegler on 9/21/12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Stopallsoundsbrick.h"
#import "SpriteManagerDelegate.h"

@implementation Stopallsoundsbrick

- (void)performFromScript:(Script*)script
{
    NSDebug(@"Performing: %@", self.description);
    
    [self.object.spriteManagerDelegate stopAllSounds];
    
}


#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"Stop All Sounds Brick"];
}


@end
