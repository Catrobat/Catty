/**
 *  Copyright (C) 2010-2024 The Catrobat Team
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

#import "SpriteObject.h"
#import "StartScript.h"
#import "Util.h"
#import "Brick.h"
#import "CBFileManager.h"
#import "AudioManager.h"
#import "CBFileManager.h"
#import "NSString+FastImageSize.h"
#import "CBMutableCopyContext.h"
#import "Pocket_Code-Swift.h"

@implementation SpriteObject

- (NSMutableArray*)lookList
{
    // lazy instantiation
    if (! _lookList)
        _lookList = [NSMutableArray array];
    return _lookList;
}

- (NSMutableArray*)soundList
{
    // lazy instantiation
    if (! _soundList)
        _soundList = [NSMutableArray array];
    return _soundList;
}

- (NSMutableArray*)scriptList
{
    // lazy instantiation
    if (! _scriptList)
        _scriptList = [NSMutableArray array];
    return _scriptList;
}

- (UserDataContainer*)userData
{
    // lazy instantiation
    if (! _userData)
        _userData = [[UserDataContainer alloc] init];
    return _userData;
}

- (NSUInteger)numberOfScripts
{
    return [self.scriptList count];
}

- (NSUInteger)numberOfTotalBricks
{
    return ([self numberOfScripts] + [self numberOfNormalBricks]);
}

- (NSUInteger)numberOfNormalBricks
{
    NSUInteger numberOfBricks = 0;
    for (Script *script in self.scriptList) {
        numberOfBricks += [script.brickList count];
    }
    return numberOfBricks;
}

- (NSUInteger)numberOfLooks
{
    return [self.lookList count];
}

- (NSUInteger)numberOfSounds
{
    return [self.soundList count];
}

- (NSString*)projectPath
{
  return [self.scene.project projectPath];
}

- (NSString*)previewImagePath
{
    Look* look = [self.lookList objectAtIndex:0];
    if (! look)
        return nil;
    
    return [look pathForScene:self.scene];
}

- (BOOL)isBackground
{
    if (self.scene && [self.scene.objects count])
        return ([self.scene.objects objectAtIndex:0] == self);
    return NO;
}

- (NSUInteger)fileSizeOfLook:(Look*)look
{
    NSString *path = [look pathForScene:self.scene];
    CBFileManager *fileManager = [CBFileManager sharedManager];
    return [fileManager sizeOfFileAtPath:path];
}

- (CGSize)dimensionsOfLook:(Look*)look
{
    NSString *path = [look pathForScene:self.scene];
    // very fast implementation! far more quicker than UIImage's size method/property
    return [path sizeOfImageForFilePath];
}

- (NSUInteger)fileSizeOfSound:(Sound*)sound
{
    NSString *path = [sound pathForScene:self.scene];
    CBFileManager *fileManager = [CBFileManager sharedManager];
    return [fileManager sizeOfFileAtPath:path];
}

- (CGFloat)durationOfSound:(Sound*)sound
{
    NSString *path = [sound pathForScene:self.scene];
    return [[AudioManager sharedAudioManager] durationOfSoundWithFilePath:path];
}

- (NSArray*)allLookNames
{
    NSMutableArray *lookNames = [NSMutableArray arrayWithCapacity:[self.lookList count]];
    for (id look in self.lookList) {
        if ([look isKindOfClass:[Look class]]) {
            [lookNames addObject:((Look*)look).name];
        }
    }
    return [lookNames copy];
}

- (NSArray*)allSoundNames
{
    NSMutableArray *soundNames = [NSMutableArray arrayWithCapacity:[self.soundList count]];
    for (id sound in self.soundList) {
        if ([sound isKindOfClass:[Sound class]]) {
            [soundNames addObject:((Sound*)sound).name];
        }
    }
    return [soundNames copy];
}

- (void)addLook:(Look*)look AndSaveToDisk:(BOOL)save
{
    if ([self hasLook:look]) {
        return;
    }
    look.name = [Util uniqueName:look.name existingNames:[self allLookNames]];
    [self.lookList addObject:look];
    if(save) {
        [self.scene.project saveToDiskWithNotification:YES];
    }
    return;
}

- (void)removeLookFromList:(Look*)look
{
    // do not use NSArray's removeObject here
    // => if isEqual is overriden this would lead to wrong results
    NSUInteger index = 0;
    for (Look *currentLook in self.lookList) {
        if (currentLook != look) {
            ++index;
            continue;
        }

        // count references in all object of that look image
        NSUInteger lookImageReferenceCounter = [self referenceCountForLook:look.fileName];
        // if image is not used by other objects, delete it
        if (lookImageReferenceCounter <= 1) {
            CBFileManager *fileManager = [CBFileManager sharedManager];
            [fileManager deleteFile:[look pathForScene:self.scene]];
        }
        [self.lookList removeObjectAtIndex:index];
        break;
    }
}

- (void)removeLooks:(NSArray*)looks AndSaveToDisk:(BOOL)save
{
    if(looks == self.lookList) {
        looks = [looks mutableCopy];
    }
    for (id look in looks) {
        if ([look isKindOfClass:[Look class]]) {
            [self removeLookFromList:look];
        }
    }
    if(save) {
        [self.scene.project saveToDiskWithNotification:YES];
    }
}

- (void)removeLook:(Look*)look AndSaveToDisk:(BOOL)save
{
    [self removeLookFromList:look];
    if(save) {
        [self.scene.project saveToDiskWithNotification:YES];
    }
}

- (void)removeSoundFromList:(Sound*)sound
{
    // do not use NSArray's removeObject here
    // => if isEqual is overriden this would lead to wrong results
    NSUInteger index = 0;
    for (Sound *currentSound in self.soundList) {
        if (currentSound != sound) {
            ++index;
            continue;
        }

        // count references in all object of that sound file
        NSUInteger soundReferenceCounter = [self referenceCountForSound:sound.fileName];
        // if sound is not used by other objects, delete it
        if (soundReferenceCounter <= 1) {
            CBFileManager *fileManager = [CBFileManager sharedManager];
            [fileManager deleteFile:[sound pathForScene:self.scene]];
        }
        [self.soundList removeObjectAtIndex:index];
        break;
    }
}

- (void)removeSounds:(NSArray*)sounds AndSaveToDisk:(BOOL)save
{
    if(sounds == self.soundList) {
        sounds = [sounds mutableCopy];
    }
    for (id sound in sounds) {
        if ([sound isKindOfClass:[Sound class]]) {
            [self removeSoundFromList:sound];
        }
    }
    if(save) {
        [self.scene.project saveToDiskWithNotification:YES];
    }
}

- (void)removeSound:(Sound*)sound AndSaveToDisk:(BOOL)save
{
    [self removeSoundFromList:sound];
    if(save) {
        [self.scene.project saveToDiskWithNotification:YES];
    }
}

- (BOOL)hasLook:(Look*)look
{
    return [self.lookList containsObject:look];
}

- (BOOL)hasSound:(Sound*)sound
{
    return [self.soundList containsObject:sound];
}

- (Look*)copyLook:(Look*)sourceLook withNameForCopiedLook:(NSString*)nameOfCopiedLook AndSaveToDisk:(BOOL)save
{
    if (! [self hasLook:sourceLook]) {
        return nil;
    }
    Look *copiedLook = [sourceLook mutableCopyWithContext:[CBMutableCopyContext new]];
    copiedLook.name = [Util uniqueName:nameOfCopiedLook existingNames:[self allLookNames]];
    [self.lookList addObject:copiedLook];
    if(save) {
        [self.scene.project saveToDiskWithNotification:YES];
    }
    return copiedLook;
}

- (Sound*)copySound:(Sound*)sourceSound withNameForCopiedSound:(NSString*)nameOfCopiedSound AndSaveToDisk:(BOOL)save
{
    if (! [self hasSound:sourceSound]) {
        return nil;
    }
    Sound *copiedSound = [sourceSound mutableCopyWithContext:[CBMutableCopyContext new]];
    copiedSound.name = [Util uniqueName:nameOfCopiedSound existingNames:[self allSoundNames]];
    [self.soundList addObject:copiedSound];
    if(save) {
        [self.scene.project saveToDiskWithNotification:YES];
    }
    return copiedSound;
}

- (void)renameLook:(Look*)look toName:(NSString*)newLookName AndSaveToDisk:(BOOL)save
{
    if (! [self hasLook:look] || [look.name isEqualToString:newLookName]) {
        return;
    }
    look.name = [Util uniqueName:newLookName existingNames:[self allLookNames]];
    if(save) {
        [self.scene.project saveToDiskWithNotification:YES];
    }
}

- (void)renameSound:(Sound*)sound toName:(NSString*)newSoundName AndSaveToDisk:(BOOL)save
{
    if (! [self hasSound:sound] || [sound.name isEqualToString:newSoundName]) {
        return;
    }
    sound.name = [Util uniqueName:newSoundName existingNames:[self allSoundNames]];
    if(save) {
        [self.scene.project saveToDiskWithNotification:YES];
    }
}

- (void)removeReferences
{
    self.scene = nil;
    [self.scriptList makeObjectsPerformSelector:@selector(removeReferences)];
}

- (NSString*)description
{
    NSMutableString *mutableString = [NSMutableString string];
    [mutableString appendFormat:@"Name: %@\r", self.name];
    [mutableString appendFormat:@"Scripts: %@\r", self.scriptList];
    [mutableString appendFormat:@"Looks: %@\r", self.lookList];
    [mutableString appendFormat:@"Sounds: %@\r", self.soundList];
    return [mutableString copy];
}

#pragma mark - Compare
- (BOOL)isEqualToSpriteObject:(SpriteObject*)spriteObject
{
    // check if object names are both equal to each other
    if (! [self.name isEqualToString:spriteObject.name]) {
        return NO;
    }

    // lookList
    if ([self.lookList count] != [spriteObject.lookList count])
        return NO;

    NSUInteger index;
    for (index = 0; index < [self.lookList count]; ++index) {
        Look *firstLook = [self.lookList objectAtIndex:index];
        Look *secondLook = [spriteObject.lookList objectAtIndex:index];

        if (! [firstLook isEqual:secondLook])
            return NO;
    }

    // soundList
    if ([self.soundList count] != [spriteObject.soundList count])
        return NO;

    for (index = 0; index < [self.soundList count]; index++) {
        Sound *firstSound = [self.soundList objectAtIndex:index];
        Sound *secondSound = [spriteObject.soundList objectAtIndex:index];
        
        if (! [firstSound isEqual:secondSound])
            return NO;
    }
    
    // scriptList
    if ([self.scriptList count] != [spriteObject.scriptList count])
        return NO;
    for (index = 0; index < [self.scriptList count]; index++) {
        Script *firstScript = [self.scriptList objectAtIndex:index];
        Script *secondScript = [spriteObject.scriptList objectAtIndex:index];
        
        if (! [firstScript isEqualToScript:secondScript])
            return NO;
    }
    
    if(self.userData && spriteObject.userData) {
        if (![self.userData isEqual:spriteObject.userData]) {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - Copy
- (id)mutableCopyWithContext:(CBMutableCopyContext*)context;
{
    if (! context) { NSError(@"%@ must not be nil!", [CBMutableCopyContext class]); }

    SpriteObject *newObject = [[SpriteObject alloc] init];
    newObject.scene = self.scene;
    newObject.name = [NSString stringWithString:self.name];
    newObject.userData = [self.userData mutableCopyWithContext:context];
    [context updateReference:self WithReference:newObject];

    // deep copy
    newObject.lookList = [NSMutableArray arrayWithCapacity:[self.lookList count]];
    for (id lookObject in self.lookList) {
        if ([lookObject isKindOfClass:[Look class]]) {
            [newObject.lookList addObject:[lookObject mutableCopyWithContext:context]];
        }
    }
    newObject.soundList = [NSMutableArray arrayWithCapacity:[self.soundList count]];
    for (id soundObject in self.soundList) {
        if ([soundObject isKindOfClass:[Sound class]]) {
            [newObject.soundList addObject:[soundObject mutableCopyWithContext:context]];
        }
    }
    newObject.scriptList = [NSMutableArray arrayWithCapacity:[self.scriptList count]];
    for (id scriptObject in self.scriptList) {
        if ([scriptObject isKindOfClass:[Script class]]) {
            Script *copiedScript = [scriptObject mutableCopyWithContext:context];
            copiedScript.object = newObject;
            [newObject.scriptList addObject:copiedScript];
        }
    }
    return newObject;
}

- (NSInteger)getRequiredResources
{
    NSInteger resources = kNoResources;
    
    for (Script *script in self.scriptList) {
        resources |= [script getRequiredResources];
    }
    return resources;
}

#pragma mark - Helpers
- (NSUInteger)referenceCountForLook:(NSString*)fileName
{
    NSUInteger referenceCount = 0;
    for (SpriteObject *object in self.scene.objects) {
        for (Look *look in object.lookList) {
            if ([look.fileName isEqualToString:fileName]) {
                ++referenceCount;
            }
        }
    }
    return referenceCount;
}

- (NSUInteger)referenceCountForSound:(NSString*)fileName
{
    NSUInteger referenceCount = 0;
    for (SpriteObject *object in self.scene.objects) {
        for (Sound *sound in object.soundList) {
            if ([sound.fileName isEqualToString:fileName]) {
                ++referenceCount;
            }
        }
    }
    return referenceCount;
}

@end
