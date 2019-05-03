/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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
#import "Project.h"
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
@property (nonatomic, weak) Project *project;
@property (nonatomic, weak) CBSpriteNode *spriteNode;

- (NSUInteger)numberOfScripts;
- (NSUInteger)numberOfTotalBricks; // including script bricks
- (NSUInteger)numberOfNormalBricks; // excluding script bricks
- (NSUInteger)numberOfLooks;
- (NSUInteger)numberOfSounds;
- (BOOL)isBackground;

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
- (NSUInteger)referenceCountForLook:(NSString*)fileName;
- (NSUInteger)referenceCountForSound:(NSString*)fileName;

// actions
- (void)addLook:(Look*)look AndSaveToDisk:(BOOL)save;
- (void)removeFromProject;
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
- (void)removeReferences;

- (NSInteger)getRequiredResources;

// compare
- (BOOL)isEqualToSpriteObject:(SpriteObject*)spriteObject;

@end
