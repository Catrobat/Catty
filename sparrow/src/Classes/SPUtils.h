//
//  SPUtils.h
//  Sparrow
//
//  Created by Daniel Sperl on 04.01.11.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIDevice.h>

/// The SPUtils class contains utility methods for different purposes.

@interface SPUtils : NSObject 

/// ----------------
/// @name Math Utils
/// ----------------

/// Finds the next power of two equal to or above the specified number.
+ (int)nextPowerOfTwo:(int)number;

/// Checks if a number is a power of two.
+ (BOOL)isPowerOfTwo:(int)number;

/// Returns a random integer number between `minValue` (inclusive) and `maxValue` (exclusive).
+ (int)randomIntBetweenMin:(int)minValue andMax:(int)maxValue;

/// Returns a random float number between 0.0 and 1.0
+ (float)randomFloat;

/// ----------------
/// @name File Utils
/// ----------------

/// Returns a Boolean value that indicates whether a file or directory exists at a specified path.
/// If you pass a relative path, the resource folder of the application bundle will be searched.
+ (BOOL)fileExistsAtPath:(NSString *)path;

/// Finds the full path for a file, favoring those with the given scale factor and
/// device idiom. Relative paths are searched in the application bundle. If no suitable file can
/// be found, the method returns nil.
+ (NSString *)absolutePathToFile:(NSString *)path withScaleFactor:(float)factor
                           idiom:(UIUserInterfaceIdiom)idiom;

/// Finds the full path for a file, favoring those with the given scale factor and the current
/// device idiom. Relative paths are searched in the application bundle. If no suitable file can
/// be found, the method returns nil.
+ (NSString *)absolutePathToFile:(NSString *)path withScaleFactor:(float)factor;

/// Finds the full path for a file, favoring those with the current content scale factor and
/// device idiom. Relative paths are searched in the application bundle. If no suitable file can
/// be found, the method returns nil.
+ (NSString *)absolutePathToFile:(NSString *)path;

@end
