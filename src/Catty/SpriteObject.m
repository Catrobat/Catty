//
//  SpriteObject.m
//  Catty
//
//  Created by Mattias Rauter on 04.04.13.
//
//

#import "SpriteObject.h"
#import "BroadcastWaitDelegate.h"
#import "StartScript.h"
#import "WhenScript.h"
#import "BroadcastScript.h"
#import "Look.h"
#import "Sound.h"
#import "Sparrow.h"
#import "SPImage.h"

@interface SpriteObject()

@property (nonatomic, strong) NSMutableArray *activeScripts;
@property (assign) int lookIndex;
@property (nonatomic, strong) SPImage *brightnessWorkaround;
@property (nonatomic, strong) NSMutableDictionary *sounds;

@end

@implementation SpriteObject

@synthesize position = _position;
@synthesize brightnessWorkaround = _brightnessWorkaround;

// --- getter - setter ---

-(NSMutableArray *)activeScripts
{
    if (_activeScripts == nil)
        _activeScripts = [[NSMutableArray alloc]init];
    return _activeScripts;
}

-(void)setPosition:(CGPoint)position
{
    //_position = position;
    
    CGPoint pos = [self stageCoordinatesForPoint:position];
    
    self.x = (pos.x);
    self.y = (pos.y);
    
}

-(CGPoint)position
{
    CGPoint pos = [self pointForStageCoordinates];
    return pos;
}

-(NSMutableDictionary*)sounds
{
    if(!_sounds) {
        _sounds  = [[NSMutableDictionary alloc] init];
    }
    return _sounds;
}


// --- other stuff ---

-(void)setInitValues
{
    self.position = CGPointMake(0.0f, 0.0f);
    self.lookIndex = 0;
}


- (NSString*)description {
    NSMutableString *ret = [[NSMutableString alloc] init];
    //[ret appendFormat:@"Sprite: (0x%@):\n", self];
    [ret appendFormat:@"\r------------------- SPRITE --------------------\r"];
    [ret appendFormat:@"Name: %@\r", self.name];
    //[ret appendFormat:@"Look List: \r%@\r\r", self.lookList];
    //[ret appendFormat:@"Script List: \r%@\r", self.scriptList];
    [ret appendFormat:@"-------------------------------------------------\r"];
    
    return [NSString stringWithString:ret];
}

#pragma mark - script methods
- (void)start
{
    [self setInitValues];
    
    // init BroadcastWait-stuff
    for (Script *script in self.scriptList) {
        if ([script isKindOfClass:[Broadcastscript class]]) {
            Broadcastscript *broadcastScript = (Broadcastscript*)script;
            if ([self.broadcastWaitDelegate respondsToSelector:@selector(registerSprite:forMessage:)]) {
                [self.broadcastWaitDelegate registerSprite:self forMessage:broadcastScript.receivedMessage];
            } else {
                NSLog(@"ERROR: BroadcastWaitDelegate not set! abort()");
                abort();
            }
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(performBroadcastScript:) name:broadcastScript.receivedMessage object:nil];
        }
    }
    
    
    for (Script *script in self.scriptList)
    {
        if ([script isKindOfClass:[Startscript class]]) {
            [self.activeScripts addObject:script];
            
            // ------------------------------------------ THREAD --------------------------------------
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [script runScript];
                
                // tell the main thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self scriptFinished:script];
                });
            });
            // ------------------------------------------ END -----------------------------------------
        }
    }
}

-(BOOL)isType:(TouchAction)type equalToString:(NSString*)action
{
#warning add other possible action-types
    if (type == kTouchActionTap && [action isEqualToString:@"Tapped"]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)onImageTouched:(SPTouchEvent *)event
{
    NSSet *touches = [event touchesWithTarget:self andPhase:SPTouchPhaseBegan];
    if ([touches anyObject]) {
        NSLog(@"TOUCHED");

        for (Script *script in self.scriptList)
        {
            if ([script isKindOfClass:[Whenscript class]]) {
                NSLog(@"Performing script with action: %@", script.description);
                
                if ([self.activeScripts containsObject:script]) {
                    [script resetScript];
                } else {
                    [self.activeScripts addObject:script];
                    
                    // ------------------------------------------ THREAD --------------------------------------
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        [script runScript];
                        
                        // tell the main thread
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            [self scriptFinished:script];
                        });
                    });
                    // ------------------------------------------ END -----------------------------------------
                }
            }
        }
    }
}

