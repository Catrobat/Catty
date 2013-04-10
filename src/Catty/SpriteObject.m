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

@interface SpriteObject()
@property (nonatomic, strong) NSMutableArray *activeScripts;
@property (assign) int lookIndex;
@end

@implementation SpriteObject

// --- getter - setter ---

-(NSMutableArray *)activeScripts
{
    if (_activeScripts == nil)
        _activeScripts = [[NSMutableArray alloc]init];
    return _activeScripts;
}

-(void)setPosition:(CGPoint)position
{
    _position = position;
    
    position = [self stageCoordinatesForPoint:position];
    
    self.x = (position.x);
    self.y = (position.y);
    
}


// --- other stuff ---

-(void)setInitValues
{
    self.showSprite = YES;
    self.alphaValue = 1.0f;
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
                    
                    NSString *responseID = (NSString*)[notification.userInfo valueForKey:@"responseID"];
                    if (responseID != nil) {
                        [[NSNotificationCenter defaultCenter]postNotificationName:responseID object:self];
                    } else {
                        NSLog(@"Why is there no responseID? I don't want to live on this planet anymore...abort()");
                        abort();
                    }
                    
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

-(void)broadcast:(NSString *)message
{
    [[NSNotificationCenter defaultCenter] postNotificationName:message object:self];
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

-(CGPoint)stageCoordinatesForPoint:(CGPoint)point
{
    CGPoint coordinates;
    coordinates.x = (point.x + Sparrow.stage.width  / 2.0f);
    coordinates.y = (Sparrow.stage.height/2.0f - point.y);
    
    return coordinates;
}

- (void)comeToFront {
//    NSLog(@"Sprite: %@ come to front", self.name);
    SPDisplayObjectContainer* myParent = self.parent;
    //[myParent setIndex:myParent.numChildren-1 ofChild:self];
    
    [myParent addChild:self];
//    NSLog(@"Finished come to front");
}

- (void)pointToDirection:(float)degrees {
    self.rotation = SP_D2R(degrees);
}

- (void)changeBrightness:(float)factor {
    //image.color = SP_COLOR(255, 0, 255);
    //image.color
}

@end
