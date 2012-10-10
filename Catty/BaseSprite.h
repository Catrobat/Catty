//
//  BaseSprite.h
//  Catty
//
//  Created by Mattias Rauter on 09.10.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Brick.h"

@interface BaseSprite : Brick

@property (strong, nonatomic) NSString *name;
@property (nonatomic, strong) GLKBaseEffect *effect;

@property (assign) CGSize contentSize;
@property (assign, nonatomic) BOOL showSprite;
@property (assign, nonatomic) GLKVector3 position;        // position - origin is bottom-left
@property (assign, nonatomic) float rotationInDegrees;
@property (assign, nonatomic) float alphaValue;


@property (readonly, strong, nonatomic) NSString *path;



-(id)initWithEffect:(GLKBaseEffect*)effect;

// graphics
-(void)update:(float)dt;
-(void)render;

-(BOOL)loadImageWithPath:(NSString*)path;
-(void)setOriginalSpriteSize;
-(void)setSpriteSizeWithWidth:(float)width andHeight:(float)height;

@end
