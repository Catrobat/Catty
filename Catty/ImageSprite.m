//
//  ImageSprite.m
//  Catty
//
//  Created by Christof Stromberger on 20.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "ImageSprite.h"
#import "Util.h"


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

@interface ImageSprite()

@property (assign) TexturedQuad quad;
@property (nonatomic, strong) GLKTextureInfo *textureInfo;

@property (assign, nonatomic) GLKVector3 position;        // position - origin is in the middle of the sprite
@property (strong, nonatomic) PositionAtTime *nextPosition;

@end



@implementation ImageSprite

@synthesize quad = _quad;
@synthesize textureInfo = _textureInfo;
@synthesize position = _position;
@synthesize effect = _effect;
@synthesize nextPosition = _nextPosition;
@synthesize contentSize = _contentSize;

- (id)initWithEffect:(GLKBaseEffect*)effect
{
    self = [super init];
    if (self)
    {
        self.effect = effect;
    }
    return self;
}


-(void)setSpriteSizeWithWidth:(float)width andHeight:(float)height
{
    self.contentSize = CGSizeMake(width, height);

    
    
    TexturedQuad newQuad;
    newQuad.bottomLeftCorner.geometryVertex = CGPointMake(0, 0);
    newQuad.bottomRightCorner.geometryVertex = CGPointMake(width, 0);
    newQuad.topLeftCorner.geometryVertex = CGPointMake(0, height);
    newQuad.topRightCorner.geometryVertex = CGPointMake(width, height);
    
    newQuad.bottomLeftCorner.textureVertex = CGPointMake(0, 0);
    newQuad.bottomRightCorner.textureVertex = CGPointMake(1, 0);
    newQuad.topLeftCorner.textureVertex = CGPointMake(0, 1);
    newQuad.topRightCorner.textureVertex = CGPointMake(1, 1);
    self.quad = newQuad;
}

- (GLKMatrix4) modelMatrix
{
    GLKMatrix4 modelMatrix = GLKMatrix4Identity;
    //    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    //    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    //    NSLog(@"self width: %f", self.contentSize.width/2);
    //    NSLog(@"width: %f, newWidth: %f", width/2, (width/2 - self.contentSize.width/2));
    //    self.position = GLKVector3Make((width/2 - self.contentSize.width/2), (height/2 - self.contentSize.height/2), 0);
    
    float x = (self.position.x) + [UIScreen mainScreen].bounds.size.width/2;
    float y = (self.position.y) + [UIScreen mainScreen].bounds.size.height/2;
    
    //    NSLog(@"x/y: %f/%f", x, y);
    
    CGSize scaledContentSize = CGSizeMake(self.contentSize.width, self.contentSize.height);
    
    modelMatrix = GLKMatrix4Translate(modelMatrix, x, y, self.position.z);
    modelMatrix = GLKMatrix4Translate(modelMatrix, -scaledContentSize.width/2, -scaledContentSize.height/2, 0);
    
    return modelMatrix;
}

#pragma mark - graphics
- (void)update:(float)dt
{
    if (self.nextPosition)
    {
        NSTimeInterval now = [[NSDate date]timeIntervalSince1970];
        
        NSLog(@"timediff: %f", self.nextPosition.timestamp - now);
        
        if (now >= self.nextPosition.timestamp)
        {
            // "checkpoint" reached
            self.position = self.nextPosition.position;
            NSLog(@"remove nextPosition");
            self.nextPosition = nil;
        }
        else
        {
            // calculate position
            double timeLeft = (self.nextPosition.timestamp - now);    // in sec
            int numberOfSteps = round(timeLeft * (float)FRAMES_PER_SECOND);               // TODO: find better way to determine FPS (e.g. GLKit-variable??)
            
            GLKVector3 direction = GLKVector3Subtract(self.nextPosition.position, self.position);
            
            GLKVector3 step = direction;
            if (numberOfSteps > 0)
                step = GLKVector3DivideScalar(direction, numberOfSteps);
            
            self.position = GLKVector3Add(self.position, step);
            
            NSLog(@"newPosition: %f/%f", self.position.x, self.position.y);
        }
    }
}

- (void)render
{
    
    NSString *pathToImage = [[NSBundle mainBundle] pathForResource:@"cloud" ofType:@"png"]; // TODO: change const string
    
    NSLog(@"Try to load image: %@", pathToImage);
    
    
    NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithBool:YES],
                              GLKTextureLoaderOriginBottomLeft,
                              nil];
    NSError *error;
    self.textureInfo = [GLKTextureLoader textureWithContentsOfFile:pathToImage options:options error:&error];
    if (self.textureInfo == nil)
    {
        NSLog(@"Error loading file: %@", [error localizedDescription]);
        return;
    }
    
    [Util log:error];
    
    [self setSpriteSizeWithWidth:self.textureInfo.width andHeight:self.textureInfo.height];
    
        
        if (!self.effect)
            NSLog(@"Sprite.m => render => NO effect set!!!");
        
        self.effect.texture2d0.name = self.textureInfo.name;
        self.effect.texture2d0.enabled = YES;
        
        self.effect.transform.modelviewMatrix = self.modelMatrix;
        
        [self.effect prepareToDraw];
        
        glEnableVertexAttribArray(GLKVertexAttribPosition);
        glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
        
        long offset = (long)&_quad;
        glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (void *) (offset + offsetof(TexturedVertex, geometryVertex)));
        glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (void *) (offset + offsetof(TexturedVertex, textureVertex)));
        
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        
        //        NSLog(@"render: %@   %f", self.name, self.position.z);
}




@end
