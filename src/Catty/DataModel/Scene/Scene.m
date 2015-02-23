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
                [self startStartScript:(StartScript*)script];
            }
        }
    }
}

- (void)startStartScript:(StartScript*)startScript
{
//    [NSOperationQueue high]
//    NSOperationQueuePriorityHigh
//    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
//    NSOperation *operation = [NSOperation new];
//    operation.qualityOfService = NSQualityOfServiceUserInitiated;
//    operation.queuePriority = NSOperationQueuePriorityVeryHigh;
    dispatch_async(self.backgroundQueue, ^{
        [startScript.object startAndAddScript:startScript completion:nil];
        NSLog(@"FINISHED");
    });
}

- (void)stopProgram
{
    self.program.playing = NO;
    self.paused = YES;
    [[AudioManager sharedAudioManager] stopAllSounds];
//    [NSThread sleepForTimeInterval:0.5f]; // XXX: wait until all blocks are finished!!
//    [self.program removeReferences];
//    [self.program updateReferences];

    for (SpriteObject *object in self.program.objectList) {
        for (Script *script in object.scriptList) {
            script.allowRunNextAction = NO;
            [script removeAllActions];
            if ([script inParentHierarchy:object]) {
                [script removeFromParent];
            }
            script.currentBrickIndex = 0;
        }
        if ([object inParentHierarchy:self]) {
            [object removeFromParent];
        }
    }
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
