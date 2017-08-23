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

#import "SpriteObject.h"
#import "StartScript.h"
#import "Look.h"
#import "Sound.h"
#import "Util.h"
#import "Brick.h"
#import "FileManager.h"
#import "AudioManager.h"
#import "AppDelegate.h"
#import "NSString+FastImageSize.h"
#import "CBMutableCopyContext.h"
#import "Scene.h"
#import "NSArray+CustomExtension.h"
#import "ProgramManager.h"

@implementation SpriteObject

- (NSMutableArray<Look *> *)lookList
{
    // lazy instantiation
    if (! _lookList)
        _lookList = [NSMutableArray array];
    return _lookList;
}

- (NSMutableArray<Sound *> *)soundList
{
    // lazy instantiation
    if (! _soundList)
        _soundList = [NSMutableArray array];
    return _soundList;
}

- (NSMutableArray<Script *> *)scriptList
{
    // lazy instantiation
    if (! _scriptList)
        _scriptList = [NSMutableArray array];
    return _scriptList;
}

- (NSArray<UserVariable *> *)variables {
    return [[self.scene.objectVariableList objectForKey:self] copy];
}

- (NSArray<UserVariable *> *)allAccessibleVariables {
    NSArray<UserVariable *> *programVariableList = [self.scene.program.programVariableList copy];
    return [programVariableList arrayByAddingObjectsFromArray:self.variables];
}

- (NSArray<NSString *> *)allAccessibleVariableNames {
    return [self.allAccessibleVariables cb_mapUsingBlock:^id(UserVariable *item) {
        return item.name;
    }];
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
    return [ProgramManager projectPathForProgram:self.scene.program];
}

- (NSString*)previewImagePathForLookAtIndex:(NSUInteger)index
{
    if (index >= [self.lookList count])
        return nil;

    Look* look = [self.lookList objectAtIndex:index];
    if (! look)
        return nil;

    NSString *imageDirPath = [[self projectPath] stringByAppendingString:kProgramImagesDirName];
    return [NSString stringWithFormat:@"%@/%@", imageDirPath, [look previewImageFileName]];
}

- (NSString*)previewImagePath
{
    return [self previewImagePathForLookAtIndex:0];
}

- (BOOL)isBackground
{
    return self.scene.backgroundObject == self;
}

- (NSString*)pathForLook:(Look*)look
{
  return [NSString stringWithFormat:@"%@%@/%@", [self projectPath], kProgramImagesDirName, look.fileName];
}

- (NSString*)pathForSound:(Sound*)sound
{
  return [NSString stringWithFormat:@"%@%@/%@", [self projectPath], kProgramSoundsDirName, sound.fileName];
}

- (NSUInteger)fileSizeOfLook:(Look*)look
{
    NSString *path = [self pathForLook:look];
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    return [appDelegate.fileManager sizeOfFileAtPath:path];
}

- (CGSize)dimensionsOfLook:(Look*)look
{
    NSString *path = [self pathForLook:look];
    return [path sizeOfImageForFilePath];
}

- (NSUInteger)fileSizeOfSound:(Sound*)sound
{
    NSString *path = [self pathForSound:sound];
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    return [appDelegate.fileManager sizeOfFileAtPath:path];
}

- (CGFloat)durationOfSound:(Sound*)sound
{
    NSString *path = [self pathForSound:sound];
    return [[AudioManager sharedAudioManager] durationOfSoundWithFilePath:path];
}

- (NSArray<NSString *> *)allLookNames
{
    return [self.lookList cb_mapUsingBlock:^NSString *(Look *look) {
        return look.name;
    }];
}

- (NSArray<Sound *> *)allSoundNames
{
    return [self.soundList cb_mapUsingBlock:^NSString *(Sound *sound) {
        return sound.name;
    }];
}

- (BOOL)hasLook:(Look*)look
{
    return [self.lookList containsObject:look];
}

- (void)addLook:(Look *)look
{
    if ([self hasLook:look]) {
        return;
    }
    NSAssert(![[self allLookNames] containsObject:look.name], @"Look with such name already exists");
    [self.lookList addObject:look];
}

- (void)removeLook:(Look *)look
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
            AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [appDelegate.fileManager deleteFile:[self previewImagePathForLookAtIndex:index]];
            [appDelegate.fileManager deleteFile:[self pathForLook:look]];
        }
        [self.lookList removeObjectAtIndex:index];
        break;
    }
}

- (void)removeLooks:(NSArray<Look *> *)looks
{
    NSParameterAssert(looks);
    
    if (looks == self.lookList) {
        looks = [looks copy];
    }
    [looks cb_foreachUsingBlock:^(Look *look) {
        [self removeLook:look];
    }];
}

