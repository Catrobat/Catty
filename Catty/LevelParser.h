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

////////// public for unit-test


-(SetLookBrick*)loadSetCostumeBrick:(GDataXMLElement*)gDataSetCostumeBrick;
-(WaitBrick*)loadWaitBrick:(GDataXMLElement*)gDataWaitBrick;
-(PlaceAtBrick*)loadPlaceAtBrick:(GDataXMLElement*)gDataXMLElement;
-(GlideToBrick*)loadGlideToBrick:(GDataXMLElement*)gDataXMLElement;
-(SetXBrick*)loadSetXBrick:(GDataXMLElement*)gDataXMLElement;
-(SetYBrick*)loadSetYBrick:(GDataXMLElement*)gDataXMLElement;
-(ChangeSizeByNBrick*)loadChangeSizeByNBrick:(GDataXMLElement*)gDataXMLElement;
-(BroadcastBrick*)loadBroadcastBrick:(GDataXMLElement*)gDataXMLElement;
-(BroadcastWaitBrick*)loadBroadcastWaitBrick:(GDataXMLElement*)gDataXMLElement;
-(ChangeXByNBrick*)loadChangeXByBrick:(GDataXMLElement*)gDataXMLElement;
-(ChangeYByNBrick*)loadChangeYByBrick:(GDataXMLElement*)gDataXMLElement;
-(PlaySoundBrick*)loadSoundBrick:(GDataXMLElement*)gDataXMLElement;
-(SetSizeToBrick*)loadSetSizeToBrick:(GDataXMLElement*)gDataXMLElement;
-(RepeatBrick*)loadRepeatBrick:(GDataXMLElement*)gDataXMLElement;
-(GoNStepsBackBrick*)loadGoNStepsBackBrick:(GDataXMLElement*)gDataXMLElement;
-(SetGhostEffectBrick*)loadGhostEffectBrick:(GDataXMLElement*)gDataXMLElement;
-(ChangeGhostEffectByNBrick*)loadChangeGhostEffectBrick:(GDataXMLElement*)gDataXMLElement;
-(SetVolumeToBrick*)loadSetVolumeToBrick:(GDataXMLElement*)gDataXMLElement;
-(ChangeVolumeByBrick*)loadChangeVolumeByBrick:(GDataXMLElement*)gDataXMLElement;
-(SpeakBrick*)loadSpeakBrick:(GDataXMLElement*)gDataXMLElement;

@end
