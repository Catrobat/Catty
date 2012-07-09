//
//  Level.h
//  Catty
//
//  Created by Mattias Rauter on 17.04.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Level : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic) float version;
@property (nonatomic) CGSize resolution;
@property (nonatomic, strong) NSArray *spritesArray;
@property (nonatomic, strong) NSArray *startScriptsArray;
@property (nonatomic, strong) NSArray *whenScriptsArray;

- (NSString*)description;
@end