- (void)moveLookAtIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex {
    NSParameterAssert(sourceIndex >= 0 && sourceIndex < self.lookList.count);
    NSParameterAssert(destinationIndex >= 0 && destinationIndex < self.lookList.count);
    
    if (sourceIndex == destinationIndex) {
        return;
    }
    Look *look = [self.lookList objectAtIndex:sourceIndex];
    [self.lookList removeObjectAtIndex:sourceIndex];
    [self.lookList insertObject:look atIndex:destinationIndex];
}

- (BOOL)hasSound:(Sound*)sound
{
    return [self.soundList containsObject:sound];
}

- (void)addSound:(Sound *)sound {
    if ([self hasSound:sound]) {
        return;
    }
    NSAssert(![[self allSoundNames] containsObject:sound.name], @"Sound with such name already exists");
    [self.soundList addObject:sound];
}

- (void)removeSound:(Sound*)sound
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
            AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [appDelegate.fileManager deleteFile:[self pathForSound:sound]];
        }
        [self.soundList removeObjectAtIndex:index];
        break;
    }
}

- (void)removeSounds:(NSArray<Sound *> *)sounds
{
    NSParameterAssert(sounds);
    
    if (sounds == self.soundList) {
        sounds = [sounds copy];
    }
    [sounds cb_foreachUsingBlock:^(Sound *sound) {
        [self removeSound:sound];
    }];
}

- (void)renameLook:(Look*)look toName:(NSString*)newLookName
{
    if (! [self hasLook:look] || [look.name isEqualToString:newLookName]) {
        return;
    }
    NSAssert(![[self allLookNames] containsObject:newLookName], @"Look with such name aleady exists");
    look.name = newLookName;
}

- (void)renameSound:(Sound*)sound toName:(NSString*)newSoundName
{
    if (! [self hasSound:sound] || [sound.name isEqualToString:newSoundName]) {
        return;
    }
    NSAssert(![[self allSoundNames] containsObject:newSoundName], @"Sound with such name aleady exists");
    sound.name = newSoundName;
}

- (void)moveSoundAtIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex {
    NSParameterAssert(sourceIndex >= 0 && sourceIndex < self.soundList.count);
    NSParameterAssert(destinationIndex >= 0 && destinationIndex < self.soundList.count);
    
    if (sourceIndex == destinationIndex) {
        return;
    }
    Sound *sound = [self.soundList objectAtIndex:sourceIndex];
    [self.soundList removeObjectAtIndex:sourceIndex];
    [self.soundList insertObject:sound atIndex:destinationIndex];
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

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (![[other class] isEqual:[self class]])
        return NO;
    
    return [self isEqualToSpriteObject:other];
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

        if (! [firstLook isEqualToLook:secondLook])
            return NO;
    }

    // soundList
    if ([self.soundList count] != [spriteObject.soundList count])
        return NO;

    for (index = 0; index < [self.soundList count]; index++) {
        Sound *firstSound = [self.soundList objectAtIndex:index];
        Sound *secondSound = [spriteObject.soundList objectAtIndex:index];
        
        if (! [firstSound isEqualToSound:secondSound])
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
    
    return YES;
}

#pragma mark - Copy
- (id)mutableCopyWithContext:(CBMutableCopyContext*)context;
{
    if (! context) { NSError(@"%@ must not be nil!", [CBMutableCopyContext class]); }

    SpriteObject *newObject = [[SpriteObject alloc] init];
    newObject.name = [NSString stringWithString:self.name];
    newObject.scene = self.scene;
    [context updateReference:self WithReference:newObject];

    // deep copy
    newObject.lookList = [NSMutableArray arrayWithCapacity:[self.lookList count]];
    for (Look *lookObject in self.lookList) {
        [newObject.lookList addObject:[lookObject mutableCopyWithContext:context]];
    }
    newObject.soundList = [NSMutableArray arrayWithCapacity:[self.soundList count]];
    for (Sound *soundObject in self.soundList) {
        [newObject.soundList addObject:[soundObject mutableCopyWithContext:context]];
    }
    newObject.scriptList = [NSMutableArray arrayWithCapacity:[self.scriptList count]];
    for (Script *scriptObject in self.scriptList) {
        Script *copiedScript = [scriptObject mutableCopyWithContext:context];
        copiedScript.object = newObject;
        [newObject.scriptList addObject:copiedScript];
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
    for (SpriteObject *object in self.scene.objectList) {
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
    for (SpriteObject *object in self.scene.objectList) {
        for (Sound *sound in object.soundList) {
            if ([sound.fileName isEqualToString:fileName]) {
                ++referenceCount;
            }
        }
    }
    return referenceCount;
}

@end
