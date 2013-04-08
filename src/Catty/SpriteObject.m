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
    
    self.x = (position.x + Sparrow.stage.width  / 2.0f) - (self.width  / 2.0f);
    self.y = (position.y + Sparrow.stage.height / 2.0f) - (self.height / 2.0f);
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
    [ret appendFormat:@"Look List: \r%@\r\r", self.lookList];
    [ret appendFormat:@"Script List: \r%@\r", self.scriptList];
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
            if ([self.broadcastWaitDelegate respondsToSelector:@selector(increaseNumberOfObserversForNotificationMessage:)]) {
                [self.broadcastWaitDelegate increaseNumberOfObserversForNotificationMessage:broadcastScript.receivedMessage];
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
                        dispatch_async(dispatch_get_main_queue(), ^{
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
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSString *responseID = (NSString*)[notification.userInfo valueForKey:@"responseID"];
                    if (responseID != nil) {
                        [[NSNotificationCenter defaultCenter]postNotificationName:responseID object:self];
                    }
                    
                    [self scriptFinished:script];
                });
            });
            // ------------------------------------------ END -----------------------------------------
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



// --- actions ---

-(void)changeLook:(Look*)look
{
    NSString *path = [self pathForLook:look];
    self.texture = [SPTexture textureWithContentsOfFile:path];
    [self readjustSize];
    self.position = self.position;  // yes! we need this! :P
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
    self.position = self.position;  // yes! we need this! :P
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


#pragma mark - Helper

-(NSString*)pathForLook:(Look*)look
{
    return [NSString stringWithFormat:@"%@images/%@", self.projectPath, look.fileName];
}

- (void)glideToPosition:(CGPoint)position withDurationInSeconds:(int)durationInSeconds fromScript:(Script *)script {

    // recalculate position
#warning todo: maybe change this ...
    CGPoint newPosition;
    newPosition.x = (position.x + Sparrow.stage.width  / 2.0f) - (self.width  / 2.0f);
    newPosition.y = (position.y + Sparrow.stage.height / 2.0f) - (self.height / 2.0f);
    
    SPTween *tween = [SPTween tweenWithTarget:self time:durationInSeconds];
    [tween animateProperty:@"x" targetValue:newPosition.x];
    [tween animateProperty:@"y" targetValue:newPosition.y];
    tween.repeatCount = 1; // only perform once
    [Sparrow.juggler addObject:tween];
    
}


@end
