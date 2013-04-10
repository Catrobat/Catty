//
//  PlaySoundBrick.m
//  Catty
//
//  Created by Dominik Ziegler on 9/21/12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Playsoundbrick.h"
#import <AVFoundation/AVAudioPlayer.h>
#import "Sound.h"

@interface Playsoundbrick()

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@end


@implementation Playsoundbrick

@synthesize sound = _sound;


//-(id)initWithFileName:(NSString *)fileName
//{
//    self = [super init];
//    if (self)
//    {
//        self.fileName = fileName;
//    }
//    
//    return self;
//}


- (void)performFromScript:(Script*)script
{
    NSLog(@"Performing: %@", self.description);
    
    [self.object playSound:self.sound];
    
//    @try
//    {
//        NSString *soundPath = [NSString stringWithFormat:@"%@sounds/%@", [self.object projectPath], self.sound.fileName];
//        NSError* error = nil;
//        AVAudioPlayer* audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:soundPath] error:&error];
//        [self.object addSound:audioPlayer];
//    }
//    @catch(NSException *ex)
//    {
//        NSLog(@"Unsupported audio format!");
//    }
    
    NSLog(@"%@",[self.object projectPath]);
}


#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"PlaySound (File Name: %@)", self.sound.fileName];
}


@end
