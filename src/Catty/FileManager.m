/**
 *  Copyright (C) 2010-2013 The Catrobat Team
 *  (http://developer.catrobat.org/credits)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  An additional term exception under section 7 of the GNU Affero
 *  General Public License, version 3, is available at
 *  (http://developer.catrobat.org/license_additional_term)
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see http://www.gnu.org/licenses/.
 */

#import "FileManager.h"
#import "Util.h"
#import "SSZipArchive.h"
#import "Logger.h"
#import "ProgramDetailStoreViewController.h"
#import "ProgramDefines.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface FileManager()

@property (nonatomic, strong, readwrite) NSString *documentsDirectory;
@property (nonatomic, strong, readwrite) NSString *iTunesSoundsDirectory;
@property (nonatomic, strong) NSString *programsDirectory;
@property (nonatomic, strong) NSURLConnection *programConnection;
@property (nonatomic, strong) NSURLConnection *imageConnection;
@property (nonatomic, strong) NSMutableData *programData;
@property (nonatomic, strong) NSMutableData *imageData;
@property (nonatomic, strong) NSMutableDictionary *imageArray;
@property (nonatomic, strong) NSMutableDictionary *programArray;
@property (nonatomic, strong) NSString *projectName;

@end

@implementation FileManager

#pragma mark - Getters and Setters
- (NSString*)documentsDirectory
{
    if (_documentsDirectory == nil) {
        _documentsDirectory = [[NSString alloc] initWithString:[Util applicationDocumentsDirectory]];
    }
    return _documentsDirectory;
}

#warning remove this later!
- (NSString*)iTunesSoundsDirectory
{
    if (_iTunesSoundsDirectory == nil) {
        _iTunesSoundsDirectory = [[NSString alloc] initWithFormat:@"%@/%@", self.documentsDirectory, kITunesSoundsFolder];
    }
    return _iTunesSoundsDirectory;
}

- (NSString*)programsDirectory
{
    if (_programsDirectory == nil) {
        _programsDirectory = [[NSString alloc] initWithFormat:@"%@/%@", self.documentsDirectory, kProgramsFolder];
    }
    return _programsDirectory;
}

- (NSMutableData*)programData {
    if (_programData == nil) {
        _programData = [[NSMutableData alloc] init];
    }
    
    return _programData;
}

- (NSMutableData*)imageData {
    if (_imageData == nil) {
        _imageData = [[NSMutableData alloc] init];
    }
    
    return _imageData;
}

- (NSMutableDictionary*)programArray {
    if (_programArray == nil) {
        _programArray = [[NSMutableDictionary alloc] init];
    }
    
    return _programArray;
}

- (NSMutableDictionary*)imageArray {
    if (_imageArray == nil) {
        _imageArray = [[NSMutableDictionary alloc] init];
    }
    
    return _imageArray;
}

#pragma mark - Operations
- (void)createDirectory:(NSString *)path
{
    NSFileManager *fileManager= [NSFileManager defaultManager];
    NSError *error = nil;
    if(! [self directoryExists:path])
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error];
    NSLogError(error);
}

- (void)deleteAllFilesInDocumentsDirectory
{
    [self deleteAllFilesOfDirectory:self.documentsDirectory];
}

- (void)deleteAllFilesOfDirectory:(NSString*)path {
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if (![path hasSuffix:@"/"]) {
        path = [NSString stringWithFormat:@"%@/", path];
    }
    
    NSError *error = nil;
    for (NSString *file in [fm contentsOfDirectoryAtPath:path error:&error]) {
        BOOL success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@%@", path, file] error:&error];
        NSLogError(error);
        
        if (!success) {
            NSError(@"Error deleting file.");
        }
    }
}

- (BOOL)fileExists:(NSString*)path
{
    BOOL isDir;
    return ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] && (! isDir));
}

- (BOOL)directoryExists:(NSString*)path
{
    BOOL isDir;
    return ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] && isDir);
}

