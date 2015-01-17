/**
 *  Copyright (C) 2010-2014 The Catrobat Team
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
@class Brick;
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

@property (nonatomic, strong) Look *currentLook;

@property (strong, nonatomic) UIImage *currentUIImageLook;

@property (nonatomic) CGFloat currentLookBrightness;

@property (nonatomic, weak) Program *program;

@property (nonatomic)NSInteger numberOfObjectsWithoutBackground;


- (NSUInteger)numberOfScripts;

- (NSUInteger)numberOfTotalBricks; // including script bricks

- (NSUInteger)numberOfNormalBricks; // excluding script bricks

- (NSUInteger)numberOfLooks;

- (NSUInteger)numberOfSounds;

- (BOOL)isBackground;

- (instancetype)deepCopy;

// events
- (void)start:(CGFloat)zPosition;
- (void)scriptFinished:(Script*)script;

- (void)broadcast:(NSString*)message;
- (void)broadcastAndWait:(NSString*)message;

- (void)performBroadcastWaitScriptWithMessage:(NSString *)message with:(dispatch_semaphore_t) sema1;
- (void)startAndAddScript:(Script*)script completion:(dispatch_block_t)completion;
- (Look*)nextLook;
- (BOOL)touchedwith:(NSSet*)touches withX:(CGFloat)x andY:(CGFloat)y;

// helpers
- (NSString*)projectPath; //for image-path!!!
- (NSString*)previewImagePathForLookAtIndex:(NSUInteger)index;
- (NSString*)previewImagePath; // thumbnail/preview image-path of first (!) look shown in several TableViewCells!!!
- (NSString*)pathForLook:(Look*)look;
- (NSString*)pathForSound:(Sound*)sound;
- (NSUInteger)fileSizeOfLook:(Look*)look;
- (CGSize)dimensionsOfLook:(Look*)look;
- (NSUInteger)fileSizeOfSound:(Sound*)sound;
- (CGFloat)durationOfSound:(Sound*)sound;
- (NSArray*)allLookNames;
- (NSArray*)allSoundNames;

// actions
- (void)changeLook:(Look*)look;
- (void)setLook;
- (void)addLook:(Look*)look AndSaveToDisk:(BOOL)save;
- (void)removeLooks:(NSArray*)looks AndSaveToDisk:(BOOL)save;
- (void)removeLook:(Look*)look AndSaveToDisk:(BOOL)save;
- (void)removeSounds:(NSArray*)sounds AndSaveToDisk:(BOOL)save;
- (void)removeSound:(Sound*)sound AndSaveToDisk:(BOOL)save;
- (void)renameLook:(Look*)look toName:(NSString*)newLookName AndSaveToDisk:(BOOL)save;
- (void)renameSound:(Sound*)sound toName:(NSString*)newSoundName AndSaveToDisk:(BOOL)save;
- (BOOL)hasLook:(Look*)look;
- (BOOL)hasSound:(Sound*)sound;
- (Look*)copyLook:(Look*)sourceLook withNameForCopiedLook:(NSString*)nameOfCopiedLook AndSaveToDisk:(BOOL)save;;
- (Sound*)copySound:(Sound*)sourceSound withNameForCopiedSound:(NSString*)nameOfCopiedSound AndSaveToDisk:(BOOL)save;;

- (BOOL)isEqualToSpriteObject:(SpriteObject*)spriteObject;

@end
