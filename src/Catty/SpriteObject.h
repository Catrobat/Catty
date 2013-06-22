/**
 *  Copyright (C) 2010-2013 The Catrobat Team
 *  (http://developer.catrobat.org/credits)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  An additional term exception under section 7 of the GNU Affero
 *  General Public License, version 3, is available at
 *  (http://developer.catrobat.org/license_additional_term)
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see http://www.gnu.org/licenses/.
 */


#import <SpriteKit/SpriteKit.h>

@class Script;
@class Look;
@class Sound;
@protocol SpriteManagerDelegate;
@protocol BroadcastWaitDelegate;

@protocol SpriteFormulaProtocol

- (CGFloat) xPosition;
- (CGFloat) yPosition;
- (CGFloat) zIndex;
- (CGFloat) alpha;
- (CGFloat) brightness;
- (CGFloat) scaleX;
- (CGFloat) rotation;

@end


@interface SpriteObject : SKSpriteNode <SpriteFormulaProtocol>

@property (assign, nonatomic) CGSize originalSize;

@property (weak, nonatomic) id<SpriteManagerDelegate> spriteManagerDelegate;
@property (weak, nonatomic) id<BroadcastWaitDelegate> broadcastWaitDelegate;

@property (strong, nonatomic) NSString *projectPath; //for image-path!!!

@property (strong, nonatomic) NSMutableArray *lookList;
@property (strong, nonatomic) NSMutableArray *soundList;

@property (nonatomic, strong) NSMutableArray *scriptList;



/* Loop Update - called once per frame. */
- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)interval;

// events
- (void)start;
- (void)scriptFinished:(Script*)script;


- (void)broadcast:(NSString*)message;
- (void)broadcastAndWait:(NSString*)message;

- (void)performBroadcastWaitScript_calledFromBroadcastWaitDelegate_withMessage:(NSString *)message;

- (Look*)nextLook;


// actions
- (void)changeLook:(Look*)look;

//- (void)glideToPosition:(CGPoint)position withDurationInSeconds:(float)durationInSeconds fromScript:(Script*)script;
//- (void)hide;
//- (void)show;
//- (void)comeToFront;
//- (void)changeSizeByNInPercent:(float)sizePercentageRate;
//- (void)changeXBy:(float)x;
//- (void)changeYBy:(float)y;
//- (void)stopAllSounds;
//- (void)setSizeToPercentage:(float)sizeInPercentage;
//- (void)goNStepsBack:(int)n;
//- (void)setTransparencyInPercent:(float)transparencyInPercent;
//- (void)changeTransparencyInPercent:(float)increaseInPercent;
//- (void)playSound:(Sound*)sound;
//- (void)speakSound:(Sound*)sound;
//- (void)setVolumeToInPercent:(float)volumeInPercent;
//- (void)changeVolumeInPercent:(float)volumeInPercent;
//- (void)turnLeft:(float)degrees;
//- (void)turnRight:(float)degrees;
//- (void)pointInDirection:(float)degrees;
//- (void)changeBrightness:(float)factor;
//- (void)moveNSteps:(float)steps;
//- (void)ifOnEdgeBounce;

@end
