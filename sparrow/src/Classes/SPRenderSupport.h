//
//  SPRenderSupport.h
//  Sparrow
//
//  Created by Daniel Sperl on 28.09.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>

#import "SPMatrix.h"

@class SPTexture;
@class SPDisplayObject;
@class SPQuad;

/** ------------------------------------------------------------------------------------------------

 A class that contains helper methods simplifying OpenGL rendering.
 
 An SPRenderSupport instance is passed to any render: method. It saves information about the
 current render state, like the alpha value, modelview matrix, and blend mode.
 
 It also keeps a list of quad batches, which can be used to render a high number of quads
 very efficiently; only changes in the state of added quads trigger OpenGL draw calls.
 
 Furthermore, several static helper methods can be used for different needs whenever some
 OpenGL processing is required.
 
------------------------------------------------------------------------------------------------- */

@interface SPRenderSupport : NSObject

/// -------------
/// @name Methods
/// -------------

/// Resets the render state stack to the default.
- (void)nextFrame;

/// Adds a quad or image to the current batch of unrendered quads. If there is a state change,
/// all previous quads are rendered at once, and the batch is reset. Note that the values for
/// alpha and blend mode are taken from the current render state, not the quad.
- (void)batchQuad:(SPQuad *)quad;

/// Renders the current quad batch and resets it.
- (void)finishQuadBatch;

/// Clears all vertex and index buffers, releasing the associated memory. Useful in low-memory
/// situations. Don't call from within a render method!
- (void)purgeBuffers;

/// Clears OpenGL's color buffer.
+ (void)clearWithColor:(uint)color alpha:(float)alpha;

/// Checks for an OpenGL error. If there is one, it is logged an the error code is returned.
+ (uint)checkForOpenGLError;

/// Raises the number of draw calls by a specific value. Call this method in custom render methods
/// to keep the statistics display in sync.
- (void)addDrawCalls:(int)count;

/// Sets up the projection matrix for ortographic 2D rendering.
- (void)setupOrthographicProjectionWithLeft:(float)left right:(float)right
                                        top:(float)top bottom:(float)bottom;

/// -------------------------
/// @name State Manipulation
/// -------------------------

/// Adds a new render state to the stack. The passed matrix is prepended to the modelview matrix;
/// the alpha value is multiplied with the current alpha; the blend mode replaces the existing
/// mode (except `BLEND_MODE_AUTO`, which will cause the current mode to prevail).
- (void)pushStateWithMatrix:(SPMatrix *)matrix alpha:(float)alpha blendMode:(uint)blendMode;

/// Restores the previous render state.
- (void)popState;

/// ----------------
/// @name Properties
/// ----------------

/// Calculates the product of modelview and projection matrix.
/// CAUTION: Use with care! Each call returns the same instance.
@property (nonatomic, readonly) SPMatrix *mvpMatrix;

/// Returns the current modelview matrix.
/// CAUTION: Use with care! Returns not a copy, but the internally used instance.
@property (nonatomic, readonly) SPMatrix *modelviewMatrix;

/// Returns the current projection matrix.
/// CAUTION: Use with care! Each call returns the same instance.
@property (nonatomic, readonly) SPMatrix *projectionMatrix;

/// Returns the current (accumulated) alpha value.
@property (nonatomic, readonly) float alpha;

/// Returns the current blend mode.
@property (nonatomic, readonly) uint blendMode;

/// Indicates the number of OpenGL ES draw calls since the last call to `nextFrame`.
@property (nonatomic, readonly) int numDrawCalls;

@end
