//
//  SPDelayedInvocation.h
//  Sparrow
//
//  Created by Daniel Sperl on 11.07.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import "SPAnimatable.h"
#import "SPEventDispatcher.h"
#import "SPMacros.h"

/** ------------------------------------------------------------------------------------------------
 
 An SPDelayedInvocation can be used to execute code at some time in the future.
 
 It can work in two ways: first, as a proxy object that will forward any method invocations
 to a certain target. Second, it can simply execute an Objective-C block. Either way, the
 provided code is executed with a given delay.
 
 The easiest way to delay an invocation is by calling [SPJuggler delayInvocationAtTarget:byTime:].
 This method will create a delayed invocation for you, adding it to the juggler right away.
 
 SPDelayedCall dispatches an Event of type `SP_EVENT_TYPE_REMOVE_FROM_JUGGLER` when it is finished,
 so that the juggler automatically removes it when it's no longer needed.
 
------------------------------------------------------------------------------------------------- */


@interface SPDelayedInvocation : SPEventDispatcher <SPAnimatable>

/// ------------------
/// @name Initializers
/// ------------------

/// Initializes a delayed invocation using both a target and a block. The instance will act as a
/// proxy object, forwarding method calls to the target after a certain time has passed; the block
/// will be invoked at the same time. _Designated Initializer_.
- (id)initWithTarget:(id)target delay:(double)time block:(SPCallbackBlock)block;

/// Initializes a delayed invocation by acting as a proxy object forwarding method calls to the
/// target after a certain time has passed.
- (id)initWithTarget:(id)target delay:(double)time;

/// Initializes the delayed invocation of a block.
- (id)initWithDelay:(double)time block:(SPCallbackBlock)block;

/// Factory method.
+ (id)invocationWithTarget:(id)target delay:(double)time;

/// Factory method.
+ (id)invocationWithDelay:(double)time block:(SPCallbackBlock)block;

/// ----------------
/// @name Properties
/// ----------------

/// The target object to which messages will be forwarded.
@property (nonatomic, readonly) id target;

/// The time messages will be delayed (in seconds).
@property (nonatomic, readonly) double totalTime;

/// The time that has already passed (in seconds).
@property (nonatomic, assign)   double currentTime;

/// Indicates if the total time has passed and the invocations have been executed.
@property (nonatomic, readonly) BOOL isComplete;

@end
