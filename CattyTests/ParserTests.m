//
//  ParserTests.m
//  Catty
//
//  Created by Christof Stromberger on 15.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "ParserTests.h"
#import "RetailParser.h"
#import "Level.h"

@implementation ParserTests

@synthesize parser = _parser;

#pragma mark - tear up & down
- (void)setUp
{
    [super setUp];

    self.parser = [[RetailParser alloc] init];
}


- (void)tearDown
{    
    [super tearDown];

}

- (void)test001_testBasicParser
{
    NSString *fileName = @"defaultProject";
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:fileName ofType:@"xml"];
    
    Level *level = [self.parser generateObjectForLevel:path];
    STAssertEquals(level.name, @"defaultProject", @"checking if the name of the level is correct");
}

@end
