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
@class SetCostumeBrick;
@class WaitBrick;
@class PlaceAtBrick;
@class GlideToBrick;
@class SetXBrick;
@class SetYBrick;
@class ChangeSizeByNBrick;
@class BroadcastBrick;
@class BroadcastWaitBrick;
@class ChangeXByBrick;
@class ChangeYByBrick;
@class PlaySoundBrick;
@class SetSizeToBrick;
@class RepeatBrick;
@class GoNStepsBackBrick;
@class SetGhostEffectBrick;
@class ChangeGhostEffectBrick;
@class SetVolumeToBrick;
@class ChangeVolumeByBrick;
@class GDataXMLElement;
@class SpeakBrick;


@interface LevelParser : NSObject

- (Level*)loadLevel:(NSData*)xmlData;

////////// public for unit-test


-(SetCostumeBrick*)loadSetCostumeBrick:(GDataXMLElement*)gDataSetCostumeBrick;
-(WaitBrick*)loadWaitBrick:(GDataXMLElement*)gDataWaitBrick;
-(PlaceAtBrick*)loadPlaceAtBrick:(GDataXMLElement*)gDataXMLElement;
-(GlideToBrick*)loadGlideToBrick:(GDataXMLElement*)gDataXMLElement;
-(SetXBrick*)loadSetXBrick:(GDataXMLElement*)gDataXMLElement;
-(SetYBrick*)loadSetYBrick:(GDataXMLElement*)gDataXMLElement;
-(ChangeSizeByNBrick*)loadChangeSizeByNBrick:(GDataXMLElement*)gDataXMLElement;
-(BroadcastBrick*)loadBroadcastBrick:(GDataXMLElement*)gDataXMLElement;
-(BroadcastWaitBrick*)loadBroadcastWaitBrick:(GDataXMLElement*)gDataXMLElement;
-(ChangeXByBrick*)loadChangeXByBrick:(GDataXMLElement*)gDataXMLElement;
-(ChangeYByBrick*)loadChangeYByBrick:(GDataXMLElement*)gDataXMLElement;
-(PlaySoundBrick*)loadSoundBrick:(GDataXMLElement*)gDataXMLElement;
-(SetSizeToBrick*)loadSetSizeToBrick:(GDataXMLElement*)gDataXMLElement;
-(RepeatBrick*)loadRepeatBrick:(GDataXMLElement*)gDataXMLElement;
-(GoNStepsBackBrick*)loadGoNStepsBackBrick:(GDataXMLElement*)gDataXMLElement;
-(SetGhostEffectBrick*)loadGhostEffectBrick:(GDataXMLElement*)gDataXMLElement;
-(ChangeGhostEffectBrick*)loadChangeGhostEffectBrick:(GDataXMLElement*)gDataXMLElement;
-(SetVolumeToBrick*)loadSetVolumeToBrick:(GDataXMLElement*)gDataXMLElement;
-(ChangeVolumeByBrick*)loadChangeVolumeByBrick:(GDataXMLElement*)gDataXMLElement;
-(SpeakBrick*)loadSpeakBrick:(GDataXMLElement*)gDataXMLElement;

@end