- (void)moveExistingFileOrDirectoryAtPath:(NSString*)oldPath toPath:(NSString*)newPath
{
    if (! [self directoryExists:oldPath])
        return;
    
    // Attempt the move
    NSURL *oldURL = [NSURL fileURLWithPath:oldPath];
    NSURL *newURL = [NSURL fileURLWithPath:newPath];
    NSError *error = nil;
    if ([[NSFileManager defaultManager] moveItemAtURL:oldURL toURL:newURL error:&error] != YES)
        NSLog(@"Unable to move file: %@", [error localizedDescription]);
    NSLogError(error);
}

- (void)deleteDirectory:(NSString *)path
{
    NSError *error = nil;
    [[NSFileManager defaultManager]removeItemAtPath:path error:&error];
    NSLogError(error);
}

- (NSArray*)getContentsOfDirectory:(NSString*)directory {
    NSError *error = nil;
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directory error:&error];
    NSLogError(error);
    
    return contents;
}

- (void)addDefaultProjectsToProgramsRootDirectory
{
    [self addBundleProjectWithName:kDefaultFirstProgramName];
    [self addBundleProjectWithName:kDefaultSecondProgramName];
    [Util setLastProgram:kDefaultFirstProgramName];
}

- (void)addBundleProjectWithName:(NSString*)projectName
{
    NSError *error;

    if (! [[NSFileManager defaultManager] fileExistsAtPath:self.programsDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:self.programsDirectory withIntermediateDirectories:NO attributes:nil error:&error];
        NSLogError(error);
    }

    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.programsDirectory error:&error];
    NSLogError(error);

    if ([contents indexOfObject:projectName]) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:projectName ofType:@"catrobat"];
        NSData *defaultProject = [NSData dataWithContentsOfFile:filePath];
        [self unzipAndStore:defaultProject withName:projectName];
    } else {
        NSInfo(@"%@ already exists...", projectName);
    }
}

- (void)downloadFileFromURL:(NSURL*)url withName:(NSString*)name
{
    self.projectName = name;
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:TIMEOUT];
    
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               [self loadProgram:data andResponse:response];
                           }];
    
    [self.programArray setObject:name forKey:url];
    
    //[[NSURLConnection alloc] initWithRequest:request delegate:self];
    //self.programConnection = connection;
}

- (void)downloadScreenshotFromURL:(NSURL*)url andBaseUrl:(NSURL*)baseurl
{
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:TIMEOUT];
    
    //NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               [self loadImage:data andResponse:response];}];
    //NSString* name = [self.programArray objectForKey:url];
    
    //[self.imageArray setObject:name forKey:url];
    //self.imageConnection = connection;
}


#pragma mark - NSURLConnection Delegates
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //    if (self.programConnection == connection) {
    //        [self.programData appendData:data];
    //    }
    //    else if (self.imageConnection == connection) {
    //        [self.imageData appendData:data];
    //    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //    if (self.programConnection == connection) {
    //        NSDebug(@"Finished program downloading");
    //
    //        [self storeDownloadedProgram];
    //
    //        if ([self.delegate respondsToSelector:@selector(downloadFinished)]) {
    //            [self.delegate performSelector:@selector(downloadFinished)];
    //        }
    //
    //        self.programData = nil;
    //        self.programConnection = nil;
    //        self.projectName = nil;
    //    }
    //    else if (self.imageConnection == connection) {
    //        NSDebug(@"Finished screenshot downloading");
    //        //path may not exist at this point -> another call to
    //        //storeDownloadedImage in unzipAndStore:withName
    //        [self storeDownloadedImage];
    //    }
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    //    if (self.programConnection == connection) {
    //        self.programData = nil;
    //        self.programConnection = nil;
    //        self.projectName = nil;
    //    }
    //    else if (self.imageConnection == connection) {
    //        self.imageData = nil;
    //        self.imageConnection = nil;
    //    }
}

