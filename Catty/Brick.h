//
//  Brick.h
//  Catty
//
//  Created by Mattias Rauter on 17.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Sprite.h"

@interface Brick : NSObject

@property (strong, nonatomic) Sprite *sprite;

- (NSString*)description;

@end
