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

#import "FileSystemStorage.h"
#import "Util.h"
#import "ProgramLoadingInfo.h"
#import "Scene.h"

@implementation FileSystemStorage

+ (NSString *)applicationDocumentsDirectory {
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
}

+ (NSString *)programsDirectory {
    return [NSString stringWithFormat:@"%@/%@/", [self applicationDocumentsDirectory], kProgramsFolder];
}

+ (NSString *)directoryNameForProgramWithName:(NSString *)programName programID:(NSString *)programID {
    NSParameterAssert(programName.length);
    
    programName = [Util replaceBlockedCharactersForString:programName];
    programID = programID ?: kNoProgramIDYetPlaceholder;
    return [NSString stringWithFormat:@"%@%@%@", programName, kProgramIDSeparator, programID];
}

+ (NSString *)directoryForProgramWithName:(NSString *)programName programID:(NSString *)programID {
    NSParameterAssert(programName.length);
    
    return [NSString stringWithFormat:@"%@/%@/", [self programsDirectory], [self directoryNameForProgramWithName:programName programID:programID]];
}

+ (NSString *)directoryForProgram:(Program *)program {
    NSParameterAssert(program);
    return [self directoryForProgramWithName:program.programName programID:program.programID];
}

+ (NSString *)xmlPathForProgramWithLoadingInfo:(ProgramLoadingInfo *)programLoadingInfo {
    NSParameterAssert(programLoadingInfo);
    return [programLoadingInfo.basePath stringByAppendingPathComponent:kProgramCodeFileName];
}

+ (NSString *)manualScreenshotPathForProgramWithLoadingInfo:(ProgramLoadingInfo *)programLoadingInfo {
    NSParameterAssert(programLoadingInfo);
    return [[self firstSceneDirectoryForProgramWithLoadingInfo:programLoadingInfo] stringByAppendingPathComponent:@"manual_screenshot.png"];
}

+ (NSString *)automaticScreenshotPathForProgramWithLoadingInfo:(ProgramLoadingInfo *)programLoadingInfo {
    NSParameterAssert(programLoadingInfo);
    return [[self firstSceneDirectoryForProgramWithLoadingInfo:programLoadingInfo] stringByAppendingPathComponent:@"automatic_screenshot.png"];
}

+ (NSString *)thumbnailPathForScreenshotAtPath:(NSString *)screenshotPath {
    NSParameterAssert(screenshotPath.length);
    NSString *screenshotFileName = [screenshotPath lastPathComponent];
    NSString *screenshotDirectory = [screenshotPath stringByDeletingLastPathComponent];
    NSString *screenshotThumbFileName = [kScreenshotThumbnailPrefix stringByAppendingString:screenshotFileName];
    return [screenshotDirectory stringByAppendingPathComponent:screenshotThumbFileName];
}

+ (NSString *)firstSceneDirectoryForProgramWithLoadingInfo:(ProgramLoadingInfo *)info {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *firstSceneNames = [userDefaults objectForKey:kFirstSceneNameOfProgramsKey];
    NSString *firstSceneName = firstSceneNames[info.visibleName];
    return firstSceneName ? [info.basePath stringByAppendingPathComponent:firstSceneName] : info.basePath;
}

+ (NSString *)manualScreenshotPathForScene:(Scene *)scene {
    return [[self directoryForScene:scene] stringByAppendingPathComponent:@"manual_screenshot.png"];
}

+ (NSString *)automaticScreenshotPathForScene:(Scene *)scene {
    NSParameterAssert(scene);
    return [[self directoryForScene:scene] stringByAppendingPathComponent:@"automatic_screenshot.png"];
}

+ (NSString *)directoryForScene:(Scene *)scene {
    NSParameterAssert(scene);
    NSAssert(scene.program, @"Scene should belong to a proram");
    
    NSString *programDirectory = [self directoryForProgram:scene.program];
    NSString *sceneName = [Util replaceBlockedCharactersForString:scene.name];
    return [NSString stringWithFormat:@"%@/%@/", programDirectory, sceneName];
}

+ (NSString *)imagesDirectoryForScene:(Scene *)scene {
    NSParameterAssert(scene);
    NSAssert(scene.program, @"Scene should belong to a proram");
    
    return [NSString stringWithFormat:@"%@/images/", [self directoryForScene:scene]];
}

+ (NSString *)soundsDirectoryForScene:(Scene *)scene {
    NSParameterAssert(scene);
    NSAssert(scene.program, @"Scene should belong to a proram");
    
    return [NSString stringWithFormat:@"%@/sounds/", [self directoryForScene:scene]];
}

+ (NSString *)previewPathForImageAtPath:(NSString *)imagePath {
    NSParameterAssert(imagePath.length);
    NSString *imageName = [imagePath lastPathComponent];
    NSString *imageDirectory = [imagePath stringByDeletingLastPathComponent];
    
    NSRange result = [imageName rangeOfString:kResourceFileNameSeparator];
    
    if ((result.location == NSNotFound) || (result.location == 0) || (result.location >= ([imageName length] - 1))) {
        abort();
        return nil;
    }
    
    NSString *previewImageName =  [NSString stringWithFormat:@"%@_%@%@",
                                   [imageName substringToIndex:result.location],
                                   kPreviewImageNamePrefix,
                                   [imageName substringFromIndex:(result.location + 1)]];

    return [imageDirectory stringByAppendingPathComponent:previewImageName];
}

@end