- (void)performBroadcastScript:(NSNotification*)notification
{
    NSLog(@"Notification: %@", notification.name);
    Broadcastscript *script = nil;
    
    for (Script *s in self.scriptList) {
        if ([s isKindOfClass:[Broadcastscript class]]) {
            Broadcastscript *tmp = (Broadcastscript*)s;
            if ([tmp.receivedMessage isEqualToString:notification.name]) {
                script = tmp;
            }
        }
    }
    
    if (script) {
        
        if ([self.activeScripts containsObject:script]) {
            [script resetScript];
        } else {
            [self.activeScripts addObject:script];
            
            // -------- ---------------------------------- THREAD --------------------------------------
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [script runScript];
                
                // tell the main thread
                dispatch_sync(dispatch_get_main_queue(), ^{
                    
//                    NSString *responseID = (NSString*)[notification.userInfo valueForKey:@"responseID"];
//                    if (responseID != nil) {
//                        [[NSNotificationCenter defaultCenter]postNotificationName:responseID object:self];
//                    } else {
//                        NSLog(@"Why is there no responseID? I don't want to live on this planet anymore...abort()");
//                        abort();
//                    }
                    
                    [self scriptFinished:script];
                });
            });
            // ------------------------------------------ END -----------------------------------------
        }
        
    }
}

-(void)performBroadcastWaitScript_calledFromBroadcastWaitDelegate_withMessage:(NSString *)message
{
    Broadcastscript *script = nil;
    
    for (Script *s in self.scriptList) {
        if ([s isKindOfClass:[Broadcastscript class]]) {
            Broadcastscript *tmp = (Broadcastscript*)s;
            if ([tmp.receivedMessage isEqualToString:message]) {
                script = tmp;
            }
        }
    }
    
    if (script) {
        
        if ([self.activeScripts containsObject:script]) {
            [script resetScript];
        } else {
            [self.activeScripts addObject:script];
            
            [script runScript];
            [self scriptFinished:script];
        }
        
    }

}


-(void)scriptFinished:(Script *)script
{
    [self.activeScripts removeObject:script];
}

-(void)stopAllScripts
{
    for (Script *script in self.activeScripts) {
        [script stopScript];
    }
    self.activeScripts = nil;
}


#pragma mark - Overwritten Methods
-(void) readjustSize
{
    [super readjustSize];
    self.pivotX = self.texture.width / 2.0f;
    self.pivotY = self.texture.height / 2.0f;
}


 


// --- actions ---

-(void)changeLook:(Look*)look
{
    NSString *path = [self pathForLook:look];
    self.texture = [SPTexture textureWithContentsOfFile:path];
    [self readjustSize];
    self.lookIndex = [self.lookList indexOfObject:look];
}


-(void)nextLook
{
    if (self.lookIndex == [self.lookList count]-1) {
        self.lookIndex = 0;
    }
    else {
        self.lookIndex++;
    }
    Look* look = [self.lookList objectAtIndex:self.lookIndex];
    NSString* path = [self pathForLook:look];
    self.texture = [SPTexture textureWithContentsOfFile:path];
    [self readjustSize];
    self.lookIndex = [self.lookList indexOfObject:look];
}

-(void)hide
{
    self.visible = NO;
    
}

-(void)show
{
    self.visible = YES;
}

-(void)turnLeft:(float)degrees
{
    self.rotation -= SP_D2R(degrees);
}

-(void)turnRight:(float)degrees
{
    self.rotation += SP_D2R(degrees);
}


- (void)glideToPosition:(CGPoint)position withDurationInSeconds:(float)durationInSeconds fromScript:(Script *)script {

    CGPoint newPosition = [self stageCoordinatesForPoint:position];

    
    SPTween *tween = [SPTween tweenWithTarget:self time:durationInSeconds];
    [tween moveToX:newPosition.x y:newPosition.y];
    tween.repeatCount = 1;
    [Sparrow.juggler addObject:tween];
}


