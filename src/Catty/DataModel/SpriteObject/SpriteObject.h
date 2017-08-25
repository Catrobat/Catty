/**
 *  Copyright (C) 2010-2017 The Catrobat Team
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
#import "CBMutableCopying.h"

@class Script;
@class Look;
@class Sound;
@class CBSpriteNode;

@interface SpriteObject : NSObject <CBMutableCopying>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableArray<Look*> *lookList;
@property (nonatomic, strong) NSMutableArray<Sound*> *soundList;
@property (nonatomic, strong) NSMutableArray<Script*> *scriptList;
@property (nonatomic, weak) Scene *scene;
@property (nonatomic, weak) CBSpriteNode *spriteNode;

@property (nonatomic, readonly) NSArray<UserVariable *> *variables;
@property (nonatomic, readonly) NSArray<UserVariable *> *allAccessibleVariables;
@property (nonatomic, readonly) NSArray<NSString *> *allAccessibleVariableNames;

- (NSUInteger)numberOfScripts;
- (NSUInteger)numberOfTotalBricks; // including script bricks
- (NSUInteger)numberOfNormalBricks; // excluding script bricks
- (NSUInteger)numberOfLooks;
- (NSUInteger)numberOfSounds;
- (BOOL)isBackground;

// helpers
- (NSString*)previewImagePathForLookAtIndex:(NSUInteger)index;
- (NSString*)previewImagePath; // thumbnail/preview image-path of first (!) look shown in several TableViewCells!!!
- (NSString*)imagesDirectory;
- (NSString*)pathForLook:(Look*)look;
- (NSString*)soundsDirectory;
- (NSString*)pathForSound:(Sound*)sound;
- (NSUInteger)fileSizeOfLook:(Look*)look;
- (CGSize)dimensionsOfLook:(Look*)look;
- (NSUInteger)fileSizeOfSound:(Sound*)sound;
- (CGFloat)durationOfSound:(Sound*)sound;
- (NSArray<NSString *> *)allLookNames;
- (NSArray<NSString *> *)allSoundNames;
- (NSUInteger)referenceCountForLook:(NSString*)fileName;
- (NSUInteger)referenceCountForSound:(NSString*)fileName;

// actions
- (void)addLook:(Look *)look;
- (void)removeLook:(Look *)look;
- (void)removeLooks:(NSArray<Look *> *)looks;
- (void)renameLook:(Look *)look toName:(NSString *)newLookName;

- (void)addSound:(Sound *)sound;
- (void)removeSound:(Sound *)sound;
- (void)removeSounds:(NSArray<Sound *> *)sounds;
- (void)renameSound:(Sound *)sound toName:(NSString*)newSoundName;

- (void)moveLookAtIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex;
- (void)moveSoundAtIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex;

- (void)removeReferences;

- (NSInteger)getRequiredResources;

// compare
- (BOOL)isEqualToSpriteObject:(SpriteObject *)spriteObject;

@end
