//
//  ImageSprite.h
//  Catty
//
//  Created by Christof Stromberger on 20.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <GLKit/GLKit.h>
#import <Foundation/Foundation.h>
#import "SpriteObject.h"
#import "StartScreenViewController.h"



@interface ImageSprite : NSObject
@property (nonatomic, strong) GLKBaseEffect *effect;
@property (assign) CGSize contentSize;

- (id)initWithEffect:(GLKBaseEffect*)effect;

// graphics
- (void)update:(float)dt;
- (void)render;

@end
