//
//  SPResizeEvent.m
//  Sparrow
//
//  Created by Daniel Sperl on 01.10.2012.
//  Copyright 2012 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPResizeEvent.h"

@implementation SPResizeEvent
{
    float _width;
    float _height;
    double _animationTime;
}

@synthesize width = _width;
@synthesize height = _height;
@synthesize animationTime = _animationTime;

- (id)initWithType:(NSString *)type width:(float)width height:(float)height 
     animationTime:(double)time
{
    if ((self = [super initWithType:type bubbles:NO]))
    {
        _width = width;
        _height = height;
        _animationTime = time;
    }
    return self;
}

- (id)initWithType:(NSString *)type width:(float)width height:(float)height
{
    return [self initWithType:type width:width height:height animationTime:0.0];
}

- (id)initWithType:(NSString*)type bubbles:(BOOL)bubbles
{
    return [self initWithType:type width:320 height:480 animationTime:0.5];
}

- (BOOL)isPortrait
{
    return _height > _width;
}

@end
