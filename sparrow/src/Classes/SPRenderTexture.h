//
//  SPRenderTexture.h
//  Sparrow
//
//  Created by Daniel Sperl on 04.12.10.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>

#import "SPDisplayObject.h"
#import "SPSubTexture.h"
#import "SPRenderSupport.h"

typedef void (^SPDrawingBlock)();

/** ------------------------------------------------------------------------------------------------
 
 An SPRenderTexture is a dynamic texture on which you can draw any display object.
 
 After creating a render texture, just call the `drawObject:` method to render an object directly 
 onto the texture. The object will be drawn onto the texture at its current position, adhering 
 its current rotation, scale and alpha properties. 
 
 Drawing is done very efficiently, as it is happening directly in graphics memory. After you have 
 drawn objects on the texture, the performance will be just like that of a normal texture - no
 matter how many objects you have drawn.
 
 If you draw lots of objects at once, it is recommended to bundle the drawing calls in a block
 via the `drawBundled:` method, like shown below. That will speed it up immensely, allowing
 you to draw hundreds of objects very quickly.
 
	[renderTexture drawBundled:^
	 {
	     for (int i=0; i<numDrawings; ++i)
	     {
	        image.rotation = (2 * PI / numDrawings) * i;
	        [renderTexture drawObject:image];            
	     }             
	 }];

------------------------------------------------------------------------------------------------- */

@interface SPRenderTexture : SPSubTexture

/// ------------------
/// @name Initializers
/// ------------------

/// Initializes a transparent render texture with the scale factor of the stage.
- (id)initWithWidth:(float)width height:(float)height;

/// Initializes a render texture with a certain ARGB color (0xAARRGGBB).
- (id)initWithWidth:(float)width height:(float)height fillColor:(uint)argb;

/// Initializes a render texture with a certain ARGB color (0xAARRGGBB) and a scale factor.
- (id)initWithWidth:(float)width height:(float)height fillColor:(uint)argb scale:(float)scale;

/// Factory method.
+ (id)textureWithWidth:(float)width height:(float)height;

/// Factory method.
+ (id)textureWithWidth:(float)width height:(float)height fillColor:(uint)argb;

/// -------------
/// @name Methods
/// -------------

/// Draws an object onto the texture, adhering its properties for position, scale, rotation and alpha.
- (void)drawObject:(SPDisplayObject *)object;

/// Bundles several calls to `drawObject:` together in a block. This avoids framebuffer switches.
- (void)drawBundled:(SPDrawingBlock)block;

/// Clears the texture with a certain color and alpha value.
- (void)clearWithColor:(uint)color alpha:(float)alpha;

@end
