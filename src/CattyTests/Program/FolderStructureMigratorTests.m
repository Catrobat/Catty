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

#import <XCTest/XCTest.h>
#import "FileSystemStorage.h"
#import "FileManager.h"
#import "AppDelegate.h"
#import "ProgramManager.h"
#import "CBXMLParser.h"
#import "FolderStructureMigrator.h"

@interface FolderStructureMigratorTests : XCTestCase
@property (nonatomic, readonly) FileManager *fileManager;
@property (nonatomic) Program *testProgram;
@end

@implementation FolderStructureMigratorTests

- (FileManager *)fileManager {
    return ((AppDelegate *)[[UIApplication sharedApplication] delegate]).fileManager;
}

- (NSString *)testProgramDirectory {
    return [self testProgramLoadingInfo].basePath;
}

- (ProgramLoadingInfo *)testProgramLoadingInfo {
    return [ProgramLoadingInfo programLoadingInfoForProgramWithName:@"Compass 0.1" programID:nil];
}

- (NSBundle *)testBundle {
    return [NSBundle bundleForClass:[self class]];
}

- (NSString *)testProgramImagesDirectory {
    return [[self testProgramDirectory] stringByAppendingPathComponent:@"images"];
}

- (NSString *)testProgramSoundsDirectory {
    return [[self testProgramDirectory] stringByAppendingPathComponent:@"sounds"];
}

- (void)setUp {
    [super setUp];
    [self.fileManager createDirectory:[FileSystemStorage programsDirectory]];
    [self.fileManager createDirectory:[self testProgramDirectory]];
    [self.fileManager createDirectory:[self testProgramImagesDirectory]];
    [self.fileManager createDirectory:[self testProgramSoundsDirectory]];
    
    NSString *xmlResourcePath = [[self testBundle] pathForResource:@"Compass_0.1_098" ofType:@"xml"];
    NSString *programXMLPath = [[self testProgramDirectory] stringByAppendingPathComponent:@"code.xml"];
    [self.fileManager copyExistingFileAtPath:xmlResourcePath toPath:programXMLPath overwrite:YES];
    
    self.testProgram = [[[CBXMLParser alloc] initWithPath:programXMLPath] parseAndCreateProgram];
}

- (void)tearDown {
    [self.fileManager deleteDirectory:[self testProgramDirectory]];
    [super tearDown];
}

- (void)privateTestDirectoriesAfterMigration {
    NSArray<NSString *> *testProgramDirectoryContent = [self.fileManager getContentsOfDirectory:[self testProgramDirectory]];
    XCTAssertTrue(testProgramDirectoryContent.count == 2);
    XCTAssertTrue([testProgramDirectoryContent containsObject:@"code.xml"]);
    XCTAssertTrue([testProgramDirectoryContent containsObject:@"Scene 1"]);
}

- (void)testAutoScreenshotMigration {
    NSString *filePath = [[self testBundle] pathForResource:@"test.png" ofType:nil];
    NSString *oldAutoScreenshotPath = [[self testProgramDirectory] stringByAppendingPathComponent:@"automatic_screenshot.png"];
    [self.fileManager copyExistingFileAtPath:filePath toPath:oldAutoScreenshotPath overwrite:YES];
    
    [FolderStructureMigrator migrateToNewFolderStructureProgram:self.testProgram withFileManager:self.fileManager];
    
    [self privateTestDirectoriesAfterMigration];
    
    NSString *newAutoScreenshotPath = [FileSystemStorage automaticScreenshotPathForScene:self.testProgram.scenes[0]];
    XCTAssertTrue([self.fileManager fileExists:newAutoScreenshotPath]);
}

- (void)testAutoScreenshotWithThumbMigration {
    NSString *filePath = [[self testBundle] pathForResource:@"test.png" ofType:nil];
    NSString *oldAutoScreenshotPath = [[self testProgramDirectory] stringByAppendingPathComponent:@"automatic_screenshot.png"];
    [self.fileManager copyExistingFileAtPath:filePath toPath:oldAutoScreenshotPath overwrite:YES];
    NSString *oldAutoScreenshotThumbPath = [[self testProgramDirectory] stringByAppendingPathComponent:@".thumb_automatic_screenshot.png"];
    [self.fileManager copyExistingFileAtPath:filePath toPath:oldAutoScreenshotThumbPath overwrite:YES];
    
    [FolderStructureMigrator migrateToNewFolderStructureProgram:self.testProgram withFileManager:self.fileManager];
    
    [self privateTestDirectoriesAfterMigration];
    
    NSString *newAutoScreenshotPath = [FileSystemStorage automaticScreenshotPathForScene:self.testProgram.scenes[0]];
    XCTAssertTrue([self.fileManager fileExists:newAutoScreenshotPath]);
    
    NSString *newAutoScreenshotThumbPath = [FileSystemStorage thumbnailPathForScreenshotAtPath:newAutoScreenshotPath];
    XCTAssertTrue([self.fileManager fileExists:newAutoScreenshotThumbPath]);
}

