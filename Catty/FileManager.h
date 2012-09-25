//
//  FileManager.h
//  Catty
//
//  Created by Christof Stromberger on 25.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileManager : NSObject <NSURLConnectionDelegate>

- (void)deleteAllFiles;
- (void)deleteAllFillesOfDirectory:(NSString*)path;
- (NSArray*)getContentsOfDirectory:(NSString*)directory;
- (void)addDefaultProject;
- (void)downloadFileFromURL:(NSURL*)url withName:(NSString*)name;
@end
