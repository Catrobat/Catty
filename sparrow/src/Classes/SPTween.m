//
//  SPTween.m
//  Sparrow
//
//  Created by Daniel Sperl on 09.05.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPTween.h"
#import "SPTransitions.h"
#import "SPTweenedProperty.h"

#define TRANS_SUFFIX  @":"

typedef float (*FnPtrTransition) (id, SEL, float);

@implementation SPTween
{
    id _target;
    SEL _transition;
    IMP _transitionFunc;
    NSMutableArray *_properties;
    
    double _totalTime;
    double _currentTime;
    double _delay;
    
    int _repeatCount;
    double _repeatDelay;
    BOOL _reverse;
    int _currentCycle;
    
    SPCallbackBlock _onStart;
    SPCallbackBlock _onUpdate;
    SPCallbackBlock _onRepeat;
    SPCallbackBlock _onComplete;
}

@synthesize totalTime = _totalTime;
@synthesize currentTime = _currentTime;
@synthesize delay = _delay;
@synthesize target = _target;
@synthesize repeatCount = _repeatCount;
@synthesize repeatDelay = _repeatDelay;
@synthesize reverse = _reverse;
@synthesize onStart = _onStart;
@synthesize onUpdate = _onUpdate;
@synthesize onRepeat = _onRepeat;
@synthesize onComplete = _onComplete;

- (id)initWithTarget:(id)target time:(double)time transition:(NSString*)transition
{
    if ((self = [super init]))
    {
        _target = target;
        _totalTime = MAX(0.0001, time); // zero is not allowed
        _currentTime = 0;
        _delay = 0;
        _properties = [[NSMutableArray alloc] init];
        _repeatCount = 1;
        _currentCycle = -1;
        _reverse = NO;

        // create function pointer for transition
        NSString *transMethod = [transition stringByAppendingString:TRANS_SUFFIX];
        _transition = NSSelectorFromString(transMethod);    
        if (![SPTransitions respondsToSelector:_transition])
            [NSException raise:SP_EXC_INVALID_OPERATION 
                        format:@"transition not found: '%@'", transition];
        _transitionFunc = [SPTransitions methodForSelector:_transition];
    }
    return self;
}

- (id)initWithTarget:(id)target time:(double)time
{
    return [self initWithTarget:target time:time transition:SP_TRANSITION_LINEAR];
}

- (void)animateProperty:(NSString*)property targetValue:(float)value
{    
    if (!_target) return; // tweening nil just does nothing.
    
    SPTweenedProperty *tweenedProp = [[SPTweenedProperty alloc] 
        initWithTarget:_target name:property endValue:value];
    [_properties addObject:tweenedProp];
}

- (void)moveToX:(float)x y:(float)y
{
    [self animateProperty:@"x" targetValue:x];
    [self animateProperty:@"y" targetValue:y];
}

- (void)scaleTo:(float)scale
{
    [self animateProperty:@"scaleX" targetValue:scale];
    [self animateProperty:@"scaleY" targetValue:scale];
}

- (void)fadeTo:(float)alpha
{
    [self animateProperty:@"alpha" targetValue:alpha];
}

- (void)advanceTime:(double)time
{
    if (time == 0.0 || (_repeatCount == 1 && _currentTime == _totalTime))
        return; // nothing to do
    else if ((_repeatCount == 0 || _repeatCount > 1) && _currentTime == _totalTime)
        _currentTime = 0.0;
    
    double previousTime = _currentTime;
    double restTime = _totalTime - _currentTime;
    double carryOverTime = time > restTime ? time - restTime : 0.0;    
    _currentTime = MIN(_totalTime, _currentTime + time);
    BOOL isStarting = _currentCycle < 0 && previousTime <= 0 && _currentTime > 0;

    if (_currentTime <= 0) return; // the delay is not over yet

    if (isStarting)
    {
        _currentCycle++;
        if (_onStart) _onStart();
    }
    
    float ratio = _currentTime / _totalTime;
    BOOL reversed = _reverse && (_currentCycle % 2 == 1);
    FnPtrTransition transFunc = (FnPtrTransition) _transitionFunc;
    Class transClass = [SPTransitions class];
    
    for (SPTweenedProperty *prop in _properties)
    {
        if (isStarting) prop.startValue = prop.currentValue;
        float transitionValue = reversed ? transFunc(transClass, _transition, 1.0 - ratio) :
                                           transFunc(transClass, _transition, ratio);
        prop.currentValue = prop.startValue + prop.delta * transitionValue;
    }
    
    if (_onUpdate) _onUpdate();
    
    if (previousTime < _totalTime && _currentTime >= _totalTime)
    {
        if (_repeatCount == 0 || _repeatCount > 1)
        {
            _currentTime = -_repeatDelay;
            _currentCycle++;
            if (_repeatCount > 1) _repeatCount--;
            if (_onRepeat) _onRepeat();
        }
        else
        {
            [self dispatchEventWithType:SP_EVENT_TYPE_REMOVE_FROM_JUGGLER];
            if (_onComplete) _onComplete();
        }
    }
    
    if (carryOverTime)
        [self advanceTime:carryOverTime];
}

- (NSString*)transition
{
    NSString *selectorName = NSStringFromSelector(_transition);
    return [selectorName substringToIndex:selectorName.length - [TRANS_SUFFIX length]];
}

- (BOOL)isComplete
{
    return _currentTime >= _totalTime && _repeatCount == 1;
}

- (void)setDelay:(double)delay
{
    _currentTime = _currentTime + _delay - delay;
    _delay = delay;
}

+ (id)tweenWithTarget:(id)target time:(double)time transition:(NSString*)transition
{
    return [[self alloc] initWithTarget:target time:time transition:transition];
}

+ (id)tweenWithTarget:(id)target time:(double)time
{
    return [[self alloc] initWithTarget:target time:time];
}

@end
