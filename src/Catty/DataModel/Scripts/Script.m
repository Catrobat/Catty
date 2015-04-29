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
#import "CBOperation.h"
#import "CBIfConditionalSequence.h"
#import "CBOperationSequence.h"
#import "LoopBeginBrick.h"
#import "LoopEndBrick.h"
#import "BroadcastBrick.h"
#import "BroadcastWaitBrick.h"
#import "NoteBrick.h"
#import "CBStack.h"
#import "NSString+CatrobatNSStringExtensions.h"

@interface Script()

@property (nonatomic, readwrite, getter=isRunning) BOOL running;
@property (nonatomic, readwrite) kBrickCategoryType brickCategoryType;
@property (nonatomic, readwrite) kBrickType brickType;
@property (nonatomic, strong) NSArray *sequenceList;

@property (nonatomic, copy) dispatch_block_t abortScriptExecutionCompletion;
@property (nonatomic, copy) dispatch_block_t fullScriptSequence;
@property (nonatomic, strong) NSMutableDictionary *whileSequences;

@end

@implementation Script

+ (Script*)scriptWithType:(kBrickType)type andCategory:(kBrickCategoryType)category
{
    return [[[self class] alloc] initWithType:type andCategory:category]; 
}

- (instancetype)initWithType:(kBrickType)type andCategory:(kBrickCategoryType)category
{
    self = [super init];
    if (self) {
        self.brickType = type;
        self.brickCategoryType = category;
    }
    return self;
}

- (id)init
{
    if (self = [super init]) {
        NSString *subclassName = NSStringFromClass([self class]);
        BrickManager *brickManager = [BrickManager sharedBrickManager];
        self.brickType = [brickManager brickTypeForClassName:subclassName];
        self.brickCategoryType = [brickManager brickCategoryTypeForBrickType:self.brickType];
        self.running = NO;
        self.abortScriptExecutionCompletion = nil;
        self.sequenceList = nil;
    }
    return self;
}

#pragma mark - Getters and Setters
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

- (NSArray*)sequenceList
{
    if (! _sequenceList) {
        _sequenceList = [NSArray array];
    }
    return _sequenceList;
}

- (NSMutableArray*)brickList
{
    if (! _brickList) {
        _brickList = [NSMutableArray array];
    }
    return _brickList;
}

- (NSMutableDictionary*)whileSequences
{
    if (! _whileSequences) {
        _whileSequences = [NSMutableDictionary new];
    }
    return _whileSequences;
}

- (void)dealloc
{
    NSDebug(@"Dealloc %@ %@", [self class], self.parent);
}

- (BOOL)scriptExecutionHasBeenAborted
{
    return (self.abortScriptExecutionCompletion != nil);
}

- (void)abortScriptExecutionWithCompletion:(dispatch_block_t)completion
{
    self.abortScriptExecutionCompletion = completion;
}

