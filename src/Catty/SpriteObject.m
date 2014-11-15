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

#import "SpriteObject.h"
#import "BroadcastWaitDelegate.h"
#import "StartScript.h"
#import "WhenScript.h"
#import "BroadcastScript.h"
#import "Look.h"
#import "Sound.h"
#import "Scene.h"
#import "Util.h"
#import "Brick.h"
#import "SetLookBrick.h"
#import "FileManager.h"
#import "GDataXMLNode.h"
#import "UIImage+CatrobatUIImageExtensions.h"
#import "UIDefines.h"
#import "AudioManager.h"
#import "AppDelegate.h"
#import "NSString+FastImageSize.h"

@interface SpriteObject()

@end

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

- (CGPoint)position
{
    return [((Scene*)self.scene) convertSceneCoordinateToPoint:super.position];
}

- (void)setPosition:(CGPoint)position
{
    super.position = [((Scene*)self.scene) convertPointToScene:position];
}

- (void)setPositionForCropping:(CGPoint)position
{
    super.position = position;
}

- (void)dealloc
{
    NSDebug(@"Dealloc: %@", self);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (NSString *)projectPath
{
  return [self.program projectPath];
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
  if (self.program && [self.program.objectList count])
    return ([self.program.objectList objectAtIndex:0] == self);
  return NO;
}

- (NSString*)xmlReferencePathForDestinationBrick:(Brick*)destinationBrick sourceBrick:(Brick*)sourceBrick
{
    NSUInteger sourceScriptCounter = 0;
    NSUInteger destinationScriptCounter = 0;
//    NSUInteger sourceBrickCounter = 0;
//    NSUInteger destinationBrickCounter = 0;

    NSUInteger scriptCounter = 0;
    for (Script *script in self.scriptList) {
        NSInteger brickCounter = 0;
        for (Brick *brick in script.brickList) {
            if (sourceBrick == brick) {
                sourceScriptCounter = scriptCounter;
//                sourceBrickCounter = brickCounter;
                break;
            }
            ++brickCounter;
        }
        ++scriptCounter;
    }

    scriptCounter = 0;
    for (Script *script in self.scriptList) {
        NSInteger brickCounter = 0;
        for (Brick *brick in script.brickList) {
            if (destinationBrick == brick) {
                destinationScriptCounter = scriptCounter;
//                destinationBrickCounter = brickCounter;
                break;
            }
            ++brickCounter;
        }
        ++scriptCounter;
    }

    // build reference path
    NSMutableString *referencePath = [NSMutableString stringWithString:@"../"];
    if (sourceScriptCounter != destinationScriptCounter) {
        [referencePath appendString:@"../"];
    }
    [referencePath appendString:[destinationBrick xmlTagName]];

    scriptCounter = 0;
    Class destinationBrickClass = [destinationBrick class];
    NSUInteger sameBrickClassIndex = 0;
    NSUInteger totalSameBrickClassCounter = 0;
    for (Script *script in self.scriptList) {
        if (scriptCounter != destinationScriptCounter) {
            ++scriptCounter;
            continue;
        }
        for (Brick *brick in script.brickList) {
            if ([brick isKindOfClass:destinationBrickClass]) {
                if (brick == destinationBrick) {
                    sameBrickClassIndex = totalSameBrickClassCounter;
                }
                ++totalSameBrickClassCounter;
            }
        }
        ++scriptCounter;
    }
    if (sameBrickClassIndex > 0) {
        [referencePath appendString:[NSString stringWithFormat:@"[%lu]", (unsigned long)(sameBrickClassIndex + 1)]];
    }
    return [referencePath copy];
}

- (NSString*)xmlReferencePathForDestinationLook:(Look*)destinationLook
{
    NSUInteger lookIndex = 0;
    for (Look *look in self.lookList) {
        if (look == destinationLook) {
            break;
        }
        ++lookIndex;
    }

    // build reference path
    NSString *indexSuffix = @"";
    if (lookIndex > 0) {
        indexSuffix = [NSString stringWithFormat:@"[%lu]", (unsigned long)(lookIndex + 1)];
    }
    return [NSString stringWithFormat:@"../../../../../lookList/look%@", indexSuffix];
}

- (instancetype)deepCopy
{
    SpriteObject *newObject = [[SpriteObject alloc] init];
    newObject.spriteManagerDelegate = nil;
    newObject.broadcastWaitDelegate = nil;
    newObject.currentLook = nil;
    newObject.currentUIImageLook = nil;
    newObject.numberOfObjectsWithoutBackground = 0;

    // deep copy
    newObject.lookList = [NSMutableArray arrayWithCapacity:[self.lookList count]];
    for (id lookObject in self.lookList) {
        if ([lookObject isKindOfClass:[Look class]]) {
            [newObject.lookList addObject:[((Look*)lookObject) deepCopy]];
        }
    }
    newObject.soundList = [NSMutableArray arrayWithCapacity:[self.soundList count]];
    for (id soundObject in self.soundList) {
        if ([soundObject isKindOfClass:[Sound class]]) {
            [newObject.soundList addObject:[((Sound*)soundObject) deepCopy]];
        }
    }
    newObject.scriptList = [NSMutableArray arrayWithCapacity:[self.scriptList count]];
    for (id scriptObject in self.scriptList) {
        if ([scriptObject isKindOfClass:[Script class]]) {
            [newObject.scriptList addObject:[((Script*)scriptObject) deepCopy]];
        }
    }
    return newObject;
}

- (GDataXMLElement*)toXML
{
    GDataXMLElement *objectXMLElement = [GDataXMLNode elementWithName:@"object"];
    GDataXMLElement *lookListXMLElement = [GDataXMLNode elementWithName:@"lookList"];
    for (id look in self.lookList) {
        if ([look isKindOfClass:[Look class]])
            [lookListXMLElement addChild:[((Look*) look) toXMLforObject:self]];
    }
    [objectXMLElement addChild:lookListXMLElement];
    [objectXMLElement addChild:[GDataXMLElement elementWithName:@"name" stringValue:self.name]];

    GDataXMLElement *scriptListXMLElement = [GDataXMLNode elementWithName:@"scriptList"];
    for (id script in self.scriptList) {
        if ([script isKindOfClass:[Script class]])
            [scriptListXMLElement addChild:[((Script*) script) toXMLforObject:self]];
    }
    [objectXMLElement addChild:scriptListXMLElement];

    GDataXMLElement *soundListXMLElement = [GDataXMLNode elementWithName:@"soundList"];
    for (id sound in self.soundList) {
        if ([sound isKindOfClass:[Sound class]])
            [soundListXMLElement addChild:[((Sound*) sound) toXMLforObject:self]];
    }
    [objectXMLElement addChild:soundListXMLElement];
    return objectXMLElement;
}

- (void)start:(CGFloat)zPosition
{
    self.position = CGPointMake(0, 0);
    self.zRotation = 0;
    self.currentLookBrightness = 0;
    if ([self isBackground]){
        self.zPosition = 0;
    }else{
        self.zPosition = zPosition;
    }
        
    

    for (Script *script in self.scriptList)
    {
        if ([script isKindOfClass:[StartScript class]]) {
            __weak typeof(self) weakSelf = self;
            [self startAndAddScript:script completion:^{
                [weakSelf scriptFinished:script];
            }];
        }

        if([script isKindOfClass:[BroadcastScript class]]) {
            if ([self.broadcastWaitDelegate respondsToSelector:@selector(registerSprite:forMessage:)]) {
                
                [self.broadcastWaitDelegate registerSprite:self forMessage:((BroadcastScript*)script).receivedMessage];
            } else {
                NSLog(@"ERROR: BroadcastWaitDelegate not set! abort()");
                abort();
            }
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(performBroadcastScript:) name:((BroadcastScript*)script).receivedMessage object:nil];
        }
    }
}

