//
//  DataModelSpriteTests.h
//  Catty
//
//  Created by Christof Stromberger on 07.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <GLKit/GLKit.h>

@class Costume;

@interface DataModelSpriteTests : SenTestCase

@property (nonatomic, strong) Costume *costume;
@property (strong, nonatomic) GLKBaseEffect *effect;
@property (nonatomic, strong) NSArray *costumeArray;

@end
