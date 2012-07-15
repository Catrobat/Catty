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
    sprite.position = GLKVector3Make(SAMPLE_POS_X, SAMPLE_POS_Y, SAMPLE_POS_Z);
    [sprite setCostumesArray:self.costumeArray];
    [sprite setIndexOfCurrentCostumeInArray:[NSNumber numberWithInt:SAMPLE_INDEX]];
    
    STAssertEquals(sprite.name, SAMPLE_NAME, @"check name");
    STAssertEquals(sprite.position, GLKVector3Make(SAMPLE_POS_X, SAMPLE_POS_Y, SAMPLE_POS_Z), @"position check");
    STAssertEquals(sprite.indexOfCurrentCostumeInArray, [NSNumber numberWithInt:SAMPLE_INDEX], @"check costume index");
    Costume *tmpCostume = [sprite.costumesArray objectAtIndex:0];
    STAssertEquals(tmpCostume.name, SAMPLE_NAME, @"check costume name");
    STAssertEquals(tmpCostume.filePath, SAMPLE_PATH, @"check costume path");
    STAssertEquals(tmpCostume.filePath, SAMPLE_PATH, @"check costume path");    
}

- (void)test002_complexSpriteTest
{
    
    Sprite *sprite = [[Sprite alloc] initWithEffect:self.effect];
    sprite.name = SAMPLE_NAME;
    sprite.position = GLKVector3Make(SAMPLE_POS_X, SAMPLE_POS_Y, SAMPLE_POS_Z);
    [sprite setCostumesArray:self.costumeArray];

    BOOL exception = NO;
    @try
    {
        [sprite setIndexOfCurrentCostumeInArray:[NSNumber numberWithInt:SAMPLE_INDEX+1]]; //error: wrong index! (index > size of array)
    }
    @catch(NSException *ex)
    {
        exception = YES;
    }
    STAssertTrue(exception, @"check if an exception was thrown");

    
}


@end
