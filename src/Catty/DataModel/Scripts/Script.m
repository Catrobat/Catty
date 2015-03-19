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

#import "Script.h"
#import "Brick.h"
#import "BrickManager.h"
#import "CBMutableCopyContext.h"
#import "Util.h"
#import "LoopBeginBrick.h"
#import "BroadcastScript.h"
#import "IfLogicBeginBrick.h"
#import "IfLogicElseBrick.h"
#import "IfLogicEndBrick.h"
#import "CBActionOperation.h"
#import "CBBroadcastOperation.h"
#import "CBBroadcastWaitOperation.h"
#import "CBIfConditionalSequence.h"
#import "CBOperationSequence.h"
#import "LoopBeginBrick.h"
#import "LoopEndBrick.h"
#import "BroadcastBrick.h"
#import "BroadcastWaitBrick.h"

@interface Script()

@property (nonatomic) BOOL restartScript;
@property (nonatomic, readwrite, getter=isRunning) BOOL running;
@property (nonatomic, readwrite) kBrickCategoryType brickCategoryType;
@property (nonatomic, readwrite) kBrickType brickType;
@property (nonatomic, strong) NSArray *sequenceList;

@end

@implementation Script

- (id)init
{
    if (self = [super init]) {
        NSString *subclassName = NSStringFromClass([self class]);
        BrickManager *brickManager = [BrickManager sharedBrickManager];
        self.brickType = [brickManager brickTypeForClassName:subclassName];
        self.brickCategoryType = [brickManager brickCategoryTypeForBrickType:self.brickType];
        self.running = NO;
        self.restartScript = NO;
        self.sequenceList = nil;
    }
    return self;
}

#pragma mark - Custom getter and setter
- (BOOL)isSelectableForObject
{
    return YES;
}

- (NSString*)brickTitle
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in the subclass %@",
                                           NSStringFromSelector(_cmd), NSStringFromClass([self class])]
                                 userInfo:nil];
}

- (NSMutableArray*)actionSequenceList
{
    if (! _actionSequenceList)
        _actionSequenceList = [NSMutableArray array];
    return _actionSequenceList;
}

- (NSArray*)sequenceList
{
    if (! _sequenceList)
        _sequenceList = [NSArray array];
    return _sequenceList;
}

- (NSMutableArray*)brickList
{
    if (! _brickList)
        _brickList = [NSMutableArray array];
    return _brickList;
}

- (void)dealloc
{
    NSDebug(@"Dealloc %@ %@", [self class], self.parent);
}

