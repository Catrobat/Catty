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

#import <Foundation/Foundation.h>


@protocol FileManagerDelegate <NSObject>

- (void) downloadFinishedWithURL:(NSURL*)url;
- (void) updateProgress:(double)progress;
- (void) setBackDownloadStatus;

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
- (void)moveExistingFileAtPath:(NSString*)oldPath toPath:(NSString*)newPath;
- (void)moveExistingDirectoryAtPath:(NSString*)oldPath toPath:(NSString*)newPath;
- (void)deleteDirectory:(NSString*)path;
- (NSUInteger)sizeOfDirectoryAtPath:(NSString*)path;
- (NSUInteger)sizeOfFileAtPath:(NSString*)path;
- (NSDate*)lastModificationTimeOfFile:(NSString*)path;
- (NSArray*)getContentsOfDirectory:(NSString*)directory;
- (void)addDefaultProgramToProgramsRootDirectoryIfNoProgramsExist;
- (void)downloadFileFromURL:(NSURL*)url withName:(NSString*)name;
- (void)downloadScreenshotFromURL:(NSURL*)url andBaseUrl:(NSURL*)baseurl andName:(NSString*) name;
- (NSString*)getFullPathForProgram:(NSString*)programName;
- (BOOL)existPlayableSoundsInDirectory:(NSString*)directoryPath;
- (void)stopLoading:(NSURL *)projecturl andImageURL:(NSURL *)imageurl;
- (NSArray*)playableSoundsInDirectory:(NSString*)directoryPath;
- (void)changeModificationDate:(NSDate*)date forFileAtPath:(NSString*)path;

@end
