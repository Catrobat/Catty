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

@interface SpriteObject()

@property (nonatomic, strong) NSMutableArray *activeScripts;
@property (nonatomic, strong) NSMutableDictionary *sounds;


@end

@implementation SpriteObject

@synthesize numberOfObjects;

-(id)init
{
    if(self = [super init]) {
        self.activeScripts = [[NSMutableArray alloc] initWithCapacity:self.scriptList.count];
    }
    return self;
}

-(NSMutableArray*)lookList
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

- (void)dealloc
{
    NSDebug(@"Dealloc: %@", self);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
  NSString *previewImageFilePath = [NSString stringWithFormat:@"%@/%@", imageDirPath, [look previewImageFileName]];
  FileManager *fileManager = [[FileManager alloc] init];
  if ([fileManager fileExists:previewImageFilePath])
    return previewImageFilePath;

  previewImageFilePath = [self pathForLook:look];
  if ([fileManager fileExists:previewImageFilePath])
    return previewImageFilePath;

  return nil;
}

- (NSString*)previewImagePath
{
  return [self previewImagePathForLookAtIndex:0];
}

-(BOOL)isBackground
{
  if (self.program && [self.program.objectList count])
    return ([self.program.objectList objectAtIndex:0] == self);
  return NO;
}

- (GDataXMLElement*)toXML
{
  GDataXMLElement *objectXMLElement = [GDataXMLNode elementWithName:@"object"];
  GDataXMLElement *lookListXMLElement = [GDataXMLNode elementWithName:@"lookList"];
  for (id look in self.lookList) {
    if ([look isKindOfClass:[Look class]])
      [lookListXMLElement addChild:[((Look*) look) toXML]];
  }
  [objectXMLElement addChild:lookListXMLElement];

  [objectXMLElement addChild:[GDataXMLElement elementWithName:@"name" stringValue:self.name]];

  GDataXMLElement *scriptListXMLElement = [GDataXMLNode elementWithName:@"scriptList"];
  // TODO: uncomment this after toXML-method in all Script-subclasses have been completely implemented
//  for (id script in self.scriptList) {
//    if ([script isKindOfClass:[Script class]])
//      [scriptListXMLElement addChild:[((Script*) script) toXML]];
//  }
  [objectXMLElement addChild:scriptListXMLElement];

  GDataXMLElement *soundListXMLElement = [GDataXMLNode elementWithName:@"soundList"];
  for (id sound in self.soundList) {
    if ([sound isKindOfClass:[Sound class]])
      [soundListXMLElement addChild:[((Sound*) sound) toXML]];
  }
  [objectXMLElement addChild:soundListXMLElement];
  return objectXMLElement;
}

