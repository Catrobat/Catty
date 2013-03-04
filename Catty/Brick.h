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

//@property (strong, nonatomic) Sprite *sprite;

#warning @mattias: I've added this property
@property (nonatomic, strong) Sprite *sprite;


- (NSString*)description;
- (void)performFromScript:(Script*)script;

@end
