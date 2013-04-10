//
//  SPVertexData.m
//  Sparrow
//
//  Created by Daniel Sperl on 18.02.13.
//  Copyright 2013 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPVertexData.h"
#import "SPMatrix.h"
#import "SPRectangle.h"
#import "SPPoint.h"
#import "SPMacros.h"

#define MIN_ALPHA (5.0f / 255.0f)

/// --- C methods ----------------------------------------------------------------------------------

SPVertexColor SPVertexColorMake(unsigned char r, unsigned char g, unsigned char b, unsigned char a)
{
    SPVertexColor vertexColor = { .r = r, .g = g, .b = b, .a = a };
    return vertexColor;
}

SPVertexColor SPVertexColorMakeWithColorAndAlpha(uint rgb, float alpha)
{
    SPVertexColor vertexColor = {
        .r = SP_COLOR_PART_RED(rgb),
        .g = SP_COLOR_PART_GREEN(rgb),
        .b = SP_COLOR_PART_BLUE(rgb),
        .a = (unsigned char)(alpha * 255.0f)
    };
    return vertexColor;
}

SPVertexColor premultiplyAlpha(SPVertexColor color)
{
    float alpha = color.a / 255.0f;
    return SPVertexColorMake(color.r * alpha,
                             color.g * alpha,
                             color.b * alpha,
                             color.a);
}

SPVertexColor unmultiplyAlpha(SPVertexColor color)
{
    float alpha = color.a / 255.0f;
    
    if (alpha != 0.0f)
        return SPVertexColorMake(color.r / alpha,
                                 color.g / alpha,
                                 color.b / alpha,
                                 color.a);
    else
        return color;
}

BOOL isOpaqueWhite(SPVertexColor color)
{
    return color.a == 255 && color.r == 255 && color.g == 255 && color.b == 255;
}

/// --- Class implementation -----------------------------------------------------------------------

@implementation SPVertexData
{
    SPVertex *_vertices;
    int _numVertices;
    BOOL _premultipliedAlpha;
}

@synthesize vertices = _vertices;
@synthesize numVertices = _numVertices;
@synthesize premultipliedAlpha = _premultipliedAlpha;

- (id)initWithSize:(int)numVertices premultipliedAlpha:(BOOL)pma
{
    if ((self = [super init]))
    {
        _premultipliedAlpha = pma;
        self.numVertices = numVertices;
    }
    
    return self;
}

- (id)initWithSize:(int)numVertices
{
    return [self initWithSize:numVertices premultipliedAlpha:NO];
}

- (id)init
{
    return [self initWithSize:0];
}

- (void)dealloc
{
    free(_vertices);
}

- (void)copyToVertexData:(SPVertexData *)target
{
    [self copyToVertexData:target atIndex:0 numVertices:_numVertices];
}

- (void)copyToVertexData:(SPVertexData *)target atIndex:(int)targetIndex
{
    [self copyToVertexData:target atIndex:targetIndex numVertices:_numVertices];
}

- (void)copyToVertexData:(SPVertexData *)target atIndex:(int)targetIndex numVertices:(int)count
{
    if (count < 0 || count > _numVertices)
        [NSException raise:SP_EXC_INDEX_OUT_OF_BOUNDS format:@"Invalid vertex count"];
    
    if (targetIndex + count > target->_numVertices)
        [NSException raise:SP_EXC_INDEX_OUT_OF_BOUNDS format:@"Target too small"];
    
    memcpy(&target->_vertices[targetIndex], _vertices, sizeof(SPVertex) * count);
}

- (SPVertex)vertexAtIndex:(int)index
{
    if (index < 0 || index >= _numVertices)
        [NSException raise:SP_EXC_INDEX_OUT_OF_BOUNDS format:@"Invalid vertex index"];

    return _vertices[index];
}

- (void)setVertex:(SPVertex)vertex atIndex:(int)index
{
    if (index < 0 || index >= _numVertices)
        [NSException raise:SP_EXC_INDEX_OUT_OF_BOUNDS format:@"Invalid vertex index"];

    _vertices[index] = vertex;
    
    if (_premultipliedAlpha)
        _vertices[index].color = premultiplyAlpha(vertex.color);
}

- (SPPoint *)positionAtIndex:(int)index
{
    if (index < 0 || index >= _numVertices)
        [NSException raise:SP_EXC_INDEX_OUT_OF_BOUNDS format:@"Invalid vertex index"];
    
    GLKVector2 position = _vertices[index].position;
    return [[SPPoint alloc] initWithX:position.x y:position.y];
}

- (void)setPosition:(SPPoint *)position atIndex:(int)index
{
    if (index < 0 || index >= _numVertices)
        [NSException raise:SP_EXC_INDEX_OUT_OF_BOUNDS format:@"Invalid vertex index"];
    
    _vertices[index].position = GLKVector2Make(position.x, position.y);
}