- (void)start:(CGFloat)zPosition
{
    self.position = CGPointMake(0, 0);
    if ([self.name isEqualToString:@"Background"])
        self.zPosition = 0;
    else
        self.zPosition = zPosition;

    for (Script *script in self.scriptList)
    {
        if ([script isKindOfClass:[StartScript class]]) {
            __block __typeof__(self) _self = self;
            [self startAndAddScript:script completion:^{
                [_self scriptFinished:script];
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


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    NSDebug(@"Touched: %@", self.name);

    for (UITouch *touch in touches) {

        for (Script *script in self.scriptList)
        {
            if ([script isKindOfClass:[WhenScript class]]) {
                
                [self startAndAddScript:script completion:^{
                    [self scriptFinished:script];
                }];
            }
        }
    }
    
}


-(void)startAndAddScript:(Script*)script completion:(dispatch_block_t)completion
{
    if([[self children] indexOfObject:script] == INT_MAX) {
        [self addChild:script];
    }
    [script startWithCompletion:completion];
}


-(Look*)nextLook
{
    int index = [self.lookList indexOfObject:self.currentLook];
    index++;
    index %= [self.lookList count];
    return [self.lookList objectAtIndex:index];
}

-(NSString*)pathForLook:(Look*)look
{
  return [NSString stringWithFormat:@"%@%@/%@", [self projectPath], kProgramImagesDirName, look.fileName];
}

-(NSString*)pathForSound:(Sound*)sound
{
  return [NSString stringWithFormat:@"%@%@/%@", [self projectPath], kProgramSoundsDirName, sound.fileName];
}

-(void)changeLook:(Look *)look
{
    UIImage* image = [UIImage imageWithContentsOfFile: [self pathForLook:look] ];
    SKTexture* texture = [SKTexture textureWithImage:image];
    self.currentUIImageLook = image;
    double xScale = self.xScale;
    double yScale = self.yScale;
    self.xScale = 1.0;
    self.yScale = 1.0;
    self.size = texture.size;
    self.texture = texture;
    self.currentLook = look;
    
    if(xScale != 1.0) {
        self.xScale = xScale;
    }
    if(yScale != 1.0) {
        self.yScale = yScale;
    }
    
}
-(void) setLook
{
    BOOL check = YES;
#warning Fix for issue that you can set look without a brick at the start -> change if there will be hide bricks for those objects which should not appear!
        for (Script *script in self.scriptList)
        {
            if ([script isKindOfClass:[StartScript class]]) {
                for(Brick* brick in script.brickList){
                    if([brick isKindOfClass:[SetLookBrick class]]) {
                        check = NO;
                    }
                }
            }
            if ([script isKindOfClass:[WhenScript class]]) {
                for(Brick* brick in script.brickList){
                    if([brick isKindOfClass:[SetLookBrick class]]) {
                        check = NO;
                    }
                }
            }
            if ([script isKindOfClass:[BroadcastScript class]]) {
                for(Brick* brick in script.brickList){
                    if([brick isKindOfClass:[SetLookBrick class]]) {
                        check = NO;
                    }
                }
            }

            
        }

    
    if(check == YES && [self.lookList count]>0){
        [self changeLook:[self.lookList objectAtIndex:0]];
        
    }
        

}


#pragma mark - Broadcast
-(void)broadcast:(NSString *)message
{
    [[NSNotificationCenter defaultCenter] postNotificationName:message object:self];
}

- (void)performBroadcastScript:(NSNotification*)notification
{
    NSDebug(@"Notification: %@", notification.name);

    for (Script *script in self.scriptList) {
        if ([script isKindOfClass:[BroadcastScript class]]) {
            BroadcastScript *broadcastScript = (BroadcastScript*)script;
            if ([broadcastScript.receivedMessage isEqualToString:notification.name]) {
                [self startAndAddScript:broadcastScript completion:^{
                    [self scriptFinished:broadcastScript];
                    NSDebug(@"FINISHED");
                }];
            }
        }
    }
    
    //dispatch_release(group);

}


-(void)broadcastAndWait:(NSString *)message
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

-(void)performBroadcastWaitScriptWithMessage:(NSString *)message
{

    for (Script *script in self.scriptList) {
        if ([script isKindOfClass:[BroadcastScript class]]) {
            BroadcastScript* broadcastScript = (BroadcastScript*)script;
            if ([broadcastScript.receivedMessage isEqualToString:message]) {
                dispatch_semaphore_t sema = dispatch_semaphore_create(0);
                
                [self startAndAddScript:broadcastScript completion:^{
                    [self scriptFinished:broadcastScript];
                    dispatch_semaphore_signal(sema);
                }];
                dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            }
        }
    }
    
    NSDebug(@"BroadcastWaitScriptDone");
    


}


- (NSString*)description
{
    return [NSString stringWithFormat:@"Object: %@\r", self.name];
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
    return [((Scene*)self.scene) convertSceneToDegrees:[Util radiansToDegree:self.zRotation]];
}

-(CGFloat) zIndex
{
    return [self zPosition];
}

-(CGFloat) brightness
{
    return [self brightness];
}


-(CGFloat) scaleX
{
    return [self scaleX];
}


//- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)interval
//{
//
//    for(Script* script in self.activeScripts) {
//        [script updateWithTimeSinceLastUpdate:interval];
//    }
//    
//}





//#pragma mark -- Getter Setter
//-(NSCondition*)speakLock
//{
//    if(!_speakLock) {
//        _speakLock = [[NSCondition alloc] init];
//        [_speakLock setName:@"Speak Lock"];
//    }
//    return _speakLock;
//}
//
//
//-(NSMutableArray *)activeScripts
//{
//    if (_activeScripts == nil)
//        _activeScripts = [[NSMutableArray alloc]init];
//    return _activeScripts;
//}
//
//-(void)setPosition:(CGPoint)position
//{
//    CGPoint pos = [self stageCoordinatesForPoint:position];
//    
//    self.x = (pos.x);
//    self.y = (pos.y);
//}
//
//-(CGPoint)position
//{
//    CGPoint pos = [self pointForStageCoordinates];
//    return pos;
//}
//
//-(NSMutableDictionary*)sounds
//{
//    if(!_sounds) {
//        _sounds  = [[NSMutableDictionary alloc] init];
//    }
//    return _sounds;
//}
//

//
//
//- (id)init
//{
//    if (self = [super init])
//    {
////        self.juggler = [[SPJuggler alloc] init];
//    }
//    return self;
//}
//
//
//
//#pragma mark - script methods
//- (void)start
//{
//    [self setInitValues];
//    
//    // init BroadcastWait-stuff
//    for (Script *script in self.scriptList) {
//        if ([script isKindOfClass:[BroadcastScript class]]) {
//            BroadcastScript *broadcastScript = (BroadcastScript*)script;
//            if ([self.broadcastWaitDelegate respondsToSelector:@selector(registerSprite:forMessage:)]) {
//                [self.broadcastWaitDelegate registerSprite:self forMessage:broadcastScript.receivedMessage];
//            } else {
//                NSLog(@"ERROR: BroadcastWaitDelegate not set! abort()");
//                abort();
//            }
//            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(performBroadcastScript:) name:broadcastScript.receivedMessage object:nil];
//        }
//    }
//    
//    
//    for (Script *script in self.scriptList)
//    {
//        if ([script isKindOfClass:[StartScript class]]) {
//            [self.activeScripts addObject:script];
//            
//
//            // ------------------------------------------ THREAD --------------------------------------
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                [script runScript];
//                
//                // tell the main thread
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self scriptFinished:script];
//                });
//            });
//            // ------------------------------------------ END -----------------------------------------
//        }
//    }
//}
//
//-(void)pause
//{
//    dispatch_suspend(self.scriptQueue);
//}
//
//
//-(void)setInitValues
//{
//    self.position = CGPointMake(0.0f, 0.0f);
//    self.lookIndex = 0;
//}
//
//
//-(BOOL)isType:(TouchAction)type equalToString:(NSString*)action
//{
//#warning add other possible action-types
//    if (type == kTouchActionTap && [action isEqualToString:@"Tapped"]) {
//        return YES;
//    } else {
//        return NO;
//    }
//}
//
//- (void)onImageTouched:(SPTouchEvent *)event
//{
//    NSSet *touches = [event touchesWithTarget:self andPhase:SPTouchPhaseBegan];
//    if ([touches anyObject]) {
//        for (Script *script in self.scriptList)
//        {
//            if ([script isKindOfClass:[WhenScript class]]) {
//                NSDebug(@"Performing script with action: %@", script.description);
//                
//                if ([self.activeScripts containsObject:script]) {
//                    [script resetScript];
//                } else {
//                    [self.activeScripts addObject:script];
//                    
//                    // ------------------------------------------ THREAD --------------------------------------
//                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                        [script runScript];
//                        
//                        // tell the main thread
//                        dispatch_sync(dispatch_get_main_queue(), ^{
//                            [self scriptFinished:script];
//                        });
//                    });
//                    // ------------------------------------------ END -----------------------------------------
//                }
//            }
//        }
//    }
//}
//
//- (void)performBroadcastScript:(NSNotification*)notification
//{
//    NSDebug(@"Notification: %@", notification.name);
//    BroadcastScript *script = nil;
//    
//    for (Script *s in self.scriptList) {
//        if ([s isKindOfClass:[BroadcastScript class]]) {
//            BroadcastScript *tmp = (BroadcastScript*)s;
//            if ([tmp.receivedMessage isEqualToString:notification.name]) {
//                script = tmp;
//            }
//        }
//    }
//    
//    if (script) {
//        
//        if ([self.activeScripts containsObject:script]) {
//            [script resetScript];
//        } else {
//            [self.activeScripts addObject:script];
//            
//            // -------- ---------------------------------- THREAD --------------------------------------
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                [script runScript];
//                
//                // tell the main thread
//                dispatch_sync(dispatch_get_main_queue(), ^{
//                    
////                    NSString *responseID = (NSString*)[notification.userInfo valueForKey:@"responseID"];
////                    if (responseID != nil) {
////                        [[NSNotificationCenter defaultCenter]postNotificationName:responseID object:self];
////                    } else {
////                        NSLog(@"Why is there no responseID? I don't want to live on this planet anymore...abort()");
////                        abort();
////                    }
//                    
//                    [self scriptFinished:script];
//                });
//            });
//            // ------------------------------------------ END -----------------------------------------
//        }
//        
//    }
//}
//
//
//
//-(void)scriptFinished:(Script *)script
//{
//    [self.activeScripts removeObject:script];
//}
//
//-(void)cleanup
//{
//    [self stopAllSounds];
//    for (Script *script in self.activeScripts) {
//        [script stopScript];
//    }
//    O
//    self.activeScripts = nil;

//}
//
//
//#pragma mark - Overwritten Methods
//-(void) readjustSize
//{
//    [super readjustSize];
//    self.pivotX = self.texture.width / 2.0f;
//    self.pivotY = self.texture.height / 2.0f;
//}
//
//
// 
//
//
//// --- actions ---
//
//-(void)changeLook:(Look*)look
//{
//    NSString *path = [self pathForLook:look];
//    self.texture = [SPTexture textureWithContentsOfFile:path];
//    [self readjustSize];
//    self.lookIndex = [self.lookList indexOfObject:look];
//}
//
//
//-(void)nextLook
//{
//    if (self.lookIndex == [self.lookList count]-1) {
//        self.lookIndex = 0;
//    }
//    else {
//        self.lookIndex++;
//    }
//    Look* look = [self.lookList objectAtIndex:self.lookIndex];
//    NSString* path = [self pathForLook:look];
//    self.texture = [SPTexture textureWithContentsOfFile:path];
//    [self readjustSize];
//    self.lookIndex = [self.lookList indexOfObject:look];
//}
//
//-(void)hide
//{
//    self.visible = NO;
//    
//}
//
//-(void)show
//{
//    self.visible = YES;
//}
//
//-(void)turnLeft:(float)degrees
//{
//    float rotationInDegrees = SP_R2D(self.rotation);
//    rotationInDegrees -= degrees;
//    if (rotationInDegrees < 0.0f) {
//        rotationInDegrees += 360.0f;
//    }
//    self.rotation = SP_D2R(rotationInDegrees);
//}
//
//-(void)turnRight:(float)degrees
//{
//    float rotationInDegrees = SP_R2D(self.rotation);
//    rotationInDegrees += degrees;
//    self.rotation = fmodf(self.rotation, 360.0f);
//    self.rotation = SP_D2R(rotationInDegrees);
//}
//
//
//- (void)glideToPosition:(CGPoint)position withDurationInSeconds:(float)durationInSeconds fromScript:(Script *)script {
//
//    CGPoint newPosition = [self stageCoordinatesForPoint:position];
////    [[AnimationHandler sharedAnimationHandler] glideToPosition:newPosition withDurationInSeconds:durationInSeconds withObject:self];
//
//    
//    SPTween *tween = [SPTween tweenWithTarget:self time:durationInSeconds];
//    [tween moveToX:newPosition.x y:newPosition.y];
//    tween.repeatCount = 1;
//    [Sparrow.juggler addObject:tween];
//}
//
//
//-(void)changeXBy:(float)x
//{
//    self.position = CGPointMake(self.position.x+x, self.position.y);
//    
//    //[[AnimationHandler sharedAnimationHandler] changeXBy:x withObject:self];
//    
////    SPTween *tween = [SPTween tweenWithTarget:self time:0.0f];
////    [tween animateProperty:@"x" targetValue:self.x+x];
////    tween.repeatCount = 1;
////    [Sparrow.juggler addObject:tween];
//
//}
//
//-(void)changeYBy:(float)y
//{
//    self.position = CGPointMake(self.position.x, self.position.y+y);
//    //[[AnimationHandler sharedAnimationHandler] changeYBy:y withObject:self];
////    SPTween *tween = [SPTween tweenWithTarget:self time:0.0f];
////    [tween animateProperty:@"y" targetValue:self.y-y];
////    tween.repeatCount = 1;
////    [Sparrow.juggler addObject:tween];
//}
//
//
//
//-(void)setSizeToPercentage:(float)sizeInPercentage
//{
//    self.scaleX = self.scaleY = sizeInPercentage/100.0f;
//}
//
//-(void)changeSizeByNInPercent:(float)sizePercentageRate
//{
//    self.scaleX += sizePercentageRate/100.0f;
//    self.scaleY += sizePercentageRate/100.0f;
//}
//
//
//- (void)speakSound:(Sound*)sound
//{
//    SPSound *soundFile = [SPSound soundWithContentsOfFile:[self pathForSpeakSound:sound]];
//    [self createSoundChannelAndAddToSounds:soundFile withKey:sound.fileName waitUntilDone:YES volume:3.0f]; // Google TTS is very quiet
//}
//
//
//-(void)playSound:(Sound*)sound
//{
//    SPSound *soundFile = [SPSound soundWithContentsOfFile:[self pathForSound:sound]];
//    [self createSoundChannelAndAddToSounds:soundFile withKey:sound.fileName waitUntilDone:NO volume:1.0f];
//}
//
//
//-(void)createSoundChannelAndAddToSounds:(SPSound*)soundFile withKey:(NSString*)key waitUntilDone:(BOOL)waitUntilDone volume:(float)volume
//{
//    SPSoundChannel* channel = nil;
//    
//    channel.volume = volume;
//    
//    if(!(channel = [self.sounds objectForKey:key])) {
//        channel = [soundFile createChannel];
//        [self.sounds setObject:channel forKey:key];
//    }else {
//        [channel stop];
//    }
//    
//    if(waitUntilDone) {
//        [channel addEventListener:@selector(onSoundCompleted:) atObject:self forType:SP_EVENT_TYPE_COMPLETED];
//    }
//    
//    [channel play];
//    
//    if(waitUntilDone) {
//        [self.speakLock lock];
//        [self.speakLock wait];
//        [self.speakLock unlock];
//    }
//}
//
//
//-(void)onSoundCompleted:(id)sound
//{
//    [self.speakLock signal];
//}
//
//-(void)setVolumeToInPercent:(float)volumeInPercent
//{
//    NSEnumerator *enumerator = [self.sounds objectEnumerator];
//    SPSoundChannel* sound;
//    while ((sound = [enumerator nextObject])) {
//        sound.volume = volumeInPercent/100.0f;
//    }
//}
//
//-(void)changeVolumeInPercent:(float)volumeInPercent
//{
//    NSEnumerator *enumerator = [self.sounds objectEnumerator];
//    SPSoundChannel* sound;
//    while ((sound = [enumerator nextObject])) {
//        sound.volume += volumeInPercent/100.0f;
//    }
//    
//}
//
//-(void)stopAllSounds
//{
//    NSEnumerator *enumerator = [self.sounds objectEnumerator];
//    SPSoundChannel* sound;
//    while ((sound = [enumerator nextObject])) {
//        [sound stop];
//    }
//    
//}
//
//-(void)setTransparencyInPercent:(float)transparencyInPercent
//{
//  self.alpha = 1.0f - transparencyInPercent / 100.0f;
//}
//
//-(void)changeTransparencyInPercent:(float)increaseInPercent
//{
//    self.alpha += 1.0f - increaseInPercent /100.0f;
//}
//
//-(void)broadcastAndWait:(NSString *)message
//{
//    if ([[NSThread currentThread] isMainThread]) {
//        
//        //TODO
//        
//        NSLog(@" ");
//        NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
//        NSLog(@"!!                                                                                       !!");
//        NSLog(@"!!  ATTENTION: THIS METHOD SHOULD NEVER EVER BE CALLED FROM MAIN-THREAD!!! BUSY WAITING  !!");
//        NSLog(@"!!                                                                                       !!");
//        NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
//        NSLog(@" ");
//        abort();
//    }
//    
////    NSString *responseID = [NSString stringWithFormat:@"%@-%d", message, arc4random()%1000000];
//    
//    if ([self.broadcastWaitDelegate respondsToSelector:@selector(performBroadcastWaitForMessage:)]) {
//        [self.broadcastWaitDelegate performBroadcastWaitForMessage:message];
//    } else {
//        NSLog(@"ERROR: BroadcastWaitDelegate not set! abort()");
//        abort();
//    }
//    
////    [[NSNotificationCenter defaultCenter]postNotificationName:message object:self userInfo:[NSDictionary dictionaryWithObject:responseID forKey:@"responseID"]];
////    
////    // TODO: busy waiting...
////    while ([self.broadcastWaitDelegate polling4testing__didAllObserversFinishForResponseID:responseID] == NO);
//    
//    
//}
//
//
//#pragma mark - Helper
//
//-(NSString*)pathForLook:(Look*)look
//{
//    return [NSString stringWithFormat:@"%@images/%@", [self projectPath], look.fileName];
//}
//
//
//-(NSString*)pathForSpeakSound:(Sound*)sound
//{
//    return [NSTemporaryDirectory() stringByAppendingPathComponent:sound.fileName];
//}
//


//
//-(CGPoint)pointForStageCoordinates
//{
//    CGPoint point;
//    point.x =   self.x - (Sparrow.stage.width /2.0f);
//    point.y = -(self.y - (Sparrow.stage.height/2.0f));
//    
//    return point;
//}
//
//
//- (void)comeToFront {
//    
//    if ([self.parent childIndex:self] == 0) {
//        // I'm the background - why should I come to font??
//        return;
//    }
//    
//    dispatch_sync(dispatch_get_main_queue(), ^{
////        [self.parent addChild:self];
//        [self.parent setIndex:self.parent.numChildren-1 ofChild:self];
//    });
//}
//
//- (void)goNStepsBack:(int)n
//{
//    int oldIndex = [self.parent childIndex:self];
//    
//    if (oldIndex == 0) {
//        // I'm the background - why should I go anywhere??
//        return;
//    }
//    
//    int index = MAX(1, oldIndex-n);
//    index = MIN(index, self.parent.numChildren-1);
//    dispatch_sync(dispatch_get_main_queue(), ^{
////        [self.parent addChild:self atIndex:index];
//        [self.parent setIndex:index ofChild:self];
//    });
//
//}
//
//- (void)pointInDirection:(float)degrees {
//    self.rotation = SP_D2R(degrees-90);
//}
//
//- (void)changeBrightness:(float)factor {
//    //image.color = SP_COLOR(255, 0, 255);
//    
//    factor /= 100.0f;
//    
//    // < 1.0f == dim
//    if (factor <= 1.0f) {
//        self.blendMode = SP_BLEND_MODE_NORMAL;
//        // READ THIS CAREFULLY
//        // Normally we would use the current
//        // color of the sprite object but since the
//        // scale factor is based on 100% we always calculate
//        // the brightness from 100%, which in turn is
//        // rgb(1.0, 1.0, 1.0) respectively 0xFFFFFF
//        //uint color = self.color;
//
//        uint color = 0xFFFFFF;
//        
//        uint rMask = 0xFF0000;
//        uint gMask = 0x00FF00;
//        uint bMask = 0x0000FF;
//        
//        uint red = (color & rMask) >> 16;
//        uint green = (color & gMask) >> 8;
//        uint blue = color & bMask;
//        
//        NSLog(@"r: %x, g: %x, b: %x", red, green, blue);
//        
//        // recalculate color
//        self.color = SP_COLOR(red * factor, green * factor, blue * factor);
//        
//        self.brightnessWorkaround = nil;
//    }
//    /*else if (factor == 1.0f) {
//        // do nothing...
//    }*/
//    else if (factor > 1.0f) {
//        // lighten
//        
//        
//        self.blendMode = SP_BLEND_MODE_ADD;
//        
//        SPImage *image = [[SPImage alloc] initWithTexture:self.texture];
//        image.x = self.x;
//        image.y = self.y;
//        image.blendMode = SP_BLEND_MODE_ADD;
//        image.pivotX = self.pivotX;
//        image.pivotY = self.pivotY;
//
//        // manipulate image color
//        uint color = image.color;
//        
//        uint rMask = 0xFF0000;
//        uint gMask = 0x00FF00;
//        uint bMask = 0x0000FF;
//        
//        uint red = (color & rMask) >> 16;
//        uint green = (color & gMask) >> 8;
//        uint blue = color & bMask;
//        
//        
//        float scaleFactor = factor - 1.0f;
//        if (scaleFactor > 1.0f) {
//            scaleFactor = 1.0f;
//        }
//        // recalculate color
//        image.color = SP_COLOR(red * scaleFactor, green * scaleFactor, blue * scaleFactor);
//
//        
//        self.brightnessWorkaround = image;
//        
//        
////        Look *look = [self.lookList objectAtIndex:self.lookIndex];
////        self.texture = [[SPTexture alloc] initWithContentsOfFile:look.
//        
//    }
//}
//
//- (void)moveNSteps:(float)steps
//{
//    
//    int xPosition = (int) round(self.position.x + steps*cos(self.rotation));
//    
//    int yPosition = (int) round(self.position.y - steps*sin(self.rotation));
//    
//    self.position = CGPointMake(xPosition, yPosition);
//}
//
//- (void)ifOnEdgeBounce
//{
//    float width = self.width;
//    float height = self.height;
//    int xPosition = self.position.x;
//    int yPosition = self.position.y;
//    
//    int virtualScreenWidth = Sparrow.stage.width/2.0f;
//    int virtualScreenHeight = Sparrow.stage.height/2.0f;
//    
//    float rotation = SP_R2D(self.rotation);
//    
//    if (xPosition < -virtualScreenWidth + width/2.0f) {
//        if (rotation <= 180.0f) {
//            rotation = (180.0f-rotation);
//        } else {
//            rotation = 270.0f + (270.0f - rotation);
//        }
//        xPosition = -virtualScreenWidth + (int) (width / 2.0f);
//        
//    } else if (xPosition > virtualScreenWidth - width / 2.0f) {
//        
//        if (rotation >= 0.0f && rotation < 90.0f) {
//            rotation = 180.0f - rotation;
//        } else {
//            rotation = 180.0f + (360.0f - rotation);
//        }
//        
//        xPosition = virtualScreenWidth - (int) (width / 2.0f);
//    }
//    
//    if (yPosition > virtualScreenHeight - height / 2.0f) {
//        
//        rotation = -rotation;
//        yPosition = virtualScreenHeight - (int) (height / 2.0f);
//        
//    } else if (yPosition < -virtualScreenHeight + height / 2.0f) {
//        
//        rotation = 360.0f - rotation;
//        yPosition = -virtualScreenHeight + (int) (height / 2);
//    }
//    
//    self.rotation = SP_D2R(rotation);
//    self.position = CGPointMake(xPosition, yPosition);
//
//}
//
//
//- (void)render:(SPRenderSupport *)support {
//    
//    if (self.brightnessWorkaround) {
//        [self.brightnessWorkaround render:support];
//    }
//    
//    [super render:support];
//}
//
//
//

//
//#pragma mark - SpriteFormulaProtocol
//
//- (CGFloat) xPosition
//{
//    return self.position.x;
//}
//
//- (CGFloat) yPosition {
//    return self.position.y;
//}
//
//- (CGFloat) brightness {
//#warning implement me right once we moved to SpriteKit
//    abort();
//    return 1.0;
//}


@end