- (void)scriptFinished:(Script*)script
{
    [self removeChildrenInArray:@[script]];
}

- (BOOL)touchedwith:(NSSet *)touches withX:(CGFloat)x andY:(CGFloat)y
{
    for (UITouch *touch in touches) {
        CGPoint touchedPoint = [touch locationInNode:self];
        NSDebug(@"x:%f,y:%f",touchedPoint.x,touchedPoint.y);
         //NSLog(@"test touch, %@",self.name);
//        UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, [UIScreen mainScreen].scale);
//        [self.scene.view drawViewHierarchyInRect:self.frame afterScreenUpdates:NO];
//        UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
        NSDebug(@"image : x:%f,y:%f",self.currentUIImageLook.size.width,self.currentUIImageLook.size.height);
        BOOL isTransparent = [self.currentUIImageLook isTransparentPixel:self.currentUIImageLook withX:touchedPoint.x andY:touchedPoint.y];
        if (isTransparent) {
            NSDebug(@"I'm transparent at this point");
            return NO;
        }
            for (Script *script in self.scriptList) {
            if ([script isKindOfClass:[WhenScript class]]) {
                __weak typeof(self) weakSelf = self;
                [self startAndAddScript:script completion:^{
                    [weakSelf scriptFinished:script];
                }];
            }
        }
        return YES;
    }
    return YES;
}

