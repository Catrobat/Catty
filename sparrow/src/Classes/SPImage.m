//
//  SPImage.m
//  Sparrow
//
//  Created by Daniel Sperl on 19.06.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPImage.h"
#import "SPPoint.h"
#import "SPTexture.h"
#import "SPGLTexture.h"
#import "SPRenderSupport.h"
#import "SPMacros.h"
#import "SPVertexData.h"

@implementation SPImage
{
    SPVertexData *_vertexDataCache;
    BOOL _vertexDataCacheInvalid;
}

@synthesize texture = _texture;

- (id)initWithTexture:(SPTexture*)texture
{
    if (!texture) [NSException raise:SP_EXC_INVALID_OPERATION format:@"texture cannot be nil!"];
    
    SPRectangle *frame = texture.frame;    
    float width  = frame ? frame.width  : texture.width;
    float height = frame ? frame.height : texture.height;
    BOOL pma = texture.premultipliedAlpha;
    
    if ((self = [super initWithWidth:width height:height color:SP_WHITE premultipliedAlpha:pma]))
    {
        _vertexData.vertices[1].texCoords.x = 1.0f;
        _vertexData.vertices[2].texCoords.y = 1.0f;
        _vertexData.vertices[3].texCoords.x = 1.0f;
        _vertexData.vertices[3].texCoords.y = 1.0f;
        
        _texture = texture;
        _vertexDataCache = [[SPVertexData alloc] initWithSize:4 premultipliedAlpha:pma];
        _vertexDataCacheInvalid = YES;
    }
    return self;
}

- (id)initWithContentsOfFile:(NSString *)path generateMipmaps:(BOOL)mipmaps
{
    return [self initWithTexture:[SPTexture textureWithContentsOfFile:path generateMipmaps:mipmaps]];
}

- (id)initWithContentsOfFile:(NSString*)path
{
    return [self initWithContentsOfFile:path generateMipmaps:NO];
}

- (id)initWithWidth:(float)width height:(float)height
{
    return [self initWithTexture:[SPTexture textureWithWidth:width height:height draw:NULL]];
}

- (void)setTexCoords:(SPPoint*)coords ofVertex:(int)vertexID
{
    [_vertexData setTexCoords:coords atIndex:vertexID];
    [self vertexDataDidChange];
}

- (void)setTexCoordsWithX:(float)x y:(float)y ofVertex:(int)vertexID
{
    [_vertexData setTexCoordsWithX:x y:y atIndex:vertexID];
    [self vertexDataDidChange];
}

- (SPPoint*)texCoordsOfVertex:(int)vertexID
{
    return [_vertexData texCoordsAtIndex:vertexID];
}

- (void)readjustSize
{
    SPRectangle *frame = _texture.frame;    
    float width  = frame ? frame.width  : _texture.width;
    float height = frame ? frame.height : _texture.height;

    _vertexData.vertices[1].position.x = width;
    _vertexData.vertices[2].position.y = height;
    _vertexData.vertices[3].position.x = width;
    _vertexData.vertices[3].position.y = height;
    
    [self vertexDataDidChange];
}

- (void)vertexDataDidChange
{
    _vertexDataCacheInvalid = YES;
}

- (void)copyVertexDataTo:(SPVertexData *)targetData atIndex:(int)targetIndex
{
    if (_vertexDataCacheInvalid)
    {
        _vertexDataCacheInvalid = NO;
        [_vertexData copyToVertexData:_vertexDataCache];
        [_texture adjustVertexData:_vertexDataCache atIndex:0 numVertices:4];
    }
    
    [_vertexDataCache copyToVertexData:targetData atIndex:targetIndex numVertices:4];
}

- (void)setTexture:(SPTexture *)value
{
    if (value == nil)
    {
        [NSException raise:SP_EXC_INVALID_OPERATION format:@"texture cannot be nil!"];
    }
    else if (value != _texture)
    {
        _texture = value;
        [_vertexData setPremultipliedAlpha:_texture.premultipliedAlpha updateVertices:YES];
        [_vertexDataCache setPremultipliedAlpha:_texture.premultipliedAlpha updateVertices:NO];
        [self vertexDataDidChange];
    }
}

+ (id)imageWithTexture:(SPTexture*)texture
{
    return [[self alloc] initWithTexture:texture];
}

+ (id)imageWithContentsOfFile:(NSString*)path
{
    return [[self alloc] initWithContentsOfFile:path];
}

@end