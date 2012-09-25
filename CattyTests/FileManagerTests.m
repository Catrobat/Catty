//
//  FileManagerTests.m
//  Catty
//
//  Created by Christof Stromberger on 25.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "FileManagerTests.h"
#import "Util.h"

#define SAMPLE_FOLDER @"TESTCASEFOLDER"

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


- (void)test002_testContentsOfDirectory {
    NSString *documentsDirectory = [Util applicationDocumentsDirectory];
    
    NSArray *contents1 = [self.fileManager getContentsOfDirectory:documentsDirectory];
    NSString *newFolderPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, SAMPLE_FOLDER];
    
    //creating new directory
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:newFolderPath withIntermediateDirectories:NO attributes:nil error:&error];
    STAssertNil(error, @"checking if an error occured");
    
    NSArray *contents2 = [self.fileManager getContentsOfDirectory:documentsDirectory];
    STAssertFalse(([contents1 count] == [contents2 count]+1), @"checking if there is one more folder");
    
    //deleting directory
    [[NSFileManager defaultManager] removeItemAtPath:newFolderPath error:&error];
    STAssertNil(error, @"checking if an error occured");
    
    NSArray *contents3 = [self.fileManager getContentsOfDirectory:documentsDirectory];
    STAssertTrue(([contents1 count] == [contents3 count]), @"checking if deletion succeded");
}

- (void)test003_addDefaultProject {
    NSString *levelDirectory = [NSString stringWithFormat:@"%@/levels", [Util applicationDocumentsDirectory]];
    NSArray *contents1 = [self.fileManager getContentsOfDirectory:levelDirectory];
    
    [self.fileManager addDefaultProject];
}


@end
