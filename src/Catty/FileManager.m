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

@interface FileManager()

@property (nonatomic, strong) NSString *documentsDirectory;
@property (nonatomic, strong) NSString *levelsDirectory;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSString *projectName;

@end


@implementation FileManager

@synthesize documentsDirectory = _documentsDirectory;
@synthesize levelsDirectory    = _levelsDirectory;
@synthesize connection         = _connection;
@synthesize data               = _data;
@synthesize projectName        = _projectName;
@synthesize delegate           = _delegate;


#pragma mark - Getter
- (NSString*)documentsDirectory {
    if (_documentsDirectory == nil) {
        _documentsDirectory = [[NSString alloc] initWithString:[Util applicationDocumentsDirectory]];
    }
    
    return _documentsDirectory;
}

- (NSString*)levelsDirectory {
    if (_levelsDirectory == nil) {
        _levelsDirectory = [[NSString alloc] initWithFormat:@"%@/levels", self.documentsDirectory];
    }
    
    return _levelsDirectory;
}

- (NSMutableData*)data {
    if (_data == nil) {
        _data = [[NSMutableData alloc] init];
    }
    
    return _data;
}




- (void)deleteAllFilesInDocumentsDirectory {
    [self deleteAllFillesOfDirectory:self.documentsDirectory];
}

- (void)deleteAllFillesOfDirectory:(NSString*)path {
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

- (void)deleteFolder:(NSString*)path {
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    NSLogError(error);
}


- (NSArray*)getContentsOfDirectory:(NSString*)directory {
    NSError *error = nil;
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directory error:&error];
    NSLogError(error);
    
    return contents;
}


- (void)addDefaultProjectToLeveLDirectory {
    
    [self addBundleProjectWithName:@"My first project"];
    [self addBundleProjectWithName:@"Aquarium 3"];
}


- (void)addBundleProjectWithName:(NSString*)projectName
{

    NSError *error;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.levelsDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:self.levelsDirectory withIntermediateDirectories:NO attributes:nil error:&error];
        NSLogError(error);
    }
    
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.levelsDirectory error:&error];
    NSLogError(error);
    
    if ([contents indexOfObject:projectName]) {
        
        NSString *filePath = [[NSBundle mainBundle] pathForResource:projectName ofType:@"catrobat"];
        NSData *defaultProject = [NSData dataWithContentsOfFile:filePath];
        
        [self unzipAndStore:defaultProject withName:projectName];
    }
    else {
        NSInfo(@"%@ already exists...", projectName);
    }
    
    
}

- (void)downloadFileFromURL:(NSURL*)url withName:(NSString*)name {   
    self.projectName = name;
    

    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:TIMEOUT];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    self.connection = connection;
}


#pragma mark - NSURLConnection Delegates
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (self.connection == connection) {
        [self.data appendData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (self.connection == connection) {
        NSDebug(@"Finished downloading");
        
        [self storeDownloadedLevel];
        
        if ([self.delegate respondsToSelector:@selector(downloadFinished)]) {
                [self.delegate performSelector:@selector(downloadFinished)];
        }
        
        self.data = nil;
        self.connection = nil;
        self.projectName = nil;
    }
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    

    
    if (self.connection == connection) {
        self.data = nil;
        self.connection = nil;
        self.projectName = nil;
    }
}


- (NSString*)getPathForLevel:(NSString*)levelName {
    NSString *path = [NSString stringWithFormat:@"%@/%@", self.levelsDirectory, levelName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return path;
    }
    
    return nil;
}


#pragma mark - Helper

- (void)storeDownloadedLevel {
    NSData *levelZip = [NSData dataWithData:self.data];
    self.data = nil;
    
    [self unzipAndStore:levelZip withName:self.projectName];
}



- (void)unzipAndStore:(NSData*)level withName:(NSString*)name {
    NSError *error;
    
    NSString *tempPath = [NSString stringWithFormat:@"%@temp.zip", NSTemporaryDirectory()];
    [level writeToFile:tempPath atomically:YES];
    
    NSString *storePath = [NSString stringWithFormat:@"%@/levels/%@", self.documentsDirectory, name];
    
    NSDebug(@"Starting unzip");
    
    [SSZipArchive unzipFileAtPath:tempPath toDestination:storePath];
    
    NSDebug(@"Unzip finished");
    
    NSDebug(@"Removing temp zip file");
    
    [[NSFileManager defaultManager] removeItemAtPath:tempPath error:&error];
    
    [Logger logError:error];

}




@end
