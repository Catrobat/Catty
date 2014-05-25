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
#import "LanguageTranslationDefines.h"

@interface FileManager()

@property (nonatomic, strong, readwrite) NSString *documentsDirectory;
@property (nonatomic, strong) NSString *programsDirectory;
@property (nonatomic, strong) NSMutableDictionary *imageTaskDict;
@property (nonatomic, strong) NSMutableDictionary *programTaskDict;
@property (nonatomic, strong) NSMutableDictionary *programNameDict;
@property (nonatomic, strong) NSMutableDictionary *imageNameDict;


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


- (NSMutableDictionary*)programTaskDict {
    if (_programTaskDict == nil) {
        _programTaskDict = [[NSMutableDictionary alloc] init];
    }
    return _programTaskDict;
}

- (NSMutableDictionary*)imageTaskDict {
    if (_imageTaskDict == nil) {
        _imageTaskDict = [[NSMutableDictionary alloc] init];
    }
    return _imageTaskDict;
}


-(NSMutableDictionary*)programNameDict
{
    if (!_programNameDict) {
        _programNameDict = [[NSMutableDictionary alloc] init];
    }
    return _programNameDict;
}
-(NSMutableDictionary*)imageNameDict
{
    if (!_imageNameDict) {
        _imageNameDict = [[NSMutableDictionary alloc] init];
    }
    return _imageNameDict;
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

#pragma mark - Operations
- (void)createDirectory:(NSString *)path
{
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSLog(@"Create directory at path: %@", path);
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

- (void)copyExistingFileAtPath:(NSString*)oldPath toPath:(NSString*)newPath overwrite:(BOOL)overwrite
{
    if (! [self fileExists:oldPath])
        return;

    if ((! [self fileExists:newPath]) || overwrite) {
        NSData *data = [NSData dataWithContentsOfFile:oldPath];
        [data writeToFile:newPath atomically:YES];
    }

//    NSURL *oldURL = [NSURL fileURLWithPath:oldPath];
//    NSURL *newURL = [NSURL fileURLWithPath:newPath];
//    NSError *error = nil;
//    if ([[NSFileManager defaultManager] copyItemAtURL:oldURL toURL:newURL error:&error] != YES)
//        NSLog(@"Unable to copy file: %@", [error localizedDescription]);
//    NSLogError(error);
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
        NSLog(@"Unable to move directory: %@", [error localizedDescription]);
    NSLogError(error);
}

- (void)deleteDirectory:(NSString *)path
{
    NSError *error = nil;
    [[NSFileManager defaultManager]removeItemAtPath:path error:&error];
    NSLogError(error);
}

- (NSUInteger)sizeOfDirectoryAtPath:(NSString*)path
{
    if (! [self directoryExists:path]) {
        return 0;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *filesArray = [fileManager subpathsOfDirectoryAtPath:path error:nil];
    NSEnumerator *filesEnumerator = [filesArray objectEnumerator];
    NSString *fileName;
    NSUInteger fileSize = 0;
    NSError *error = nil;
    while (fileName = [filesEnumerator nextObject]) {
        NSDictionary *fileDictionary = [fileManager attributesOfItemAtPath:[path stringByAppendingPathComponent:fileName] error:&error];
        NSLogError(error);
        fileSize += [fileDictionary fileSize];
    }
    return fileSize;
}

- (NSUInteger)sizeOfFileAtPath:(NSString*)path
{
    if (! [self fileExists:path]) {
        return 0;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSDictionary *fileDictionary = [fileManager attributesOfItemAtPath:path error:&error];
    NSLogError(error);
    return [fileDictionary fileSize];
}

- (NSDate*)lastModificationTimeOfFile:(NSString*)path
{
    if (! [self fileExists:path]) {
        return 0;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSDictionary *fileDictionary = [fileManager attributesOfItemAtPath:path error:&error];
    NSLogError(error);
    return [fileDictionary fileModificationDate];
}

- (NSArray*)getContentsOfDirectory:(NSString*)directory
{
    NSError *error = nil;
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directory error:&error];
    NSLogError(error);
    return contents;
}

- (void)addDefaultProgramToProgramsRootDirectoryIfNoProgramsExist
{
    NSString *basePath = [Program basePath];
    NSError *error;
    NSArray *programLoadingInfos = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:basePath error:&error];
    NSLogError(error);

    BOOL areAnyProgramsLeft = NO;
    for (NSString *programLoadingInfo in programLoadingInfos) {
        // exclude .DS_Store folder on MACOSX simulator
        if ([programLoadingInfo isEqualToString:@".DS_Store"]) {
            continue;
        }
        areAnyProgramsLeft = YES;
        break;
    }
    if (! areAnyProgramsLeft) {
        [self addBundleProgramWithName:kDefaultProgramName];
        [Util lastProgram];
    }
}

- (void)addBundleProgramWithName:(NSString*)projectName
{
    NSError *error;
    if (! [self directoryExists:self.programsDirectory]) {
        [self createDirectory:self.programsDirectory];
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
////    NSOperationQueue * queue = [[NSOperationQueue alloc]init];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url
//                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
//                                         timeoutInterval:TIMEOUT];
//    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
////    NSLog(@"Data: %@",connection);
////    [NSURLConnection sendAsynchronousRequest:request
////                                       queue:queue
////                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
//////                               if (![queue isSuspended]) {
////                                   [self loadProgram:data andResponse:response];
//////                               }
////                               
////                           }];
//    [self.programArray setObject:name forKey:connection.currentRequest.URL];
//    [self.connectionArray addObject:connection];

    NSURLSessionConfiguration *sessionConfig =
    [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session =
    [NSURLSession sessionWithConfiguration:sessionConfig
                                  delegate:self
                             delegateQueue:nil];

    NSURLSessionDownloadTask *getProgramTask =
    [session downloadTaskWithURL:url];
    
    [self.programTaskDict setObject:url forKey:getProgramTask];
    [self.programNameDict setObject:name forKey:getProgramTask];
    [getProgramTask resume];

}

- (void)downloadScreenshotFromURL:(NSURL*)url andBaseUrl:(NSURL*)baseurl andName:(NSString*) name
{
//    NSURLRequest *request = [NSURLRequest requestWithURL:url
//                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
//                                         timeoutInterval:TIMEOUT];
//    
//    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
//    NSDebug(@"Image: %@",connection);
////    [NSURLConnection sendAsynchronousRequest:request
////                                       queue:[NSOperationQueue mainQueue]
////                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
////                               [self loadImage:data andResponse:response];}];
//    //NSString* name = [self.programArray objectForKey:url];
//    
//    [self.imageArray setObject:name forKey:connection.currentRequest.URL];
//    [self.connectionArray addObject:connection];
    //self.imageConnection = connection;
    
    NSURLSessionConfiguration *sessionConfig =
    [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session =
    [NSURLSession sessionWithConfiguration:sessionConfig
                                  delegate:self
                             delegateQueue:nil];
    
    NSURLSessionDownloadTask *getImageTask =
    [session downloadTaskWithURL:url];
    
    [self.imageTaskDict setObject:url forKey:getImageTask];
    [self.imageNameDict setObject:name forKey:getImageTask];
    [getImageTask resume];
    
    
    
}

- (void)changeModificationDate:(NSDate*)date forFileAtPath:(NSString*)path
{
    if (! [self fileExists:path]) {
        return;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:date, NSFileModificationDate, NULL];
    [fileManager setAttributes:attributes ofItemAtPath:path error:&error];
    NSLogError(error);
}

#pragma mark - NSURLConnection Delegates
//-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
//{
//    NSMutableData* data = [[NSMutableData alloc] init];
//    
//    NSString* name = [self.programArray objectForKey:connection.currentRequest.URL];
//    if (name) {
//        [self.programDataArray setObject:data forKey:connection.currentRequest.URL];
//        NSNumber *progress = [NSNumber numberWithFloat:0];
//        [self.progressDict setObject:progress forKey:connection.currentRequest.URL];
//    }
//    else
//    {
//        [self.imageDataArray setObject:data forKey:connection.currentRequest.URL];
//    }
//    
//    if ([self getFreeDiskspace]>[response expectedContentLength]) {
//        NSNumber* size = [NSNumber numberWithLongLong:[response expectedContentLength]];
//        ///Length of data!!!
//        [self.downloadSizeDict setObject:size forKey:connection.currentRequest.URL];
//        
//        UIApplication* app = [UIApplication sharedApplication];
//        app.networkActivityIndicatorVisible = YES;
//    }else{
//        [self stopLoading:connection.currentRequest.URL andImageURL:connection.currentRequest.URL];
//        [Util alertWithText:kUIAlertViewTitleNotEnoughFreeMemory];
//        if ([self.delegate respondsToSelector:@selector(setBackDownloadStatus)]) {
//            [self.delegate setBackDownloadStatus];
//        }
//    
//    }
//    
//    NSNumber* size = [NSNumber numberWithLongLong:[response expectedContentLength]];
//    ///Length of data!!!
//    [self.downloadSizeDict setObject:size forKey:connection.currentRequest.URL];
//
//    UIApplication* app = [UIApplication sharedApplication];
//    app.networkActivityIndicatorVisible = YES;
//}

//- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
//{
//    NSMutableData* storedData = [self.programDataArray objectForKey:connection.currentRequest.URL];
//    if (storedData) {
//        [storedData appendData:data];
//        
//        [self.programDataArray removeObjectForKey:connection.currentRequest.URL];
//        [self.programDataArray setObject:storedData forKey:connection.currentRequest.URL];
//
//    }
//    else{
//        storedData =[self.imageDataArray objectForKey:connection.currentRequest.URL];
//        
//        [storedData appendData:data];
//        
//        [self.imageDataArray removeObjectForKey:connection.currentRequest];
//        [self.imageDataArray setObject:storedData forKey:connection.currentRequest.URL];
//
//    }
//    //do something with data length
//    NSNumber* progress = [self.progressDict objectForKey:connection.currentRequest.URL];
//    [self.progressDict removeObjectForKey:connection.currentRequest.URL];
//    
//    NSNumber* size = [self.downloadSizeDict objectForKey:connection.currentRequest.URL];
//    NSDebug(@"%f",progress.floatValue+((float) [data length] / (float) size.longLongValue));
//    progress = [NSNumber numberWithFloat:progress.floatValue+((float) [data length] / (float) size.longLongValue)];
//    [self.progressDict setObject:progress forKey:connection.currentRequest.URL];
//    
//    if ([self.delegate respondsToSelector:@selector(updateProgress:)] && [self.projectURL isEqual:connection.currentRequest.URL]) {
//        if (progress.floatValue == 1) {
//            [self.delegate updateProgress:progress.floatValue-1];
//        }
//        else{
//            [self.delegate updateProgress:progress.floatValue];
//        }
//        
//    }
//    UIApplication* app = [UIApplication sharedApplication];
//    app.networkActivityIndicatorVisible = YES;
//    
//    NSDebug(@"%f",progress.floatValue+((float) [data length] / (float) size.longLongValue));
//
//    //    if (self.programConnection == connection) {
//    //        [self.programData appendData:data];
//    //    }
//    //    else if (self.imageConnection == connection) {
//    //        [self.imageData appendData:data];
//    //    }
//    
//}
//
//- (void)connectionDidFinishLoading:(NSURLConnection *)connection
//{
//    
//    NSMutableData* storedData = [self.programDataArray objectForKey:connection.currentRequest.URL];
//    if (storedData) {
//        [self storeDownloadedProgram:storedData andConnection:connection];
//        
//        [self.programDataArray removeObjectForKey:connection.currentRequest.URL];
//        [self resetProgramDatawithKey:connection];
//        [self.progressDict removeObjectForKey:connection.currentRequest.URL];
//        [self.downloadSizeDict removeObjectForKey:connection.currentRequest.URL];
//    }
//    else{
//        storedData =[self.imageDataArray objectForKey:connection.currentRequest.URL];
//        
//        [self storeDownloadedImage:storedData andURL:connection.currentRequest.URL];
//        [self.imageDataArray removeObjectForKey:connection.currentRequest.URL];
//        [self resetImageDataAndConnection:connection];
//        
//    }
//
//    UIApplication* app = [UIApplication sharedApplication];
//    app.networkActivityIndicatorVisible = NO;
//    
//    //    if (self.programConnection == connection) {
//    //        NSDebug(@"Finished program downloading");
//    //
//    //        [self storeDownloadedProgram];
//    //
//    //        if ([self.delegate respondsToSelector:@selector(downloadFinished)]) {
//    //            [self.delegate performSelector:@selector(downloadFinished)];
//    //        }
//    //
//    //        self.programData = nil;
//    //        self.programConnection = nil;
//    //        self.projectName = nil;
//    //    }
//    //    else if (self.imageConnection == connection) {
//    //        NSDebug(@"Finished screenshot downloading");
//    //        //path may not exist at this point -> another call to
//    //        //storeDownloadedImage in unzipAndStore:withName
//    //        [self storeDownloadedImage];
//    //    }
//}

//- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
//    
//    //    if (self.programConnection == connection) {
//    //        self.programData = nil;
//    //        self.programConnection = nil;
//    //        self.projectName = nil;
//    //    }
//    //    else if (self.imageConnection == connection) {
//    //        self.imageData = nil;
//    //        self.imageConnection = nil;
//    //    }
//    [self resetImageDataAndConnection:connection];
//    [self resetProgramDatawithKey:connection];
//    [self.imageDataArray removeObjectForKey:connection.currentRequest.URL];
//    [self.programDataArray removeObjectForKey:connection.currentRequest.URL];
//    [self.progressDict removeObjectForKey:connection.currentRequest.URL];
//    [self.downloadSizeDict removeObjectForKey:connection.currentRequest.URL];
//    [connection cancel];
//    UIApplication* app = [UIApplication sharedApplication];
//    app.networkActivityIndicatorVisible = NO;
//    
//}

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

#pragma mark - Helper
- (void)storeDownloadedProgram:(NSData *)data andTask:(NSURLSessionDownloadTask *)task
{
    NSString* name = [self.programNameDict objectForKey:task];
    [self unzipAndStore:data withName:name];
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"finishedloading" object:nil];
    NSURL* url = [self.programTaskDict objectForKey:task];
    if ([self.delegate respondsToSelector:@selector(downloadFinishedWithURL:)] && [self.projectURL isEqual:url]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate downloadFinishedWithURL:url];
        });
    }

}

- (void)storeDownloadedImage:(NSData *)data andTask:(NSURLSessionDownloadTask *) task
{
    if (data != nil) {
        NSString *name = [self.imageNameDict objectForKey:task];
        NSString *storePath = [NSString stringWithFormat:@"%@/small_screenshot.png", [self getFullPathForProgram:name]];
        NSDebug(@"path for image is: %@", storePath);
        if ([data writeToFile:storePath atomically:YES]) {
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
    if (self.imageNameDict.count > 0) {
        NSArray *temp = [self.imageNameDict allKeysForObject:name];
        if (temp) {
            NSURLSessionDownloadTask *key = [temp objectAtIndex:0];
            [self storeDownloadedImage:programData andTask:key];
        }
    }
}




-(void)stopLoading:(NSURL *)projecturl andImageURL:(NSURL *)imageurl
{
    if (self.programTaskDict.count > 0) {
        NSArray *temp = [self.programTaskDict allKeysForObject:projecturl];
        if (temp) {
            NSURLSessionDownloadTask *key = [temp objectAtIndex:0];
            [self stopLoading:key];
        }
    }
    if (self.imageTaskDict.count > 0) {
        NSArray *temp = [self.imageTaskDict allKeysForObject:imageurl];
        if (temp) {
            NSURLSessionDownloadTask *key = [temp objectAtIndex:0];
            [self stopLoading:key];
        }
    }
 
}

-(void)stopLoading:(NSURLSessionDownloadTask *)task
{
    [task suspend];
    NSURL* url = [self.programTaskDict objectForKey:task];
    if (url) {
        [self.programTaskDict removeObjectForKey:task];
        [self.programNameDict removeObjectForKey:task];
    }else{
        url = [self.imageTaskDict objectForKey:task];
        if (url) {
            [self.imageTaskDict removeObjectForKey:task];
            [self.imageNameDict removeObjectForKey:task];
        }
        
    }
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;

    
}

-(uint64_t)getFreeDiskspace {
    uint64_t totalFreeSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];

    if (dictionary) {
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
        NSDebug(@"Memory Capacity of %llu MiB with %llu MiB Free memory available.",
                (([[dictionary objectForKey: NSFileSystemSize] unsignedLongLongValue]/1024ll)/1024ll),
                ((totalFreeSpace/1024ll)/1024ll));
    } else {
        NSError(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
    
    return totalFreeSpace;
}


#pragma mark NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSURL* url = [self.programTaskDict objectForKey:downloadTask];
    
    if (url) {
        [self storeDownloadedProgram:[NSData dataWithContentsOfURL:location] andTask:downloadTask];
        
        [self.programTaskDict removeObjectForKey:downloadTask];
        [self.programNameDict removeObjectForKey:downloadTask];

    }else{
        url = [self.imageTaskDict objectForKey:downloadTask];
        [self storeDownloadedImage:[NSData dataWithContentsOfURL:location] andTask:downloadTask];
        [self.imageTaskDict removeObjectForKey:downloadTask];
        [self.imageNameDict removeObjectForKey:downloadTask];

    }
    [downloadTask suspend];
    

    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    NSURL* url = [self.programTaskDict objectForKey:downloadTask];
    if (!url) {
        return;
    }
    if ([self getFreeDiskspace] < totalBytesExpectedToWrite) {
        [self stopLoading:downloadTask];
        [Util alertWithText:kUIAlertViewTitleNotEnoughFreeMemory];
        if ([self.delegate respondsToSelector:@selector(setBackDownloadStatus)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate setBackDownloadStatus];
            });

        }
        UIApplication* app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = NO;
        return;
    }else{
        double progress = (double)totalBytesWritten/(double)totalBytesExpectedToWrite;
        if (url) {
            if ([self.delegate respondsToSelector:@selector(updateProgress:)] && [self.projectURL isEqual:url]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate updateProgress:progress];
                });
            }

        }
        UIApplication* app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = YES;
        
    }
    
    
    

}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error) {
        [task suspend];
        
        NSURL* url = [self.programTaskDict objectForKey:task];
        if (url) {
            [self.programTaskDict removeObjectForKey:task];
            [self.programNameDict removeObjectForKey:task];
        }else{
           url = [self.imageTaskDict objectForKey:task];
            if (url) {
                [self.imageTaskDict removeObjectForKey:task];
                [self.imageNameDict removeObjectForKey:task];
            }
            
        }
        UIApplication* app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = NO;

    }
}

@end
