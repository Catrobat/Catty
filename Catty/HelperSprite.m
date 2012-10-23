//
//  HelperSprite.m
//  Catty
//
//  Created by Mattias Rauter on 28.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "HelperSprite.h"

typedef struct {
    CGPoint geometryVertex;
    CGPoint textureVertex;
} TexturedVertex;

typedef struct {
    TexturedVertex bottomLeftCorner;
    TexturedVertex bottomRightCorner;
    TexturedVertex topLeftCorner;
    TexturedVertex topRightCorner;
} TexturedQuad;

@interface HelperSprite()

@property (assign) TexturedQuad quad;

@end

@implementation HelperSprite

@synthesize contentSize = _contentSize;
@synthesize position = _position;
@synthesize effect = _effect;
@synthesize textureInfo = _textureInfo;
@synthesize quad = _quad;


- (void)loadImage:(NSString*)pathToImage width:(float)width height:(float)height;
{
    NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithBool:YES],
                              GLKTextureLoaderOriginBottomLeft,
                              nil];
    
    NSError *error;
    
    
    NSLog(@"Try to load image: %@", pathToImage);
    
    self.textureInfo = [GLKTextureLoader textureWithContentsOfFile:pathToImage options:options error:&error];
    if (self.textureInfo == nil)
    {
        NSLog(@"Error loading file: %@", [error localizedDescription]);
        return;
    }
    
    self.contentSize = CGSizeMake(width, height);
    
    TexturedQuad newQuad;
    newQuad.bottomLeftCorner.geometryVertex = CGPointMake(0, 0);
    newQuad.bottomRightCorner.geometryVertex = CGPointMake(self.contentSize.width, 0);
    newQuad.topLeftCorner.geometryVertex = CGPointMake(0, self.contentSize.height);
    newQuad.topRightCorner.geometryVertex = CGPointMake(self.contentSize.width, self.contentSize.height);
    
    newQuad.bottomLeftCorner.textureVertex = CGPointMake(0, 0);
    newQuad.bottomRightCorner.textureVertex = CGPointMake(1, 0);
    newQuad.topLeftCorner.textureVertex = CGPointMake(0, 1);
    newQuad.topRightCorner.textureVertex = CGPointMake(1, 1);
    self.quad = newQuad;
}

- (GLKMatrix4) modelMatrix
{
    GLKMatrix4 modelMatrix = GLKMatrix4Identity;
    
    modelMatrix = GLKMatrix4Translate(modelMatrix, self.position.x, self.position.y, self.position.z);
    
    return modelMatrix;
}

#pragma mark - graphics
- (void)update:(float)dt
{
}

- (void)render
{

        if (!self.effect)
            NSLog(@"Sprite.m => render => NO effect set!!!");
        
        self.effect.texture2d0.name = self.textureInfo.name;
        self.effect.texture2d0.enabled = YES;
        
        self.effect.transform.modelviewMatrix = self.modelMatrix;
        
        
        self.effect.useConstantColor = YES;
        self.effect.constantColor = GLKVector4Make(255, 255, 255, 1.0f);
    
                
        [self.effect prepareToDraw];
        
        glEnableVertexAttribArray(GLKVertexAttribPosition);
        glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
        
        long offset = (long)&_quad;
        glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (void *) (offset + offsetof(TexturedVertex, geometryVertex)));
        glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (void *) (offset + offsetof(TexturedVertex, textureVertex)));
        
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        

}



@end
