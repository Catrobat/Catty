//
//  SpriteManagerDelegate.h
//  Catty
//
//  Created by Mattias Rauter on 18.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVAudioPlayer.h>


@class SpriteObject;

@protocol SpriteManagerDelegate <NSObject>

-(void)bringToFrontSprite:(SpriteObject*)sprite;
-(void)bringNStepsBackSprite:(SpriteObject*)sprite numberOfSteps:(int)n;

-(void)stopAllSounds;

@end
