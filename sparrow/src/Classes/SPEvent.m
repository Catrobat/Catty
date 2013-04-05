//
//  SPEvent.m
//  Sparrow
//
//  Created by Daniel Sperl on 27.04.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPEventDispatcher.h"
#import "SPEvent.h"
#import "SPEvent_Internal.h"

@implementation SPEvent
{
    SPEventDispatcher *__weak _target;
    SPEventDispatcher *__weak _currentTarget;
    NSString *_type;
    BOOL _stopsImmediatePropagation;
    BOOL _stopsPropagation;
    BOOL _bubbles;
}

@synthesize target = _target;
@synthesize currentTarget = _currentTarget;
@synthesize type = _type;
@synthesize bubbles = _bubbles;

- (id)initWithType:(NSString*)type bubbles:(BOOL)bubbles
{    
    if ((self = [super init]))
    {        
        _type = [[NSString alloc] initWithString:type];
        _bubbles = bubbles;
    }
    return self;
}

- (id)initWithType:(NSString*)type
{
    return [self initWithType:type bubbles:NO];
}

- (id)init
{
    return [self initWithType:@"undefined"];
}

- (void)stopImmediatePropagation
{
    _stopsImmediatePropagation = YES;
}

- (void)stopPropagation
{
    _stopsPropagation = YES;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"[%@: type=\"%@\", bubbles=%@]",
            NSStringFromClass([self class]), _type, _bubbles ? @"YES" : @"NO"];
}

+ (id)eventWithType:(NSString*)type bubbles:(BOOL)bubbles
{
    return [[self alloc] initWithType:type bubbles:bubbles];
}

+ (id)eventWithType:(NSString*)type
{
    return [[self alloc] initWithType:type];
}


@end

// -------------------------------------------------------------------------------------------------

@implementation SPEvent (Internal)

- (BOOL)stopsImmediatePropagation
{ 
    return _stopsImmediatePropagation;
}

- (BOOL)stopsPropagation
{ 
    return _stopsPropagation;
}

- (void)setTarget:(SPEventDispatcher*)target
{
    if (_target != target)
        _target = target;
}

- (void)setCurrentTarget:(SPEventDispatcher*)currentTarget
{
    if (_currentTarget != currentTarget)
        _currentTarget = currentTarget;
}

@end
