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

#import "ProgramTableViewControllerTests.h"
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

// TODO: use mock objects for dependencies and constructor dependency injection, but XCTest does not seem to support this at the moment

@interface ProgramTableViewControllerTests ()
@property (nonatomic, strong) ProgramTableViewController *programTableViewController;
@property (nonatomic, strong) FileManager *fileManager;
@end

@implementation ProgramTableViewControllerTests

- (void)setUp
{
    [super setUp];
    self.programTableViewController.delegate = nil; // no delegate needed for our tests
}

- (void)tearDown
{
    [super tearDown];
    [ProgramTableViewControllerTests removeProject:[ProgramTableViewControllerTests defaultProjectPath]];
    // TODO: remove this hack later
    for (NSUInteger i = 1; i < 20; i++) {
        NSLog(@"%@", [NSString stringWithFormat:@"%@ (%d)",[ProgramTableViewControllerTests defaultProjectPath],i]);
        [ProgramTableViewControllerTests removeProject:[NSString stringWithFormat:@"%@ (%d)",[ProgramTableViewControllerTests defaultProjectPath],i]];
    }
    self.programTableViewController = nil;
    self.fileManager = nil;
}

#pragma mark - Default Program Tests
- (void)testNewDefaultProgramIfFolderExists
{
    // check if setUp method instantiated an instance of ProgramTableViewController (lazy instantiation) and
    // the instance should have created an empty default project including a defaultProject-directory
    XCTAssertFalse([self.fileManager directoryExists:[ProgramTableViewControllerTests defaultProjectPath]], @"The ProgramTableViewController did not create the project folder for the new project");
}

- (void)testNewDefaultProgramHasBackgroundObjectCell
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:kBackgroundObjectIndex inSection:kBackgroundSectionIndex];
    [self.programTableViewController viewDidLoad];
    [self.programTableViewController viewWillAppear:NO];
    UITableViewCell *cell = [self.programTableViewController tableView:self.programTableViewController.tableView cellForRowAtIndexPath:indexPath];
    NSString *backgroundCellTitle = nil;
    if ([cell conformsToProtocol:@protocol(CatrobatImageCell)]) {
        UITableViewCell <CatrobatImageCell>* imageCell = (UITableViewCell <CatrobatImageCell>*)cell;
        backgroundCellTitle = imageCell.titleLabel.text;
    }

    XCTAssertTrue([backgroundCellTitle isEqualToString:kBackgroundObjectName], @"The ProgramTableViewController did not create the background cell correctly.");
}

