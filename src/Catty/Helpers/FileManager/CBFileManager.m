/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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

#import "CBFileManager.h"
#import "Util.h"
#import <ZipArchive/ZipArchive.h>
#import "Sound.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "NetworkDefines.h"
#import "Pocket_Code-Swift.h"

@interface CBFileManager ()

@property (nonatomic, strong, readwrite) NSString *documentsDirectory;
@property (nonatomic, strong) NSString *projectsDirectory;
@property (nonatomic, strong) NSMutableDictionary *projectTaskDict;
@property (nonatomic, strong) NSMutableDictionary *projectNameDict;
@property (nonatomic, strong) NSMutableDictionary *projectIDDict;

@property (nonatomic, strong) NSURLSession *downloadSession;

@end

@implementation CBFileManager

+ (instancetype)sharedManager {
    static CBFileManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[CBFileManager alloc] init];
    });
    return sharedManager;
}

#pragma mark - Getters and Setters
- (NSString*)documentsDirectory
{
    if (_documentsDirectory == nil) {
        _documentsDirectory = [[NSString alloc] initWithString:[Util applicationDocumentsDirectory]];
    }
    return _documentsDirectory;
}

- (NSString*)projectsDirectory
{
    if (_projectsDirectory == nil) {
        _projectsDirectory = [[NSString alloc] initWithFormat:@"%@/%@", self.documentsDirectory, kProjectsFolder];
    }
    return _projectsDirectory;
}


- (NSMutableDictionary*)projectTaskDict {
    if (_projectTaskDict == nil) {
        _projectTaskDict = [[NSMutableDictionary alloc] init];
    }
    return _projectTaskDict;
}

- (NSMutableDictionary*)projectNameDict
{
    if (!_projectNameDict) {
        _projectNameDict = [[NSMutableDictionary alloc] init];
    }
    return _projectNameDict;
}

- (NSMutableDictionary*)projectIDDict
{
    if (! _projectIDDict) {
        _projectIDDict = [[NSMutableDictionary alloc] init];
    }
    return _projectIDDict;
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
    NSFileManager *CBFileManager = [NSFileManager defaultManager];
    NSDebug(@"Create directory at path: %@", path);
    if (! [self directoryExists:path]) {
        if(![CBFileManager createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error])
            NSLogError(error);
    }
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

        if (!success) {
            NSLogError(error);
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
    if ([[NSFileManager defaultManager] copyItemAtURL:oldURL toURL:newURL error:&error] != YES) {
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
    if ([[NSFileManager defaultManager] moveItemAtURL:oldURL toURL:newURL error:&error] != YES) {
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
    if ([[NSFileManager defaultManager] moveItemAtURL:oldURL toURL:newURL error:&error] != YES) {
        NSError(@"Unable to move directory: %@", [error localizedDescription]);
        NSLogError(error);
    }
}

- (void)deleteFile:(NSString*)path
{
    NSError *error = nil;
    if(![[NSFileManager defaultManager] removeItemAtPath:path error:&error]) {
        NSError(@"Error while deleting file: %@", path);
        NSLogError(error);
    } else
        NSDebug(@"File deleted: %@", path);
}

- (void)deleteDirectory:(NSString *)path
{
    NSError *error = nil;
    if(![[NSFileManager defaultManager] removeItemAtPath:path error:&error]) {
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
    NSFileManager *CBFileManager = [NSFileManager defaultManager];
    NSArray *filesArray = [CBFileManager subpathsOfDirectoryAtPath:path error:nil];
    NSEnumerator *filesEnumerator = [filesArray objectEnumerator];
    NSString *fileName;
    NSUInteger fileSize = 0;
    NSError *error = nil;
    while (fileName = [filesEnumerator nextObject]) {
        NSDictionary *fileDictionary = [CBFileManager attributesOfItemAtPath:[path stringByAppendingPathComponent:fileName] error:&error];
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
    NSFileManager *CBFileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSDictionary *fileDictionary = [CBFileManager attributesOfItemAtPath:path error:&error];
    if(!fileDictionary)
        NSLogError(error);
    return (NSUInteger)[fileDictionary fileSize];
}

- (NSDate*)lastModificationTimeOfFile:(NSString*)path
{
    if (! [self fileExists:path]) {
        return 0;
    }
    NSFileManager *CBFileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSDictionary *fileDictionary = [CBFileManager attributesOfItemAtPath:path error:&error];
    if(!fileDictionary)
        NSLogError(error);
    return [fileDictionary fileModificationDate];
}

- (NSArray*)getContentsOfDirectory:(NSString*)directory
{
    NSError *error = nil;
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directory error:&error];
    if(!contents)
        NSLogError(error);
    return contents;
}

- (void)addDefaultProjectToProjectsRootDirectoryIfNoProjectsExist
{
    if ([Project areThereAnyProjects]) {
        return;
    }
    [self addNewBundleProjectWithName:kDefaultProjectBundleName];
    ProjectLoadingInfo *loadingInfo = [ProjectLoadingInfo projectLoadingInfoForProjectWithName:kDefaultProjectBundleName projectID:nil];
    Project *project = [Project projectWithLoadingInfo:loadingInfo];
    [project translateDefaultProject];
}

- (void)addNewBundleProjectWithName:(NSString*)projectName
{
    NSError *error;
    if (! [self directoryExists:self.projectsDirectory]) {
        [self createDirectory:self.projectsDirectory];
    }

    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.projectsDirectory error:&error];
    if(!contents)
        NSLogError(error);

    if ([contents indexOfObject:projectName]) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:projectName ofType:@"catrobat"];
        NSData *defaultProject = [NSData dataWithContentsOfFile:filePath];
        [self unzipAndStore:defaultProject withProjectID:nil withName:projectName];
    } else {
        NSInfo(@"%@ already exists...", projectName);
    }
}

- (void)downloadProjectFromURL:(NSURL*)url withProjectID:(NSString*)projectID andName:(NSString*)name
{
    NSDebug(@"Starting downloading project '%@' with id %@ from url: %@", name, projectID, [url absoluteString]);
    
    if (! self.downloadSession) {
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfig.timeoutIntervalForRequest = kConnectionTimeout;
        self.downloadSession = [NSURLSession sessionWithConfiguration:sessionConfig
                                                             delegate:self
                                                        delegateQueue:nil];
    }
    
    NSURLSessionDownloadTask *getProjectTask = [self.downloadSession downloadTaskWithURL:url];
    if (getProjectTask) {
        [self.projectTaskDict setObject:url forKey:getProjectTask];
        [self.projectNameDict setObject:name forKey:getProjectTask];
        [self.projectIDDict setObject:projectID forKey:getProjectTask];
        [getProjectTask resume];
    }
}

- (void)changeModificationDate:(NSDate*)date forFileAtPath:(NSString*)path
{
    if (! [self fileExists:path]) {
        return;
    }
    NSFileManager *CBFileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:date, NSFileModificationDate, NULL];
    [CBFileManager setAttributes:attributes ofItemAtPath:path error:&error];
    NSLogError(error);
}

