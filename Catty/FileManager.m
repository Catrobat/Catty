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
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSString *projectName;

@end


@implementation FileManager

@synthesize documentsDirectory = _documentsDirectory;
@synthesize levelsDirectory    = _levelsDirectory;
@synthesize connection         = _connection;
@synthesize data               = _data;
@synthesize projectName        = _projectName;


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

//custom getter for data
- (NSMutableData*)data {
    if (_data == nil) {
        _data = [[NSMutableData alloc] init];
    }
    
    return _data;
}



/* ---------------------------- METHODS ----------------------------------- */



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
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.levelsDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:self.levelsDirectory withIntermediateDirectories:NO attributes:nil error:&error];
        [Util log:error];
    }
    
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.levelsDirectory error:&error];
    [Util log:error];
    
    if ([contents indexOfObject:@"DefaultProject"]) {
        //default project does not exist
        NSString *projectName = @"DefaultProject";
        
        NSString *filePath = [[NSBundle mainBundle] pathForResource:projectName ofType:@"catrobat"];
        NSData *defaultProject = [NSData dataWithContentsOfFile:filePath];
        
        //storing level
        [self unzipAndStore:defaultProject withName:projectName];
    }
    else { //default project already exists in levels folder
        NSLog(@"DefaultProject already exists...");
    }
    
}

- (void)downloadFileFromURL:(NSURL*)url withName:(NSString*)name {   
    self.projectName = name;
    
    //creating url request
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:TIMEOUT];
    
    //creating connection
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    self.connection = connection;
}


#pragma mark - NSURLConnection Delegates
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (self.connection == connection) {
        //NSLog(@"Received data from server");
        [self.data appendData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (self.connection == connection) {
        NSLog(@"Finished");
        
        //storing level
        [self storeDownloadedLevel];
               
        //freeing space
        self.data = nil;
        self.connection = nil;
        self.projectName = nil;
        
        //reloading view
        //[self update];
    }
}

//connection error
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"An connection error occured!");
    
    if (self.connection == connection) {
        self.data = nil;
        self.connection = nil;
        self.projectName = nil;
    }
}




/* ------------------------------- HELPER ----------------------------------- */

- (void)storeDownloadedLevel {
    NSData *levelZip = [NSData dataWithData:self.data];
    self.data = nil;
    
    [self unzipAndStore:levelZip withName:self.projectName];
}

//unzip and store this level
- (void)unzipAndStore:(NSData*)level withName:(NSString*)name {
    NSError *error;
    
    //path for temp file
    NSString *tempPath = [NSString stringWithFormat:@"%@temp.zip", NSTemporaryDirectory()];
    
    //writing to file
    [level writeToFile:tempPath atomically:YES];
    
    //path for storing file
    //    NSString *storePath = [NSString stringWithFormat:@"%@/levels/RocketProject", documentsDirectory];
    NSString *storePath = [NSString stringWithFormat:@"%@/levels/%@", self.documentsDirectory, name];
    
    
    NSLog(@"Starting unzip");
    
    //unzip file
    [SSZipArchive unzipFileAtPath:tempPath toDestination:storePath];
    
    NSLog(@"Unzip finished");
    
    NSLog(@"Removing temp zip file");
    [[NSFileManager defaultManager] removeItemAtPath:tempPath error:&error];
    [Util log:error];
}



@end
