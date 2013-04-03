//
//  SPJuggler.m
//  Sparrow
//
//  Created by Daniel Sperl on 09.05.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPJuggler.h"
#import "SPAnimatable.h"
#import "SPDelayedInvocation.h"
#import "SPEventDispatcher.h"

@implementation SPJuggler
{
    NSMutableArray *_objects;
    double _elapsedTime;
}

@synthesize elapsedTime = _elapsedTime;

- (id)init
{    
    if ((self = [super init]))
    {        
        _objects = [[NSMutableArray alloc] init];
        _elapsedTime = 0.0;
    }
    return self;
}

- (void)advanceTime:(double)seconds
{
    _elapsedTime += seconds;
    
    // we need work with a copy, since user-code could modify the collection during the enumeration
    for (id<SPAnimatable> object in [NSArray arrayWithArray:_objects])
        [object advanceTime:seconds];
}

- (void)addObject:(id<SPAnimatable>)object
{
    if (object && ![_objects containsObject:object])
    {
        [_objects addObject:object];
        
        if ([(id)object isKindOfClass:[SPEventDispatcher class]])
            [(SPEventDispatcher *)object addEventListener:@selector(onRemove:) atObject:self
                                                  forType:SP_EVENT_TYPE_REMOVE_FROM_JUGGLER];
    }
}

- (void)onRemove:(SPEvent *)event
{
    [self removeObject:(id<SPAnimatable>)event.target];
}

- (void)removeObject:(id<SPAnimatable>)object
{
    [_objects removeObject:object];
    
    if ([(id)object isKindOfClass:[SPEventDispatcher class]])
        [(SPEventDispatcher *)object removeEventListenersAtObject:self
                                     forType:SP_EVENT_TYPE_REMOVE_FROM_JUGGLER];
}

- (void)removeAllObjects
{
    for (id object in _objects)
    {
        if ([(id)object isKindOfClass:[SPEventDispatcher class]])
            [(SPEventDispatcher *)object removeEventListenersAtObject:self
                                         forType:SP_EVENT_TYPE_REMOVE_FROM_JUGGLER];
    }
    
    [_objects removeAllObjects];
}

- (void)removeObjectsWithTarget:(id)object
{
    SEL targetSel = @selector(target);
    NSMutableArray *remainingObjects = [[NSMutableArray alloc] init];
    
    for (id currentObject in _objects)
    {
        if (![currentObject respondsToSelector:targetSel] || ![[currentObject target] isEqual:object])
            [remainingObjects addObject:currentObject];
        else if ([(id)currentObject isKindOfClass:[SPEventDispatcher class]])
            [(SPEventDispatcher *)currentObject removeEventListenersAtObject:self
                                                forType:SP_EVENT_TYPE_REMOVE_FROM_JUGGLER];
    }
    
    _objects = remainingObjects;
}

- (BOOL)containsObject:(id<SPAnimatable>)object
{
    return [_objects containsObject:object];
}

- (id)delayInvocationAtTarget:(id)target byTime:(double)time
{
    SPDelayedInvocation *delayedInv = [SPDelayedInvocation invocationWithTarget:target delay:time];
    [self addObject:delayedInv];
    return delayedInv;    
}

- (id)delayInvocationByTime:(double)time block:(SPCallbackBlock)block
{
    SPDelayedInvocation *delayedInv = [SPDelayedInvocation invocationWithDelay:time block:block];
    [self addObject:delayedInv];
    return delayedInv;
}

+ (SPJuggler *)juggler
{
    return [[SPJuggler alloc] init];
}

@end
