//
//  Sprite.h
//  Catty
//
//  Created by Mattias Rauter on 17.04.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "enums.h"
#import "SpriteManagerDelegate.h"
#import <AVFoundation/AVAudioPlayer.h>


#define SPRITE_IMAGE_FOLDER @"images"

//@class SpriteManagerDelegate;
@class Costume;
@class Script;
@class Sound;
@class StartScript;
@class WhenScript;

//////////////////////////////////////////////////////////////////////////////////////////

@interface PositionAtTime : NSObject
@property (assign, nonatomic) GLKVector3 position;
@property (assign, nonatomic) double timestamp;
+(PositionAtTime*)positionAtTimeWithPosition:(GLKVector3)position andTimestamp:(double)timestamp;
@end

//////////////////////////////////////////////////////////////////////////////////////////


@interface Sprite : NSObject



@property (weak, nonatomic) id<SpriteManagerDelegate> spriteManagerDelegate;

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *projectPath; //for image-path!!!
@property (readonly, strong, nonatomic) NSArray *costumesArray;
@property (readonly, strong, nonatomic) NSArray *soundsArray;
@property (readonly, strong, nonatomic) NSArray *startScriptsArray;
@property (readonly, strong, nonatomic) NSArray *whenScriptsArray;
@property (readonly, strong, nonatomic) NSDictionary *broadcastScripts; //TODO: ONE broadcast-script for ONE message?? Hopefully, yes - otherwise: change this :(
@property (assign) CGSize contentSize;
@property (nonatomic, strong) GLKBaseEffect *effect;

// init, add
- (id)initWithEffect:(GLKBaseEffect*)effect;

- (void)setProjectResolution:(CGSize)projectResolution;

- (void)addCostume:(Costume*)costume;
- (void)addCostumes:(NSArray*)costumesArray;
- (void)addSound:(AVAudioPlayer*)sound;
- (void)addStartScript:(StartScript*)script;
- (void)addWhenScript:(WhenScript*)script;
- (void)addBroadcastScript:(Script*)script forMessage:(NSString*)message;

- (float)getZIndex;
- (void)setZIndex:(float)newZIndex;
- (void)decrementZIndexByOne;

// graphics
- (void)update:(float)dt;
- (void)render;

// other stuff
- (NSString*)description;

// events
- (CGRect)boundingBox;
- (void)start;
- (void)touch:(TouchAction)type;

// actions
- (void)placeAt:(GLKVector3)newPosition;    //origin is in the middle of the sprite
- (void)wait:(int)durationInMilliSecs;
- (void)changeCostume:(NSNumber*)indexOfCostumeInArray;
- (void)nextCostume;
- (void)glideToPosition:(GLKVector3)position withinDurationInMilliSecs:(int)durationInMilliSecs;
- (void)hide;
- (void)show;
- (void)setXPosition:(float)xPosition;
- (void)setYPosition:(float)yPosition;
- (void)broadcast:(NSString*)message;
- (void)comeToFront;
- (void)changeSizeByN:(float)sizePercentageRate;
- (void)changeXBy:(float)x;
- (void)stopAllSounds;
- (void)setSizeToPercentage:(float)sizeInPercentage;
- (void)addLoopBricks:(NSArray*)bricks;

@end
