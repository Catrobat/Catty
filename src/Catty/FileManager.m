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
#import "AppDelegate.h"
#import "Sound.h"
#import "Program.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface FileManager()

@property (nonatomic, strong, readwrite) NSString *documentsDirectory;
@property (nonatomic, strong) NSString *programsDirectory;
@property (nonatomic, strong) NSMutableDictionary *imageArray;
@property (nonatomic, strong) NSMutableDictionary *programArray;
@property (nonatomic, strong) NSMutableDictionary *programDataArray;
@property (nonatomic, strong) NSMutableDictionary *imageDataArray;
@property (nonatomic, strong) NSMutableArray *connectionArray;
@property (nonatomic,strong) NSMutableDictionary *progressDict;
@property (nonatomic,strong) NSMutableDictionary *downloadSizeDict;
@property (nonatomic) long long downloadsize;

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

- (NSString*)programsDirectory
{
    if (_programsDirectory == nil) {
        _programsDirectory = [[NSString alloc] initWithFormat:@"%@/%@", self.documentsDirectory, kProgramsFolder];
    }
    return _programsDirectory;
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


-(NSMutableDictionary*)programDataArray
{
    if (!_programDataArray) {
        _programDataArray = [[NSMutableDictionary alloc] init];
    }
    return _programDataArray;
}
-(NSMutableDictionary*)imageDataArray
{
    if (!_imageDataArray) {
        _imageDataArray = [[NSMutableDictionary alloc] init];
    }
    return _imageDataArray;
}
-(NSMutableArray*)connectionArray
{
    if (!_connectionArray) {
        _connectionArray = [[NSMutableArray alloc] init];
    }
    return _connectionArray;
}
-(NSMutableDictionary*)progressDict
{
    if (!_progressDict) {
        _progressDict = [[NSMutableDictionary alloc] init];
    }
    return _progressDict;
}
-(NSMutableDictionary*)downloadSizeDict
{
    if (!_downloadSizeDict) {
        _downloadSizeDict = [[NSMutableDictionary alloc] init];
    }
    return _downloadSizeDict;
}


#pragma mark - Operations
- (void)createDirectory:(NSString *)path
{
    NSFileManager *fileManager= [NSFileManager defaultManager];
    NSError *error = nil;
    if (! [self directoryExists:path])
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

- (void)copyExistingFileAtPath:(NSString*)oldPath toPath:(NSString*)newPath
{
    if (! [self fileExists:oldPath])
        return;

    // Attempt the copy
    NSURL *oldURL = [NSURL fileURLWithPath:oldPath];
    NSURL *newURL = [NSURL fileURLWithPath:newPath];
    NSError *error = nil;
    if ([[NSFileManager defaultManager] copyItemAtURL:oldURL toURL:newURL error:&error] != YES)
        NSLog(@"Unable to copy file: %@", [error localizedDescription]);
    NSLogError(error);
}

- (void)copyExistingDirectoryAtPath:(NSString*)oldPath toPath:(NSString*)newPath
{
    if (! [self directoryExists:oldPath])
        return;

    // Attempt the copy
    NSURL *oldURL = [NSURL fileURLWithPath:oldPath];
    NSURL *newURL = [NSURL fileURLWithPath:newPath];
    NSError *error = nil;
    if ([[NSFileManager defaultManager] copyItemAtURL:oldURL toURL:newURL error:&error] != YES)
        NSLog(@"Unable to copy file: %@", [error localizedDescription]);
    NSLogError(error);
}

- (void)moveExistingFileAtPath:(NSString*)oldPath toPath:(NSString*)newPath
{
    if (! [self fileExists:oldPath])
        return;

    // Attempt the move
    NSURL *oldURL = [NSURL fileURLWithPath:oldPath];
    NSURL *newURL = [NSURL fileURLWithPath:newPath];
    NSError *error = nil;
    if ([[NSFileManager defaultManager] moveItemAtURL:oldURL toURL:newURL error:&error] != YES)
        NSLog(@"Unable to move file: %@", [error localizedDescription]);
    NSLogError(error);
}

- (void)moveExistingDirectoryAtPath:(NSString*)oldPath toPath:(NSString*)newPath
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
    NSString *basePath = [Program basePath];
    NSError *error;
    NSArray *programLoadingInfos = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:basePath error:&error];
    NSLogError(error);

    BOOL firstProgramExists = NO;
    BOOL secondProgramExists = NO;
    for (NSString *programLoadingInfo in programLoadingInfos) {
        if ([programLoadingInfo isEqualToString:kDefaultFirstProgramName]) {
            firstProgramExists = YES;
        } else if ([programLoadingInfo isEqualToString:kDefaultSecondProgramName]) {
            secondProgramExists = YES;
        }
    }
    if (firstProgramExists) {
        [self addBundleProjectWithName:kDefaultFirstProgramName];
    }
    if (secondProgramExists) {
        [self addBundleProjectWithName:kDefaultSecondProgramName];
    }

    if (! [Util lastProgram]) {
        [Util setLastProgram:kDefaultFirstProgramName];
    }
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
    NSDebug(@"%@",url);
//    NSOperationQueue * queue = [[NSOperationQueue alloc]init];
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:TIMEOUT];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
//    NSLog(@"Data: %@",connection);
//    [NSURLConnection sendAsynchronousRequest:request
//                                       queue:queue
//                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
////                               if (![queue isSuspended]) {
//                                   [self loadProgram:data andResponse:response];
////                               }
//                               
//                           }];
    [self.programArray setObject:name forKey:connection.currentRequest.URL];
    [self.connectionArray addObject:connection];
}

