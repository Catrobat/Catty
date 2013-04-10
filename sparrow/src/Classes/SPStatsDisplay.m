//
//  SPStatsDisplay.m
//  Sparrow
//
//  Created by Daniel Sperl on 27.03.13.
//  Copyright 2013 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPStatsDisplay.h"
#import "SPEnterFrameEvent.h"
#import "SPBitmapFont.h"
#import "SPTextField.h"
#import "SPQuad.h"
#import "SPBlendMode.h"

@implementation SPStatsDisplay
{
    SPTextField *_textField;
    int _framesPerSecond;
    int _numDrawCalls;
    
    double _totalTime;
    int _frameCount;
}

- (id)init
{
    if ((self = [super init]))
    {
        SPQuad *background = [[SPQuad alloc] initWithWidth:45 height:17 color:0x0];
        [self addChild:background];
        
        _framesPerSecond = 0;
        _numDrawCalls = 0;

        self.blendMode = SP_BLEND_MODE_NONE;
        
        [self addEventListener:@selector(onAddedToStage:) atObject:self
                       forType:SP_EVENT_TYPE_ADDED_TO_STAGE];
        [self addEventListener:@selector(onEnterFrame:) atObject:self
                       forType:SP_EVENT_TYPE_ENTER_FRAME];
    }
    return self;
}

- (void)onAddedToStage:(SPEvent *)event
{
    _framesPerSecond = _numDrawCalls = 0;
    [self update];
}

- (void)onEnterFrame:(SPEnterFrameEvent *)event
{
    _totalTime += event.passedTime;
    _frameCount++;
    
    if (_totalTime > 1.0)
    {
        _framesPerSecond = roundf(_frameCount / _totalTime);
        _frameCount = _totalTime = 0;
        [self update];
    }
}

- (void)update
{
    if (!_textField)
    {
        _textField = [[SPTextField alloc] initWithWidth:48 height:17 text:@""
            fontName:SP_BITMAP_FONT_MINI fontSize:SP_NATIVE_FONT_SIZE color:SP_WHITE];
        _textField.hAlign = SPHAlignLeft;
        _textField.vAlign = SPVAlignTop;
        _textField.x = 2;
        [self addChild:_textField];
    }
    
    _textField.text = [NSString stringWithFormat:@"FPS: %d\nDRW: %d",
                       _framesPerSecond, _numDrawCalls];
}

@end
