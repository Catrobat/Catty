//
//  SpriteObject.h
//  Catty
//
//  Created by Mattias Rauter on 04.04.13.
//
//

#import "SPImage.h"

@class Script;
@class Look;
@protocol SpriteManagerDelegate;
@protocol BroadcastWaitDelegate;

@interface SpriteObject : SPImage

@property (strong, nonatomic) NSString *name;

@property (assign, nonatomic) CGSize originalSize;
@property (assign, nonatomic) BOOL showSprite;
@property (assign, nonatomic) CGPoint position;
@property (assign, nonatomic) float alphaValue;


@property (weak, nonatomic) id<SpriteManagerDelegate> spriteManagerDelegate;
@property (weak, nonatomic) id<BroadcastWaitDelegate> broadcastWaitDelegate;

@property (strong, nonatomic) NSString *projectPath; //for image-path!!!

@property (strong, nonatomic) NSArray *lookList;
@property (strong, nonatomic) NSMutableArray *soundList;

@property (nonatomic, strong) NSArray *scriptList;



- (NSString*)description;

// events
- (void)start;
- (void)scriptFinished:(Script*)script;
- (void)stopAllScripts;
- (void)onImageTouched:(SPTouchEvent*)event;

// actions
- (void)placeAt:(GLKVector3)newPosition;
- (void)changeLook:(Look*)look;
- (void)nextLook;
- (void)glideToPosition:(CGPoint)position withDurationInSeconds:(float)durationInSeconds fromScript:(Script*)script;
- (void)hide;
- (void)show;
- (void)setXPosition:(float)xPosition;
- (void)setYPosition:(float)yPosition;
- (void)broadcast:(NSString*)message;
- (void)broadcastAndWait:(NSString*)message;
- (void)addSound:(id)sound;
- (void)comeToFront;
- (void)changeSizeByN:(float)sizePercentageRate;
- (void)changeXBy:(int)x;
- (void)changeYBy:(int)y;
- (void)stopAllSounds;
- (void)setSizeToPercentage:(float)sizeInPercentage;
- (void)goNStepsBack:(int)n;
- (void)setTransparency:(float)transparency;
- (void)changeTransparencyBy:(NSNumber*)increase;
- (void)setVolumeTo:(float)volume;
- (void)changeVolumeBy:(float)percent;
- (void)turnLeft:(float)degrees;
- (void)turnRight:(float)degrees;
- (void)pointToDirection:(float)degrees;



@end