- (void)setPositionWithX:(float)x y:(float)y atIndex:(int)index
{
    if (index < 0 || index >= _numVertices)
        [NSException raise:SP_EXC_INDEX_OUT_OF_BOUNDS format:@"Invalid vertex index"];
    
    _vertices[index].position = GLKVector2Make(x, y);
}

- (SPPoint *)texCoordsAtIndex:(int)index
{
    if (index < 0 || index >= _numVertices)
        [NSException raise:SP_EXC_INDEX_OUT_OF_BOUNDS format:@"Invalid vertex index"];
    
    GLKVector2 texCoords = _vertices[index].texCoords;
    return [[SPPoint alloc] initWithX:texCoords.x y:texCoords.y];
}

- (void)setTexCoords:(SPPoint *)texCoords atIndex:(int)index
{
    if (index < 0 || index >= _numVertices)
        [NSException raise:SP_EXC_INDEX_OUT_OF_BOUNDS format:@"Invalid vertex index"];
    
    _vertices[index].texCoords = GLKVector2Make(texCoords.x, texCoords.y);
}

- (void)setTexCoordsWithX:(float)x y:(float)y atIndex:(int)index
{
    if (index < 0 || index >= _numVertices)
        [NSException raise:SP_EXC_INDEX_OUT_OF_BOUNDS format:@"Invalid vertex index"];
    
    _vertices[index].texCoords = GLKVector2Make(x, y);
}

- (void)setColor:(uint)color alpha:(float)alpha atIndex:(int)index
{
    if (index < 0 || index >= _numVertices)
        [NSException raise:SP_EXC_INDEX_OUT_OF_BOUNDS format:@"Invalid vertex index"];
    
    alpha = SP_CLAMP(alpha, _premultipliedAlpha ? MIN_ALPHA : 0.0f, 1.0f);
    
    SPVertexColor vertexColor = SPVertexColorMakeWithColorAndAlpha(color, alpha);
    _vertices[index].color = _premultipliedAlpha ? premultiplyAlpha(vertexColor) : vertexColor;
}

- (void)setColor:(uint)color alpha:(float)alpha
{
    for (int i=0; i<_numVertices; ++i)
        [self setColor:color alpha:alpha atIndex:i];
}

- (uint)colorAtIndex:(int)index
{
    if (index < 0 || index >= _numVertices)
        [NSException raise:SP_EXC_INDEX_OUT_OF_BOUNDS format:@"Invalid vertex index"];

    SPVertexColor vertexColor = _vertices[index].color;
    if (_premultipliedAlpha) vertexColor = unmultiplyAlpha(vertexColor);
    return SP_COLOR(vertexColor.r, vertexColor.g, vertexColor.b);
}

- (void)setColor:(uint)color atIndex:(int)index
{
    float alpha = [self alphaAtIndex:index];
    [self setColor:color alpha:alpha atIndex:index];
}

- (void)setColor:(uint)color
{
    for (int i=0; i<_numVertices; ++i)
        [self setColor:color atIndex:i];
}

- (void)setAlpha:(float)alpha atIndex:(int)index
{
    uint color = [self colorAtIndex:index];
    [self setColor:color alpha:alpha atIndex:index];
}

- (void)setAlpha:(float)alpha
{
    for (int i=0; i<_numVertices; ++i)
        [self setAlpha:alpha atIndex:i];
}

- (float)alphaAtIndex:(int)index
{
    if (index < 0 || index >= _numVertices)
        [NSException raise:SP_EXC_INDEX_OUT_OF_BOUNDS format:@"Invalid vertex index"];
    
    return _vertices[index].color.a / 255.0f;
}

- (void)scaleAlphaBy:(float)factor
{
    [self scaleAlphaBy:factor atIndex:0 numVertices:_numVertices];
}

- (void)scaleAlphaBy:(float)factor atIndex:(int)index numVertices:(int)count
{
    if (index < 0 || index + count > _numVertices)
        [NSException raise:SP_EXC_INDEX_OUT_OF_BOUNDS format:@"Invalid index range"];
    
    if (factor == 1.0f) return;
    int minAlpha = _premultipliedAlpha ? (int)(MIN_ALPHA * 255.0f) : 0;
    
    for (int i=index; i<index+count; ++i)
    {
        SPVertex *vertex = &_vertices[i];
        SPVertexColor vertexColor = vertex->color;
        unsigned char newAlpha = SP_CLAMP(vertexColor.a * factor, minAlpha, 255);
        
        if (_premultipliedAlpha)
        {
            vertexColor = unmultiplyAlpha(vertexColor);
            vertexColor.a = newAlpha;
            vertex->color = premultiplyAlpha(vertexColor);
        }
        else
        {
            vertex->color = SPVertexColorMake(vertexColor.r, vertexColor.g, vertexColor.b, newAlpha);
        }
    }
}

