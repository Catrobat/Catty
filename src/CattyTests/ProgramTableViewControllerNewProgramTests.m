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

// NOTE: needed for ProgramTableViewController.h to make some non-public methods that are needed for testing
// visible for this class
#define CATTY_TESTS 1

#import "ProgramTableViewControllerNewProgramTests.h"
#import "ProgramTableViewController.h"
#import "Program.h"
#import "ProgramDefines.h"
#import "AppDelegate.h"
#import "FileManager.h"
#import "Util.h"
#import "ProgramLoadingInfo.h"
#import "CatrobatImageCell.h"
#import "DarkBlueGradientBorderedImageCell.h"
#import "CellTagDefines.h"
#import "Parser.h"
#import "SpriteObject.h"
#import "Brick.h"
#import "Script.h"
#import "ActionSheetAlertViewTags.h"
#import "MyProgramsViewController.h"

#define kNewProgramName @"My new program"

// TODO: use mock objects for dependencies and constructor dependency injection, but XCTest does not seem to support this at the moment

@interface ProgramTableViewControllerNewProgramTests ()
@property (nonatomic, strong) ProgramTableViewController *programTableViewController;
@property (nonatomic, strong) FileManager *fileManager;
@property (nonatomic, strong) Program *defaultProgram;
@end

@implementation ProgramTableViewControllerNewProgramTests

- (void)setUp
{
    [super setUp];
    if (self.defaultProgram) {
        [ProgramTableViewControllerNewProgramTests removeProject:[self.defaultProgram projectPath]];
    }
    self.programTableViewController.delegate = nil; // no delegate needed for our tests
}

- (void)setupForNewProgram
{
    self.defaultProgram = [Program defaultProgramWithName:kNewProgramName];
    self.programTableViewController.program = self.defaultProgram;
    self.programTableViewController.isNewProgram = YES;
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

    XCTAssertTrue([backgroundCellTitle isEqualToString:kBackgroundObjectName], @"The ProgramTableViewController did not create the background cell correctly.");
}

- (void)testNewProgramObjectCellTitles
{
    [self setupForNewProgram];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:kObjectIndex inSection:kObjectSectionIndex];
    [self.programTableViewController viewDidLoad];
    [self.programTableViewController viewWillAppear:NO];
    UITableViewCell *cell = [self.programTableViewController tableView:self.programTableViewController.tableView cellForRowAtIndexPath:indexPath];
    NSString *firstObjectCellTitle = nil;
    if ([cell conformsToProtocol:@protocol(CatrobatImageCell)]) {
        UITableViewCell <CatrobatImageCell>* imageCell = (UITableViewCell <CatrobatImageCell>*)cell;
        firstObjectCellTitle = imageCell.titleLabel.text;
    }

    XCTAssertTrue([firstObjectCellTitle isEqualToString:kDefaultObjectName], @"The ProgramTableViewController did not create the first object cell correctly.");
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

- (void)testNewProgramRenameProgramName
{
    [self setupForNewProgram];
    NSString *newProgramName = @"This is a test program";
    [ProgramTableViewControllerNewProgramTests removeProject:[NSString stringWithFormat:@"%@%@", [Program basePath], newProgramName]];
    [self.programTableViewController viewDidLoad];
    [self.programTableViewController viewWillAppear:NO];
    UIAlertView *alertView = [[UIAlertView alloc] init];
    alertView.tag = kRenameAlertViewTag;
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [alertView textFieldAtIndex:0];
    textField.text = newProgramName;
    XCTAssertNoThrow([self.programTableViewController alertView:alertView clickedButtonAtIndex:kAlertViewButtonOK], @"Could not rename program");

    // TODO: write some tests for random input to test input validators and filters

    Program *program = self.programTableViewController.program;
    XCTAssertNotNil(program.header.programName, @"Name of renamed program is nil, testing an empty string...");
    XCTAssertTrue([program.header.programName isEqualToString:newProgramName], @"Name of renamed program is %@, but should be %@ ProgramTableViewController", program.header.programName, newProgramName);
    [ProgramTableViewControllerNewProgramTests removeProject:[NSString stringWithFormat:@"%@%@", [Program basePath], newProgramName]];
}

