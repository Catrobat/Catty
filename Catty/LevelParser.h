//
//  LevelParser.h
//  Catty
//
//  Created by Christof Stromberger on 19.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <Foundation/Foundation.h>


@class Level;

/// just for unit-tests:
@class SetLookBrick;
@class WaitBrick;
@class PlaceAtBrick;
@class GlideToBrick;
@class SetXBrick;
@class SetYBrick;
@class ChangeSizeByNBrick;
@class BroadcastBrick;
@class BroadcastWaitBrick;
@class ChangeXByNBrick;
@class ChangeYByNBrick;
@class PlaySoundBrick;
@class SetSizeToBrick;
@class RepeatBrick;
@class GoNStepsBackBrick;
@class SetGhostEffectBrick;
@class ChangeGhostEffectByNBrick;
@class SetVolumeToBrick;
@class ChangeVolumeByBrick;
@class GDataXMLElement;
@class SpeakBrick;


@interface LevelParser : NSObject

- (Level*)loadLevel:(NSData*)xmlData;

@end
