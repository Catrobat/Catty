//
//  DataModelCostumeTests.m
//  Catty
//
//  Created by Christof Stromberger on 07.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "DataModelCostumeTests.h"
#import "Look.h"

#define SAMPLE_NAME @"KittyCat"
#define SAMPLE_PATH @"normalcat.png"


@implementation DataModelCostumeTests

//#pragma mark - test cases
////just a basic test
//- (void)test001_createBasicCostumeNameTest
//{
//    Costume *testCostume = [[Costume alloc] initWithName:SAMPLE_NAME andPath:SAMPLE_PATH];
//    
//    STAssertEquals(testCostume.costumeName, SAMPLE_NAME, @"check name");
//    STAssertEquals(testCostume.costumeFileName, SAMPLE_PATH, @"check path");
//
//}
//
////this test case checks if it is possible to set nil as path for a custome
//- (void)test002_createCostumeWithInvalidPath
//{
//    BOOL exception = NO;
//    @try
//    {
//        Costume *testCostume __attribute__((unused)) = [[Costume alloc] initWithName:SAMPLE_NAME andPath:nil];
//    }
//    @catch(NSException *ex)
//    {
//        exception = YES;
//    }
//    STAssertTrue(exception, @"check if an exception was thrown");
//    
//    exception = NO;
//    @try
//    {
//        Costume *testCostume __attribute__((unused)) = [[Costume alloc] initWithPath:nil];
//    }
//    @catch(NSException *ex)
//    {
//        exception = YES;
//    }
//    STAssertTrue(exception, @"check if an exception was thrown");
//}

@end
