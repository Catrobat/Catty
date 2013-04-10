//
//  SPStage.h
//  Sparrow
//
//  Created by Daniel Sperl on 15.03.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import "SPDisplayObjectContainer.h"
#import "SPMacros.h"

@class SPTouchProcessor;
@class SPJuggler;

/** ------------------------------------------------------------------------------------------------

 An SPStage is the root of the display tree. It represents the rendering area of the application.
 
 Sparrow will create the stage for you. The root object of your game will be the first child of
 the stage. You can access `root` and `stage` from any display object using the respective 
 properties. 
 
 The stage's `width` and `height` values define the coordinate system of your game. The color
 of the stage defines the background color of your game.
 
------------------------------------------------------------------------------------------------- */

@interface SPStage : SPDisplayObjectContainer

/// --------------------
/// @name Initialization
/// --------------------

/// Initializes a stage with a certain size in points.
- (id)initWithWidth:(float)width height:(float)height;

/// ----------------
/// @name Properties
/// ----------------

/// The background color of the stage. Default: black.
@property (nonatomic, assign) uint color;

/// The height of the stage's coordinate system.
@property (nonatomic, assign) float width;

/// The width of the stage's coordinate system.
@property (nonatomic, assign) float height;

@end
