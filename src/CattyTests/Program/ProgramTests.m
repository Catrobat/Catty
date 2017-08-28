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
#import "Program.h"
#import "FileManager.h"
#import "AppDelegate.h"
#import "Util.h"
#import "LanguageTranslationDefines.h"
#import "ProgramManager.h"
#import "FileSystemStorage.h"
#import "ProgramLoadingInfo.h"
#import "Scene.h"

@interface ProgramTests : XCTestCase

@property (nonatomic, strong) Program *program;
@property (nonatomic, strong) FileManager *fileManager;

@end

@implementation ProgramTests

- (void)setUp
{
    [super setUp];
    NSString *programsDirectory = [FileSystemStorage programsDirectory];
    if (! [self.fileManager directoryExists:programsDirectory]) {
        [self.fileManager createDirectory:programsDirectory];
    }
}

- (void)tearDown
{
    if (self.program) {
        [[ProgramManager instance] removeProgramWithLoadingInfo:[ProgramLoadingInfo programLoadingInfoForProgram:self.program]];
    }
    self.program = nil;
    self.fileManager = nil;
    [super tearDown];
}

- (void)setupForNewProgram
{
    self.program = [Program defaultProgramWithName:kLocalizedNewProgram];
    [[ProgramManager instance] addProgram:self.program];
}

- (void)testNewProgramIfProjectFolderExists
{
    [self setupForNewProgram];
    NSString *programDirectory = [ProgramLoadingInfo programLoadingInfoForProgram:self.program].basePath;
    XCTAssertTrue([self.fileManager directoryExists:programDirectory], @"No project folder created for the new project");
}

- (void)testNewProgramIfScenesFolderExists
{
    [self setupForNewProgram];
    
    for (Scene *scene in self.program.scenes) {
        NSString *sceneDirectory = [FileSystemStorage directoryForScene:scene];
        XCTAssertTrue([self.fileManager directoryExists:sceneDirectory], @"No scene folder created for the new project");
    }
}

- (void)testNewProgramIfImagesFolderExists
{
    [self setupForNewProgram];
    
    for (Scene *scene in self.program.scenes) {
        NSString *sceneImagesDirectory = [FileSystemStorage imagesDirectoryForScene:scene];
        XCTAssertTrue([self.fileManager directoryExists:sceneImagesDirectory], @"No images folder created for the new project");
    }
}

- (void)testNewProgramIfSoundsFolderExists
{
    [self setupForNewProgram];
    
    for (Scene *scene in self.program.scenes) {
        NSString *sceneSoundsDirectory = [FileSystemStorage soundsDirectoryForScene:scene];
        XCTAssertTrue([self.fileManager directoryExists:sceneSoundsDirectory], @"No sounds folder created for the new project");
    }
}

- (void)testAddingNewSceneCreatesNewFolders {
    [self setupForNewProgram];
    
    Scene *scene = [[Scene alloc] initWithName:@"New scene"
                                    objectList:@[]
                            objectVariableList:[OrderedMapTable weakToStrongObjectsMapTable]
                                 originalWidth:@"100"
                                originalHeight:@"100"];
    
    [[ProgramManager instance] addScene:scene toProgram:self.program];
    [[ProgramManager instance] saveProgram:self.program];
    
    for (Scene *scene in self.program.scenes) {
        NSString *sceneDirectory = [FileSystemStorage directoryForScene:scene];
        NSString *sceneImagesDirectory = [FileSystemStorage imagesDirectoryForScene:scene];
        NSString *sceneSoundsDirectory = [FileSystemStorage soundsDirectoryForScene:scene];
        
        XCTAssertTrue([self.fileManager directoryExists:sceneDirectory], @"Scene directory was not created");
        XCTAssertTrue([self.fileManager directoryExists:sceneImagesDirectory], @"Scene images directory was not created");
        XCTAssertTrue([self.fileManager directoryExists:sceneSoundsDirectory], @"Scene sounds directory was not created");
    }
}

#pragma mark - getters and setters
- (FileManager*)fileManager
{
    if (! _fileManager)
        _fileManager = ((AppDelegate*)[UIApplication sharedApplication].delegate).fileManager;
    return _fileManager;
}

@end
