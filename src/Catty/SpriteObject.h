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
#import "Program.h"
#import "ProgramDefines.h"

@class Script;
@class Look;
@class Sound;
@class GDataXMLElement;
@protocol SpriteManagerDelegate;
@protocol BroadcastWaitDelegate;

@protocol SpriteFormulaProtocol

- (CGFloat) xPosition;
- (CGFloat) yPosition;
- (CGFloat) zIndex;
- (CGFloat) alpha;
- (CGFloat) brightness;
- (CGFloat) scaleX;
- (CGFloat) scaleY;
- (CGFloat) rotation;

@end


@interface SpriteObject : SKSpriteNode <SpriteFormulaProtocol>

@property (assign, nonatomic) CGSize originalSize;

@property (weak, nonatomic) id<SpriteManagerDelegate> spriteManagerDelegate;
@property (weak, nonatomic) id<BroadcastWaitDelegate> broadcastWaitDelegate;

@property (nonatomic, strong) NSMutableArray *lookList;

@property (nonatomic, strong) NSMutableArray *soundList;

@property (nonatomic, strong) NSMutableArray *scriptList;

@property (nonatomic, strong) Look* currentLook;

@property (strong, nonatomic) UIImage* currentUIImageLook;

@property (nonatomic) CGFloat currentLookBrightness;

@property (nonatomic,strong) Program* program;

@property (nonatomic)NSInteger numberOfObjectsWithoutBackground;

- (BOOL)isBackground;

- (GDataXMLElement*)toXML;


// events
- (void)start:(CGFloat)zPosition;
- (void)scriptFinished:(Script*)script;


- (void)broadcast:(NSString*)message;
- (void)broadcastAndWait:(NSString*)message;

-(void)performBroadcastWaitScriptWithMessage:(NSString *)message with:(dispatch_semaphore_t) sema1;
-(void)startAndAddScript:(Script*)script completion:(dispatch_block_t)completion;
- (Look*)nextLook;

// helpers
- (NSString*)projectPath; //for image-path!!!
- (NSString*)previewImagePathForLookAtIndex:(NSUInteger)index;
- (NSString*)previewImagePath; // thumbnail/preview image-path of first (!) look shown in several TableViewCells!!!
- (NSString*)pathForLook:(Look*)look;
- (NSString*)pathForSound:(Sound*)sound;

// actions
- (void)changeLook:(Look*)look;
- (void)setLook;

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