- (void)computeSequenceList
{
    NSMutableArray *scriptSequenceList = [NSMutableArray array];
    CBOperationSequence *currentOperationSequence = [CBOperationSequence new];
    NSMutableArray *sequenceStack = [NSMutableArray array];
    NSMutableArray *currentSequenceList = scriptSequenceList;

    for (Brick *brick in self.brickList) {
        if ([brick isKindOfClass:[IfLogicBeginBrick class]]) {
            if (! [currentOperationSequence isEmpty]) {
                [currentSequenceList addObject:currentOperationSequence];
            }
            // preserve currentSequenceList and push it to stack
            [sequenceStack addObject:currentSequenceList];
            currentSequenceList = [NSMutableArray array]; // new sequence list for If
            currentOperationSequence = [CBOperationSequence new];
        } else if ([brick isKindOfClass:[IfLogicElseBrick class]]) {
            if (! [currentOperationSequence isEmpty]) {
                [currentSequenceList addObject:currentOperationSequence];
            }
            // preserve currentSequenceList and push it to stack
            [sequenceStack addObject:currentSequenceList];
            currentSequenceList = [NSMutableArray array]; // new sequence list for Else
            currentOperationSequence = [CBOperationSequence new];
        } else if ([brick isKindOfClass:[IfLogicEndBrick class]]) {
            if (! [currentOperationSequence isEmpty]) {
                [currentSequenceList addObject:currentOperationSequence];
            }
            IfLogicEndBrick *endBrick = (IfLogicEndBrick*)brick;
            IfLogicBeginBrick *ifBrick = endBrick.ifBeginBrick;
            IfLogicElseBrick *elseBrick = endBrick.ifElseBrick;
            CBIfConditionalSequence *ifSequence = [CBIfConditionalSequence sequenceWithConditionalBrick:ifBrick];
            if (elseBrick) {
                // currentSequenceList is ElseSequenceList
                ifSequence.elseSequenceList = currentSequenceList;
                // pop IfSequenceList from stack
                currentSequenceList = [sequenceStack lastObject];
                [sequenceStack removeLastObject];
            }
            // now currentSequenceList is IfSequenceList
            ifSequence.sequenceList = currentSequenceList;

            // pop currentSequenceList from stack
            currentSequenceList = [sequenceStack lastObject];
            [sequenceStack removeLastObject];
            [currentSequenceList addObject:ifSequence];
            currentOperationSequence = [CBOperationSequence new];
        } else if ([brick isKindOfClass:[LoopBeginBrick class]]) {
            if (! [currentOperationSequence isEmpty]) {
                [currentSequenceList addObject:currentOperationSequence];
            }
            // preserve currentSequenceList and push it to stack
            [sequenceStack addObject:currentSequenceList];
            currentSequenceList = [NSMutableArray array]; // new sequence list for Loop
            currentOperationSequence = [CBOperationSequence new];
        } else if ([brick isKindOfClass:[LoopEndBrick class]]) {
            if (! [currentOperationSequence isEmpty]) {
                [currentSequenceList addObject:currentOperationSequence];
            }
            // loop end -> fetch currentSequenceList from stack
            CBConditionalSequence *conditionalSequence = [CBConditionalSequence sequenceWithConditionalBrick:((LoopEndBrick*)brick).loopBeginBrick];
            conditionalSequence.sequenceList = currentSequenceList;
            currentSequenceList = [sequenceStack lastObject];
            [sequenceStack removeLastObject];
            [currentSequenceList addObject:conditionalSequence];
            currentOperationSequence = [CBOperationSequence new];
        } else if ([brick isKindOfClass:[BroadcastBrick class]]) {
            [currentOperationSequence addOperation:[CBBroadcastOperation operationWithBroadcastBrick:(BroadcastBrick*)brick]];
        } else if ([brick isKindOfClass:[BroadcastWaitBrick class]]) {
            [currentOperationSequence addOperation:[CBBroadcastWaitOperation operationWithBroadcastWaitBrick:(BroadcastWaitBrick*)brick]];
        } else {
            [currentOperationSequence addOperation:[CBActionOperation operationWithAction:[brick action]]];
        }
    }
    assert(scriptSequenceList == currentSequenceList); // sanity check just to ensure!

    if (! [currentOperationSequence isEmpty]) {
        [currentSequenceList addObject:currentOperationSequence];
    }
    self.sequenceList = (NSArray*)currentSequenceList;
}

#pragma mark - Copy
- (id)mutableCopyWithContext:(CBMutableCopyContext*)context
{
    if(!context) NSError(@"%@ must not be nil!", [CBMutableCopyContext class]);

    Script *copiedScript = [[self class] new];
    copiedScript.brickCategoryType = self.brickCategoryType;
    copiedScript.brickType = self.brickType;
    if (self.action) {
        copiedScript.action = [NSString stringWithString:self.action];
    }

    [context updateReference:self WithReference:copiedScript];

    // deep copy
    copiedScript.brickList = [NSMutableArray arrayWithCapacity:[self.brickList count]];
    for (id brick in self.brickList) {
        if ([brick isKindOfClass:[Brick class]]) {
            // TODO: issue #308 - implement deep copy for all bricks here!!
            Brick *copiedBrick = [brick mutableCopyWithContext:context]; // there are some bricks that refer to other sound, look, sprite objects...
            copiedBrick.script = copiedScript;
            [copiedScript.brickList addObject:copiedBrick];
        }
    }
    if ([self isKindOfClass:[BroadcastScript class]]) {
        ((BroadcastScript*)copiedScript).receivedMessage = ((BroadcastScript*)self).receivedMessage;
    }
    return copiedScript;
}

#pragma mark - Description
- (NSString*)description
{
    NSMutableString *ret = [[NSMutableString alloc] initWithString:NSStringFromClass([self class])];
    [ret appendFormat:@"(%@)", self.object.name];
    if ([self.brickList count] > 0) {
        [ret appendString:@"Bricks: \r"];
        for (Brick *brick in self.brickList) {
            [ret appendFormat:@"%@\r", brick];
        }
    } else {
        [ret appendString:@"Bricks array empty!\r"];
    }
    return ret;
}