//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    
//    //NSDebug(@"Touched: %@", self.name);
//    //UITouch *touch = [[event allTouches] anyObject];
//    for (UITouch *touch in touches) {
//        CGPoint touchedPoint = [touch locationInNode:self];
//        BOOL isTransparent = NO;//[self.currentUIImageLook isTransparentPixel:self.currentUIImageLook withX:touchedPoint.x andY:touchedPoint.y];
//        NSLog(@"test touch, %@",self.name);
//        if (isTransparent == NO) {
//            for (Script *script in self.scriptList)
//            {
//                if ([script isKindOfClass:[WhenScript class]]) {
//                    
//                    [self startAndAddScript:script completion:^{
//                        [self scriptFinished:script];
//                    }];
//                    
//                }
//                
//            }
//            //return YES;
//            
//        }
//        else{
//            NSLog(@"transparent");
//            //return NO;
//        }
//        
//    }
//    //return YES;
//}

- (void)startAndAddScript:(Script*)script completion:(dispatch_block_t)completion
{
//    if ([[self children] indexOfObject:script] == NSNotFound) { <== does not work any more under iOS8!!
    if (! [script inParentHierarchy:self]) {
        [script removeFromParent]; // just to ensure
        [self addChild:script];
    }
    [script startWithCompletion:completion];
}

