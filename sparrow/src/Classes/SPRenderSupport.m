//
//  SPRenderSupport.m
//  Sparrow
//
//  Created by Daniel Sperl on 28.09.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPRenderSupport.h"
#import "SPDisplayObject.h"
#import "SPVertexData.h"
#import "SPQuadBatch.h"
#import "SPTexture.h"
#import "SPMacros.h"
#import "SPQuad.h"
#import "SPBlendMode.h"

#import <GLKit/GLKit.h>

// --- helper macros -------------------------------------------------------------------------------

#define CURRENT_STATE()  ((SPRenderState *)(_stateStack[_stateStackIndex]))
#define CURRENT_BATCH()  ((SPQuadBatch *)(_quadBatches[_quadBatchIndex]))

// --- helper class --------------------------------------------------------------------------------

@interface SPRenderState : NSObject

@property (nonatomic, readonly) SPMatrix *modelviewMatrix;
@property (nonatomic, readonly) float alpha;
@property (nonatomic, readonly) uint blendMode;

- (void)setupDerivedFromState:(SPRenderState *)state withModelviewMatrix:(SPMatrix *)matrix
                        alpha:(float)alpha blendMode:(uint)blendMode;

@end

@implementation SPRenderState

@synthesize modelviewMatrix = _modelviewMatrix;
@synthesize alpha = _alpha;
@synthesize blendMode = _blendMode;

- (id)init
{
    if ((self = [super init]))
    {
        _modelviewMatrix = [SPMatrix matrixWithIdentity];
        _alpha = 1.0f;
        _blendMode = SP_BLEND_MODE_NORMAL;
    }
    return self;
}

- (void)setupDerivedFromState:(SPRenderState *)state withModelviewMatrix:(SPMatrix *)matrix
                        alpha:(float)alpha blendMode:(uint)blendMode
{
    _alpha = alpha * state->_alpha;
    _blendMode = blendMode == SP_BLEND_MODE_AUTO ? state->_blendMode : blendMode;
    
    [_modelviewMatrix copyFromMatrix:state->_modelviewMatrix];
    [_modelviewMatrix prependMatrix:matrix];
}

@end

// --- class implementation ------------------------------------------------------------------------

@implementation SPRenderSupport
{
    SPMatrix *_projectionMatrix;
    SPMatrix *_mvpMatrix;
    int _numDrawCalls;
    
    NSMutableArray *_stateStack;
    int _stateStackIndex;
    int _stateStackSize;
    
    NSMutableArray *_quadBatches;
    int _quadBatchIndex;
    int _quadBatchSize;
}

@synthesize projectionMatrix = _projectionMatrix;
@synthesize mvpMatrix = _mvpMatrix;
@synthesize numDrawCalls = _numDrawCalls;

- (id)init
{
    if ((self = [super init]))
    {
        _projectionMatrix = [[SPMatrix alloc] init];
        _mvpMatrix        = [[SPMatrix alloc] init];
        
        _stateStack = [[NSMutableArray alloc] initWithObjects:[[SPRenderState alloc] init], nil];
        _stateStackIndex = 0;
        _stateStackSize = 1;
        
        _quadBatches = [[NSMutableArray alloc] initWithObjects:[[SPQuadBatch alloc] init], nil];
        _quadBatchIndex = 0;
        _quadBatchSize = 1;
        
        [self setupOrthographicProjectionWithLeft:0 right:320 top:0 bottom:480];
    }
    return self;
}

- (void)nextFrame
{
    _stateStackIndex = 0;
    _quadBatchIndex = 0;
    _numDrawCalls = 0;
}

- (void)purgeBuffers
{
    [_quadBatches removeAllObjects];
    [_quadBatches addObject:[[SPQuadBatch alloc] init]];
     _quadBatchIndex = 0;
     _quadBatchSize = 1;
}

