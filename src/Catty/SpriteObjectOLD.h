//
//  Sprite.h
//  Catty
//
//  Created by Mattias Rauter on 17.04.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "enums.h"
#import <AVFoundation/AVAudioPlayer.h>
#import "BaseSprite.h"


#define SPRITE_IMAGE_FOLDER @"images"

@protocol SpriteManagerDelegate;
@protocol BroadcastWaitDelegate;
@class Costume;
@class Script;
@class Sound;
@class Script;
@class Look;

//////////////////////////////////////////////////////////////////////////////////////////

@interface PositionAtTime : NSObject
@property (assign, nonatomic) GLKVector3 position;
@property (assign, nonatomic) double timestamp;
+(PositionAtTime*)positionAtTimeWithPosition:(GLKVector3)position andTimestamp:(double)timestamp;
@end

//////////////////////////////////////////////////////////////////////////////////////////


@interface SpriteObjectOLD : BaseSprite <AVAudioPlayerDelegate>



@property (weak, nonatomic) id<SpriteManagerDelegate> spriteManagerDelegate;
@property (weak, nonatomic) id<BroadcastWaitDelegate> broadcastWaitDelegate;

@property (strong, nonatomic) NSString *projectPath; //for image-path!!!
@property (readonly, strong, nonatomic) NSArray *lookList;
@property (readonly, strong, nonatomic) NSMutableArray *soundList;

// new script array (contains StartScrupt and WhenScripts
@property (nonatomic, strong) NSArray *scriptList;
#warning todo for mattias: change implementation of stage (etc.) for handling scriptList instead of startScriptsArray and whenScriptsArray


@property (readonly, assign, nonatomic) float xOffset;        // black border, if proportions are different (project-xml-resolution vs. screen-resolution)
@property (readonly, assign, nonatomic) float yOffset;
//@property (readonly, assign, nonatomic) BOOL showSprite;
@property (readonly, assign, nonatomic) GLKVector3 position;        // position - origin is in the middle of the sprite
//@property (readonly, assign, nonatomic) float alphaValue;
@property (readonly, assign, nonatomic) float scaleWidth;
@property (readonly, assign, nonatomic) float scaleHeight;


// init, add
- (id)initWithEffect:(GLKBaseEffect*)effect;

- (void)setProjectResolution:(CGSize)projectResolution;

- (void)addCostume:(Costume*)costume;
- (void)addCostumes:(NSArray*)costumesArray;
- (void)addStartScript:(Script*)script;
- (void)addWhenScript:(Script*)script;
- (void)addBroadcastScript:(Script*)script forMessage:(NSString*)message;

- (float)getZIndex;
- (void)setZIndex:(float)newZIndex;
- (void)decrementZIndexByOne;

// graphics
- (void)update:(float)dt;

// other stuff
- (NSString*)description;

// events
- (CGRect)boundingBox;
- (void)start;
- (void)touch:(TouchAction)type;
- (void)scriptFinished:(Script*)script;
- (void)stopAllScripts;

// actions
- (void)placeAt:(GLKVector3)newPosition;    //origin is in the middle of the sprite
//- (void)wait:(int)durationInMilliSecs fromScript:(Script*)script;
- (void)changeCostume:(Look*)look;
- (void)nextCostume;
- (void)glideToPosition:(GLKVector3)position withDurationInSeconds:(int)durationInSeconds fromScript:(Script*)script;
- (void)hide;
- (void)show;
- (void)setXPosition:(float)xPosition;
- (void)setYPosition:(float)yPosition;
- (void)broadcast:(NSString*)message;
- (void)broadcastAndWait:(NSString*)message;
- (void)addSound:(AVAudioPlayer*)sound;
- (void)comeToFront;
- (void)changeSizeByN:(float)sizePercentageRate;
- (void)changeXBy:(int)x;
- (void)changeYBy:(int)y;
- (void)stopAllSounds;
- (void)setSizeToPercentage:(float)sizeInPercentage;
//- (void)addLoopBricks:(NSArray*)bricks;
- (void)goNStepsBack:(int)n;
- (void)setTransparency:(float)transparency;
- (void)changeTransparencyBy:(NSNumber*)increase;
- (void)setVolumeTo:(float)volume;
- (void)changeVolumeBy:(float)percent;
- (void)turnLeft:(float)degrees;
- (void)turnRight:(float)degrees;

@end