- (void)appendVertex:(SPVertex)vertex
{
    self.numVertices += 1;
    
    if (_vertices) // just to shut down an Analyzer warning ... this will never be NULL.
    {
        if (_premultipliedAlpha) vertex.color = premultiplyAlpha(vertex.color);
        _vertices[_numVertices-1] = vertex;
    }
}

- (void)transformVerticesWithMatrix:(SPMatrix *)matrix atIndex:(int)index numVertices:(int)count
{
    if (index < 0 || index + count > _numVertices)
        [NSException raise:SP_EXC_INDEX_OUT_OF_BOUNDS format:@"Invalid index range"];
    
    if (!matrix) return;
    
    GLKMatrix3 glkMatrix = [matrix convertToGLKMatrix3];
    
    for (int i=index, end=index+count; i<end; ++i)
    {
        GLKVector2 pos = _vertices[i].position;
        _vertices[i].position.x = glkMatrix.m00 * pos.x + glkMatrix.m10 * pos.y + glkMatrix.m20;
        _vertices[i].position.y = glkMatrix.m11 * pos.y + glkMatrix.m01 * pos.x + glkMatrix.m21;
    }
}

- (void)setNumVertices:(int)value
{
    if (value != _numVertices)
    {
        if (value)
        {
            if (_vertices)
                _vertices = realloc(_vertices, sizeof(SPVertex) * value);
            else
                _vertices = malloc(sizeof(SPVertex) * value);
            
            if (value > _numVertices)
            {
                memset(&_vertices[_numVertices], 0, sizeof(SPVertex) * (value - _numVertices));
                
                for (int i=_numVertices; i<value; ++i)
                    _vertices[i].color = SPVertexColorMakeWithColorAndAlpha(0, 1.0f);
            }
        }
        else
        {
            free(_vertices);
            _vertices = NULL;
        }
        
        _numVertices = value;
    }
}

- (SPRectangle *)bounds
{
    return [self boundsAfterTransformation:nil atIndex:0 numVertices:_numVertices];
}

- (SPRectangle *)boundsAfterTransformation:(SPMatrix *)matrix
{
    return [self boundsAfterTransformation:matrix atIndex:0 numVertices:_numVertices];
}

- (SPRectangle *)boundsAfterTransformation:(SPMatrix *)matrix atIndex:(int)index numVertices:(int)count
{
    if (index < 0 || index + count > _numVertices)
        [NSException raise:SP_EXC_INDEX_OUT_OF_BOUNDS format:@"Invalid index range"];
    
    if (!count) return nil;
    
    float minX = FLT_MAX, maxX = -FLT_MAX, minY = FLT_MAX, maxY = -FLT_MAX;
    int endIndex = index + count;
    
    if (matrix)
    {
        for (int i=index; i<endIndex; ++i)
        {
            GLKVector2 position = _vertices[i].position;
            SPPoint *transformedPoint = [matrix transformPointWithX:position.x y:position.y];
            float tfX = transformedPoint.x;
            float tfY = transformedPoint.y;
            minX = MIN(minX, tfX);
            maxX = MAX(maxX, tfX);
            minY = MIN(minY, tfY);
            maxY = MAX(maxY, tfY);
        }
    }
    else
    {
        for (int i=index; i<endIndex; ++i)
        {
            GLKVector2 position = _vertices[i].position;
            minX = MIN(minX, position.x);
            maxX = MAX(maxX, position.x);
            minY = MIN(minY, position.y);
            maxY = MAX(maxY, position.y);
        }
    }
    
    return [SPRectangle rectangleWithX:minX y:minY width:maxX-minX height:maxY-minY];
}

- (void)setPremultipliedAlpha:(BOOL)value
{
    [self setPremultipliedAlpha:value updateVertices:YES];
}

- (void)setPremultipliedAlpha:(BOOL)value updateVertices:(BOOL)update
{
    if (value == _premultipliedAlpha) return;
    
    if (update)
    {
        if (value)
        {
            for (int i=0; i<_numVertices; ++i)
                _vertices[i].color = premultiplyAlpha(_vertices[i].color);
        }
        else
        {
            for (int i=0; i<_numVertices; ++i)
                _vertices[i].color = unmultiplyAlpha(_vertices[i].color);
        }
    }
    
    _premultipliedAlpha = value;
}

- (SPVertex *)vertices
{
    return _vertices;
}

- (BOOL)tinted
{
    for (int i=0; i<_numVertices; ++i)
        if (!isOpaqueWhite(_vertices[i].color)) return YES;
    
    return NO;
}

@end
