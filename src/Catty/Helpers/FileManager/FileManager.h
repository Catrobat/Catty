/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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
#import "ProgramLoadingInfo.h"
#import "Program.h"


@protocol FileManagerDelegate <NSObject>

- (void) downloadFinishedWithURL:(NSURL*)url andProgramLoadingInfo:(ProgramLoadingInfo*)info;
- (void) updateProgress:(double)progress;
- (void) setBackDownloadStatus;
- (void) timeoutReached;

@end

@interface FileManager : NSObject <NSURLSessionDelegate,NSURLSessionDownloadDelegate>

@property (nonatomic, weak) id delegate;
@property (nonatomic, strong, readonly) NSString *documentsDirectory;
@property (atomic, strong) NSURL* projectURL;

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
- (void)addDefaultProgramToProgramsRootDirectoryIfNoProgramsExist;
- (void)downloadProgramFromURL:(NSURL*)url withProgramID:(NSString*)programID andName:(NSString*)name;
- (BOOL)existPlayableSoundsInDirectory:(NSString*)directoryPath;
- (void)stopLoading:(NSURL *)projecturl;
- (NSArray*)playableSoundsInDirectory:(NSString*)directoryPath;
- (void)changeModificationDate:(NSDate*)date forFileAtPath:(NSString*)path;
- (uint64_t)freeDiskspace;
- (NSData*)zipProgram:(Program*)program;
- (void)unzipAndStore:(NSData*)programData
        withProgramID:(NSString*)programID
             withName:(NSString*)name;

@end
