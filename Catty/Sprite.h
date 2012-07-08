//
//  Sprite.h
//  Catty
//
//  Created by Mattias Rauter on 17.04.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <GLKit/GLKit.h>

@class Costume;

@interface Sprite : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSArray *costumesArray;
@property (strong, nonatomic) NSArray *soundsArray;
@property (assign) GLKVector3 position;
@property (assign) CGSize contentSize;
@property (nonatomic, strong) GLKBaseEffect *effect;
@property (nonatomic) int indexOfCurrentCostumeInArray;

- (id)initWithEffect:(GLKBaseEffect*)effect;
- (void)render;
- (NSString*)description;

- (CGRect)boundingBox;


@end
