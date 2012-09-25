//
//  FileManager.m
//  Catty
//
//  Created by Christof Stromberger on 25.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "FileManager.h"
#import "Util.h"
#import "SSZipArchive.h"

@interface FileManager()

@property (nonatomic, strong) NSString *documentsDirectory;
@property (nonatomic, strong) NSString *levelsDirectory;

@end


@implementation FileManager

@synthesize documentsDirectory = _documentsDirectory;
@synthesize levelsDirectory    = _levelsDirectory;


//custom getter method for documents directory member property
- (NSString*)documentsDirectory {
    if (_documentsDirectory == nil) {
        _documentsDirectory = [[NSString alloc] initWithString:[Util applicationDocumentsDirectory]];
    }
    
    return _documentsDirectory;
}

//custom getter for levels directory
- (NSString*)levelsDirectory {
    if (_levelsDirectory == nil) {
        _levelsDirectory = [[NSString alloc] initWithFormat:@"%@/levels", self.documentsDirectory];
    }
    
    return _levelsDirectory;
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

//retrieving contents of directory
- (NSArray*)getContentsOfDirectory:(NSString*)directory {
    NSError *error = nil;
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directory error:&error];
    [Util log:error];
    
    return contents;
}


//this method adds the default project to the levels folder
- (void)addDefaultProject {
    NSError *error;
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.levelsDirectory error:&error];
    [Util log:error];
    
    if ([contents indexOfObject:@"DefaultProject"]) {
        //default project does not exist
        
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"DefaultProject" ofType:@"catrobat"];
        NSData *defaultProject = [NSData dataWithContentsOfFile:filePath];
        
        //path for temp file
        NSString *tempPath = [NSString stringWithFormat:@"%@temp.zip", NSTemporaryDirectory()];
        
        //writing to file
        [defaultProject writeToFile:tempPath atomically:YES];
        
        //path for storing file
        //    NSString *storePath = [NSString stringWithFormat:@"%@/levels/RocketProject", documentsDirectory];
        NSString *storePath = [NSString stringWithFormat:@"%@/levels/DefaultProject", self.documentsDirectory];
        
        
        NSLog(@"Starting unzip");
        
        //unzip file
        [SSZipArchive unzipFileAtPath:tempPath toDestination:storePath];
        
        NSLog(@"Unzip finished");
        
        NSLog(@"Removing temp zip file");
        [[NSFileManager defaultManager] removeItemAtPath:tempPath error:&error];
        [Util log:error];
        
//        NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/levels", self.documentsDirectory] error:&error];
//        [Util log:error];
//        NSLog(@"Contents: %@", contents);   
        
    }
    else { //default project already exists in levels folder
        NSLog(@"DefaultProject already exists...");
    }
    
}



@end
