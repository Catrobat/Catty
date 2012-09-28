//
//  HelperSprite.h
//  Catty
//
//  Created by Mattias Rauter on 28.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface HelperSprite : NSObject

@property (assign) CGSize contentSize;
@property (assign, nonatomic) GLKVector3 position;
@property (nonatomic, strong) GLKBaseEffect *effect;
@property (nonatomic, strong) GLKTextureInfo *textureInfo;

-(void)loadImage:(NSString*)pathToImage width:(float)width height:(float)height;
-(void)render;

@end
