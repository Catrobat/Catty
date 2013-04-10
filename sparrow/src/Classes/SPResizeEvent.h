//
//  SPResizeEvent.h
//  Sparrow
//
//  Created by Daniel Sperl on 01.10.2012.
//  Copyright 2012 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPEvent.h"

#define SP_EVENT_TYPE_RESIZE @"resize"

/** ------------------------------------------------------------------------------------------------
 
 An SPResizeEvent is triggered when the size of the GLKView object that Sparrow renders into is
 changed. The most probably reason for this to happen is when the device orientation changes.
 Every display object that is connected to the stage receives this event.
 
------------------------------------------------------------------------------------------------- */

@interface SPResizeEvent : SPEvent

/// ------------------
/// @name Initializers
/// ------------------

/// Initializes a resize event with the given parameters. _Designated Initializer_.
- (id)initWithType:(NSString *)type width:(float)width height:(float)height 
     animationTime:(double)time;

/// Initializes a resize event with the given parameters. Animation time will be zero.
- (id)initWithType:(NSString *)type width:(float)width height:(float)height;

/// ----------------
/// @name Properties
/// ----------------

/// The new width of the stage (in points).
@property (nonatomic, readonly) float width;

/// The new height of the stage (in points).
@property (nonatomic, readonly) float height;

/// If the event was triggered by a change of the device orientation, indicates the duration of the
/// pending rotation, measured in seconds.
@property (nonatomic, readonly) double animationTime;

/// Indicates if the new size is portrait or landscape.
@property (nonatomic, readonly) BOOL isPortrait;

@end
