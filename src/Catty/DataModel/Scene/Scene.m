/**
 *  Copyright (C) 2010-2015 The Catrobat Team
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

#import "Scene.h"
#import "Program.h"
#import "SpriteObject.h"
#import "StartScript.h"
#import "HideBrick.h"
#import "AudioManager.h"

#warning REMOVE!!!
#import "ForeverBrick.h"
#import "NoteBrick.h"

@interface Scene()

@property (nonatomic, strong) dispatch_queue_t backgroundQueue;

@end

@implementation Scene

- (dispatch_queue_t)backgroundQueue
{
    if (! _backgroundQueue) {
//        _backgroundQueue = dispatch_queue_create("org.catrobat.startScript", DISPATCH_QUEUE_CONCURRENT);
        _backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    }
    return _backgroundQueue;
}

- (id)initWithSize:(CGSize)size andProgram:(Program*)program
{
    if (self = [super initWithSize:size]) {
        self.program = program;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)dealloc
{
    NSDebug(@"Dealloc Scene");
}

- (void)willMoveFromView:(SKView*)view
{
    [self removeAllChildren];
    [self removeAllActions];
}

- (void)didMoveToView:(SKView*)view
{
    [self startProgram];
}

- (void)startProgram
{
    if (! [[NSThread currentThread] isMainThread]) {
        NSLog(@" ");
        NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
        NSLog(@"!!                                                                                       !!");
        NSLog(@"!! FATAL: THIS METHOD SHOULD NEVER EVER BE CALLED FROM ANOTHER THREAD EXCEPT MAIN-THREAD !!");
        NSLog(@"!!                                                                                       !!");
        NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
        NSLog(@" ");
        abort();
    }

    // init and prepare Scene
    CGFloat zPosition = 1.0f;
    [self removeAllChildren]; // just to ensure
    self.program.playing = YES;
    [self.program setupBroadcastHandling];
    for (SpriteObject *spriteObject in self.program.objectList) {
        // minor user experience improvement: check if first Brick in StartScript is HideBrick
        BOOL found = NO;
        for (Script *script in spriteObject.scriptList) {
            if ([script isKindOfClass:[StartScript class]]) {
                id firstBrick = [script.brickList firstObject];
                if ([firstBrick isKindOfClass:[HideBrick class]]) {
                    found = YES;
                }
                break;
            }
        }
        spriteObject.hidden = found;
        // now add the brick with correct visability-state to the Scene
        [self addChild:spriteObject];
        NSDebug(@"%f", zPosition);
        [spriteObject start:zPosition];
        [spriteObject setLook];
        spriteObject.userInteractionEnabled = YES;

        if (! ([spriteObject isBackground])) {
            ++zPosition;
        }
    }

    // start StartScripts of all SpriteObjects simultaneously!!
    for (SpriteObject *spriteObject in self.program.objectList) {
        for (Script *script in spriteObject.scriptList) {
            if ([script isKindOfClass:[StartScript class]]) {
                [script.object startAndAddScript:script completion:nil];
            }
        }
    }

//
//    // compute all sequence lists
//    for (SpriteObject *spriteObject in self.program.objectList) {
//        for (Script *script in spriteObject.scriptList) {
//            [script computeSequenceList];
//        }
//    }
//
//    // start StartScripts of all SpriteObjects simultaneously!!
//    for (SpriteObject *spriteObject in self.program.objectList) {
//        for (Script *script in spriteObject.scriptList) {
//            if ([script isKindOfClass:[StartScript class]]) {
////                dispatch_async(self.backgroundQueue, ^{
//                    [script.object startAndAddScript:script completion:nil];
////                });
//            }
//        }
//    }
}

- (void)stopProgramWithCompletion:(dispatch_block_t)completion
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        self.program.playing = NO;
        [[AudioManager sharedAudioManager] stopAllSounds];

        // continue scene so that all SpriteKit actions can be finished
        self.view.paused = NO;
    });

    // perform waiting on another thread!
    // busy waiting until all scripts finished!!
    for (SpriteObject *spriteObject in self.program.objectList) {
        for (Script *script in spriteObject.scriptList) {
            // CAVE: Never remove this (empty) while loop here!!
            while (script.isRunning) {
                [script stop];
                NSLog(@"%@ in %@ is still running (Scene %@). Waiting until script finished execution...", [script class], spriteObject.name, (self.isPaused ? @"paused" : @"still running"));
//                for (Brick *brick in script.brickList) {
//                    if (brick && brick.semaphore) {
//                        dispatch_semaphore_signal(brick.semaphore); // XXX: HACK!!
//                    }
//                }
                [NSThread sleepForTimeInterval:1.0f];
            }
        }
    }
    NSLog(@"All scripts finished execution!");

    // remove all references in program hierarchy
    [self.program removeReferences];

    dispatch_sync(dispatch_get_main_queue(), ^{
        self.view.paused = YES; // pause scene!

        // now all (!) scripts of all (!) objects have been finished! we can safely remove all SpriteObjects from Scene
        // NOTE: this for-in-loop MUST NOT be combined with previous for-in-loop because there could exist some
        //       Scripts in SpriteObjects that contain pointToBricks to other (!) SpriteObjects
        for (SpriteObject *spriteObject in self.program.objectList) {
            for (Script *script in spriteObject.scriptList) {
                [script stop];
                if ([script inParentHierarchy:spriteObject]) {
                    [script removeFromParent];
                }
            }
            if ([spriteObject inParentHierarchy:self]) {
                [spriteObject removeFromParent];
            }
        }
    });
    [self.program removeReferences];
    NSLog(@"All SpriteObjects and Scripts have been removed from Scene!");

    if (completion) {
        completion();
    }
}

- (void)restartProgramWithCompletion:(dispatch_block_t)completion
{
    [self stopProgramWithCompletion:nil];
}

- (CGPoint)convertPointToScene:(CGPoint)point
{
    CGPoint scenePoint;
    scenePoint.x = [self convertXCoordinateToScene:point.x];
    scenePoint.y = [self convertYCoordinateToScene:point.y];
    return scenePoint;
}

- (CGFloat)convertYCoordinateToScene:(CGFloat)y
{
    return (self.size.height/2.0f + y);
}

- (CGFloat)convertXCoordinateToScene:(CGFloat)x
{
    return (self.scene.size.width/2.0f + x);
}

- (CGPoint)convertSceneCoordinateToPoint:(CGPoint)point
{
    CGFloat x = point.x - self.scene.size.width/2.0f;
    CGFloat y = point.y - self.scene.size.height/2.0f;
    return CGPointMake(x, y);
}

- (CGFloat)convertDegreesToScene:(CGFloat)degrees
{
    return 360.0f - degrees;
}

- (CGFloat)convertSceneToDegrees:(CGFloat)degrees
{
    return 360.0f + degrees;
}

- (BOOL)touchedwith:(NSSet*)touches withX:(CGFloat)x andY:(CGFloat)y
{
    if (! self.program.isPlaying) {
        return NO;
    }

    NSDebug(@"StartTouchOfScene");
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    NSDebug(@"x:%f,y:%f", location.x, location.y);
    BOOL foundObject = NO;
    NSArray *nodesAtPoint = [self nodesAtPoint:location];
    if ([nodesAtPoint count] == 0) {
        return NO;
    }

    SpriteObject *obj1 = nodesAtPoint[[nodesAtPoint count]-1];
    NSInteger counter = [nodesAtPoint count]-2;
    NSDebug(@"How many nodes are touched: %ld",(long)counter);
    NSDebug(@"First Node:%@",obj1);
    if (! obj1.name) {
        return NO;
    }

    while (! foundObject) {
        CGPoint point = [touch locationInNode:obj1];
        if (! obj1.hidden) {
            if (! [obj1 touchedwith:touches withX:point.x andY:point.y]) {
                CGFloat zPosition = obj1.zPosition;
                zPosition -= 1;
                if (zPosition == -1 || counter < 0) {
                    foundObject =  YES;
                    NSDebug(@"Found Object");
                } else {
                    obj1 = nodesAtPoint[counter];
                    NSDebug(@"NextNode: %@",obj1);
                    --counter;
                }
            } else {
                foundObject = YES;
                NSDebug(@"Found Object");
            }
        } else {
            obj1 = nodesAtPoint[counter];
            NSDebug(@"NextNode: %@",obj1);
            --counter;
        }
    }
    return YES;
}

@end