- (Look*)nextLook
{
    NSInteger index = [self.lookList indexOfObject:self.currentLook];
    index++;
    index %= [self.lookList count];
    return [self.lookList objectAtIndex:index];
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
    // very fast implementation! far more quicker than UIImage's size method/property
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

- (void)addLook:(Look*)look
{
    if ([self hasLook:look]) {
        return;
    }
    look.name = [Util uniqueName:look.name existingNames:[self allLookNames]];
    [self.lookList addObject:look];
    [self.program saveToDisk];
    return;
}

- (void)changeLook:(Look *)look
{
    UIImage* image = [UIImage imageWithContentsOfFile:[self pathForLook:look]];
    SKTexture* texture = nil;
    if ([self isBackground]) {
        texture = [SKTexture textureWithImage:image];
        self.currentUIImageLook = image;
    } else {
// We do not need cropping if touch through transparent pixel is possible!!!!
        
//        CGRect newRect = [image cropRectForImage:image];
        
//        if ((newRect.size.height <= image.size.height - 50 && newRect.size.height <= image.size.height - 50)) {
//            CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, newRect);
//            UIImage *newImage = [UIImage imageWithCGImage:imageRef];
////            NSLog(@"%f,%f,%f,%f",newRect.origin.x,newRect.origin.y,newRect.size.width,newRect.size.height);
//            [self setPositionForCropping:CGPointMake(newRect.origin.x+newRect.size.width/2,self.scene.size.height-newRect.origin.y-newRect.size.height/2)];
//            CGImageRelease(imageRef);
//            texture = [SKTexture textureWithImage:newImage];
//            self.currentUIImageLook = newImage;
//        }
//        else{
            texture = [SKTexture textureWithImage:image];
            self.currentUIImageLook = image;
//        }
    }

    double xScale = self.xScale;
    double yScale = self.yScale;
    self.xScale = 1.0;
    self.yScale = 1.0;
    self.size = texture.size;
    self.texture = texture;
    self.currentLook = look;

    if (xScale != 1.0) {
        self.xScale = (CGFloat)xScale;
    }
    if (yScale != 1.0) {
        self.yScale = (CGFloat)yScale;
    }

}

- (void)setLook
{
    if (self.lookList.count > 0) {
        [self changeLook:[self.lookList objectAtIndex:0]];
    }
    
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
        NSUInteger lookImageReferenceCounter = 0;
        for (SpriteObject *object in self.program.objectList) {
            for (Look *lookToCheck in object.lookList) {
                if ([lookToCheck.fileName isEqualToString:look.fileName]) {
                    ++lookImageReferenceCounter;
                }
            }
        }
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

- (void)removeLooks:(NSArray*)looks
{
    for (id look in looks) {
        if ([look isKindOfClass:[Look class]]) {
            [self removeLookFromList:look];
        }
    }
    [self.program saveToDisk];
}

- (void)removeLook:(Look*)look
{
    [self removeLookFromList:look];
    [self.program saveToDisk];
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
        NSUInteger soundReferenceCounter = 0;
        for (SpriteObject *object in self.program.objectList) {
            for (Sound *soundToCheck in object.soundList) {
                if ([soundToCheck.fileName isEqualToString:sound.fileName]) {
                    ++soundReferenceCounter;
                }
            }
        }
        // if sound is not used by other objects, delete it
        if (soundReferenceCounter <= 1) {
            AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [appDelegate.fileManager deleteFile:[self pathForSound:sound]];
        }
        [self.soundList removeObjectAtIndex:index];
        break;
    }
}

- (void)removeSounds:(NSArray*)sounds
{
    for (id sound in sounds) {
        if ([sound isKindOfClass:[Sound class]]) {
            [self removeSoundFromList:sound];
        }
    }
    [self.program saveToDisk];
}

- (void)removeSound:(Sound*)sound
{
    [self removeSoundFromList:sound];
    [self.program saveToDisk];
}

- (BOOL)hasLook:(Look*)look
{
    return [self.lookList containsObject:look];
}

- (BOOL)hasSound:(Sound*)sound
{
    return [self.soundList containsObject:sound];
}

- (Look*)copyLook:(Look*)sourceLook withNameForCopiedLook:(NSString*)nameOfCopiedLook
{
    if (! [self hasLook:sourceLook]) {
        return nil;
    }
    Look *copiedLook = [sourceLook deepCopy];
    copiedLook.name = [Util uniqueName:nameOfCopiedLook existingNames:[self allLookNames]];
    [self.lookList addObject:copiedLook];
    [self.program saveToDisk];
    return copiedLook;
}

- (Sound*)copySound:(Sound*)sourceSound withNameForCopiedSound:(NSString*)nameOfCopiedSound
{
    if (! [self hasSound:sourceSound]) {
        return nil;
    }
    Sound *copiedSound = [sourceSound deepCopy];
    copiedSound.name = [Util uniqueName:nameOfCopiedSound existingNames:[self allSoundNames]];
    [self.soundList addObject:copiedSound];
    [self.program saveToDisk];
    return copiedSound;
}

- (void)renameLook:(Look*)look toName:(NSString*)newLookName
{
    if (! [self hasLook:look] || [look.name isEqualToString:newLookName]) {
        return;
    }
    look.name = [Util uniqueName:newLookName existingNames:[self allLookNames]];
    [self.program saveToDisk];
}

- (void)renameSound:(Sound*)sound toName:(NSString*)newSoundName
{
    if (! [self hasSound:sound] || [sound.name isEqualToString:newSoundName]) {
        return;
    }
    sound.name = [Util uniqueName:newSoundName existingNames:[self allSoundNames]];
    [self.program saveToDisk];
}

#pragma mark - Broadcast
- (void)broadcast:(NSString*)message
{
    NSDebug(@"Broadcast: %@, Object: %@", message, self.name);
    [[NSNotificationCenter defaultCenter] postNotificationName:message object:self];
}

- (void)performBroadcastScript:(NSNotification*)notification
{
    NSDebug(@"Notification: %@, Object: %@", notification.name, self.name);

    for (Script *script in self.scriptList) {
        if ([script isKindOfClass:[BroadcastScript class]]) {
            BroadcastScript *broadcastScript = (BroadcastScript*)script;
            if ([broadcastScript.receivedMessage isEqualToString:notification.name]) {
                
                __weak typeof(self) weakSelf = self;
                [self startAndAddScript:broadcastScript completion:^{
                    [weakSelf scriptFinished:broadcastScript];
                    NSDebug(@"FINISHED");
                }];
            }
        }
    }
    //dispatch_release(group);
}

- (void)broadcastAndWait:(NSString*)message
{
    if ([[NSThread currentThread] isMainThread]) {
        NSLog(@" ");
        NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
        NSLog(@"!!                                                                                       !!");
        NSLog(@"!!  ATTENTION: THIS METHOD SHOULD NEVER EVER BE CALLED FROM MAIN-THREAD!!! BUSY WAITING  !!");
        NSLog(@"!!                                                                                       !!");
        NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
        NSLog(@" ");
        abort();
    }

    if ([self.broadcastWaitDelegate respondsToSelector:@selector(performBroadcastWaitForMessage:)]) {
        [self.broadcastWaitDelegate performBroadcastWaitForMessage:message];
    } else {
        NSLog(@"ERROR: BroadcastWaitDelegate not set! abort()");
        abort();
    }

}

- (void)performBroadcastWaitScriptWithMessage:(NSString*)message with:(dispatch_semaphore_t)sema1
{

    for (Script *script in self.scriptList) {
        if ([script isKindOfClass:[BroadcastScript class]]) {
            BroadcastScript* broadcastScript = (BroadcastScript*)script;
            if ([broadcastScript.receivedMessage isEqualToString:message]) {
                dispatch_semaphore_t sema = dispatch_semaphore_create(0);
                
                __weak typeof(self) weakSelf = self;
                [self startAndAddScript:broadcastScript completion:^{
                    [weakSelf scriptFinished:broadcastScript];
                    dispatch_semaphore_signal(sema);
                }];
                dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
                dispatch_semaphore_signal(sema1);
            }
        }
    }
    NSDebug(@"BroadcastWaitScriptDone");
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

- (BOOL)isEqualToSpriteObject:(SpriteObject*)spriteObject
{
    NSUInteger index;
    if(![self.name isEqualToString:spriteObject.name])
        return NO;
    
    // lookList
    if([self.lookList count] != [spriteObject.lookList count])
        return NO;
    for(index = 0; index < [self.lookList count]; index++) {
        Look *firstLook = [self.lookList objectAtIndex:index];
        Look *secondLook = [spriteObject.lookList objectAtIndex:index];
        
        if(![firstLook isEqualToLook:secondLook])
            return NO;
    }
    
    // soundList
    if([self.soundList count] != [spriteObject.soundList count])
        return NO;
    for(index = 0; index < [self.soundList count]; index++) {
        Sound *firstSound = [self.soundList objectAtIndex:index];
        Sound *secondSound = [spriteObject.soundList objectAtIndex:index];
        
        if(![firstSound isEqualToSound:secondSound])
            return NO;
    }
    
    // scriptList
    if([self.scriptList count] != [spriteObject.scriptList count])
        return NO;
    for(index = 0; index < [self.scriptList count]; index++) {
        Script *firstScript = [self.scriptList objectAtIndex:index];
        Script *secondScript = [spriteObject.scriptList objectAtIndex:index];
        
        if(![firstScript isEqualToScript:secondScript])
            return NO;
    }
    
    return YES;
}

#pragma mark - Formula Protocol
-(CGFloat)xPosition
{
    return self.position.x;
}

-(CGFloat)yPosition
{
    return self.position.y;
}

-(CGFloat)rotation
{
    return (CGFloat)[Util radiansToDegree:self.zRotation];
}

-(CGFloat) zIndex
{
    return [self zPosition];
}

-(CGFloat) brightness
{
    return 100 * self.currentLookBrightness;
}


-(CGFloat) scaleX
{
    return [self xScale]*100;
}

-(CGFloat) scaleY
{
    return [self yScale]*100;
}

@end
