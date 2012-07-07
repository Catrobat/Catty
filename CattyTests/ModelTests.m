//
//  ModelTests.m
//  Catty
//
//  Created by Christof Stromberger on 07.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "ModelTests.h"
#import "Costume.h"


@implementation ModelTests

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
- (void)test001_createBasicCostume
{
    Costume *testCostume = [[Costume alloc] init];
    //testCostume.name = 
    
    STFail(@"Unit tests are not implemented yet in CattyTests");
}

@end
