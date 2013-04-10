//
//  SPProgram.h
//  Sparrow
//
//  Created by Daniel Sperl on 14.03.13.
//  Copyright 2013 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>

/** ------------------------------------------------------------------------------------------------
 
 An SPProgram wraps a GLSL program (containing the source code for both vertex and fragment shader)
 into an object.
 
 Use the `uniformByName:` and `attributeByName:` properties to query the index of the respective
 variables.
 
------------------------------------------------------------------------------------------------- */

@interface SPProgram : NSObject

/// ------------------
/// @name Initializers
/// ------------------

/// Initializes a GLSL program by compiling vertex and fragment shaders from source. In debug
/// mode, compilation erros are logged into the console. _Designated Initializer_.
- (id)initWithVertexShader:(NSString *)vertexShader fragmentShader:(NSString *)fragmentShader;

/// -------------
/// @name Methods
/// -------------

/// Returns the index of a uniform with a certain name.
- (int)uniformByName:(NSString *)name;

/// Returns the index of an attribute with a certain name.
- (int)attributeByName:(NSString *)name;

/// ----------------
/// @name Properties
/// ----------------

/// The handle of the program object needed.
@property (nonatomic, readonly) uint name;

/// The source code of the vertex shader.
@property (nonatomic, readonly) NSString *vertexShader;

/// The source code of the fragment shader.
@property (nonatomic, readonly) NSString *fragmentShader;

@end
