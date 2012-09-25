//
//  FileManager.m
//  Catty
//
//  Created by Christof Stromberger on 25.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "FileManager.h"
#import "Util.h"

@interface FileManager()

@property (nonatomic, strong) NSString *documentsDirectory;

@end


@implementation FileManager

@synthesize documentsDirectory = _documentsDirectory;


//custom getter method for documents directory member property
- (NSString*)documentsDirectory {
    if (_documentsDirectory == nil) {
        _documentsDirectory = [[NSString alloc] initWithString:[Util applicationDocumentsDirectory]];
    }
    
    return _documentsDirectory;
}


//deleting all files of documents directory
- (void)deleteAllFiles {
    [self deleteAllFillesOfDirectory:self.documentsDirectory];
}


//deleting all files of specified path
- (void)deleteAllFillesOfDirectory:(NSString*)path {
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if (![path hasSuffix:@"/"]) {
        path = [NSString stringWithFormat:@"%@/", path];
    }
    
    NSError *error = nil;
    for (NSString *file in [fm contentsOfDirectoryAtPath:path error:&error]) {
        BOOL success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@%@", path, file] error:&error];
        [Util log:error];
        
        if (!success) {
            NSLog(@"Error deleting file.");
        }
    }
}

@end
