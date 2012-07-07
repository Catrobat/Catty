//
//  Level.h
//  Catty
//
//  Created by Mattias Rauter on 17.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Level : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic) float version;
@property (nonatomic) CGSize resolution;
@property (nonatomic, strong) NSArray *spritesArray;

@end
