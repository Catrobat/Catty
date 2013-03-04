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


-(id)initWithFileName:(NSString *)fileName
{
    self = [super init];
    if (self)
    {
        self.fileName = fileName;
    }
    
    return self;
}


- (void)performFromScript:(Script*)script
{
    NSLog(@"Performing: %@", self.description);
    
    @try
    {
        NSString *soundPath = [NSString stringWithFormat:@"%@sounds/%@", [self.sprite projectPath], _fileName];
        AVAudioPlayer* audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:soundPath] error:NULL];
        [self.sprite addSound:audioPlayer];
    }
    @catch(NSException *ex)
    {
        NSLog(@"Unsupported audio format!");
    }
    
    NSLog(@"%@",[self.sprite projectPath]);
}


#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"PlaySound (File Name: %@)", _fileName];
}


@end
