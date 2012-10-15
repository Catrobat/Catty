//
//  HelperTests.m
//  Catty
//
//  Created by Dominik Ziegler on 10/15/12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "HelperTests.h"
#import "CustomExtensions.h"

@implementation HelperTests

-(void)test001_sha1
{
    
    NSString* result = @"e409e734777e651cc39ea45fc22e61b0e3c304be";
    
    NSString* testString = @"Das ist ein Test String";
    
    STAssertEqualObjects(result, [testString sha1], @"Sha-1 was not correct");
}


@end