- (void)testManualScreenshotMigration {
    NSString *filePath = [[self testBundle] pathForResource:@"test.png" ofType:nil];
    NSString *oldManualScreenshotPath = [[self testProgramDirectory] stringByAppendingPathComponent:@"manual_screenshot.png"];
    [self.fileManager copyExistingFileAtPath:filePath toPath:oldManualScreenshotPath overwrite:YES];
    
    [FolderStructureMigrator migrateToNewFolderStructureProgram:self.testProgram withFileManager:self.fileManager];
    
    [self privateTestDirectoriesAfterMigration];
    
    NSString *newManualScenePath = [FileSystemStorage manualScreenshotPathForScene:self.testProgram.scenes[0]];
    XCTAssertTrue([self.fileManager fileExists:newManualScenePath]);
}

- (void)testManualScreenshotWithThumbMigration {
    NSString *filePath = [[self testBundle] pathForResource:@"test.png" ofType:nil];
    NSString *oldManualScreenshotPath = [[self testProgramDirectory] stringByAppendingPathComponent:@"manual_screenshot.png"];
    [self.fileManager copyExistingFileAtPath:filePath toPath:oldManualScreenshotPath overwrite:YES];
    NSString *oldManualScreenshotThumbPath = [[self testProgramDirectory] stringByAppendingPathComponent:@".thumb_manual_screenshot.png"];
    [self.fileManager copyExistingFileAtPath:filePath toPath:oldManualScreenshotThumbPath overwrite:YES];
    
    [FolderStructureMigrator migrateToNewFolderStructureProgram:self.testProgram withFileManager:self.fileManager];
    
    [self privateTestDirectoriesAfterMigration];
    
    NSString *newManualScreenshotPath = [FileSystemStorage manualScreenshotPathForScene:self.testProgram.scenes[0]];
    XCTAssertTrue([self.fileManager fileExists:newManualScreenshotPath]);
    
    NSString *newManualScreenshotThumbPath = [FileSystemStorage thumbnailPathForScreenshotAtPath:newManualScreenshotPath];
    XCTAssertTrue([self.fileManager fileExists:newManualScreenshotThumbPath]);
}

- (void)testImagesMigration {
    NSString *filePath = [[self testBundle] pathForResource:@"test.png" ofType:nil];
    NSString *firstImagePath = [[self testProgramImagesDirectory] stringByAppendingPathComponent:@"2324FA67_first image.png"];
    [self.fileManager copyExistingFileAtPath:filePath toPath:firstImagePath overwrite:YES];
    NSString *firstImagePreviewPath = [[self testProgramImagesDirectory] stringByAppendingPathComponent:@"2324FA67_small_first image.png"];
    [self.fileManager copyExistingFileAtPath:filePath toPath:firstImagePreviewPath overwrite:YES];
    NSString *secondImagePath = [[self testProgramImagesDirectory] stringByAppendingPathComponent:@"645234C76D_Second_Image.png"];
    [self.fileManager copyExistingFileAtPath:filePath toPath:secondImagePath overwrite:YES];
    
    [FolderStructureMigrator migrateToNewFolderStructureProgram:self.testProgram withFileManager:self.fileManager];
    
    [self privateTestDirectoriesAfterMigration];
    
    NSString *sceneImagesDirectory = [FileSystemStorage imagesDirectoryForScene:self.testProgram.scenes[0]];
    
    NSString *firstImageNewPath = [sceneImagesDirectory stringByAppendingPathComponent:@"2324FA67_first image.png"];
    XCTAssertTrue([self.fileManager fileExists:firstImageNewPath]);
    
    NSString *firstImagePreviewNewPath = [sceneImagesDirectory stringByAppendingPathComponent:@"2324FA67_small_first image.png"];
    XCTAssertTrue([self.fileManager fileExists:firstImagePreviewNewPath]);
    
    NSString *secondImageNewPath = [sceneImagesDirectory stringByAppendingPathComponent:@"645234C76D_Second_Image.png"];
    XCTAssertTrue([self.fileManager fileExists:secondImageNewPath]);
}

- (void)testSoundsMigration {
    NSString *filePath = [[self testBundle] pathForResource:@"silence.mp3" ofType:nil];
    NSString *firstSoundPath = [[self testProgramSoundsDirectory] stringByAppendingPathComponent:@"234FA67_first sound.mp3"];
    [self.fileManager copyExistingFileAtPath:filePath toPath:firstSoundPath overwrite:YES];
    NSString *secondSoundPath = [[self testProgramSoundsDirectory] stringByAppendingPathComponent:@"645234C76D_Second_Sound.png"];
    [self.fileManager copyExistingFileAtPath:filePath toPath:secondSoundPath overwrite:YES];
    
    [FolderStructureMigrator migrateToNewFolderStructureProgram:self.testProgram withFileManager:self.fileManager];
    
    [self privateTestDirectoriesAfterMigration];
    
    NSString *sceneSoundsDirectory = [FileSystemStorage soundsDirectoryForScene:self.testProgram.scenes[0]];
    
    NSString *firstSoundNewPath = [sceneSoundsDirectory stringByAppendingPathComponent:@"234FA67_first sound.mp3"];
    XCTAssertTrue([self.fileManager fileExists:firstSoundNewPath]);
    
    NSString *secondSoundNewPath = [sceneSoundsDirectory stringByAppendingPathComponent:@"645234C76D_Second_Sound.png"];
    XCTAssertTrue([self.fileManager fileExists:secondSoundNewPath]);
}

@end
