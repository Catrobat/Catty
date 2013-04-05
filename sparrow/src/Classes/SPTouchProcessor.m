//
//  SPTouchProcessor.m
//  Sparrow
//
//  Created by Daniel Sperl on 03.05.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPTouchProcessor.h"
#import "SPMacros.h"
#import "SPTouchEvent.h"
#import "SPTouch.h"
#import "SPTouch_Internal.h"
#import "SPPoint.h"
#import "SPMatrix.h"
#import "SPDisplayObjectContainer.h"

#import <UIKit/UIKit.h>

#define MULTITAP_TIME 0.25f
#define MULTITAP_DIST 25

@implementation SPTouchProcessor
{
    SPDisplayObjectContainer *__weak _root;
    NSMutableSet *_currentTouches;
}

@synthesize root = _root;

- (id)initWithRoot:(SPDisplayObjectContainer*)root
{
    if ((self = [super init]))
    {
        _root = root;
        _currentTouches = [[NSMutableSet alloc] initWithCapacity:2];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelCurrentTouches:)
                                              name:UIApplicationWillResignActiveNotification object:nil];
    }
    return self;
}

- (id)init
{    
    return [self initWithRoot:nil];
}

- (void)processTouches:(NSSet*)touches
{
    NSMutableSet *processedTouches = [[NSMutableSet alloc] init];
    
    // process new touches
    for (SPTouch *touch in touches)
    {
        SPTouch *currentTouch = nil;
        
        for (SPTouch *existingTouch in _currentTouches)
        {
            if (existingTouch.phase == SPTouchPhaseEnded || existingTouch.phase == SPTouchPhaseCancelled)
                continue;
            
            if ((existingTouch.globalX == touch.previousGlobalX &&
                 existingTouch.globalY == touch.previousGlobalY) ||
                (existingTouch.globalX == touch.globalX &&
                 existingTouch.globalY == touch.globalY))
            {
                // existing touch; update values
                existingTouch.timestamp = touch.timestamp;
                existingTouch.previousGlobalX = touch.previousGlobalX;
                existingTouch.previousGlobalY = touch.previousGlobalY;
                existingTouch.globalX = touch.globalX;
                existingTouch.globalY = touch.globalY;
                existingTouch.phase = touch.phase;
                existingTouch.tapCount = touch.tapCount;
                
                if (!existingTouch.target.stage)
                {
                    // target could have been removed from stage -> find new target in that case
                    SPPoint *touchPosition = [SPPoint pointWithX:touch.globalX y:touch.globalY];
                    existingTouch.target = [_root hitTestPoint:touchPosition];       
                }
                
                currentTouch = existingTouch;
                break;
            }
        }
        
        if (!currentTouch)
        {
            // new touch!
            currentTouch = [SPTouch touch];
            currentTouch.timestamp = touch.timestamp;
            currentTouch.globalX = touch.globalX;
            currentTouch.globalY = touch.globalY;
            currentTouch.previousGlobalX = touch.previousGlobalX;
            currentTouch.previousGlobalY = touch.previousGlobalY;
            currentTouch.phase = touch.phase;
            currentTouch.tapCount = touch.tapCount;
            SPPoint *touchPosition = [SPPoint pointWithX:touch.globalX y:touch.globalY];
            currentTouch.target = [_root hitTestPoint:touchPosition];
        }
        
        [processedTouches addObject:currentTouch];
    }
    
    // dispatch events         
    for (SPTouch *touch in processedTouches)
    {       
        SPTouchEvent *touchEvent = [[SPTouchEvent alloc] initWithType:SP_EVENT_TYPE_TOUCH 
                                                              touches:processedTouches];
        [touch.target dispatchEvent:touchEvent];
    }
    
    _currentTouches = processedTouches;
}

- (void)cancelCurrentTouches:(NSNotification *)notification
{
    double now = CACurrentMediaTime();
    
    for (SPTouch *touch in _currentTouches)
    {
        touch.phase = SPTouchPhaseCancelled;
        touch.timestamp = now;
    }

    for (SPTouch *touch in _currentTouches)
        [touch.target dispatchEvent:[SPTouchEvent eventWithType:SP_EVENT_TYPE_TOUCH touches:_currentTouches]];

    [_currentTouches removeAllObjects];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
