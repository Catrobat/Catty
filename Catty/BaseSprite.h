//
//  BaseSprite.h
//  Catty
//
//  Created by Mattias Rauter on 09.10.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface BaseSprite : NSObject

@property (strong, nonatomic) NSString *name;
@property (nonatomic, strong) GLKBaseEffect *effect;

@property (assign) CGSize contentSize;
@property (assign, nonatomic) BOOL showSprite;
@property (assign, nonatomic) GLKVector3 realPosition;        // position - origin is bottom-left
@property (assign, nonatomic) float rotationInDegrees;
@property (assign, nonatomic) float alphaValue;

@property (readonly, strong, nonatomic) NSString *path;
@property (assign, nonatomic) float scaleFactor;    // scale image to fit screen


-(id)init;
-(id)initWithEffect:(GLKBaseEffect*)effect;


// getter
-(CGSize)originalImageSize;

// graphics
-(void)update:(float)dt;
-(void)render;

-(BOOL)loadImageWithPath:(NSString*)path;
-(BOOL)loadImageWithPath:(NSString*)path width:(float)width height:(float)height;
-(void)setOriginalSpriteSize;
-(void)setSpriteSizeWithWidth:(float)width andHeight:(float)height;

@end
