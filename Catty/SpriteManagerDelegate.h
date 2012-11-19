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
-(void)bringNStepsBackSprite:(Sprite*)sprite numberOfSteps:(int)n;

-(void)stopAllSounds;

-(void)increaseNumberOfObserversForNotificationMessage:(NSString*)notificationMessage;
-(void)object:(id)object isWaitingForAllObserversOfMessage:(NSString*)notificationMessage withResponseID:(NSString*)responseID;

-(BOOL)polling4testing__didAllObserversFinishForResponseID:(NSString*)responseID;

@end