#pragma mark - isEqualToScript
- (BOOL)isEqualToScript:(Script *)script
{
    if(self.brickCategoryType != script.brickCategoryType)
        return NO;
    if(self.brickType != script.brickType)
        return NO;
    if(![Util isEqual:self.brickTitle toObject:script.brickTitle])
        return NO;
    if(![Util isEqual:self.action toObject:script.action])
        return NO;
    if(![Util isEqual:self.object.name toObject:script.object.name])
        return NO;

    if([self.brickList count] != [script.brickList count])
        return NO;

    NSUInteger index;
    for(index = 0; index < [self.brickList count]; index++) {
        Brick *firstBrick = [self.brickList objectAtIndex:index];
        Brick *secondBrick = [script.brickList objectAtIndex:index];
        
        if(![firstBrick isEqualToBrick:secondBrick]) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - Script logic
- (void)reset
{
    NSDebug(@"Reset");
    for (Brick *brick in self.brickList) {
        if ([brick isKindOfClass:[LoopBeginBrick class]]) {
            [((LoopBeginBrick*)brick) reset];
        }
    }
}

- (void)restart
{
    self.restartScript = YES;
}

- (void)stop
{
    [self removeAllActions];
    self.restartScript = NO;
}

- (void)startWithCompletion:(dispatch_block_t)completion
{
    NSDebug(@"Starting: %@", NSStringFromClass([self class]));

//    if ([self isKindOfClass:[BroadcastScript class]]) {
//        NSLog(@"Starting BroadcastScript of object %@", self.object.name);
//    }

    [self reset];
    if ([self hasActions]) {
//        NSLog(@"%@ has actions", [self class]);
        [self removeAllActions];
    } else {
        [self runAllActions];
    }

    // only remove from parent if program is still playing, otherwise script will be removed
    // via stopProgram-method in Scene
    if (self.object.program.isPlaying) {
        //    [self.object removeChildrenInArray:@[script]];
        [self removeFromParent];
    }
    if (completion) {
        completion();
    }
}

- (void)runAllActions
{
//    NSString *preservedScriptName = NSStringFromClass([self class]);
//    NSString *preservedObjectName = self.object.name;
//    NSDebug(@"Started %@ in object %@", preservedScriptName, preservedObjectName);

    self.running = YES;

    dispatch_block_t sequenceBlock = [self sequenceBlockForSequenceList:self.sequenceList];
    if (self.object.program.isPlaying && sequenceBlock) {
        sequenceBlock();
    }

//    NSUInteger currentBrickIndex = 0;
//    while (true) {
//        @synchronized(self) {
//            if (self.restartScript) {
//                currentBrickIndex = 0;
//                [self runSequenceAndWait:YES]; // XXX: not sure if we should wait here!!
//                self.restartScript = NO;
//            }
//            if ((! self.object.program.isPlaying) || currentBrickIndex >= [self.brickList count]) {
//                if (! self.object.program.isPlaying) {
//                    NSLog(@"Forced to finish Script: %@", NSStringFromClass([self class]));
//                }
//                break;
//            }
//            Brick *brick = [self.brickList objectAtIndex:currentBrickIndex];
//            currentBrickIndex = [brick runActionWithIndex:currentBrickIndex];
//            ++currentBrickIndex;
//        }
//    }
//    if (self.object.program.isPlaying) {
//        // if we do NOT wait here, the script will be removed from the Scene
//        // before all actions have been executed!
//        [self runSequenceAndWait:YES];
//    }
    self.running = NO;
//    NSDebug(@"Finished %@ in object %@", preservedScriptName, preservedObjectName);
}

- (dispatch_block_t)sequenceBlockForSequenceList:(NSArray*)sequenceList
{
    dispatch_block_t completionBlock = nil;
    for (CBSequence *sequence in [sequenceList reverseObjectEnumerator]) {
        if ([sequence isKindOfClass:[CBOperationSequence class]]) {
            completionBlock = [self sequenceBlockForOperationSequence:(CBOperationSequence*)sequence
                                                 finalCompletionBlock:completionBlock];
        } else if ([sequence isKindOfClass:[CBIfConditionalSequence class]]) {
            // if else sequence
            NSError(@"UNIMPLEMENTED IFCONDITIONALSEQUENCE");
            abort();
        } else if ([sequence isKindOfClass:[CBConditionalSequence class]]) {
            // loop sequence
            CBConditionalSequence *conditionalSequence = (CBConditionalSequence*)sequence;
            completionBlock = [self sequenceBlockForSequenceList:conditionalSequence.sequenceList];
            if (completionBlock == nil) {
                continue;
            }
            completionBlock = ^{
                if ([conditionalSequence checkCondition]) {
                    completionBlock();
                }
            };
        }
    }
    return completionBlock;
}

- (dispatch_block_t)sequenceBlockForOperationSequence:(CBOperationSequence*)operationSequence
                                 finalCompletionBlock:(dispatch_block_t)finalCompletionBlock
{
    NSDate *startTime = [NSDate date];
    if (finalCompletionBlock) {
        finalCompletionBlock = ^{
            NSLog(@"  Duration for Sequence in %@: %fms", [self class], [[NSDate date] timeIntervalSinceDate:startTime]*1000);
            finalCompletionBlock();
        };
    } else {
        finalCompletionBlock = ^{
            NSLog(@"  Duration for Sequence in %@: %fms", [self class], [[NSDate date] timeIntervalSinceDate:startTime]*1000);
        };
    }
    NSUInteger index = 0;
    dispatch_block_t completionBlock = nil;
    NSArray *operationList = operationSequence.operationList;
    __weak Script *weakSelf = self;
    for (CBOperation *operation in [operationList reverseObjectEnumerator]) {
        if ([operation isKindOfClass:[CBActionOperation class]]) {
            CBActionOperation *actionOperation = (CBActionOperation*)operation;
            if (index) {
                completionBlock = ^{
                    NSLog(@"test");
                    [weakSelf runAction:actionOperation.action completion:completionBlock];
                };
            } else {
                completionBlock = ^{
                    NSLog(@"test2");
                    [weakSelf runAction:actionOperation.action completion:finalCompletionBlock];
                };
            }
        } else if ([operation isKindOfClass:[CBBroadcastOperation class]]) {
            // cancel all upcoming actions if BroadcastBrick calls its own script
            BroadcastBrick *broadcastBrick = ((CBBroadcastOperation*)operation).broadcastBrick;
            if ([self isKindOfClass:[BroadcastScript class]]) {
                BroadcastScript *broadcastScript = (BroadcastScript*)self;
                if ([broadcastBrick.broadcastMessage isEqualToString:broadcastScript.receivedMessage]) {
                    completionBlock = ^{ [broadcastBrick performBroadcast]; };
                    break;
                }
            }
            if (index) {
                completionBlock = ^{ NSLog(@"broadcast"); [broadcastBrick performBroadcast]; completionBlock(); };
            } else {
                completionBlock = ^{ NSLog(@"broadcast"); [broadcastBrick performBroadcast]; finalCompletionBlock(); };
            }
        } else if ([operation isKindOfClass:[CBBroadcastWaitOperation class]]) {
            NSError(@"UNIMPLEMENTED BROADCASTWAIT");
            abort();
        } else {
            NSError(@"UNSUPPORTED OPERATION!!");
            abort();
        }
        ++index;
    }
    return completionBlock;
}

- (void)runSequenceAndWait:(BOOL)wait
{
    __weak Script *weakSelf = self;
    if (wait) { self.semaphore = dispatch_semaphore_create(0); }
    NSDate *startTime = [NSDate date];
    dispatch_block_t finalCompletionBlock = ^{
        if (wait) { dispatch_semaphore_signal(weakSelf.semaphore); }
        NSLog(@"  Duration for Sequence in %@: %fms", [self class], [[NSDate date] timeIntervalSinceDate:startTime]*1000);
    };
    NSUInteger index = 0;
    dispatch_block_t completionBlock = nil;
    for (SKAction *action in [self.actionSequenceList reverseObjectEnumerator]) {
        if (! index) {
            completionBlock = ^{[weakSelf runAction:action completion:finalCompletionBlock];};
            ++index;
            continue;
        }
        completionBlock = ^{[weakSelf runAction:action completion:completionBlock];};
        ++index;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.actionSequenceList count] && weakSelf.object.program.isPlaying && completionBlock) {
            completionBlock();
        } else {
            if (wait) { dispatch_semaphore_signal(weakSelf.semaphore); }
        }
    });
    if (wait) { dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER); }
    [self.actionSequenceList removeAllObjects];
}

