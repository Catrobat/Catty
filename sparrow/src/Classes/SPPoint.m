//
//  SPPoint.m
//  Sparrow
//
//  Created by Daniel Sperl on 23.03.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPPoint.h"
#import "SPMacros.h"
#import <math.h>

// --- class implementation ------------------------------------------------------------------------

#define SQ(x) ((x)*(x))

@implementation SPPoint
{
    float _x;
    float _y;
}

@synthesize x = _x;
@synthesize y = _y;

// designated initializer
- (id)initWithX:(float)x y:(float)y
{
    if ((self = [super init]))
    {
        _x = x;
        _y = y;        
    }
    return self;
}

- (id)initWithPolarLength:(float)length angle:(float)angle
{
    return [self initWithX:cosf(angle)*length y:sinf(angle)*length];
}

- (id)init
{
    return [self initWithX:0.0f y:0.0f];
}

- (float)length
{
    return sqrtf(SQ(_x) + SQ(_y));
}

- (float)lengthSquared 
{
    return SQ(_x) + SQ(_y);
}

- (float)angle
{
    return atan2f(_y, _x);
}

- (BOOL)isOrigin
{
    return _x == 0.0f && _y == 0.0f;
}

- (SPPoint *)invert
{
    return [[SPPoint alloc] initWithX:-_x y:-_y];
}

- (SPPoint*)addPoint:(SPPoint*)point
{
    return [[SPPoint alloc] initWithX:_x+point->_x y:_y+point->_y];
}

- (SPPoint*)subtractPoint:(SPPoint*)point
{
    return [[SPPoint alloc] initWithX:_x-point->_x y:_y-point->_y];
}

- (SPPoint *)scaleBy:(float)scalar
{
    return [[SPPoint alloc] initWithX:_x * scalar y:_y * scalar];
}

- (SPPoint *)rotateBy:(float)angle  
{
    float sina = sinf(angle);
    float cosa = cosf(angle);
    return [[SPPoint alloc] initWithX:(_x * cosa) - (_y * sina) y:(_x * sina) + (_y * cosa)];
}

- (SPPoint *)normalize
{
    if (_x == 0 && _y == 0)
        [NSException raise:SP_EXC_INVALID_OPERATION format:@"Cannot normalize point in the origin"];
        
    float inverseLength = 1.0f / self.length;
    return [[SPPoint alloc] initWithX:_x * inverseLength y:_y * inverseLength];
}

- (float)dot:(SPPoint *)other
{
    return _x * other->_x + _y * other->_y;
}

- (void)copyFromPoint:(SPPoint *)point
{
    _x = point->_x;
    _y = point->_y;
}

- (void)setX:(float)x y:(float)y
{
    _x = x;
    _y = y;
}

- (GLKVector2)convertToGLKVector
{
    return GLKVector2Make(_x, _y);
}

- (BOOL)isEquivalent:(SPPoint *)other
{
    if (other == self) return YES;
    else if (!other) return NO;
    else
    {
        SPPoint *point = (SPPoint*)other;
        return SP_IS_FLOAT_EQUAL(_x, point->_x) && SP_IS_FLOAT_EQUAL(_y, point->_y);    
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"[SPPoint: x=%f, y=%f]", _x, _y];
}

+ (float)distanceFromPoint:(SPPoint*)p1 toPoint:(SPPoint*)p2
{
    return sqrtf(SQ(p2->_x - p1->_x) + SQ(p2->_y - p1->_y));
}

+ (SPPoint *)interpolateFromPoint:(SPPoint *)p1 toPoint:(SPPoint *)p2 ratio:(float)ratio
{
    float invRatio = 1.0f - ratio;
    return [SPPoint pointWithX:invRatio * p1->_x + ratio * p2->_x
                             y:invRatio * p1->_y + ratio * p2->_y];
}

+ (float)angleBetweenPoint:(SPPoint *)p1 andPoint:(SPPoint *)p2
{
    float cos = [p1 dot:p2] / (p1.length * p2.length);
    return cos >= 1.0f ? 0.0f : acosf(cos);
}

+ (id)pointWithPolarLength:(float)length angle:(float)angle
{
    return [[self alloc] initWithPolarLength:length angle:angle];
}

+ (id)pointWithX:(float)x y:(float)y
{
    return [[self alloc] initWithX:x y:y];
}

+ (id)point
{
    return [[self alloc] init];
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone*)zone
{
    return [[[self class] allocWithZone:zone] initWithX:_x y:_y];
}

#pragma mark SPPoolObject

SP_IMPLEMENT_MEMORY_POOL();

@end
