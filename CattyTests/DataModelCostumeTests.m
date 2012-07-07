//
//  DataModelCostumeTests.m
//  Catty
//
//  Created by Christof Stromberger on 07.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "DataModelCostumeTests.h"
#import "Costume.h"

#define SAMPLE_NAME @"KittyCat"
#define SAMPLE_PATH @"kittycat.png"


@implementation DataModelCostumeTests

#pragma mark - tear up & down
- (void)setUp
{
    [super setUp];
}


- (void)tearDown
{    
    [super tearDown];
}

#pragma mark - test cases
//just a basic test
- (void)test001_createBasicCostumeNameTest
{
    Costume *testCostume = [[Costume alloc] initWithName:SAMPLE_NAME andPath:SAMPLE_PATH];
    
    STAssertEquals(testCostume.name, SAMPLE_NAME, @"check name");
    STAssertEquals(testCostume.filePath, SAMPLE_PATH, @"check path");

}

//this test case checks if it is possible to set nil as path for a custome
- (void)test002_createCostumeWithInvalidPath
{
    BOOL exception = NO;
    @try
    {
        Costume *testCostume __attribute__((unused)) = [[Costume alloc] initWithName:SAMPLE_NAME andPath:nil];
    }
    @catch(NSException *ex)
    {
        exception = YES;
    }
    STAssertTrue(exception, @"check if an exception was thrown");
    
    exception = NO;
    @try
    {
        Costume *testCostume __attribute__((unused)) = [[Costume alloc] initWithPath:nil];
    }
    @catch(NSException *ex)
    {
        exception = YES;
    }
    STAssertTrue(exception, @"check if an exception was thrown");
}

@end