- (void)testNewDefaultProgramObjectCellTitles
{
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

- (void)testNewDefaultProgramNumberOfSections
{
    [self.programTableViewController viewDidLoad];
    [self.programTableViewController viewWillAppear:NO];
    NSInteger numberOfSections = [self.programTableViewController numberOfSectionsInTableView:self.programTableViewController.tableView];
    XCTAssertEqual(numberOfSections, kNumberOfSectionsInProgramTableViewController, @"Wrong number of sections in ProgramTableViewController");
}

- (void)testNewDefaultProgramNumberOfBackgroundRows
{
    [self.programTableViewController viewDidLoad];
    [self.programTableViewController viewWillAppear:NO];
    NSInteger numberOfBackgroundRows = [self.programTableViewController tableView:self.programTableViewController.tableView numberOfRowsInSection:kBackgroundSectionIndex];
    XCTAssertEqual(numberOfBackgroundRows, kBackgroundObjects, @"Wrong number of background rows in ProgramTableViewController");
}

- (void)testNewDefaultProgramNumberOfObjectRows
{
    [self.programTableViewController viewDidLoad];
    [self.programTableViewController viewWillAppear:NO];
    NSInteger numberOfObjectRows = [self.programTableViewController tableView:self.programTableViewController.tableView numberOfRowsInSection:kObjectSectionIndex];
    XCTAssertEqual(numberOfObjectRows, kDefaultNumOfObjects, @"Wrong number of object rows in ProgramTableViewController");
}

- (void)testNewDefaultProgramRenameProgramName
{
    NSString *newProgramName = @"This is a test program";
    [ProgramTableViewControllerTests removeProject:[NSString stringWithFormat:@"%@%@", [Program basePath], newProgramName]];
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
    [ProgramTableViewControllerTests removeProject:[NSString stringWithFormat:@"%@%@", [Program basePath], newProgramName]];
}

- (void)testNewDefaultProgramRenameProgramNameDelegateTest
{
    NSString *newProgramName = @"This is a test program";
    [ProgramTableViewControllerTests removeProject:[NSString stringWithFormat:@"%@%@", [Program basePath], newProgramName]];
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
    [ProgramTableViewControllerTests removeProject:[NSString stringWithFormat:@"%@%@", [Program basePath], newProgramName]];
}

#pragma mark - Tests for all existing programs
// existing programs like Aquarium, My first project, ...
- (void)testExistingProgramsIfFolderExists
{
    NSString *basePath = [Program basePath];
    NSError *error;
    NSArray *levels = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:basePath error:&error];
    NSLogError(error);

    for (NSString *level in levels) {
        // exclude .DS_Store folder on MACOSX simulator
        if ([level isEqualToString:@".DS_Store"])
            continue;

        ProgramLoadingInfo *loadingInfo = [[ProgramLoadingInfo alloc] init];
        loadingInfo.basePath = [NSString stringWithFormat:@"%@%@/", [Program basePath], level];
        loadingInfo.visibleName = level;
        NSLog(@"Project name: %@", level);
        self.programTableViewController.delegate = nil; // no delegate needed for this test
        self.programTableViewController.program = [Program programWithLoadingInfo:loadingInfo];
        [self.programTableViewController viewDidLoad];
        [self.programTableViewController viewWillAppear:NO];
        XCTAssertFalse([self.fileManager directoryExists:loadingInfo.basePath], @"The ProgramTableViewController did not create the project folder for the new project");
        self.programTableViewController = nil; // unload program table view controller
    }
}

- (void)testExistingProgramsObjectCells
{
    [ProgramTableViewControllerTests removeProject:[ProgramTableViewControllerTests defaultProjectPath]];
    NSString *basePath = [Program basePath];
    NSError *error;
    NSArray *levels = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:basePath error:&error];
    NSLogError(error);

    for (NSString *level in levels) {
        // exclude .DS_Store folder on MACOSX simulator
        if ([level isEqualToString:@".DS_Store"])
            continue;

        ProgramLoadingInfo *loadingInfo = [[ProgramLoadingInfo alloc] init];
        loadingInfo.basePath = [NSString stringWithFormat:@"%@%@/", [Program basePath], level];
        loadingInfo.visibleName = level;
        NSLog(@"Project name: %@", level);
        Program *program = [self loadProgram:loadingInfo];
        XCTAssertNotNil(program, @"Could not create program");
        if (! program) {
            NSLog(@"Loading level %@ failed", level);
            continue;
        }

        self.programTableViewController.delegate = nil; // no delegate needed for this test
        self.programTableViewController.program = [Program programWithLoadingInfo:loadingInfo];
        [self.programTableViewController performSelectorOnMainThread:@selector(view) withObject:nil waitUntilDone:YES];
        [self.programTableViewController viewDidLoad];
        [self.programTableViewController viewWillAppear:NO];

        // test background object cell
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:kBackgroundObjectIndex inSection:kBackgroundSectionIndex];
        UITableViewCell *cell = [self.programTableViewController tableView:self.programTableViewController.tableView cellForRowAtIndexPath:indexPath];
        NSString *backgroundObjectCellTitle = nil;
        if ([cell conformsToProtocol:@protocol(CatrobatImageCell)]) {
            UITableViewCell <CatrobatImageCell>* imageCell = (UITableViewCell <CatrobatImageCell>*)cell;
            backgroundObjectCellTitle = imageCell.titleLabel.text;
        }
        // TODO: german name "Hintergrund" instead of "background"
        XCTAssertTrue(([backgroundObjectCellTitle isEqualToString:kBackgroundTitle] || [backgroundObjectCellTitle isEqualToString:@"Hintergrund"]), @"The ProgramTableViewController did not create the background object cell correctly.");

        NSUInteger objectCounter = 0;
        NSLog(@"Program: %@", program.header.programName);
        NSLog(@"Number of objects: %d", [program.objectList count]);
        for (SpriteObject *object in program.objectList) {
            if (! objectCounter) {
                ++objectCounter;
                continue; // first object is background
            }

            indexPath = [NSIndexPath indexPathForRow:(objectCounter-1) inSection:kObjectSectionIndex];
            NSLog(@"%@", [indexPath description]);
            cell = [self.programTableViewController tableView:self.programTableViewController.tableView cellForRowAtIndexPath:indexPath];
            NSString *objectCellTitle = nil;
            if ([cell conformsToProtocol:@protocol(CatrobatImageCell)]) {
                UITableViewCell <CatrobatImageCell>* imageCell = (UITableViewCell <CatrobatImageCell>*)cell;
                objectCellTitle = imageCell.titleLabel.text;
            }
            NSLog(@"Name for object cell %@ - should be: %@", objectCellTitle, object.name);
            XCTAssertNotNil(object.name, @"Name of SpriteObject is nil, testing an empty string...");
            XCTAssertTrue([objectCellTitle isEqualToString:object.name], @"Wrong name for object cell %@ in program %@. Should be: %@", objectCellTitle, program.header.programName, object.name);
            ++objectCounter;
        }
        self.programTableViewController = nil; // unload program table view controller
    }
}

