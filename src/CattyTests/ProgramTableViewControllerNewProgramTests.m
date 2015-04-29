/**
 *  Copyright (C) 2010-2015 The Catrobat Team
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

// NOTE: needed for ProgramTableViewController.h to make some non-public methods that are needed for testing
// visible for this class
#define CATTY_TESTS 1

#import <XCTest/XCTest.h>
#import "ProgramTableViewController.h"
#import "Program.h"
#import "ProgramDefines.h"
#import "AppDelegate.h"
#import "FileManager.h"
#import "Util.h"
#import "ProgramLoadingInfo.h"
#import "CatrobatImageCell.h"
#import "DarkBlueGradientImageCell.h"
#import "CellTagDefines.h"
#import "Parser.h"
#import "SpriteObject.h"
#import "Brick.h"
#import "Script.h"
#import "ActionSheetAlertViewTags.h"
#import "MyProgramsViewController.h"
#import "LanguageTranslationDefines.h"

@interface ProgramTableViewControllerNewProgramTests : XCTest
@property (nonatomic, strong) ProgramTableViewController *programTableViewController;
@property (nonatomic, strong) FileManager *fileManager;
@property (nonatomic, strong) Program *defaultProgram;
@end

@implementation ProgramTableViewControllerNewProgramTests

- (void)setUp
{
    [super setUp];
    if (! [self.fileManager directoryExists:[Program basePath]]) {
        [self.fileManager createDirectory:[Program basePath]];
    }
    if (self.defaultProgram) {
        [ProgramTableViewControllerNewProgramTests removeProject:[self.defaultProgram projectPath]];
    }
    self.programTableViewController.delegate = nil; // no delegate needed for our tests
    [Util activateTestMode:YES];
}

- (void)setupForNewProgram
{
    self.defaultProgram = [Program defaultProgramWithName:kLocalizedNewProgram programID:nil];
    self.programTableViewController.program = self.defaultProgram;
}

- (void)tearDown
{
    if (self.defaultProgram) {
        [ProgramTableViewControllerNewProgramTests removeProject:[self.defaultProgram projectPath]];
    }
    self.programTableViewController = nil;
    self.fileManager = nil;
    [super tearDown];
}

#pragma mark - New Program Tests
- (void)testNewProgramHasBackgroundObjectCell
{
    [self setupForNewProgram];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:kBackgroundObjectIndex inSection:kBackgroundSectionIndex];
    [self.programTableViewController viewDidLoad];
    [self.programTableViewController viewWillAppear:NO];
    UITableViewCell *cell = [self.programTableViewController tableView:self.programTableViewController.tableView cellForRowAtIndexPath:indexPath];
    NSString *backgroundCellTitle = nil;
    if ([cell conformsToProtocol:@protocol(CatrobatImageCell)]) {
        UITableViewCell<CatrobatImageCell> *imageCell = (UITableViewCell<CatrobatImageCell>*)cell;
        backgroundCellTitle = imageCell.titleLabel.text;
    }

    XCTAssertTrue([backgroundCellTitle isEqualToString:kLocalizedBackground], @"The ProgramTableViewController did not create the background cell correctly.");
}

- (void)testNewProgramBackgroundCellTitles
{
    [self setupForNewProgram];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:kBackgroundObjectIndex inSection:kBackgroundSectionIndex];
    [self.programTableViewController viewDidLoad];
    [self.programTableViewController viewWillAppear:NO];
    UITableViewCell *cell = [self.programTableViewController tableView:self.programTableViewController.tableView cellForRowAtIndexPath:indexPath];
    NSString *firstObjectCellTitle = nil;
    if ([cell conformsToProtocol:@protocol(CatrobatImageCell)]) {
        UITableViewCell <CatrobatImageCell>* imageCell = (UITableViewCell <CatrobatImageCell>*)cell;
        firstObjectCellTitle = imageCell.titleLabel.text;
    }
    XCTAssertTrue([firstObjectCellTitle isEqualToString:kLocalizedBackground], @"The ProgramTableViewController did not create the background cell correctly.");
}

- (void)testNewProgramNumberOfSections
{
    [self setupForNewProgram];
    [self.programTableViewController viewDidLoad];
    [self.programTableViewController viewWillAppear:NO];
    NSInteger numberOfSections = [self.programTableViewController numberOfSectionsInTableView:self.programTableViewController.tableView];
    XCTAssertEqual(numberOfSections, kNumberOfSectionsInProgramTableViewController, @"Wrong number of sections in ProgramTableViewController");
}

- (void)testNewProgramNumberOfBackgroundRows
{
    [self setupForNewProgram];
    [self.programTableViewController viewDidLoad];
    [self.programTableViewController viewWillAppear:NO];
    NSInteger numberOfBackgroundRows = [self.programTableViewController tableView:self.programTableViewController.tableView numberOfRowsInSection:kBackgroundSectionIndex];
    XCTAssertEqual(numberOfBackgroundRows, kBackgroundObjects, @"Wrong number of background rows in ProgramTableViewController");
}

- (void)testNewProgramNumberOfObjectRows
{
    [self setupForNewProgram];
    [self.programTableViewController viewDidLoad];
    [self.programTableViewController viewWillAppear:NO];
    NSInteger numberOfObjectRows = [self.programTableViewController tableView:self.programTableViewController.tableView numberOfRowsInSection:kObjectSectionIndex];
    XCTAssertEqual(numberOfObjectRows, kDefaultNumOfObjects, @"Wrong number of object rows in ProgramTableViewController");
}

#pragma mark - getters and setters
- (ProgramTableViewController*)programTableViewController
{
    // lazy instantiation
    if (! _programTableViewController) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPhone" bundle:[NSBundle mainBundle]];
        _programTableViewController = [storyboard instantiateViewControllerWithIdentifier:@"ProgramTableViewController"];
        [_programTableViewController performSelectorOnMainThread:@selector(view) withObject:nil waitUntilDone:YES];
    }
    return _programTableViewController;
}

- (FileManager*)fileManager
{
    if (! _fileManager)
        _fileManager = ((AppDelegate*)[UIApplication sharedApplication].delegate).fileManager;
    return _fileManager;
}

#pragma mark - helpers
- (Program*)loadProgram:(ProgramLoadingInfo*)loadingInfo
{
    Program *program = [Program programWithLoadingInfo:loadingInfo];
    [program setAsLastUsedProgram];
    return program;
}

+ (void)removeProject:(NSString*)projectPath
{
    FileManager *fileManager = ((AppDelegate*)[UIApplication sharedApplication].delegate).fileManager;
    if ([fileManager directoryExists:projectPath])
        [fileManager deleteDirectory:projectPath];
    [Util setLastProgramWithName:nil programID:nil];
}

@end
