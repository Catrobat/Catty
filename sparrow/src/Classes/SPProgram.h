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

@interface SPProgram : NSObject

- (id)initWithVertexShader:(NSString *)vertexShader fragmentShader:(NSString *)fragmentShader;

- (int)uniformByName:(NSString *)name;
- (int)attributeByName:(NSString *)name;

@property (nonatomic, readonly) uint name;
@property (nonatomic, readonly) NSString *vertexShader;
@property (nonatomic, readonly) NSString *fragmentShader;

@end