- (BOOL)existPlayableSoundsInDirectory:(NSString*)directoryPath
{
    return ([[self playableSoundsInDirectory:directoryPath] count] > 0);
}

#pragma mark - Helper
- (void)storeDownloadedProject:(NSData *)data andTask:(NSURLSessionDownloadTask *)task
{
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                    options:NSJSONReadingMutableContainers
                                                      error:nil];
    
    if (jsonObject && [jsonObject isKindOfClass:[NSDictionary class]] && [jsonObject objectForKey:@"error"]) {
        // JSON API returned a 404 error (different from HTTP 404 error)
        if ([self.delegate respondsToSelector:@selector(fileNotFound)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate fileNotFound];
            });
        }
        
        return;
    }

    NSString *name = [self.projectNameDict objectForKey:task];
    NSString *projectID = [self.projectIDDict objectForKey:task];
    if ([self unzipAndStore:data withProjectID:projectID withName:name])
    {
        ProjectLoadingInfo* info = [ProjectLoadingInfo projectLoadingInfoForProjectWithName:name
                                                                                  projectID:projectID];
        NSURL* url = [self.projectTaskDict objectForKey:task];
        if ([self.delegate respondsToSelector:@selector(downloadFinishedWithURL:andProjectLoadingInfo:)] && [self.projectURL isEqual:url]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate downloadFinishedWithURL:url andProjectLoadingInfo:info];
            });
        } else if ([self.delegate respondsToSelector:@selector(downloadFinishedWithURL:andProjectLoadingInfo:)] && [self.delegate isKindOfClass:[HelpWebViewController class]]){
            [self.delegate downloadFinishedWithURL:url andProjectLoadingInfo:info];
        }
    }
}

// IMPORTANT: all downloaded projects own a unique projectID, but if this project was generated by the user
//            AND (!) has not been uploaded to the Pocket Code Website yet, a No-Project-ID-Yet placeholder
//            will be added to the project directory's name. This No-Project-ID-Yet placeholder will be
//            automatically replaced by a unique projectID (retrieved from the Pocket Code website) later
//            after the user has uploaded this project.
- (BOOL)unzipAndStore:(NSData*)projectData withProjectID:(NSString*)projectID withName:(NSString*)name
{
    NSError *error;
    NSString *tempPath = [NSString stringWithFormat:@"%@temp.zip", NSTemporaryDirectory()];
    [projectData writeToFile:tempPath atomically:YES];
    if ((! projectID) || (! [projectID length])) {
        projectID = kNoProjectIDYetPlaceholder;
    }
    NSString *storePath = [NSString stringWithFormat:@"%@/%@_%@", self.projectsDirectory, name, projectID];

    NSDebug(@"Starting unzip");
    BOOL unzipSuccess = [SSZipArchive unzipFileAtPath:tempPath toDestination:storePath];
    NSDebug(@"Unzip finished");

    NSDebug(@"Removing temp zip file");
    [[NSFileManager defaultManager] removeItemAtPath:tempPath error:&error];

    [Logger logError:error];

    if (!unzipSuccess) {
        NSDebug(@"Unzip unsuccessfull");
        if ([self.delegate respondsToSelector:@selector(invalidZip)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate invalidZip];
            });
        }

        return NO;
    }

    [self addSkipBackupAttributeToItemAtURL:storePath];
    return YES;
}

