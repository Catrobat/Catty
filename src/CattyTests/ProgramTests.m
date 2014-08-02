/**
 *  Copyright (C) 2010-2014 The Catrobat Team
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

@interface ProgramTests : XCTestCase

@property (nonatomic, strong) Program *program;
@property (nonatomic, strong) FileManager *fileManager;

@end

@implementation ProgramTests

- (void)setUp
{
    [super setUp];
    if (! [self.fileManager directoryExists:[Program basePath]]) {
        [self.fileManager createDirectory:[Program basePath]];
    }
}

- (void)tearDown
{
    if (self.program) {
        [ProgramTests removeProject:[self.program projectPath]];
    }
    self.program = nil;
    self.fileManager = nil;
    [super tearDown];
}

- (void)setupForNewProgram
{
    self.program = [Program defaultProgramWithName:kGeneralNewDefaultProgramName];
}

- (void)testNewProgramIfProjectFolderExists
{
    [self setupForNewProgram];
    XCTAssertTrue([self.fileManager directoryExists:[self.program projectPath]], @"No project folder created for the new project");
}

- (void)testNewProgramIfImagesFolderExists
{
    [self setupForNewProgram];
    NSString *imagesDirName = [NSString stringWithFormat:@"%@%@", [self.program projectPath], kProgramImagesDirName];
    XCTAssertTrue([self.fileManager directoryExists:imagesDirName], @"No images folder created for the new project");
}

- (void)testNewProgramIfSoundsFolderExists
{
    [self setupForNewProgram];
    NSString *soundsDirName = [NSString stringWithFormat:@"%@%@", [self.program projectPath], kProgramSoundsDirName];
    XCTAssertTrue([self.fileManager directoryExists:soundsDirName], @"No sounds folder created for the new project");
}

#pragma mark - getters and setters
- (FileManager*)fileManager
{
    if (! _fileManager)
        _fileManager = ((AppDelegate*)[UIApplication sharedApplication].delegate).fileManager;
    return _fileManager;
}

+ (void)removeProject:(NSString*)projectPath
{
    FileManager *fileManager = ((AppDelegate*)[UIApplication sharedApplication].delegate).fileManager;
    if ([fileManager directoryExists:projectPath])
        [fileManager deleteDirectory:projectPath];
    [Util setLastProgram:nil];
}

@end