- (void)downloadScreenshotFromURL:(NSURL*)url andBaseUrl:(NSURL*)baseurl andName:(NSString*) name
{
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:TIMEOUT];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSDebug(@"Image: %@",connection);
//    [NSURLConnection sendAsynchronousRequest:request
//                                       queue:[NSOperationQueue mainQueue]
//                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
//                               [self loadImage:data andResponse:response];}];
    //NSString* name = [self.programArray objectForKey:url];
    
    [self.imageArray setObject:name forKey:connection.currentRequest.URL];
    [self.connectionArray addObject:connection];
    //self.imageConnection = connection;
}

#pragma mark - NSURLConnection Delegates


-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSMutableData* data = [[NSMutableData alloc] init];
    
    NSString* name = [self.programArray objectForKey:connection.currentRequest.URL];
    if (name) {
        [self.programDataArray setObject:data forKey:connection.currentRequest.URL];
        NSNumber *progress = [NSNumber numberWithFloat:0];
        [self.progressDict setObject:progress forKey:connection.currentRequest.URL];
    }
    else
    {
        [self.imageDataArray setObject:data forKey:connection.currentRequest.URL];
    }
    
    NSNumber* size = [NSNumber numberWithLongLong:[response expectedContentLength]];
    ///Length of data!!!
    [self.downloadSizeDict setObject:size forKey:connection.currentRequest.URL];

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSMutableData* storedData = [self.programDataArray objectForKey:connection.currentRequest.URL];
    if (storedData) {
        [storedData appendData:data];
        
        [self.programDataArray removeObjectForKey:connection.currentRequest.URL];
        [self.programDataArray setObject:storedData forKey:connection.currentRequest.URL];

    }
    else{
        storedData =[self.imageDataArray objectForKey:connection.currentRequest.URL];
        
        [storedData appendData:data];
        
        [self.imageDataArray removeObjectForKey:connection.currentRequest];
        [self.imageDataArray setObject:storedData forKey:connection.currentRequest.URL];

    }
    //do something with data length
    NSNumber* progress = [self.progressDict objectForKey:connection.currentRequest.URL];
    [self.progressDict removeObjectForKey:connection.currentRequest.URL];
    
    NSNumber* size = [self.downloadSizeDict objectForKey:connection.currentRequest.URL];
    NSDebug(@"%f",progress.floatValue+((float) [data length] / (float) size.longLongValue));
    progress = [NSNumber numberWithFloat:progress.floatValue+((float) [data length] / (float) size.longLongValue)];
    [self.progressDict setObject:progress forKey:connection.currentRequest.URL];
    if ([self.delegate respondsToSelector:@selector(updateProgress:)]) {
        if (progress.floatValue == 1) {
            [self.delegate updateProgress:progress.floatValue-1];
        }
        else{
            [self.delegate updateProgress:progress.floatValue];
        }
        
    }
    NSDebug(@"%f",progress.floatValue+((float) [data length] / (float) size.longLongValue));

    //    if (self.programConnection == connection) {
    //        [self.programData appendData:data];
    //    }
    //    else if (self.imageConnection == connection) {
    //        [self.imageData appendData:data];
    //    }
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    NSMutableData* storedData = [self.programDataArray objectForKey:connection.currentRequest.URL];
    if (storedData) {
        [self storeDownloadedProgram:storedData andConnection:connection];
        
        [self.programDataArray removeObjectForKey:connection.currentRequest.URL];
        [self resetProgramDatawithKey:connection];
        [self.progressDict removeObjectForKey:connection.currentRequest.URL];
        [self.downloadSizeDict removeObjectForKey:connection.currentRequest.URL];
    }
    else{
        storedData =[self.imageDataArray objectForKey:connection.currentRequest.URL];
        
        [self storeDownloadedImage:storedData andURL:connection.currentRequest.URL];
        [self.imageDataArray removeObjectForKey:connection.currentRequest.URL];
        [self resetImageDataAndConnection:connection];
        
    }
    
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
    [self resetImageDataAndConnection:connection];
    [self resetProgramDatawithKey:connection];
    [self.imageDataArray removeObjectForKey:connection.currentRequest.URL];
    [self.programDataArray removeObjectForKey:connection.currentRequest.URL];
    [self.progressDict removeObjectForKey:connection.currentRequest.URL];
    [self.downloadSizeDict removeObjectForKey:connection.currentRequest.URL];
    [connection cancel];
    
}