-(NSData*)zipProject:(Project*)project
{
    NSString *targetPath = [NSString stringWithFormat:@"%@temp.zip", NSTemporaryDirectory()];
    NSDebug(@"ZIPing project:%@ to path:%@", project.header.programName, targetPath);
    
    bool success = [SSZipArchive createZipFileAtPath:targetPath withContentsOfDirectory:project.projectPath];
    
    if(success) {
        NSData *zipData = [[NSData alloc] initWithContentsOfFile:targetPath];
        
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:targetPath error:&error];
        [Logger logError:error];
        
        return zipData;
    } else {
        NSDebug(@"ZIPing failed");
        return NULL;
    }
}

- (void)stopLoading:(NSURL *)projecturl
{
    if (self.projectTaskDict.count > 0) {
        NSArray *temp = [self.projectTaskDict allKeysForObject:projecturl];
        if (temp) {
            NSURLSessionDownloadTask *key = [temp objectAtIndex:0];
            [self stopLoadingTask:key];
        }
    }
}

- (void)stopLoadingTask:(NSURLSessionDownloadTask *)task
{
    [task cancel];
    NSURL* url = [self.projectTaskDict objectForKey:task];
    if (url) {
        [self.projectTaskDict removeObjectForKey:task];
        [self.projectNameDict removeObjectForKey:task];
        [self.projectIDDict removeObjectForKey:task];
    }
    [Util setNetworkActivityIndicator:NO];
}

- (uint64_t)freeDiskspace
{
    uint64_t totalFreeSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];

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
    NSURL *url = [self.projectTaskDict objectForKey:downloadTask];
    if (url) {
        [self storeDownloadedProject:[NSData dataWithContentsOfURL:location] andTask:downloadTask];
        [self.projectTaskDict removeObjectForKey:downloadTask];
        [self.projectNameDict removeObjectForKey:downloadTask];
        [self.projectIDDict removeObjectForKey:downloadTask];
        // Notification for reloading MyProjectViewController
        [[NSNotificationCenter defaultCenter] postNotificationName:kProjectDownloadedNotification object:self];
    }
    [Util setNetworkActivityIndicator:NO];
}

- (void)URLSession:(NSURLSession*)session downloadTask:(NSURLSessionDownloadTask*)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    NSURL* url = [self.projectTaskDict objectForKey:downloadTask];
    if (! url) {
        return;
    }
    
    uint64_t freeDiskspace = [self freeDiskspace];
    if (totalBytesExpectedToWrite != NSURLResponseUnknownLength && freeDiskspace < totalBytesExpectedToWrite) {
        [self stopLoadingTask:downloadTask];
        if ([self.delegate respondsToSelector:@selector(maximumFilesizeReached)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate maximumFilesizeReached];
            });
        }
        [Util setNetworkActivityIndicator:NO];
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
        dispatch_async(dispatch_get_main_queue(), ^{
            [Util setNetworkActivityIndicator:YES];
        });
    }
}

- (void)URLSession:(NSURLSession*)session task:(NSURLSessionTask*)task didCompleteWithError:(NSError*)error
{
    if (error) {
        // FIXME: hack: workaround for app crash issue...
        if (error.code != kCFURLErrorNotConnectedToInternet) {
            [task suspend];
            [Util setNetworkActivityIndicator:NO];
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
        if (error.code == kCFURLErrorDataLengthExceedsMaximum){
            if ([self.delegate respondsToSelector:@selector(maximumFilesizeReached)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate maximumFilesizeReached];
                });
            }
            return;
        }
        
        NSURL *url = [self.projectTaskDict objectForKey:task];
        if (url) {
            [self.projectTaskDict removeObjectForKey:task];
            [self.projectNameDict removeObjectForKey:task];
            [self.projectIDDict removeObjectForKey:task];
        }
        if ([self.delegate respondsToSelector:@selector(setBackDownloadStatus)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate setBackDownloadStatus];
            });
        }
        [Util setNetworkActivityIndicator:NO];
    }
}

-(void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(setBackDownloadStatus)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate setBackDownloadStatus];
        });
    }
    [Util setNetworkActivityIndicator:NO];
}


#pragma mark - exclude file from iCloud Backup
- (BOOL)addSkipBackupAttributeToItemAtURL:(NSString *)URL
{
    NSURL *localFileURL = [NSURL fileURLWithPath:URL];
    assert([NSFileManager.defaultManager fileExistsAtPath:URL]);

    NSError *error = nil;
    BOOL success = [localFileURL setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&error];
    if (!success) {
        NSError(@"Error excluding %@ from backup %@", URL.lastPathComponent, error);
    }
    return success;
}

@end