- (void)testExistingProgramsNumberOfSections
{
    [ProgramTableViewControllerTests removeProject:[ProgramTableViewControllerTests defaultProjectPath]];
    NSString *basePath = [Program basePath];
    NSError *error;
    NSArray *levels = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:basePath error:&error];
    NSLogError(error);

    for (NSString *level in levels) {
        // exclude .DS_Store folder on MACOSX simulator
        if ([level isEqualToString:@".DS_Store"])
            continue;

        ProgramLoadingInfo *loadingInfo = [[ProgramLoadingInfo alloc] init];
        loadingInfo.basePath = [NSString stringWithFormat:@"%@%@/", [Program basePath], level];
        loadingInfo.visibleName = level;
        NSLog(@"Project name: %@", level);

        self.programTableViewController.delegate = nil; // no delegate needed for this test
        self.programTableViewController.program = [Program programWithLoadingInfo:loadingInfo];
        [self.programTableViewController performSelectorOnMainThread:@selector(view) withObject:nil waitUntilDone:YES];
        [self.programTableViewController viewDidLoad];
        [self.programTableViewController viewWillAppear:NO];

        NSInteger numberOfSections = (NSInteger)[self.programTableViewController numberOfSectionsInTableView:self.programTableViewController.tableView];
        XCTAssertEqual(numberOfSections, kNumberOfSectionsInProgramTableViewController, @"Wrong number of sections in ProgramTableViewController for program: %@", level);
        self.programTableViewController = nil; // unload program table view controller
    }
}

- (void)testExistingProgramsNumberOfBackgroundRows
{
    [ProgramTableViewControllerTests removeProject:[ProgramTableViewControllerTests defaultProjectPath]];
    NSString *basePath = [Program basePath];
    NSError *error;
    NSArray *levels = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:basePath error:&error];
    NSLogError(error);

    for (NSString *level in levels) {
        // exclude .DS_Store folder on MACOSX simulator
        if ([level isEqualToString:@".DS_Store"])
            continue;

        ProgramLoadingInfo *loadingInfo = [[ProgramLoadingInfo alloc] init];
        loadingInfo.basePath = [NSString stringWithFormat:@"%@%@/", [Program basePath], level];
        loadingInfo.visibleName = level;
        NSLog(@"Project name: %@", level);

        self.programTableViewController.delegate = nil; // no delegate needed for this test
        self.programTableViewController.program = [Program programWithLoadingInfo:loadingInfo];
        [self.programTableViewController performSelectorOnMainThread:@selector(view) withObject:nil waitUntilDone:YES];
        [self.programTableViewController viewDidLoad];
        [self.programTableViewController viewWillAppear:NO];

        NSInteger numberOfBackgroundRows = (NSInteger)[self.programTableViewController tableView:self.programTableViewController.tableView numberOfRowsInSection:kBackgroundSectionIndex];
        XCTAssertEqual(numberOfBackgroundRows, kBackgroundObjects, @"Wrong number of background rows in ProgramTableViewController for program: %@", level);
        self.programTableViewController = nil; // unload program table view controller
    }
}

