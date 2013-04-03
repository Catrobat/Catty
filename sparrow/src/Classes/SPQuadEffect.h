//
//  SPBaseEffect.h
//  Sparrow
//
//  Created by Daniel Sperl on 12.03.13.
//  Copyright 2013 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>

@class SPMatrix;
@class SPTexture;

@interface SPQuadEffect : NSObject

- (void)prepareToDraw;

@property (nonatomic, copy) SPMatrix *mvpMatrix;
@property (nonatomic, strong) SPTexture *texture;
@property (nonatomic, assign) BOOL premultipliedAlpha;
@property (nonatomic, assign) BOOL useTinting;
@property (nonatomic, assign) float alpha;

@property (nonatomic, readonly) int attribPosition;
@property (nonatomic, readonly) int attribTexCoords;
@property (nonatomic, readonly) int attribColor;

@end
