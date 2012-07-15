//
//  Sprite.h
//  Catty
//
//  Created by Mattias Rauter on 17.04.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "Types.h"

@class Costume;
@class Script;

@interface Sprite : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSMutableArray *costumesArray;
@property (strong, nonatomic) NSArray *soundsArray;
@property (strong, nonatomic) NSArray *startScriptsArray;
@property (strong, nonatomic) NSArray *whenScriptsArray;
@property (assign) GLKVector3 position;
@property (assign) CGSize contentSize;
@property (nonatomic, strong) GLKBaseEffect *effect;
@property (nonatomic) NSNumber *indexOfCurrentCostumeInArray;

- (id)initWithEffect:(GLKBaseEffect*)effect;
- (void)render;
- (NSString*)description;
- (void)addStartScript:(Script*)script;
- (void)addWhenScript:(Script*)script;
- (CGRect)boundingBox;
- (void)start;
- (void)touch:(InputType)type;


@end
