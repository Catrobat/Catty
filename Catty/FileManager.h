//
//  FileManager.h
//  Catty
//
//  Created by Christof Stromberger on 25.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileManager : NSObject <NSURLConnectionDelegate>

@property (nonatomic, strong) id delegate;

- (void)deleteAllFiles;
- (void)deleteAllFillesOfDirectory:(NSString*)path;
- (void)deleteFolder:(NSString*)path;
- (NSArray*)getContentsOfDirectory:(NSString*)directory;
- (void)addDefaultProject;
- (void)downloadFileFromURL:(NSURL*)url withName:(NSString*)name;
- (NSString*)getPathForLevel:(NSString*)levelName;

@end
