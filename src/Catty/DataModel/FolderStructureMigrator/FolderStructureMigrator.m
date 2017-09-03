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

#import "FolderStructureMigrator.h"
#import "Program.h"
#import "FileManager.h"
#import "FileSystemStorage.h"

@implementation FolderStructureMigrator

+ (NSString *)oldImagesDirectoryForProgram:(Program *)program {
    NSString *programDirectory = [FileSystemStorage directoryForProgram:program];
    return [NSString stringWithFormat:@"%@/images/", programDirectory];
}

+ (NSString *)oldSoundsDirectoryForProgram:(Program *)program {
    NSString *programDirectory = [FileSystemStorage directoryForProgram:program];
    return [NSString stringWithFormat:@"%@/sounds/", programDirectory];
}

+ (NSString *)oldAutomaticScreenshotPathForProgram:(Program *)program {
    return [[FileSystemStorage directoryForProgram:program] stringByAppendingPathComponent:@"automatic_screenshot.png"];
}

+ (NSString *)oldManualScreenshotPathForProgram:(Program *)program {
    return [[FileSystemStorage directoryForProgram:program] stringByAppendingPathComponent:@"manual_screenshot.png"];
}

+ (void)migrateToNewFolderStructureProgram:(Program *)program withFileManager:(FileManager *)fileManager {
    NSAssert([program.scenes count] == 1, @"Inconsistency");
    
    Scene *scene = [program.scenes objectAtIndex:0];
    
    NSString *sceneDirectory = [FileSystemStorage directoryForScene:scene];
    [fileManager createDirectory:sceneDirectory];
    
    NSString *programImagesDirectory = [self oldImagesDirectoryForProgram:program];
    NSString *sceneImagesDirectory = [FileSystemStorage imagesDirectoryForScene:scene];
    [fileManager moveExistingDirectoryAtPath:programImagesDirectory toPath:sceneImagesDirectory];
    
    NSString *programSoundsDirectory = [self oldSoundsDirectoryForProgram:program];
    NSString *sceneSoundsDirectory = [FileSystemStorage soundsDirectoryForScene:scene];
    [fileManager moveExistingDirectoryAtPath:programSoundsDirectory toPath:sceneSoundsDirectory];
    
    NSString *programAutomaticScreenshotPath = [self oldAutomaticScreenshotPathForProgram:program];
    NSString *sceneAutomaticScreenshotPath = [FileSystemStorage automaticScreenshotPathForScene:scene];
    [fileManager moveExistingFileAtPath:programAutomaticScreenshotPath toPath:sceneAutomaticScreenshotPath overwrite:YES];
    
    NSString *programAutomaticScreenshotThumbPath = [FileSystemStorage thumbnailPathForScreenshotAtPath:programAutomaticScreenshotPath];
    NSString *sceneAutomaticScreenshotThumbPath = [FileSystemStorage thumbnailPathForScreenshotAtPath:sceneAutomaticScreenshotPath];
    [fileManager moveExistingFileAtPath:programAutomaticScreenshotThumbPath toPath:sceneAutomaticScreenshotThumbPath overwrite:YES];
    
    NSString *programManualScreenshotPath = [self oldManualScreenshotPathForProgram:program];
    NSString *sceneManualScreenshotPath = [FileSystemStorage manualScreenshotPathForScene:scene];
    [fileManager moveExistingFileAtPath:programManualScreenshotPath toPath:sceneManualScreenshotPath overwrite:YES];
    
    NSString *programManualScreenshotThumbPath = [FileSystemStorage thumbnailPathForScreenshotAtPath:programManualScreenshotPath];
    NSString *sceneManualScreenshotThumbPath = [FileSystemStorage thumbnailPathForScreenshotAtPath:sceneManualScreenshotPath];
    [fileManager moveExistingFileAtPath:programManualScreenshotThumbPath toPath:sceneManualScreenshotThumbPath overwrite:YES];
}

@end