- (void)computeSequenceList
{
    NSMutableArray *scriptSequenceList = [NSMutableArray array];
    CBOperationSequence *currentOperationSequence = [CBOperationSequence new];
    CBStack *sequenceStack = [CBStack new];
    NSMutableArray *currentSequenceList = scriptSequenceList;

    for (Brick *brick in self.brickList) {
        if ([brick isKindOfClass:[IfLogicBeginBrick class]]) {
            if (! [currentOperationSequence isEmpty]) {
                [currentSequenceList addObject:currentOperationSequence];
            }
            // preserve currentSequenceList and push it to stack
            [sequenceStack pushElement:currentSequenceList];
            currentSequenceList = [NSMutableArray array]; // new sequence list for If
            currentOperationSequence = [CBOperationSequence new];
        } else if ([brick isKindOfClass:[IfLogicElseBrick class]]) {
            if (! [currentOperationSequence isEmpty]) {
                [currentSequenceList addObject:currentOperationSequence];
            }
            // preserve currentSequenceList and push it to stack
            [sequenceStack pushElement:currentSequenceList];
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
                currentSequenceList = [sequenceStack popElement];
            }
            // now currentSequenceList is IfSequenceList
            ifSequence.sequenceList = currentSequenceList;

            // pop currentSequenceList from stack
            currentSequenceList = [sequenceStack popElement];
            [currentSequenceList addObject:ifSequence];
            currentOperationSequence = [CBOperationSequence new];
        } else if ([brick isKindOfClass:[LoopBeginBrick class]]) {
            if (! [currentOperationSequence isEmpty]) {
                [currentSequenceList addObject:currentOperationSequence];
            }
            // preserve currentSequenceList and push it to stack
            [sequenceStack pushElement:currentSequenceList];
            currentSequenceList = [NSMutableArray array]; // new sequence list for Loop
            currentOperationSequence = [CBOperationSequence new];
        } else if ([brick isKindOfClass:[LoopEndBrick class]]) {
            if (! [currentOperationSequence isEmpty]) {
                [currentSequenceList addObject:currentOperationSequence];
            }
            // loop end -> fetch currentSequenceList from stack
            CBConditionalSequence *conditionalSequence = [CBConditionalSequence sequenceWithConditionalBrick:((LoopEndBrick*)brick).loopBeginBrick];
            conditionalSequence.sequenceList = currentSequenceList;
            currentSequenceList = [sequenceStack popElement];
            [currentSequenceList addObject:conditionalSequence];
            currentOperationSequence = [CBOperationSequence new];
        } else if ([brick isKindOfClass:[NoteBrick class]]) {
            // ignore NoteBricks!
        } else {
            [currentOperationSequence addOperation:[CBOperation operationForBrick:brick]];
        }
    }
    assert(scriptSequenceList == currentSequenceList); // sanity check just to ensure!

    if (! [currentOperationSequence isEmpty]) {
        [currentSequenceList addObject:currentOperationSequence];
    }
    self.sequenceList = (NSArray*)currentSequenceList;
    [self prepareAllActions];
}

