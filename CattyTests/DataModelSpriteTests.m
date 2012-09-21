//
//  DataModelSpriteTests.m
//  Catty
//
//  Created by Christof Stromberger on 07.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "DataModelSpriteTests.h"
#import "Costume.h"
#import "Sprite.h"

#define SAMPLE_NAME @"KittyCat"
#define SAMPLE_PATH @"normalcat.png"
#define SAMPLE_POS_X 100
#define SAMPLE_POS_Y 100
#define SAMPLE_POS_Z 0
#define SAMPLE_INDEX 0
#define SAMPLE_COSTUME_NAME @"SampleCostume"

@implementation DataModelSpriteTests

@synthesize costume = _costume;
@synthesize effect = _effect;
@synthesize costumeArray = _costumeArray;

#pragma mark - tear up & down
- (void)setUp
{
    [super setUp];

    //this is tested in DataModelCostumeTests.m
    self.costume = [[Costume alloc] initWithName:SAMPLE_NAME andPath:SAMPLE_PATH];
    self.effect = [[GLKBaseEffect alloc] init];
    self.costumeArray = [[NSArray alloc] initWithObjects:self.costume, nil];

}


- (void)tearDown
{    
    [super tearDown];
    
    self.costume = nil;
    self.effect = nil;
    self.costumeArray = nil;
}

#pragma mark - unit tests
- (void)test001_createBasicSprite
{
    Sprite *sprite = [[Sprite alloc] initWithEffect:self.effect];
    sprite.name = SAMPLE_NAME;
    sprite.projectPath = SAMPLE_PATH;
    
    //creating tmp costume
    Costume *costume = [[Costume alloc] initWithName:SAMPLE_COSTUME_NAME andPath:SAMPLE_PATH];
    [sprite addCostume:costume];
    STAssertEquals(sprite.name, SAMPLE_NAME, @"check name");
    Costume *retCostume = [sprite.costumesArray objectAtIndex:0];
    STAssertEqualObjects(costume, retCostume, @"checking costume of sprite");
}


@end
