//
//  SpriteManagerDelegate.h
//  Catty
//
//  Created by Mattias Rauter on 18.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVAudioPlayer.h>


@class Sprite;

@protocol SpriteManagerDelegate <NSObject>

-(void)bringToFrontSprite:(Sprite*)sprite;

-(void)addSound:(AVAudioPlayer*)sound forSprite:(Sprite*)sprite;

-(void)stopAllSounds;

-(void)setVolumeTo:(float)volume forSprite:(Sprite*)sprite;

-(void)changeVolumeBy:(float)percent forSprite:(Sprite*)sprite;

@end
