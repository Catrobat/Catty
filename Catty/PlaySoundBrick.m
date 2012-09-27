//
//  PlaySoundBrick.m
//  Catty
//
//  Created by Dominik Ziegler on 9/21/12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "PlaySoundBrick.h"
#import <AVFoundation/AVAudioPlayer.h>

@interface PlaySoundBrick()

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@end


@implementation PlaySoundBrick

@synthesize fileName = _fileName;


- (void)performOnSprite:(Sprite *)sprite
{
    NSLog(@"Performing: %@", self.description);
    
    @try
    {
        NSString *soundPath = [NSString stringWithFormat:@"%@sounds/%@", [sprite projectPath], _fileName];
        AVAudioPlayer* audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:soundPath] error:NULL];
        [sprite addSound:audioPlayer];
    }
    @catch(NSException *ex)
    {
        NSLog(@"Unsupported audio format!");
    }
}


#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"PlaySound (File Name: %@)", _fileName];
}


@end