- (void)testNewProgramRenameProgramNameDelegateTest
{
    [self setupForNewProgram];
    NSString *newProgramName = @"This is a test program";
    [ProgramTableViewControllerNewProgramTests removeProject:[NSString stringWithFormat:@"%@%@", [Program basePath], newProgramName]];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPhone" bundle:[NSBundle mainBundle]];
    MyProgramsViewController<LevelUpdateDelegate> *myProgramsViewController = [storyboard instantiateViewControllerWithIdentifier:@"MyProgramsViewController"];
    [myProgramsViewController performSelectorOnMainThread:@selector(view) withObject:nil waitUntilDone:YES];
    self.programTableViewController.delegate = myProgramsViewController;
    [self.programTableViewController viewDidLoad];
    [self.programTableViewController viewWillAppear:NO];
    UIAlertView *alertView = [[UIAlertView alloc] init];
    alertView.tag = kRenameAlertViewTag;
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [alertView textFieldAtIndex:0];
    textField.text = newProgramName;
    XCTAssertNoThrow([self.programTableViewController alertView:alertView clickedButtonAtIndex:kAlertViewButtonOK], @"Could not rename program");

    // TODO: write some tests for random input to test input validators and filters

    NSInteger numberOfRows = [myProgramsViewController tableView:myProgramsViewController.tableView numberOfRowsInSection:0];
    NSInteger matchNewNameCounter = 0;
    for (NSInteger counter = 0; counter < numberOfRows; ++counter) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:counter inSection:0];
        UITableViewCell *cell = [myProgramsViewController tableView:myProgramsViewController.tableView cellForRowAtIndexPath:indexPath];
        NSString *levelName = nil;
        if ([cell conformsToProtocol:@protocol(CatrobatImageCell)]) {
            UITableViewCell <CatrobatImageCell>* imageCell = (UITableViewCell <CatrobatImageCell>*)cell;
            levelName = imageCell.titleLabel.text;
        }
        NSLog(@"Name of level is: %@", levelName);
        XCTAssertNotNil(levelName, @"Name of renamed program is nil, testing an empty string...");
        XCTAssertFalse([levelName isEqualToString:kDefaultProgramName], @"Did not rename level of delegate");
        if ([levelName isEqualToString:newProgramName]) {
            ++matchNewNameCounter;
        }
    }
    XCTAssertEqual(matchNewNameCounter, 1, @"Did not rename level of delegate correctly. Number of renamed levels: %d", matchNewNameCounter);
    [ProgramTableViewControllerNewProgramTests removeProject:[NSString stringWithFormat:@"%@%@", [Program basePath], newProgramName]];
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
    if (_fileManager)
        _fileManager = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).fileManager;
    return _fileManager;
}

#pragma mark - helpers
- (Program*)loadProgram:(ProgramLoadingInfo*)loadingInfo
{
    NSDebug(@"Try to load project '%@'", loadingInfo.visibleName);
    NSDebug(@"Path: %@", loadingInfo.basePath);
    NSString *xmlPath = [NSString stringWithFormat:@"%@", loadingInfo.basePath];
    NSDebug(@"XML-Path: %@", xmlPath);
    Program *program = [[[Parser alloc] init] generateObjectForLevel:[xmlPath stringByAppendingFormat:@"%@", kProgramCodeFileName]];

    if (! program)
        return nil;

    NSDebug(@"ProjectResolution: width/height:  %f / %f", program.header.screenWidth.floatValue, program.header.screenHeight.floatValue);

    // setting effect
    for (SpriteObject *sprite in program.objectList)
    {
        //sprite.spriteManagerDelegate = self;
        //sprite.broadcastWaitDelegate = self.broadcastWaitHandler;

        // TODO: change!
        for (Script *script in sprite.scriptList) {
            for (Brick *brick in script.brickList) {
                brick.object = sprite;
            }
        }
    }
    [Util setLastProgram:program.header.programName];
    return program;
}

+ (void)removeProject:(NSString*)projectPath
{
    FileManager *fileManager = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).fileManager;
    if ([fileManager directoryExists:projectPath])
        [fileManager deleteDirectory:projectPath];
    [Util setLastProgram:nil];
}

@end
