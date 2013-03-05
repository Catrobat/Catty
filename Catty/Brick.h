//
//  Brick.h
//  Catty
//
//  Created by Mattias Rauter on 17.04.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Sprite.h"
@class Script;

@interface Brick : NSObject

@property (nonatomic, strong) Sprite *sprite;

- (id)initWithSprite:(Sprite*)sprite;

- (NSString*)description;
- (void)performFromScript:(Script*)script;

@end