- (void)testExistingProgramsNumberOfObjectRows
{
    [ProgramTableViewControllerTests removeProject:[ProgramTableViewControllerTests defaultProjectPath]];
    NSString *basePath = [Program basePath];
    NSError *error;
    NSArray *levels = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:basePath error:&error];
    NSLogError(error);

    for (NSString *level in levels) {
        // exclude .DS_Store folder on MACOSX simulator
        if ([level isEqualToString:@".DS_Store"])
            continue;

        ProgramLoadingInfo *loadingInfo = [[ProgramLoadingInfo alloc] init];
        loadingInfo.basePath = [NSString stringWithFormat:@"%@%@/", [Program basePath], level];
        loadingInfo.visibleName = level;
        NSLog(@"Project name: %@", level);
        Program *program = [self loadProgram:loadingInfo];
        XCTAssertNotNil(program, @"Could not create program");
        if (! program) {
            NSLog(@"Loading level %@ failed", level);
            continue;
        }

        self.programTableViewController.delegate = nil; // no delegate needed for this test
        self.programTableViewController.program = [Program programWithLoadingInfo:loadingInfo];
        [self.programTableViewController performSelectorOnMainThread:@selector(view) withObject:nil waitUntilDone:YES];
        [self.programTableViewController viewDidLoad];
        [self.programTableViewController viewWillAppear:NO];

        NSUInteger numberOfObjectRows = (NSUInteger)[self.programTableViewController tableView:self.programTableViewController.tableView numberOfRowsInSection:kObjectSectionIndex];
        XCTAssertEqual(numberOfObjectRows, ([program.objectList count] - 1), @"Wrong number of object rows in ProgramTableViewController for program: %@", program.header.programName);
        self.programTableViewController = nil; // unload program table view controller
    }
}

- (void)testExistingProgramsTestRemoveBackgroundObjectTestMustFail
{
    [ProgramTableViewControllerTests removeProject:[ProgramTableViewControllerTests defaultProjectPath]];
    NSString *basePath = [Program basePath];
    NSError *error;
    NSArray *levels = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:basePath error:&error];
    NSLogError(error);

    for (NSString *level in levels) {
        // exclude .DS_Store folder on MACOSX simulator
        if ([level isEqualToString:@".DS_Store"])
            continue;

        ProgramLoadingInfo *loadingInfo = [[ProgramLoadingInfo alloc] init];
        loadingInfo.basePath = [NSString stringWithFormat:@"%@%@/", [Program basePath], level];
        loadingInfo.visibleName = level;
        NSLog(@"Project name: %@", level);

        self.programTableViewController.delegate = nil; // no delegate needed for this test
        self.programTableViewController.program = [Program programWithLoadingInfo:loadingInfo];
        [self.programTableViewController performSelectorOnMainThread:@selector(view) withObject:nil waitUntilDone:YES];
        [self.programTableViewController viewDidLoad];
        [self.programTableViewController viewWillAppear:NO];

        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:kBackgroundObjectIndex inSection:kBackgroundSectionIndex];
        BOOL result = [self.programTableViewController tableView:self.programTableViewController.tableView canEditRowAtIndexPath:indexPath];
        XCTAssertFalse(result, @"ProgramTableViewController permits removing background cell in program %@", level);
        self.programTableViewController = nil; // unload program table view controller
    }
}