-(void)changeXBy:(float)x
{
    
    SPTween *tween = [SPTween tweenWithTarget:self time:0.0f];
    [tween animateProperty:@"x" targetValue:self.x+x];
    tween.repeatCount = 1;
    [Sparrow.juggler addObject:tween];

}

-(void)changeYBy:(float)y
{
    SPTween *tween = [SPTween tweenWithTarget:self time:0.0f];
    [tween animateProperty:@"y" targetValue:self.y-y];
    tween.repeatCount = 1;
    [Sparrow.juggler addObject:tween];
}

-(void)broadcast:(NSString *)message
{
    [[NSNotificationCenter defaultCenter] postNotificationName:message object:self];
}


-(void)setSizeToPercentage:(float)sizeInPercentage
{
    self.scaleX = self.scaleY = sizeInPercentage/100.0f;
}

-(void)changeSizeByNInPercent:(float)sizePercentageRate
{
    self.scaleX += sizePercentageRate/100.0f;
    self.scaleY += sizePercentageRate/100.0f;
}


- (void)speakSound:(Sound*)sound
{
    SPSound *soundFile = [SPSound soundWithContentsOfFile:[self pathForSpeakSound:sound]];
    [self createSoundChannelAndAddToSounds:soundFile withKey:sound.fileName];
}


-(void)playSound:(Sound*)sound
{
    SPSound *soundFile = [SPSound soundWithContentsOfFile:[self pathForSound:sound]];
    [self createSoundChannelAndAddToSounds:soundFile withKey:sound.fileName];
}


-(void)createSoundChannelAndAddToSounds:(SPSound*)soundFile withKey:(NSString*)key
{
    SPSoundChannel* channel = nil;
    
    
    if(!(channel = [self.sounds objectForKey:key])) {
        channel = [soundFile createChannel];
        [self.sounds setObject:channel forKey:key];
    }
    
    [channel stop];
    [channel play];
    
}

-(void)setVolumeToInPercent:(float)volumeInPercent
{
    NSEnumerator *enumerator = [self.sounds objectEnumerator];
    SPSoundChannel* sound;
    while ((sound = [enumerator nextObject])) {
        sound.volume = volumeInPercent/100.0f;
    }
}

-(void)changeVolumeInPercent:(float)volumeInPercent
{
    NSEnumerator *enumerator = [self.sounds objectEnumerator];
    SPSoundChannel* sound;
    while ((sound = [enumerator nextObject])) {
        sound.volume += volumeInPercent/100.0f;
    }
    
}

-(void)stopAllSounds
{
    NSEnumerator *enumerator = [self.sounds objectEnumerator];
    SPSoundChannel* sound;
    while ((sound = [enumerator nextObject])) {
        [sound stop];
    }
    
}

-(void)setTransparencyInPercent:(float)transparencyInPercent
{
  self.alpha = 1.0f - transparencyInPercent / 100.0f;
}

-(void)changeTransparencyInPercent:(float)increaseInPercent
{
    self.alpha += 1.0f - increaseInPercent /100.0f;
}

-(void)broadcastAndWait:(NSString *)message
{
    if ([[NSThread currentThread] isMainThread]) {
        
        //TODO
        
        NSLog(@" ");
        NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
        NSLog(@"!!                                                                                       !!");
        NSLog(@"!!  ATTENTION: THIS METHOD SHOULD NEVER EVER BE CALLED FROM MAIN-THREAD!!! BUSY WAITING  !!");
        NSLog(@"!!                                                                                       !!");
        NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
        NSLog(@" ");
        abort();
    }
    
//    NSString *responseID = [NSString stringWithFormat:@"%@-%d", message, arc4random()%1000000];
    
    if ([self.broadcastWaitDelegate respondsToSelector:@selector(performBroadcastWaitForMessage:)]) {
        [self.broadcastWaitDelegate performBroadcastWaitForMessage:message];
    } else {
        NSLog(@"ERROR: BroadcastWaitDelegate not set! abort()");
        abort();
    }
    
//    [[NSNotificationCenter defaultCenter]postNotificationName:message object:self userInfo:[NSDictionary dictionaryWithObject:responseID forKey:@"responseID"]];
//    
//    // TODO: busy waiting...
//    while ([self.broadcastWaitDelegate polling4testing__didAllObserversFinishForResponseID:responseID] == NO);
    
    
}