#pragma mark - Copy
- (id)mutableCopyWithContext:(CBMutableCopyContext*)context
{
    if (! context) NSError(@"%@ must not be nil!", [CBMutableCopyContext class]);

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
    if (self.brickCategoryType != script.brickCategoryType)
        return NO;
    if (self.brickType != script.brickType)
        return NO;
    if (! [Util isEqual:self.brickTitle toObject:script.brickTitle])
        return NO;
    if (! [Util isEqual:self.action toObject:script.action])
        return NO;
    if (! [Util isEqual:self.object.name toObject:script.object.name])
        return NO;

    if ([self.brickList count] != [script.brickList count])
        return NO;

    NSUInteger index;
    for (index = 0; index < [self.brickList count]; ++index) {
        Brick *firstBrick = [self.brickList objectAtIndex:index];
        Brick *secondBrick = [script.brickList objectAtIndex:index];

        if (! [firstBrick isEqualToBrick:secondBrick]) {
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

- (void)start
{
    assert(self.object.program.isPlaying); // ensure that program is playing!
    assert(! self.isRunning); // ensure that script is NOT already running!
    NSLog(@"Starting: %@ of object %@", [self class], [self.object class]);

    if (! [self inParentHierarchy:self.object]) {
        NSLog(@" + Adding this node to object");
        [self.object addChild:self];
    }

    [self reset]; // just to ensure
    if ([self hasActions]) {
        [self removeAllActions];
    }
    [self runAllActions];
}

- (void)selfBroadcastRestart
{
    assert(self.object.program.isPlaying); // ensure that program is playing!
    assert(self.isRunning); // ensure that script is already running!
    assert([self isKindOfClass:[BroadcastScript class]]);
    [self reset];
    [self runAllActions];
}

- (void)restart
{
    assert(self.object.program.isPlaying); // ensure that program is playing!
    assert(self.isRunning); // ensure that script is already running!
    __weak Script *weakSelf = self;
    self.abortScriptExecutionCompletion = ^{
        NSLog(@"!! ABORT DETECTED !! => Restarting [%@] now!", [weakSelf class]);
        if ([weakSelf isKindOfClass:[BroadcastScript class]]) {
            NSLog(@"Starting BroadcastScript of object %@", weakSelf.object.name);
        }

        [weakSelf reset];
        if ([weakSelf hasActions]) {
            [weakSelf removeAllActions];
        }
        weakSelf.abortScriptExecutionCompletion = nil; // reset before starting script again!
        [weakSelf runAllActions];
    };
}

- (void)stop
{
    assert(self.object.program.isPlaying); // ensure that program is playing!
    assert(self.isRunning); // ensure that script is already running!
    __weak Script *weakSelf = self;
    self.abortScriptExecutionCompletion = ^{
        NSLog(@"!! ABORT DETECTED !! => Stopping [%@] now!", [weakSelf class]);
        if ([weakSelf isKindOfClass:[BroadcastScript class]]) {
            NSLog(@"Starting BroadcastScript of object %@", weakSelf.object.name);
        }

        [weakSelf reset];
        if ([weakSelf hasActions]) {
            [weakSelf removeAllActions];
        }
        weakSelf.abortScriptExecutionCompletion = nil; // reset before starting script again!
        weakSelf.running = NO;
        if ([weakSelf inParentHierarchy:weakSelf.object]) {
            [weakSelf removeFromParent];
        }
        NSLog(@"%@ stopped!", [weakSelf class]);
    };
}

- (void)prepareAllActions
{
//    NSString *preservedScriptName = NSStringFromClass([self class]);
//    NSString *preservedObjectName = self.object.name;
//    NSDebug(@"Started %@ in object %@", preservedScriptName, preservedObjectName);
    __weak Script *weakSelf = self;
    dispatch_block_t scriptEndCompletion = ^{
        @synchronized(weakSelf) {
            if ([weakSelf isKindOfClass:[BroadcastScript class]]) {
                // TODO: avoid concurrency conflicts between BroadcastBricks and BroadcastWaitBricks!!!
                BroadcastScript *broadcastScript = (BroadcastScript*)weakSelf;
                if (broadcastScript.isCalledByOtherScriptBroadcastWait) {
                    [broadcastScript signalForWaitingBroadcasts]; // signal finished broadcast!
                }
            }
            dispatch_block_t abortScriptExecutionCompletion = weakSelf.abortScriptExecutionCompletion;
            if (abortScriptExecutionCompletion != nil) {
                // resets abort flag and aborts script execution here
                abortScriptExecutionCompletion();
                weakSelf.abortScriptExecutionCompletion = nil;
                NSLog(@"%@ aborted while finishing!", [weakSelf class]);
                return;
            }
            weakSelf.running = NO;
            if ([weakSelf inParentHierarchy:weakSelf.object]) {
                [weakSelf removeFromParent];
            }
            NSLog(@"%@ finished!", [weakSelf class]);
        }
        
    };
    dispatch_block_t sequenceBlock = [self sequenceBlockForSequenceList:self.sequenceList
                                                   finalCompletionBlock:scriptEndCompletion];
    self.fullScriptSequence = sequenceBlock;
}

- (void)runAllActions
{
    assert(self.fullScriptSequence != nil); // ensure that fullScriptSequence already exists
    assert(self.object.program.isPlaying); // ensure that program is playing!
    self.running = YES;
    self.fullScriptSequence();
}

- (dispatch_block_t)sequenceBlockForSequenceList:(NSArray*)sequenceList
                            finalCompletionBlock:(dispatch_block_t)finalCompletionBlock
{
    assert(finalCompletionBlock != nil); // required parameter must NOT be nil!!
    __weak Script *weakSelf = self;
    dispatch_block_t completionBlock = finalCompletionBlock;
    for (CBSequence *sequence in [sequenceList reverseObjectEnumerator]) {
        if ([sequence isKindOfClass:[CBOperationSequence class]]) {
            completionBlock = [self sequenceBlockForOperationSequence:(CBOperationSequence*)sequence
                                                 finalCompletionBlock:completionBlock];
        } else if ([sequence isKindOfClass:[CBIfConditionalSequence class]]) {
            // if else sequence
            CBIfConditionalSequence *ifSequence = (CBIfConditionalSequence*)sequence;
            completionBlock = ^{
                if ([ifSequence checkCondition]) {
                    [weakSelf sequenceBlockForSequenceList:ifSequence.sequenceList
                                      finalCompletionBlock:completionBlock]();
                } else {
                    [weakSelf sequenceBlockForSequenceList:ifSequence.elseSequenceList
                                      finalCompletionBlock:completionBlock]();
                }
            };
        } else if ([sequence isKindOfClass:[CBConditionalSequence class]]) {
            // loop sequence
            completionBlock = [self repeatingSequenceBlockForConditionalSequence:(CBConditionalSequence*)sequence
                                                            finalCompletionBlock:completionBlock];
        }
    }
    assert(completionBlock != nil); // this method must NEVER return nil!!
    return completionBlock;
}

- (dispatch_block_t)repeatingSequenceBlockForConditionalSequence:(CBConditionalSequence*)conditionalSequence
                                            finalCompletionBlock:(dispatch_block_t)finalCompletionBlock
{
    assert(finalCompletionBlock != nil); // required parameter must NOT be nil!!
    __weak Script *weakSelf = self;
    NSString *localUniqueIdentifier = [NSString localUniqueIdenfier];
    dispatch_block_t completionBlock = ^{
        if ([conditionalSequence checkCondition]) {
            NSDate *startTime = [NSDate date];
            dispatch_block_t loopEndCompletionBlock = ^{
                // high priority queue only needed for blocking purposes...
                // the reason for this is that you should NEVER block the (serial) main_queue!!
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    NSTimeInterval duration = [[NSDate date] timeIntervalSinceDate:startTime];
                    //NSLog(@"  Duration for Sequence: %fms", [[NSDate date] timeIntervalSinceDate:startTime]*1000);
                    if (duration < 0.02f) {
                        [NSThread sleepForTimeInterval:(0.02f-duration)];
                    }
                    // now switch back to the main queue for executing the sequence!
                    dispatch_async(dispatch_get_main_queue(), ^{
                        dispatch_block_t whileSequence = weakSelf.whileSequences[localUniqueIdentifier];
                        if (whileSequence) {
                            whileSequence();
                        }
                    });
                });
            };
            [weakSelf sequenceBlockForSequenceList:conditionalSequence.sequenceList
                              finalCompletionBlock:loopEndCompletionBlock]();
        } else {
            finalCompletionBlock();
        }
    };
    self.whileSequences[localUniqueIdentifier] = completionBlock;
    assert(completionBlock != nil); // this method must NEVER return nil!!
    return completionBlock;
}

- (dispatch_block_t)sequenceBlockForOperationSequence:(CBOperationSequence*)operationSequence
                                 finalCompletionBlock:(dispatch_block_t)finalCompletionBlock
{
    assert(finalCompletionBlock != nil); // required parameter must NOT be nil!!
#ifdef DEBUG
    NSDate *startTime = [NSDate date];
#endif
    __weak Script *weakSelf = self;
    if (finalCompletionBlock) {
        finalCompletionBlock = ^{
            NSDebug(@"  Duration for Sequence in %@: %fms", [weakSelf class], [[NSDate date] timeIntervalSinceDate:startTime]*1000);
            finalCompletionBlock();
        };
    } else {
        finalCompletionBlock = ^{
            NSDebug(@"  Duration for Sequence in %@: %fms", [weakSelf class], [[NSDate date] timeIntervalSinceDate:startTime]*1000);
        };
    }
    dispatch_block_t completionBlock = finalCompletionBlock;
    NSArray *operationList = operationSequence.operationList;
    for (CBOperation *operation in [operationList reverseObjectEnumerator]) {
        if ([operation.brick isKindOfClass:[BroadcastBrick class]]) {
            // cancel all upcoming actions if BroadcastBrick calls its own script
            BroadcastBrick *broadcastBrick = (BroadcastBrick*)operation.brick;
            if ([self isKindOfClass:[BroadcastScript class]]) {
                BroadcastScript *broadcastScript = (BroadcastScript*)self;
                if ([broadcastBrick.broadcastMessage isEqualToString:broadcastScript.receivedMessage]) {
                    // DO NOT call completionBlock here so that upcoming actions are ignored!
                    completionBlock = ^{
                        // end of script reached!! Scripts will be aborted due to self-calling broadcast
                        if (broadcastScript.isCalledByOtherScriptBroadcastWait) {
                            [broadcastScript signalForWaitingBroadcasts]; // signal finished broadcast!
                        }
                        NSDebug(@"BroadcastScript ended due to self broadcast!");
                        [broadcastBrick performBroadcast]; // finally perform broadcast
                    };
                    continue;
                }
            }
            completionBlock = ^{
                [broadcastBrick performBroadcast];
                completionBlock(); // the script must continue here. upcoming actions are executed!!
            };
        } else if ([operation.brick isKindOfClass:[BroadcastWaitBrick class]]) {
            // cancel all upcoming actions if BroadcastWaitBrick calls its own script
            BroadcastWaitBrick *broadcastWaitBrick = (BroadcastWaitBrick*)operation.brick;
            if ([self isKindOfClass:[BroadcastScript class]]) {
                BroadcastScript *broadcastScript = (BroadcastScript*)self;
                if ([broadcastWaitBrick.broadcastMessage isEqualToString:broadcastScript.receivedMessage]) {
                    // DO NOT call completionBlock here so that upcoming actions are ignored!
                    completionBlock = ^{
                        // end of script reached!! Scripts will be aborted due to self-calling broadcast
                        if (broadcastScript.isCalledByOtherScriptBroadcastWait) {
                            [broadcastScript signalForWaitingBroadcasts]; // signal finished broadcast!
                        }
                        NSDebug(@"BroadcastScript ended due to self broadcastWait!");
                        // finally perform normal (!) broadcast
                        // no waiting required, since there all upcoming actions in the sequence are omitted!
                        [broadcastWaitBrick performBroadcastButDontWait];
                    };
                    continue;
                }
            }
            completionBlock = ^{
                [broadcastWaitBrick performBroadcastAndWaitWithCompletion:completionBlock];
            };
        } else if (operation.brick) {
            completionBlock = ^{
                NSDebug(@"[%@] %@ action", [weakSelf class], [operation.brick class]);
                dispatch_block_t abortScriptExecutionCompletion = weakSelf.abortScriptExecutionCompletion;
                if (abortScriptExecutionCompletion != nil) {
                    // resets abort flag and aborts script execution here
                    abortScriptExecutionCompletion();
                    weakSelf.abortScriptExecutionCompletion = nil;
                    NSLog(@"%@ aborted!", [weakSelf class]);
                    return;
                }
                [weakSelf runAction:operation.brick.action completion:completionBlock];
            };
        } else {
            NSError(@"NO BRICK GIVEN!!");
            abort();
        }
    }
    assert(completionBlock != nil); // this method must NEVER return nil!!
    return completionBlock;
}

- (void)removeReferences
{
    // DO NOT CHANGE ORDER HERE!
    self.sequenceList = nil;
    self.abortScriptExecutionCompletion = nil;
    self.fullScriptSequence = nil;
    self.whileSequences = nil;
    [self.brickList makeObjectsPerformSelector:@selector(removeReferences)];
    self.object = nil;
}

@end
