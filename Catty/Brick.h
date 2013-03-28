//
//  Brick.h
//  Catty
//
//  Created by Mattias Rauter on 17.04.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpriteObject.h"
@class Script;

@interface Brick : NSObject

@property (nonatomic, strong) SpriteObject *object;

- (id)initWithSprite:(SpriteObject*)sprite;

- (NSString*)description;
- (void)performFromScript:(Script*)script;

@end