#pragma mark - Helper

-(NSString*)pathForLook:(Look*)look
{
    return [NSString stringWithFormat:@"%@images/%@", self.projectPath, look.fileName];
}

-(NSString*)pathForSound:(Sound*)sound
{
    return [NSString stringWithFormat:@"%@sounds/%@", self.projectPath, sound.fileName];
}

-(NSString*)pathForSpeakSound:(Sound*)sound
{
    return [NSTemporaryDirectory() stringByAppendingPathComponent:sound.fileName];
}

-(CGPoint)stageCoordinatesForPoint:(CGPoint)point
{
    CGPoint coordinates;
    coordinates.x = [self xStageCoordinateForCoordinate:point.x];
    coordinates.y = [self yStageCoordinateForCoordinate:point.y];
    
    return coordinates;
}

-(float)yStageCoordinateForCoordinate:(float)y {
    return (Sparrow.stage.height/2.0f - y);
}

-(float)xStageCoordinateForCoordinate:(float)x {
    return (x + Sparrow.stage.width  / 2.0f);
}

-(CGPoint)pointForStageCoordinates
{
    CGPoint point;
    point.x =   self.x - (Sparrow.stage.width /2.0f);
    point.y = -(self.y - (Sparrow.stage.height/2.0f));
    
    return point;
}


- (void)comeToFront {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.parent addChild:self];
    });
}

- (void)goNStepsBack:(int)n
{
    int index = MAX(0, [self.parent childIndex:self]-fabs(n));
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.parent addChild:self atIndex:index];
    });

}

- (void)pointInDirection:(float)degrees {
    self.rotation = SP_D2R(degrees-90);
}

- (void)changeBrightness:(float)factor {
    //image.color = SP_COLOR(255, 0, 255);
    
    // < 1.0f == dim
    if (factor <= 1.0f) {
        self.blendMode = SP_BLEND_MODE_NORMAL;
        // READ THIS CAREFULLY
        // Normally we would use the current
        // color of the sprite object but since the
        // scale factor is based on 100% we always calculate
        // the brightness from 100%, which in turn is
        // rgb(1.0, 1.0, 1.0) respectively 0xFFFFFF
        //uint color = self.color;

        uint color = 0xFFFFFF;
        
        uint rMask = 0xFF0000;
        uint gMask = 0x00FF00;
        uint bMask = 0x0000FF;
        
        uint red = (color & rMask) >> 16;
        uint green = (color & gMask) >> 8;
        uint blue = color & bMask;
        
        NSLog(@"r: %x, g: %x, b: %x", red, green, blue);
        
        // recalculate color
        self.color = SP_COLOR(red * factor, green * factor, blue * factor);
        
        self.brightnessWorkaround = nil;
    }
    /*else if (factor == 1.0f) {
        // do nothing...
    }*/
    else if (factor > 1.0f) {
        // lighten
        
        
        self.blendMode = SP_BLEND_MODE_ADD;
        
        SPImage *image = [[SPImage alloc] initWithTexture:self.texture];
        image.x = self.x;
        image.y = self.y;
        image.blendMode = SP_BLEND_MODE_ADD;
        image.pivotX = self.pivotX;
        image.pivotY = self.pivotY;

        // manipulate image color
        uint color = image.color;
        
        uint rMask = 0xFF0000;
        uint gMask = 0x00FF00;
        uint bMask = 0x0000FF;
        
        uint red = (color & rMask) >> 16;
        uint green = (color & gMask) >> 8;
        uint blue = color & bMask;
        
        
        float scaleFactor = factor - 1.0f;
        if (scaleFactor > 1.0f) {
            scaleFactor = 1.0f;
        }
        // recalculate color
        image.color = SP_COLOR(red * scaleFactor, green * scaleFactor, blue * scaleFactor);

        
        self.brightnessWorkaround = image;
        
        
//        Look *look = [self.lookList objectAtIndex:self.lookIndex];
//        self.texture = [[SPTexture alloc] initWithContentsOfFile:look.
        
    }
}

- (void)render:(SPRenderSupport *)support {
    
    if (self.brightnessWorkaround) {
        [self.brightnessWorkaround render:support];
    }
    
    [super render:support];
}

@end