- (NSString*)getFullPathForProgram:(NSString *)programName
{
    NSString *path = [NSString stringWithFormat:@"%@/%@", self.programsDirectory, programName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return path;
    }
    return nil;
}

- (BOOL)documentsDirectoryContainsPlayableSound
{
    NSError *error;
    NSArray *fileNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.documentsDirectory error:&error];
    NSLogError(error);

    for (NSString *fileName in fileNames) {
        // exclude .DS_Store folder on MACOSX simulator
        if ([fileName isEqualToString:@".DS_Store"])
            continue;

        NSString *file = [NSString stringWithFormat:@"%@/%@", self.documentsDirectory, fileName];
        CFStringRef fileExtension = (__bridge CFStringRef)[file pathExtension];
        CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
//        NSString *contentType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass(fileUTI, kUTTagClassMIMEType);
//        NSLog(@"contentType: %@", contentType);

        // check if mime type is playable with AVAudioPlayer
        BOOL isPlayable = UTTypeConformsTo(fileUTI, kUTTypeAudio);
        CFRelease(fileUTI); // manually free this, because ownership was transfered to ARC

        if (isPlayable) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Helper
- (void)storeDownloadedProgram:(NSData*)data andResponse:(NSURLResponse*)response
{
    NSString* name = [self.programArray objectForKey:response.URL];
    [self unzipAndStore:data withName:name];
}

- (void)storeDownloadedImage:(NSData*)data andResponse:(NSURLResponse*)response
{
    if (data != nil) {
        NSString *name = [self.imageArray objectForKey:response.URL];
        NSString *storePath = [NSString stringWithFormat:@"%@/small_screenshot.png", [self getFullPathForProgram:name]];
        //[self resetImageDataAndConnection:response];
        NSDebug(@"path for image is: %@", storePath);
        if ([self.imageData writeToFile:storePath atomically:YES]) {
            //[self resetImageDataAndConnection:response];
        }
    }
}

- (void)unzipAndStore:(NSData*)programData withName:(NSString*)name
{
    NSError *error;
    NSString *tempPath = [NSString stringWithFormat:@"%@temp.zip", NSTemporaryDirectory()];
    [programData writeToFile:tempPath atomically:YES];
    NSString *storePath = [NSString stringWithFormat:@"%@/%@", self.programsDirectory, name];

    NSDebug(@"Starting unzip");
    [SSZipArchive unzipFileAtPath:tempPath toDestination:storePath];
    NSDebug(@"Unzip finished");

    NSDebug(@"Removing temp zip file");
    [[NSFileManager defaultManager] removeItemAtPath:tempPath error:&error];

    [Logger logError:error];

    //image-data may not be complete at this point -> another call to
    //storeDownloadedImage in connectionDidFinishLoading
    if (self.imageArray.count > 0) {
        NSArray *temp = [self.imageArray allKeysForObject:name];
        if (temp) {
            NSURLResponse *key = [temp objectAtIndex:0];
            [self storeDownloadedImage:programData andResponse:key];
        }
    }
}

- (void)resetImageDataAndConnection:(NSURLResponse*)response
{
    [self.imageArray removeObjectForKey:response.URL];
}

- (void)resetProgramDatawithKey:(NSURLResponse*)response
{
    [self.programArray removeObjectForKey:response.URL];
}

- (void)loadProgram:(NSData*)data andResponse:(NSURLResponse*)response
{
    [self storeDownloadedProgram:data andResponse:response];
    //    if ([_delegate respondsToSelector:@selector(downloadFinished)]) {
    //        [_delegate performSelector:@selector(downloadFinished)];
    //    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"finishedloading" object:nil];
    self.programData = nil;
    self.programConnection = nil;
    self.projectName = nil;
}

-(void)loadImage:(NSData*)data andResponse:(NSURLResponse*)response
{
    [self storeDownloadedImage:data andResponse: response];
}

@end
