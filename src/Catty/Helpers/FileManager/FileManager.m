/**
 *  Copyright (C) 2010-2017 The Catrobat Team
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
#import "Sound.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "NetworkDefines.h"
#import "HelpWebViewController.h"
#import "ProgramManager.h"
#import "FileSystemStorage.h"

@interface FileManager ()

@property (nonatomic, strong, readwrite) NSString *documentsDirectory;
@property (nonatomic, strong) NSMutableDictionary *programTaskDict;
@property (nonatomic, strong) NSMutableDictionary *programNameDict;
@property (nonatomic, strong) NSMutableDictionary *programIDDict;

@property (nonatomic, strong) NSURLSession *downloadSession;

@property (nonatomic, readonly) NSFileManager *fileManager;

@end

@implementation FileManager

- (instancetype)initWithFileManager:(NSFileManager *)fileManager {
    self = [super init];
    if (self) {
        _fileManager = fileManager;
    }
    return self;
}

- (instancetype)init {
    return [self initWithFileManager:[NSFileManager defaultManager]];
}

#pragma mark - Getters and Setters
- (NSString*)documentsDirectory
{
    return [FileSystemStorage applicationDocumentsDirectory];
}

- (NSMutableDictionary*)programTaskDict {
    if (_programTaskDict == nil) {
        _programTaskDict = [[NSMutableDictionary alloc] init];
    }
    return _programTaskDict;
}

- (NSMutableDictionary*)programNameDict
{
    if (!_programNameDict) {
        _programNameDict = [[NSMutableDictionary alloc] init];
    }
    return _programNameDict;
}

- (NSMutableDictionary*)programIDDict
{
    if (! _programIDDict) {
        _programIDDict = [[NSMutableDictionary alloc] init];
    }
    return _programIDDict;
}

- (NSArray*)playableSoundsInDirectory:(NSString*)directoryPath
{
    NSError *error;
    NSArray *fileNames = [self.fileManager contentsOfDirectoryAtPath:directoryPath error:&error];
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
            NSString *fileNameWithoutExtension = ([fileParts count] ? [fileParts firstObject] : fileName);
            sound.fileName = fileName;
            NSUInteger soundNameLength = [fileNameWithoutExtension length];
            if (soundNameLength > kMaxNumOfSoundNameCharacters)
                soundNameLength = kMaxNumOfSoundNameCharacters;
            
            NSRange stringRange = {0,  soundNameLength};
            stringRange = [fileNameWithoutExtension rangeOfComposedCharacterSequencesForRange:stringRange];
            sound.name = [fileNameWithoutExtension substringWithRange:stringRange];
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
    NSDebug(@"Create directory at path: %@", path);
    if (! [self directoryExists:path]) {
        if(![self.fileManager createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error])
            NSLogError(error);
    }
}

- (void)deleteAllFilesInDocumentsDirectory
{
    [self deleteAllFilesOfDirectory:self.documentsDirectory];
}

- (void)deleteAllFilesOfDirectory:(NSString*)path {
    if (![path hasSuffix:@"/"]) {
        path = [NSString stringWithFormat:@"%@/", path];
    }

    NSError *error = nil;
    for (NSString *file in [self.fileManager contentsOfDirectoryAtPath:path error:&error]) {
        BOOL success = [self.fileManager removeItemAtPath:[NSString stringWithFormat:@"%@%@", path, file] error:&error];

        if (!success) {
            NSLogError(error);
            NSError(@"Error deleting file.");
        }
    }
}

- (BOOL)fileExists:(NSString*)path
{
    BOOL isDir;
    return ([self.fileManager fileExistsAtPath:path isDirectory:&isDir] && (! isDir));
}

- (BOOL)directoryExists:(NSString*)path
{
    BOOL isDir;
    return ([self.fileManager fileExistsAtPath:path isDirectory:&isDir] && isDir);
}

- (void)copyExistingFileAtPath:(NSString*)oldPath toPath:(NSString*)newPath overwrite:(BOOL)overwrite
{
    if (! [self fileExists:oldPath])
        return;

    if ([self fileExists:newPath]) {
        if (overwrite) {
            [self deleteFile:newPath];
        } else {
            return;
        }
    }

    NSData *data = [NSData dataWithContentsOfFile:oldPath];
    [data writeToFile:newPath atomically:YES];
}

- (void)copyExistingDirectoryAtPath:(NSString*)oldPath toPath:(NSString*)newPath
{
    if (! [self directoryExists:oldPath])
        return;

    // Attempt to copy
    NSURL *oldURL = [NSURL fileURLWithPath:oldPath];
    NSURL *newURL = [NSURL fileURLWithPath:newPath];
    NSError *error = nil;
    if ([self.fileManager copyItemAtURL:oldURL toURL:newURL error:&error] != YES) {
        NSError(@"Unable to copy file: %@", [error localizedDescription]);
        NSLogError(error);
    }
}

- (void)moveExistingFileAtPath:(NSString*)oldPath toPath:(NSString*)newPath overwrite:(BOOL)overwrite
{
    if (! [self fileExists:oldPath] || [oldPath isEqualToString:newPath])
        return;

    if ([self fileExists:newPath]) {
        if (overwrite) {
            [self deleteFile:newPath];
        } else {
            return;
        }
    }

    // Attempt the move
    NSURL *oldURL = [NSURL fileURLWithPath:oldPath];
    NSURL *newURL = [NSURL fileURLWithPath:newPath];
    NSError *error = nil;
    if ([self.fileManager moveItemAtURL:oldURL toURL:newURL error:&error] != YES) {
        NSError(@"Unable to move file: %@", [error localizedDescription]);
        NSLogError(error);
    }
}

- (void)moveExistingDirectoryAtPath:(NSString*)oldPath toPath:(NSString*)newPath
{
    if (! [self directoryExists:oldPath])
        return;

    // Attempt the move
    NSURL *oldURL = [NSURL fileURLWithPath:oldPath];
    NSURL *newURL = [NSURL fileURLWithPath:newPath];
    NSError *error = nil;
    if ([self.fileManager moveItemAtURL:oldURL toURL:newURL error:&error] != YES) {
        NSError(@"Unable to move directory: %@", [error localizedDescription]);
        NSLogError(error);
    }
}

- (void)deleteFile:(NSString*)path
{
    NSError *error = nil;
    if(![self.fileManager removeItemAtPath:path error:&error]) {
        NSError(@"Error while deleting file: %@", path);
        NSLogError(error);
    } else
        NSDebug(@"File deleted: %@", path);
}

- (void)deleteDirectory:(NSString *)path
{
    NSError *error = nil;
    if(![self.fileManager removeItemAtPath:path error:&error]) {
        NSError(@"Error while deleting directory: %@", path);
        NSLogError(error);
    } else
        NSDebug(@"Directory deleted: %@", path);
}

- (NSUInteger)sizeOfDirectoryAtPath:(NSString*)path
{
    if (! [self directoryExists:path]) {
        return 0;
    }
    NSArray *filesArray = [self.fileManager subpathsOfDirectoryAtPath:path error:nil];
    NSEnumerator *filesEnumerator = [filesArray objectEnumerator];
    NSString *fileName;
    NSUInteger fileSize = 0;
    NSError *error = nil;
    while (fileName = [filesEnumerator nextObject]) {
        NSDictionary *fileDictionary = [self.fileManager attributesOfItemAtPath:[path stringByAppendingPathComponent:fileName] error:&error];
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
    NSError *error = nil;
    NSDictionary *fileDictionary = [self.fileManager attributesOfItemAtPath:path error:&error];
    if(!fileDictionary)
        NSLogError(error);
    return (NSUInteger)[fileDictionary fileSize];
}

- (NSDate*)lastModificationTimeOfFile:(NSString*)path
{
    if (! [self fileExists:path]) {
        return 0;
    }
    NSError *error = nil;
    NSDictionary *fileDictionary = [self.fileManager attributesOfItemAtPath:path error:&error];
    if(!fileDictionary)
        NSLogError(error);
    return [fileDictionary fileModificationDate];
}

- (NSArray*)getContentsOfDirectory:(NSString*)directory
{
    NSError *error = nil;
    NSArray *contents = [self.fileManager contentsOfDirectoryAtPath:directory error:&error];
    if(!contents)
        NSLogError(error);
    return contents;
}

- (void)downloadProgramFromURL:(NSURL*)url withProgramID:(NSString*)programID andName:(NSString*)name
{
    NSDebug(@"Starting downloading program '%@' with id %@ from url: %@", name, programID, [url absoluteString]);
    
    if (! self.downloadSession) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
        // iOS8 specific stuff
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
//        sessionConfig.identifier = @"at.tugraz";
#else
        // iOS7 specific stuff
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration backgroundSessionConfiguration:@"at.tugraz"];
#endif
        
        sessionConfig.timeoutIntervalForRequest = kConnectionTimeout;
        self.downloadSession = [NSURLSession sessionWithConfiguration:sessionConfig
                                                             delegate:self
                                                        delegateQueue:nil];
    }
    
    NSURLSessionDownloadTask *getProgramTask = [self.downloadSession downloadTaskWithURL:url];
    if (getProgramTask) {
        [self.programTaskDict setObject:url forKey:getProgramTask];
        [self.programNameDict setObject:name forKey:getProgramTask];
        [self.programIDDict setObject:programID forKey:getProgramTask];
        [getProgramTask resume];
    }
}

- (void)changeModificationDate:(NSDate*)date forFileAtPath:(NSString*)path
{
    if (! [self fileExists:path]) {
        return;
    }
    NSError *error = nil;
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:date, NSFileModificationDate, NULL];
    [self.fileManager setAttributes:attributes ofItemAtPath:path error:&error];
    NSLogError(error);
}

- (BOOL)existPlayableSoundsInDirectory:(NSString*)directoryPath
{
    return ([[self playableSoundsInDirectory:directoryPath] count] > 0);
}

#pragma mark - Helper
- (void)storeDownloadedProgram:(NSData *)data andTask:(NSURLSessionDownloadTask *)task
{
    NSString *name = [self.programNameDict objectForKey:task];
    NSString *programID = [self.programIDDict objectForKey:task];
    [self unzipAndStore:data withProgramID:programID withName:name];
    ProgramLoadingInfo* info = [ProgramLoadingInfo programLoadingInfoForProgramWithName:name
                                                                              programID:programID];
    NSURL* url = [self.programTaskDict objectForKey:task];
    if ([self.delegate respondsToSelector:@selector(downloadFinishedWithURL:andProgramLoadingInfo:)] && [self.projectURL isEqual:url]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate downloadFinishedWithURL:url andProgramLoadingInfo:info];
        });
    }else if ([self.delegate respondsToSelector:@selector(downloadFinishedWithURL:andProgramLoadingInfo:)] && [self.delegate isKindOfClass:[HelpWebViewController class]]){
        [self.delegate downloadFinishedWithURL:url andProgramLoadingInfo:info];
    }

}

// IMPORTANT: all downloaded programs own a unique programID, but if this program was generated by the user
//            AND (!) has not been uploaded to the Pocket Code Website yet, a No-Program-ID-Yet placeholder
//            will be added to the program directory's name. This No-Program-ID-Yet placeholder will be
//            automatically replaced by a unique programID (retrieved from the Pocket Code website) later
//            after the user has uploaded this program.
- (void)unzipAndStore:(NSData*)programData withProgramID:(NSString*)programID withName:(NSString*)name
{
    NSError *error;
    NSString *tempPath = [NSString stringWithFormat:@"%@temp.zip", NSTemporaryDirectory()];
    [programData writeToFile:tempPath atomically:YES];
    if ((! programID) || (! [programID length])) {
        programID = kNoProgramIDYetPlaceholder;
    }
    
    NSString *storePath = [NSString stringWithFormat:@"%@/%@_%@", [FileSystemStorage programsDirectory], name, programID];

    NSDebug(@"Starting unzip");
    [SSZipArchive unzipFileAtPath:tempPath toDestination:storePath];
    NSDebug(@"Unzip finished");

    NSDebug(@"Removing temp zip file");
    [self.fileManager removeItemAtPath:tempPath error:&error];

    [Logger logError:error];

    [self addSkipBackupAttributeToItemAtURL:storePath];
}

-(NSData*)zipProgram:(Program*)program
{
    NSString *targetPath = [NSString stringWithFormat:@"%@temp.zip", NSTemporaryDirectory()];
    NSDebug(@"ZIPing program:%@ to path:%@", program.programName, targetPath);
    bool success = YES;//[SSZipArchive createZipFileAtPath:targetPath withContentsOfDirectory:program.projectPath];
    
    if(success) {
        NSData *zipData = [[NSData alloc] initWithContentsOfFile:targetPath];
        
        NSError *error;
        [self.fileManager removeItemAtPath:targetPath error:&error];
        [Logger logError:error];
        
        return zipData;
    } else {
        NSDebug(@"ZIPing failed");
        return NULL;
    }
}

- (void)stopLoading:(NSURL *)projecturl
{
    if (self.programTaskDict.count > 0) {
        NSArray *temp = [self.programTaskDict allKeysForObject:projecturl];
        if (temp) {
            NSURLSessionDownloadTask *key = [temp objectAtIndex:0];
            [self stopLoadingTask:key];
        }
    }
}

- (void)stopLoadingTask:(NSURLSessionDownloadTask *)task
{
    [task cancel];
    NSURL* url = [self.programTaskDict objectForKey:task];
    if (url) {
        [self.programTaskDict removeObjectForKey:task];
        [self.programNameDict removeObjectForKey:task];
        [self.programIDDict removeObjectForKey:task];
    }
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;

    
}

- (uint64_t)freeDiskspace
{
    uint64_t totalFreeSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [self.fileManager attributesOfFileSystemForPath:[paths lastObject] error: &error];

    if (dictionary) {
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
        NSDebug(@"Memory Capacity of %llu MiB with %llu MiB Free memory available.", (([[dictionary objectForKey: NSFileSystemSize] unsignedLongLongValue]/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
    } else {
        NSError(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
    return totalFreeSpace;
}

#pragma mark - NSURLSessionDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSURL *url = [self.programTaskDict objectForKey:downloadTask];
    if (url) {
        [self storeDownloadedProgram:[NSData dataWithContentsOfURL:location] andTask:downloadTask];
        [self.programTaskDict removeObjectForKey:downloadTask];
        [self.programNameDict removeObjectForKey:downloadTask];
        [self.programIDDict removeObjectForKey:downloadTask];
        // Notification for reloading MyProgramViewController
        [[NSNotificationCenter defaultCenter] postNotificationName:kProgramDownloadedNotification object:self];
    }
    
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;
}

- (void)URLSession:(NSURLSession*)session downloadTask:(NSURLSessionDownloadTask*)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    NSURL* url = [self.programTaskDict objectForKey:downloadTask];
    if (! url) {
        return;
    }
    if ([self freeDiskspace] < totalBytesExpectedToWrite) {
        [self stopLoadingTask:downloadTask];
        [Util alertWithText:kLocalizedNotEnoughFreeMemoryDescription];
        if ([self.delegate respondsToSelector:@selector(setBackDownloadStatus)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate setBackDownloadStatus];
            });
        }
        UIApplication* app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = NO;
        return;
    } else {
        double progress = (double)totalBytesWritten/(double)totalBytesExpectedToWrite;
        if (url) {
            if ([self.delegate respondsToSelector:@selector(updateProgress:)] && [self.projectURL isEqual:url]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate updateProgress:progress];
                });
            }else if ([self.delegate respondsToSelector:@selector(updateProgress:)] && [self.delegate isKindOfClass:[HelpWebViewController class]]){
                [self.delegate updateProgress:progress];
            }

        }
        UIApplication* app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = YES;
    }
}

- (void)URLSession:(NSURLSession*)session task:(NSURLSessionTask*)task didCompleteWithError:(NSError*)error
{
    if (error) {
        // XXX: hack: workaround for app crash issue...
        if (error.code != kCFURLErrorNotConnectedToInternet) {
            [task suspend];
            UIApplication* app = [UIApplication sharedApplication];
            app.networkActivityIndicatorVisible = NO;
        }
        if (error.code == kCFURLErrorCannotFindHost) {
            if ([self.delegate respondsToSelector:@selector(setBackDownloadStatus)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate setBackDownloadStatus];
                });
            }
            return;
        }
        if (error.code == kCFURLErrorTimedOut){
            if ([self.delegate respondsToSelector:@selector(timeoutReached)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate timeoutReached];
                });
            }
            return;
        }
        NSURL *url = [self.programTaskDict objectForKey:task];
        if (url) {
            [self.programTaskDict removeObjectForKey:task];
            [self.programNameDict removeObjectForKey:task];
            [self.programIDDict removeObjectForKey:task];
        }
        if ([self.delegate respondsToSelector:@selector(setBackDownloadStatus)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate setBackDownloadStatus];
            });
        }
        UIApplication* app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = NO;
    }
}

-(void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(setBackDownloadStatus)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate setBackDownloadStatus];
        });
    }
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;
}


#pragma mark - exclude file from iCloud Backup
- (BOOL)addSkipBackupAttributeToItemAtURL:(NSString *)URL
{
    NSURL *localFileURL = [NSURL fileURLWithPath:URL];
    assert([self.fileManager fileExistsAtPath:URL]);

    NSError *error = nil;
    BOOL success = [localFileURL setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&error];
    if (!success) {
        NSError(@"Error excluding %@ from backup %@", URL.lastPathComponent, error);
    }
    return success;
}

@end
