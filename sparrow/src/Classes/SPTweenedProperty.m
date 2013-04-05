//
//  SPTweenedProperty.m
//  Sparrow
//
//  Created by Daniel Sperl on 17.10.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPTweenedProperty.h"
#import "SPMacros.h"

typedef float  (*FnPtrGetterF)  (id, SEL);
typedef double (*FnPtrGetterD)  (id, SEL);
typedef int    (*FnPtrGetterI)  (id, SEL);
typedef uint   (*FnPtrGetterUI) (id, SEL);

typedef void (*FnPtrSetterF)  (id, SEL, float);
typedef void (*FnPtrSetterD)  (id, SEL, double);
typedef void (*FnPtrSetterI)  (id, SEL, int);
typedef void (*FnPtrSetterUI) (id, SEL, uint);

@implementation SPTweenedProperty
{
    id  _target;
    
    SEL _getter;
    IMP _getterFunc;
    SEL _setter;
    IMP _setterFunc;
    
    float _startValue;
    float _endValue;
    char  _numericType;
}

@synthesize startValue = _startValue;
@synthesize endValue = _endValue;

- (id)initWithTarget:(id)target name:(NSString *)name endValue:(float)endValue
{
    if ((self = [super init]))
    {
        _target = target;        
        _endValue = endValue;
        
        _getter = NSSelectorFromString(name);
        _setter = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", 
                                        [[name substringToIndex:1] uppercaseString], 
                                        [name substringFromIndex:1]]);
        
        if (![_target respondsToSelector:_getter] || ![_target respondsToSelector:_setter])
            [NSException raise:SP_EXC_INVALID_OPERATION format:@"property not found or readonly: '%@'", 
             name];    
        
        // query argument type
        NSMethodSignature *sig = [_target methodSignatureForSelector:_getter];
        _numericType = *[sig methodReturnType];    
        if (_numericType != 'f' && _numericType != 'i' && _numericType != 'd' && _numericType != 'I')
            [NSException raise:SP_EXC_INVALID_OPERATION format:@"property not numeric: '%@'", name];
        
        _getterFunc = [_target methodForSelector:_getter];
        _setterFunc = [_target methodForSelector:_setter];       
    }
    return self;
}

- (id)init
{
    return [self initWithTarget:nil name:nil endValue:0.0f];
}

- (void)setCurrentValue:(float)value
{
    if (_numericType == 'f')
    {
        FnPtrSetterF func = (FnPtrSetterF)_setterFunc;
        func(_target, _setter, value);
    }        
    else if (_numericType == 'd')
    {
        FnPtrSetterD func = (FnPtrSetterD)_setterFunc;
        func(_target, _setter, (double)value);
    }
    else if (_numericType == 'I')
    {
        FnPtrSetterUI func = (FnPtrSetterUI)_setterFunc;
        func(_target, _setter, (double)value);
    }
    else
    {
        FnPtrSetterI func = (FnPtrSetterI)_setterFunc;
        func(_target, _setter, (int)(value > 0 ? value+0.5f : value-0.5f));
    }        
}

- (float)currentValue
{
    if (_numericType == 'f')
    {
        FnPtrGetterF func = (FnPtrGetterF)_getterFunc;
        return func(_target, _getter);
    }
    else if (_numericType == 'd')
    {
        FnPtrGetterD func = (FnPtrGetterD)_getterFunc;
        return func(_target, _getter);
    }
    else if (_numericType == 'I')
    {
        FnPtrGetterUI func = (FnPtrGetterUI)_getterFunc;
        return func(_target, _getter);
    }
    else 
    {
        FnPtrGetterI func = (FnPtrGetterI)_getterFunc;
        return func(_target, _getter);
    }
}

- (float)delta
{
    return _endValue - _startValue;
}

@end
