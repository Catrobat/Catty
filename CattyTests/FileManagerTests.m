//
//  FileManagerTests.m
//  Catty
//
//  Created by Christof Stromberger on 25.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "FileManagerTests.h"
#import "Util.h"

@implementation FileManagerTests

@synthesize fileManager = _fileManager;

#pragma mark - tear up & down
- (void)setUp
{
    [super setUp];
    
    self.fileManager = [[FileManager alloc] init];
}

- (void)tearDown
{
    [super tearDown];
    
}

- (void)test001_testDocumentsDirectory {
    NSString *documentsDirectory = [Util applicationDocumentsDirectory];
    STAssertNotNil(documentsDirectory, @"checking documents directory");
    STAssertTrue([documentsDirectory hasSuffix:@"/Documents"], @"checking last folder of path");
}


@end
