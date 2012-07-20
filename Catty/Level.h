//
//  Level.h
//  Catty
//
//  Created by Mattias Rauter on 17.04.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Level : NSObject

@property (nonatomic, strong) NSString *versionName;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *versionCode;
@property (nonatomic, strong) NSString *screenResolution;
@property (nonatomic) CGSize resolution;
@property (nonatomic, strong) NSMutableArray *spritesArray;

- (NSString*)description;
@end