- (void)testExistingProgramsTestRemoveAllObjectsExceptLastOneMustSucceedAndRemoveLastObjectMustFail
{
    [ProgramTableViewControllerTests removeProject:[ProgramTableViewControllerTests defaultProjectPath]];
    NSString *basePath = [Program basePath];
    NSError *error;
    NSArray *levels = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:basePath error:&error];
    NSLogError(error);
    
    for (NSString *level in levels) {
        // exclude .DS_Store folder on MACOSX simulator
        if ([level isEqualToString:@".DS_Store"])
            continue;

        ProgramLoadingInfo *loadingInfo = [[ProgramLoadingInfo alloc] init];
        loadingInfo.basePath = [NSString stringWithFormat:@"%@%@/", [Program basePath], level];
        loadingInfo.visibleName = level;
        NSLog(@"Project name: %@", level);
        Program *program = [self loadProgram:loadingInfo];
        XCTAssertNotNil(program, @"Could not create program");
        if (! program) {
            NSLog(@"Loading level %@ failed", level);
            continue;
        }

        self.programTableViewController.delegate = nil; // no delegate needed for this test
        self.programTableViewController.program = [Program programWithLoadingInfo:loadingInfo];
        [self.programTableViewController performSelectorOnMainThread:@selector(view) withObject:nil waitUntilDone:YES];
        [self.programTableViewController viewDidLoad];
        [self.programTableViewController viewWillAppear:NO];

        NSInteger objectCounter = 0;
        NSInteger totalNumOfObjects = [program.objectList count];
        for (SpriteObject *object in program.objectList) {
            // first object = background object => skip removing background object
            // (already considered in previous test)
            if (! objectCounter) {
                objectCounter++;
                continue;
            }
            // remove object at first index row
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:kObjectIndex inSection:kObjectSectionIndex];
            BOOL result = [self.programTableViewController tableView:self.programTableViewController.tableView canEditRowAtIndexPath:indexPath];
            if (objectCounter < totalNumOfObjects) {
                XCTAssertTrue(result, @"ProgramTableViewController forbids removing object cell for object %@ in program %@", object.name, program.header.programName);
                if (result) {
                    [self.programTableViewController tableView:self.programTableViewController.tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:indexPath];
                }
            } else {
                XCTAssertFalse(result, @"ProgramTableViewController permits removing last object cell for object %@ in program %@", object.name, program.header.programName);
            }
            objectCounter++;
        }

        // number of remaining table rows in background section must be 1
        NSInteger numberOfRows = [self.programTableViewController tableView:self.programTableViewController.tableView numberOfRowsInSection:kBackgroundSectionIndex];
        XCTAssertEqual(numberOfRows, 1, @"Wrong number of background rows in ProgramTableViewController for program: %@", program.header.programName);

        // number of remaining table rows in object section must be 1
        numberOfRows = [self.programTableViewController tableView:self.programTableViewController.tableView numberOfRowsInSection:kObjectSectionIndex];
        XCTAssertEqual(numberOfRows, 0, @"Wrong number of object rows in ProgramTableViewController for program: %@", program.header.programName);

        // check if name of last object name is equal to the title of the last remaining table row in the object section
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:kBackgroundObjectIndex inSection:kBackgroundSectionIndex];
        UITableViewCell *cell = [self.programTableViewController tableView:self.programTableViewController.tableView cellForRowAtIndexPath:indexPath];
        NSString *objectCellTitle = nil;
        if ([cell conformsToProtocol:@protocol(CatrobatImageCell)]) {
            UITableViewCell <CatrobatImageCell>* imageCell = (UITableViewCell <CatrobatImageCell>*)cell;
            objectCellTitle = imageCell.titleLabel.text;
        }
        SpriteObject *lastObject = [program.objectList objectAtIndex:kBackgroundObjectIndex];
        NSLog(@"Name for object cell %@ - should be: %@", objectCellTitle, lastObject.name);
        XCTAssertNotNil(lastObject.name, @"Name of SpriteObject is nil, testing an empty string...");
        XCTAssertTrue([objectCellTitle isEqualToString:lastObject.name], @"Wrong name for object cell %@ in program %@. Should be: %@", objectCellTitle, program.header.programName, lastObject.name);
        self.programTableViewController = nil; // unload program table view controller
    }
}

#pragma mark - Getters and setters
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

+ (NSString*)defaultProjectPath
{
    return [NSString stringWithFormat:@"%@%@", [Program basePath], kDefaultProgramName];
}

@end