+ (void)clearWithColor:(uint)color alpha:(float)alpha;
{
    float red   = SP_COLOR_PART_RED(color)   / 255.0f;
    float green = SP_COLOR_PART_GREEN(color) / 255.0f;
    float blue  = SP_COLOR_PART_BLUE(color)  / 255.0f;
    
    glClearColor(red, green, blue, alpha);
    glClear(GL_COLOR_BUFFER_BIT);
}

+ (uint)checkForOpenGLError
{
    GLenum error = glGetError();
    if (error != 0) NSLog(@"There was an OpenGL error: 0x%x", error);
    return error;
}

- (void)addDrawCalls:(int)count
{
    _numDrawCalls += count;
}

- (void)setupOrthographicProjectionWithLeft:(float)left right:(float)right
                                        top:(float)top bottom:(float)bottom;
{
    [_projectionMatrix setA:2.0f/(right-left) b:0.0f c:0.0f d:2.0f/(top-bottom)
                         tx:-(right+left) / (right-left)
                         ty:-(top+bottom) / (top-bottom)];
}

#pragma mark - state stack

- (void)pushStateWithMatrix:(SPMatrix *)matrix alpha:(float)alpha blendMode:(uint)blendMode
{
    SPRenderState *previousState = CURRENT_STATE();
    
    if (_stateStackSize == _stateStackIndex + 1)
    {
        [_stateStack addObject:[[SPRenderState alloc] init]];
        ++_stateStackSize;
    }
    
    ++_stateStackIndex;
    
    [CURRENT_STATE() setupDerivedFromState:previousState withModelviewMatrix:matrix
                                     alpha:alpha blendMode:blendMode];
}

- (void)popState
{
    if (_stateStackIndex == 0)
        [NSException raise:SP_EXC_INVALID_OPERATION format:@"The state stack must not be empty"];
        
    --_stateStackIndex;
}

- (float)alpha
{
    return CURRENT_STATE().alpha;
}

- (uint)blendMode
{
    return CURRENT_STATE().blendMode;
}

- (SPMatrix *)modelviewMatrix
{
    return CURRENT_STATE().modelviewMatrix;
}

- (SPMatrix *)mvpMatrix
{
    [_mvpMatrix copyFromMatrix:CURRENT_STATE().modelviewMatrix];
    [_mvpMatrix appendMatrix:_projectionMatrix];
    return _mvpMatrix;
}

- (void)applyBlendModeForPremultipliedAlpha:(BOOL)pma
{
    [SPBlendMode applyBlendFactorsForBlendMode:CURRENT_STATE().blendMode premultipliedAlpha:pma];
}

#pragma mark - rendering

- (void)batchQuad:(SPQuad *)quad
{
    SPRenderState *currentState = CURRENT_STATE();
    SPQuadBatch *currentBatch = CURRENT_BATCH();
    
    float alpha = currentState.alpha;
    uint blendMode = currentState.blendMode;
    SPMatrix *modelviewMatrix = currentState.modelviewMatrix;
    
    if ([currentBatch isStateChangeWithTinted:quad.tinted texture:quad.texture alpha:alpha
                           premultipliedAlpha:quad.premultipliedAlpha blendMode:blendMode
                                     numQuads:1])
    {
        [self finishQuadBatch];
        currentBatch = CURRENT_BATCH();
    }
    
    [currentBatch addQuad:quad alpha:alpha blendMode:blendMode matrix:modelviewMatrix];
}

- (void)finishQuadBatch
{
    SPQuadBatch *currentBatch = CURRENT_BATCH();
    
    if (currentBatch.numQuads)
    {
        [currentBatch renderWithMvpMatrix:_projectionMatrix];
        [currentBatch reset];
        
        ++_quadBatchIndex;
        ++_numDrawCalls;
        
        if (_quadBatchSize <= _quadBatchIndex)
        {
            [_quadBatches addObject:[[SPQuadBatch alloc] init]];
            ++_quadBatchSize;
        }
    }
}

@end