- (void)removeReferences
{
    [self.brickList makeObjectsPerformSelector:@selector(removeReferences)];
    self.object = nil;
}

//- (void)runNextAction
//{
//    // check if script execution was terminated
//    if (! self.allowRunNextAction) {
//        NSDebug(@"Forced to finish Script: %@", NSStringFromClass([self class]));
//        if (self.completion) {
//            self.completion();
//        }
//        return;
//    }
//
//    // check if script is finished
//    if (self.currentBrickIndex >= [self.brickList count]) {
//        NSDebug(@"Finished Script: %@", NSStringFromClass([self class]));
//        if (self.completion) {
//            self.completion();
//        }
//        return;
//    }
//
//    NSDebug(@"Running Next Action");
//    NSDebug(@"Self Parent: %@", self.parent);
//
//    Brick *currentBrick = [self.brickList objectAtIndex:self.currentBrickIndex];
//    ++self.currentBrickIndex;
//
//    SKAction *action = [self fakeAction];
////    SKAction *action = nil;
//    if ([currentBrick isKindOfClass:[LoopBeginBrick class]]) {
//        BOOL condition = [((LoopBeginBrick*)currentBrick) checkCondition];
//        if (! condition) {
//            LoopEndBrick *loopEndBrick = ((LoopBeginBrick*)currentBrick).loopEndBrick;
//            self.currentBrickIndex = (1 + [self.brickList indexOfObject:loopEndBrick]);
//        }
//    } else if ([currentBrick isKindOfClass:[LoopEndBrick class]]) {
//        LoopBeginBrick *loopBeginBrick = ((LoopEndBrick*)currentBrick).loopBeginBrick;
//        self.currentBrickIndex = [self.brickList indexOfObject:loopBeginBrick];
//        if (self.currentBrickIndex == NSNotFound) {
//            abort();
//        }
//    } else if ([currentBrick isKindOfClass:[BroadcastWaitBrick class]]) {
//        NSDebug(@"broadcast wait");
//        __weak Script *weakSelf = self;
//        __weak BroadcastWaitBrick *weakBroadcastWaitBrick = (BroadcastWaitBrick*)currentBrick;
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//            [weakBroadcastWaitBrick performBroadcastWait];
//            [weakSelf nextAction];
//        });
//        return;
//        //    } else if ([currentBrick isKindOfClass:[BroadcastBrick class]]) {
//        //        NSDebug(@"broadcast");
//        //        __weak Script* weakself = self;
//        ////            NSMutableArray* actionArray = [[NSMutableArray alloc] init];
//        //            SKAction *action = [currentBrick action];
//        ////            [actionArray addObject:action];
//        ////            SKAction *sequence = [SKAction sequence:actionArray];
//        ////            if (! action || ! actionArray || ! sequence) {
//        ////                abort();
//        ////            }
//        //            [self runAction:action];
//        //            [weakself runNextAction];
//    } else if ([currentBrick isKindOfClass:[IfLogicBeginBrick class]]) {
//        BOOL condition = [((IfLogicBeginBrick*)currentBrick) checkCondition];
//        if (! condition) {
//            self.currentBrickIndex = (1 + [self.brickList indexOfObject:((IfLogicBeginBrick*)currentBrick).ifElseBrick]);
//        }
//        if (self.currentBrickIndex == NSIntegerMin) {
//            NSError(@"The XML-Structure is wrong, please fix the project");
//        }
//    } else if ([currentBrick isKindOfClass:[IfLogicElseBrick class]]) {
//        self.currentBrickIndex = (1 + [self.brickList indexOfObject:((IfLogicElseBrick*)currentBrick).ifEndBrick]);
//        if (self.currentBrickIndex == NSIntegerMin) {
//            NSError(@"The XML-Structure is wrong, please fix the project");
//        }
//    } else if ([currentBrick isKindOfClass:[IfLogicEndBrick class]]) {
//        IfLogicBeginBrick *ifBeginBrick = ((IfLogicEndBrick*)currentBrick).ifBeginBrick;
//        if ([self.brickList indexOfObject:ifBeginBrick] == NSNotFound) {
//            abort();
//        }
//    } else if ([currentBrick isKindOfClass:[NoteBrick class]]) {
//        // nothing to do!
//    } else {
//        action = [currentBrick action];
//    }
//
//    __weak Script *weakSelf = self;
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if (action && self.allowRunNextAction) {
//            [weakSelf runAction:action completion:^{
//                NSDebug(@"Finished: %@", action);
//                [weakSelf nextAction];
//            }];
//        } else {
//            [weakSelf runNextAction];
//            return;
//        }
//    });
//}
//
//- (void)nextAction
//{
//    // Needs to be async because of recursion!
//    __weak Script* weakSelf = self;
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [weakSelf runNextAction];
//    });
//}

@end
