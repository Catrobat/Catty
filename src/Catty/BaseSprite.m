/**
 *  Copyright (C) 2010-2013 The Catrobat Team
 *  (http://developer.catrobat.org/credits)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  An additional term exception under section 7 of the GNU Affero
 *  General Public License, version 3, is available at
 *  (http://developer.catrobat.org/license_additional_term)
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see http://www.gnu.org/licenses/.
 */


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


-(BOOL)loadImageWithPath:(NSString*)path width:(float)width height:(float)height
{
    [self loadImageWithPath:path];
    [self setSpriteSizeWithWidth:width andHeight:height];
    return YES;
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
        
        abort();
        
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
        
    modelMatrix = GLKMatrix4MakeRotation(self.rotationInDegrees * M_PI / 180.0f, 0, 0, 1);
    
    modelMatrix = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(self.realPosition.x, self.realPosition.y, self.realPosition.z),
                                     modelMatrix);
    
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
