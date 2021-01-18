/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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

#import <Foundation/Foundation.h>
#import "ProjectLoadingInfo.h"
#import "Project.h"

@protocol CBFileManagerDelegate <NSObject>

- (void) downloadFinishedWithURL:(NSURL*)url andProjectLoadingInfo:(ProjectLoadingInfo*)info;
- (void) updateProgress:(double)progress;
- (void) setBackDownloadStatus;
- (void) timeoutReached;
- (void) maximumFilesizeReached;
- (void) fileNotFound;
- (void) invalidZip;

@end

@interface CBFileManager : NSObject <NSURLSessionDelegate,NSURLSessionDownloadDelegate>

@property (nonatomic, weak) id delegate;
@property (nonatomic, strong, readonly) NSString *documentsDirectory;
@property (atomic, strong) NSURL* projectURL;

+ (instancetype)sharedManager;

- (void)createDirectory:(NSString*)path;
- (void)deleteAllFilesInDocumentsDirectory;
- (void)deleteAllFilesOfDirectory:(NSString*)path;
- (BOOL)fileExists:(NSString*)path;
- (BOOL)directoryExists:(NSString*)path;
- (void)copyExistingFileAtPath:(NSString*)oldPath toPath:(NSString*)newPath overwrite:(BOOL)overwrite;
- (void)copyExistingDirectoryAtPath:(NSString*)oldPath toPath:(NSString*)newPath;
- (void)moveExistingFileAtPath:(NSString*)oldPath toPath:(NSString*)newPath overwrite:(BOOL)overwrite;
- (void)moveExistingDirectoryAtPath:(NSString*)oldPath toPath:(NSString*)newPath;
- (void)deleteFile:(NSString*)path;
- (void)deleteDirectory:(NSString*)path;
- (NSUInteger)sizeOfDirectoryAtPath:(NSString*)path;
- (NSUInteger)sizeOfFileAtPath:(NSString*)path;
- (NSDate*)lastModificationTimeOfFile:(NSString*)path;
- (NSArray*)getContentsOfDirectory:(NSString*)directory;
- (void)addDefaultProjectToProjectsRootDirectoryIfNoProjectsExist;
- (void)downloadProjectFromURL:(NSURL*)url withProjectID:(NSString*)projectID andName:(NSString*)name;
- (BOOL)existPlayableSoundsInDirectory:(NSString*)directoryPath;
- (void)stopLoading:(NSURL *)projecturl;
- (NSArray*)playableSoundsInDirectory:(NSString*)directoryPath;
- (void)changeModificationDate:(NSDate*)date forFileAtPath:(NSString*)path;
- (uint64_t)freeDiskspace;
- (NSData*)zipProject:(Project*)project;
- (BOOL)unzipAndStore:(NSData*)projectData
        withProjectID:(NSString*)projectID
             withName:(NSString*)name;

@end
