//
//  SPSparrow.h
//  Sparrow
//
//  Created by Daniel Sperl on 27.01.13.
//  Copyright 2013 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import "SPViewController.h"
#import "SPJuggler.h"

/** ------------------------------------------------------------------------------------------------
 
 The Sparrow class provides static convenience methods to access certain properties of the current
 SPViewController.
 
------------------------------------------------------------------------------------------------- */

@interface Sparrow : NSObject

/// The currently active SPViewController.
+ (SPViewController *)currentController;

/// A juggler that is advanced once per frame by the current view controller.
+ (SPJuggler *)juggler;

/// The stage that is managed by the current view controller.
+ (SPStage *)stage;

/// The root object of your game, i.e. an instance of the class you passed to the 'startWithRoot:'
/// method of SPViewController.
+ (SPDisplayObject *)root;

/// The content scale factor of the current view controller.
+ (float)contentScaleFactor;

@end