- (NSString*)getFullPathForProgram:(NSString *)programName
{
    NSString *path = [NSString stringWithFormat:@"%@/%@", self.programsDirectory, programName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return path;
    }
    return nil;
}

- (BOOL)existPlayableSoundsInDirectory:(NSString*)directoryPath
{
    return ([[self playableSoundsInDirectory:directoryPath] count] > 0);
}

- (NSArray*)playableSoundsInDirectory:(NSString*)directoryPath
{
    NSError *error;
    NSArray *fileNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:&error];
    NSLogError(error);

    NSMutableArray *sounds = [NSMutableArray array];
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
            Sound *sound = [[Sound alloc] init];
            NSArray *fileParts = [fileName componentsSeparatedByString:@"."];
            NSString *fileNameWithoutExtension = ([fileParts count] ? [fileParts objectAtIndex:0] : fileName);
            sound.fileName = fileName;
            sound.name = fileNameWithoutExtension;
            sound.playing = NO;
            [sounds addObject:sound];
        }
    }
    return [sounds copy];
}

#pragma mark - Helper
- (void)storeDownloadedProgram:(NSData*)data andConnection:(NSURLConnection*)connection
{
    NSString* name = [self.programArray objectForKey:connection.currentRequest.URL];
    [self unzipAndStore:data withName:name];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"finishedloading" object:nil];
}

- (void)storeDownloadedImage:(NSData*)data andURL:(NSURL*)url
{
    if (data != nil) {
        NSString *name = [self.imageArray objectForKey:url];
        NSString *storePath = [NSString stringWithFormat:@"%@/small_screenshot.png", [self getFullPathForProgram:name]];
        NSDebug(@"path for image is: %@", storePath);
        if ([data writeToFile:storePath atomically:YES]) {
//            [self resetImageDataAndConnection:response];
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
            NSURL *key = [temp objectAtIndex:0];
            [self storeDownloadedImage:programData andURL:key];
        }
    }
}

- (void)resetImageDataAndConnection:(NSURLConnection*)connection
{
    [self.imageArray removeObjectForKey:connection.currentRequest.URL];
}

- (void)resetProgramDatawithKey:(NSURLConnection*)connection
{
    [self.programArray removeObjectForKey:connection.currentRequest.URL];
}


-(void)loadImage:(NSData*)data andResponse:(NSURLConnection*)connection
{
    [self storeDownloadedImage:data andURL:connection.currentRequest.URL];
}

-(void)stopLoading:(NSURL *)projecturl andImageURL:(NSURL *)imageurl
{
    for (NSURLConnection* connection in self.connectionArray) {
        if ([connection.currentRequest.URL isEqual:projecturl]) {
            [connection cancel];
            [self.connectionArray removeObject:connection];
            return;
        }
        if ([connection.currentRequest.URL isEqual:imageurl]) {
            [connection cancel];
            [self.connectionArray removeObject:connection];
            return;
        }

    }
    [self.progressDict removeObjectForKey:projecturl];
    [self.downloadSizeDict removeObjectForKey:projecturl];
}

@end
