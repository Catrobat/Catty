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
#import "Scene.h"
#import "SpriteObject.h"
#import "OrderedMapTable.h"
#import "Header.h"
#import "ProgramManager.h"
#import "ProgramLoadingInfo.h"
#import "FileManager.h"
#import "AppDelegate.h"
#import "FileSystemStorage.h"

@interface FirstSceneNameTests : XCTestCase
@property (nonatomic) NSMutableArray<Program *> *programs;
@property (nonatomic, readonly) FileManager *fileManager;
@end

static NSInteger kNumberOfPrograms = 5;

@implementation FirstSceneNameTests

- (FileManager*)fileManager
{
    return ((AppDelegate*)[UIApplication sharedApplication].delegate).fileManager;
}

- (void)setUp {
    [super setUp];
    
    NSString *programsDirectory = [FileSystemStorage programsDirectory];
    if (! [self.fileManager directoryExists:programsDirectory]) {
        [self.fileManager createDirectory:programsDirectory];
    }
    
    self.programs = [NSMutableArray arrayWithCapacity:kNumberOfPrograms];
    for (int i = 0; i < kNumberOfPrograms; i++) {
        Scene *scene = [Scene defaultSceneWithName:[NSString stringWithFormat:@"scene %d", i]];
        
        Header *header = [Header defaultHeader];
        header.programName = [NSString stringWithFormat:@"program %d", i];
        header.screenWidth = @(scene.originalWidth.floatValue);
        header.screenHeight = @(scene.originalHeight.floatValue);
        
        Program *program = [[Program alloc] initWithHeader:header
                                                    scenes:@[scene]
                                       programVariableList:@[]];
        
        [self.programs addObject:program];
        
        [[ProgramManager instance] addProgram:program];
    }
}

- (void)tearDown
{
    [self.fileManager deleteDirectory:[FileSystemStorage programsDirectory]];
    self.programs = nil;
    [super tearDown];
}

- (void)firstSceneNameOfProgramWithName:(NSString *)programName shouldBe:(NSString *)firstSceneName {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary<NSString *, NSString *> *firstSceneNames = [userDefaults objectForKey:kFirstSceneNameOfProgramsKey];
    NSString *userDefaultsFirstSceneName = firstSceneNames[programName];
    
    XCTAssertEqual(firstSceneName, userDefaultsFirstSceneName);
}

- (void)testAddProgram {
    for (Program *program in self.programs) {
        [self firstSceneNameOfProgramWithName:program.programName shouldBe:program.scenes[0].name];
    }
}

- (void)testRemoveProgram {
    for (Program *program in self.programs) {
        ProgramLoadingInfo *info = [ProgramLoadingInfo programLoadingInfoForProgram:program];
        [[ProgramManager instance] removeProgramWithLoadingInfo:info];
        
        [self firstSceneNameOfProgramWithName:program.programName shouldBe:nil];
    }
}

- (void)testCopyProgram {
    for (Program *program in self.programs) {
        ProgramLoadingInfo *info = [ProgramLoadingInfo programLoadingInfoForProgram:program];
        ProgramLoadingInfo *infoCopy = [[ProgramManager instance] copyProgramWithLoadingInfo:info
                                                                      destinationProgramName:[NSString stringWithFormat:@"%@ copy", program.programName]];
        
        [self firstSceneNameOfProgramWithName:infoCopy.visibleName shouldBe:program.scenes[0].name];
    }
}

- (void)testRenameProgram {
    for (Program *program in self.programs) {
        NSString *oldProgramName = program.programName;
        NSString *newProgramName = [NSString stringWithFormat:@"%@ renamed", oldProgramName];
        [[ProgramManager instance] renameProgram:program toName:newProgramName];
        
        [self firstSceneNameOfProgramWithName:oldProgramName shouldBe:nil];
        [self firstSceneNameOfProgramWithName:newProgramName shouldBe:program.scenes[0].name];
    }
}

- (void)testRemoveScenes {
    Program *program = self.programs[3]; // any existing program
    
    NSString *nameOfNewScene = @"name of new scene";
    Scene *newScene = [Scene defaultSceneWithName:nameOfNewScene];
    [[ProgramManager instance] addScene:newScene toProgram:program];
    
    [[ProgramManager instance] removeScenes:@[program.scenes[0]] fromProgram:program];
    
    [self firstSceneNameOfProgramWithName:program.programName shouldBe:nameOfNewScene];
}

- (void)testRenameScene {
    Program *program = self.programs[1]; // any existing program
    
    NSString *newNameOfScene = @"new name of scene";
    [[ProgramManager instance] renameScene:program.scenes[0] toName:newNameOfScene];
    
    [self firstSceneNameOfProgramWithName:program.programName shouldBe:newNameOfScene];
}

- (void)testMoveScene {
    Program *program = self.programs[0]; // any existing program
    
    NSString *nameOfNewScene = @"name of new scene";
    Scene *newScene = [Scene defaultSceneWithName:nameOfNewScene];
    [[ProgramManager instance] addScene:newScene toProgram:program];
    
    [program moveSceneAtIndex:0 toIndex:1];
    [[ProgramManager instance] saveProgram:program];
    
    [self firstSceneNameOfProgramWithName:program.programName shouldBe:nameOfNewScene];
}

@end
