//
//  SPSubTexture.m
//  Sparrow
//
//  Created by Daniel Sperl on 27.06.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPSubTexture.h"
#import "SPVertexData.h"
#import "SPRectangle.h"
#import "SPMacros.h"

@implementation SPSubTexture
{
    SPTexture *_baseTexture;
    SPRectangle *_clipping;
    SPRectangle *_rootClipping;
    SPRectangle *_frame;
}

@synthesize baseTexture = _baseTexture;
@synthesize clipping = _clipping;
@synthesize frame = _frame;

- (id)initWithRegion:(SPRectangle*)region ofTexture:(SPTexture*)texture
{
    return [self initWithRegion:region frame:nil ofTexture:texture];
}

- (id)initWithRegion:(SPRectangle *)region frame:(SPRectangle *)frame ofTexture:(SPTexture *)texture
{
    if ((self = [super init]))
    {
        _baseTexture = texture;
        _frame = [frame copy];
        
        // convert region to clipping rectangle (which has values between 0 and 1)
        if (region)
            self.clipping = [SPRectangle rectangleWithX:region.x/texture.width
                                                      y:region.y/texture.height
                                                  width:region.width/texture.width
                                                 height:region.height/texture.height];
        else
            self.clipping = [SPRectangle rectangleWithX:0.0f y:0.0f width:1.0f height:1.0f];
    }
    return self;
}

- (id)init
{
    return nil;
}

- (void)setClipping:(SPRectangle *)clipping
{
    // private method! Only called via the constructor - thus we don't need to create a copy.
    _clipping = clipping;
    
    // if the base texture is a sub texture as well, calculate clipping 
    // in reference to the root texture         
    _rootClipping = [_clipping copy];
    SPTexture *baseTexture = _baseTexture;
    while ([baseTexture isKindOfClass:[SPSubTexture class]])
    {
        SPSubTexture *baseSubTexture = (SPSubTexture *)baseTexture;
        SPRectangle *baseClipping = baseSubTexture->_clipping;
        
        _rootClipping.x = baseClipping.x + _rootClipping.x * baseClipping.width;
        _rootClipping.y = baseClipping.y + _rootClipping.y * baseClipping.height;
        _rootClipping.width *= baseClipping.width;
        _rootClipping.height *= baseClipping.height;
        
        baseTexture = baseSubTexture.baseTexture;
    } 
}

- (void)adjustVertexData:(SPVertexData *)vertexData atIndex:(int)index numVertices:(int)count
{
    if (_frame)
    {
        if (count != 4)
            [NSException raise:SP_EXC_INVALID_OPERATION
                        format:@"Textures with a frame can only be used on quads"];
        
        float deltaRight  = _frame.width  + _frame.x - self.width;
        float deltaBottom = _frame.height + _frame.y - self.height;
        
        vertexData.vertices[index].position.x -= _frame.x;
        vertexData.vertices[index].position.y -= _frame.y;
        
        vertexData.vertices[index+1].position.x -= deltaRight;
        vertexData.vertices[index+1].position.y -= _frame.y;

        vertexData.vertices[index+2].position.x -= _frame.x;
        vertexData.vertices[index+2].position.y -= deltaBottom;
        
        vertexData.vertices[index+3].position.x -= deltaRight;
        vertexData.vertices[index+3].position.y -= deltaBottom;
    }
    
    float clipX = _rootClipping.x;
    float clipY = _rootClipping.y;
    float clipWidth = _rootClipping.width;
    float clipHeight = _rootClipping.height;
    
    for (int i=index; i<index+count; ++i)
    {
        GLKVector2 texCoords = vertexData.vertices[i].texCoords;
        vertexData.vertices[i].texCoords.x = clipX + texCoords.x * clipWidth;
        vertexData.vertices[i].texCoords.y = clipY + texCoords.y * clipHeight;
    }
}

- (float)width
{
    return _baseTexture.width * _clipping.width;
}

- (float)height
{
    return _baseTexture.height * _clipping.height;
}

- (uint)name
{
    return _baseTexture.name;
}

- (void)setRepeat:(BOOL)value
{
    _baseTexture.repeat = value;
}

- (BOOL)repeat
{
    return _baseTexture.repeat;
}

- (SPTextureSmoothing)smoothing
{    
    return _baseTexture.smoothing;
}

- (void)setSmoothing:(SPTextureSmoothing)value
{
    _baseTexture.smoothing = value;
}

- (BOOL)premultipliedAlpha
{
    return _baseTexture.premultipliedAlpha;
}

- (float)scale
{
    return _baseTexture.scale;
}

+ (id)textureWithRegion:(SPRectangle*)region ofTexture:(SPTexture*)texture
{
    return [[self alloc] initWithRegion:region ofTexture:texture];
}

@end
