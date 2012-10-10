//
//  BaseSprite.m
//  Catty
//
//  Created by Mattias Rauter on 09.10.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "BaseSprite.h"


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


@interface BaseSprite()
@property (nonatomic, strong) GLKTextureInfo *textureInfo;
@property (assign) TexturedQuad quad;
@property (strong, nonatomic) NSString *path;
@end



@implementation BaseSprite

@synthesize name = _name;
@synthesize path = _path;
@synthesize effect = _effect;
@synthesize contentSize = _contentSize;
@synthesize showSprite = _showSprite;
@synthesize realPosition = _realPosition;
@synthesize rotationInDegrees = _rotationInDegrees;
@synthesize alphaValue = _alphaValue;

-(id)init
{
    self = [super init];
    if (self)
    {
        [self setInitValuesForBaseSprite];
    }
    return self;
}

-(id)initWithEffect:(GLKBaseEffect*)effect
{
    self = [super init];
    if (self)
    {
        self.effect = effect;
        [self setInitValuesForBaseSprite];
    }
    return self;
}

-(void)setInitValuesForBaseSprite
{
    self.showSprite = YES;
    self.alphaValue = 1.0f;
    self.realPosition = GLKVector3Make(0.0f, 0.0f, 0.0f);
    self.scaleFactor = 1.0f;
}

-(CGSize)originalImageSize
{
    return CGSizeMake(self.textureInfo.width, self.textureInfo.height);
}


-(BOOL)loadImageWithPath:(NSString *)path
{
    NSLog(@"Try to load image '%@'", path);
        
    NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithBool:YES],
                              GLKTextureLoaderOriginBottomLeft,
                              nil];
    NSError *error;
        
    self.textureInfo = [GLKTextureLoader textureWithContentsOfFile:path options:options error:&error];
    if (self.textureInfo == nil)
    {
        NSLog(@"Error loading file: %@", [error localizedDescription]);
        return NO;
    }
    // else
    self.path = path;
    
    [self setOriginalSpriteSize];
    return YES;
}

-(void)setOriginalSpriteSize
{
    [self setSpriteSizeWithWidth:self.textureInfo.width andHeight:self.textureInfo.height];
}

-(void)setSpriteSizeWithWidth:(float)width andHeight:(float)height
{
    self.contentSize = CGSizeMake(width, height);
    
    TexturedQuad newQuad;
    newQuad.bottomLeftCorner.geometryVertex = CGPointMake(-width/2.0f, -height/2.0f);
    newQuad.bottomRightCorner.geometryVertex = CGPointMake(width/2.0f, -height/2.0f);
    newQuad.topLeftCorner.geometryVertex = CGPointMake(-width/2.0f, height/2.0f);
    newQuad.topRightCorner.geometryVertex = CGPointMake(width/2.0f, height/2.0f);
    
    newQuad.bottomLeftCorner.textureVertex = CGPointMake(0, 0);
    newQuad.bottomRightCorner.textureVertex = CGPointMake(1, 0);
    newQuad.topLeftCorner.textureVertex = CGPointMake(0, 1);
    newQuad.topRightCorner.textureVertex = CGPointMake(1, 1);
    self.quad = newQuad;
}



- (GLKMatrix4) modelMatrix
{
    GLKMatrix4 modelMatrix = GLKMatrix4Identity;
        
//    modelMatrix = GLKMatrix4Translate(modelMatrix, 0.0f, 0.0f, 0.0f);
//    modelMatrix = GLKMatrix4RotateZ(modelMatrix, GLKMathDegreesToRadians(self.rotationInDegrees));
//    modelMatrix = GLKMatrix4Rotate(modelMatrix, GLKMathDegreesToRadians(self.rotationInDegrees), 0.0f, 0.0f, 1.0f);
    
    modelMatrix = GLKMatrix4Translate(modelMatrix, self.realPosition.x, self.realPosition.y, self.realPosition.z);
    modelMatrix = GLKMatrix4Scale(modelMatrix, self.scaleFactor, self.scaleFactor, 1.0f);
    
    return modelMatrix;
}

#pragma mark - graphics
- (void)update:(float)dt
{
}

- (void)render
{
    if (self.showSprite)
    {
        
        if (!self.effect)
            NSLog(@"BaseSprite.m => render => NO effect set!!!");
        
        self.effect.texture2d0.name = self.textureInfo.name;
        self.effect.texture2d0.enabled = YES;
        
        self.effect.transform.modelviewMatrix = self.modelMatrix;
        
        self.effect.useConstantColor = YES;
        self.effect.constantColor = GLKVector4Make(255, 255, 255, self.alphaValue);
        
        [self.effect prepareToDraw];
        
        glEnableVertexAttribArray(GLKVertexAttribPosition);
        glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
        
        long offset = (long)&_quad;
        glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (void *) (offset + offsetof(TexturedVertex, geometryVertex)));
        glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (void *) (offset + offsetof(TexturedVertex, textureVertex)));
        
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    }
}

@end
