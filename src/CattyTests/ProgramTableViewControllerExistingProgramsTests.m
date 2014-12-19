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

// NOTE: needed for ProgramTableViewController.h to make some non-public methods that are needed for testing
// visible for this class
#define CATTY_TESTS 1

#import "ProgramTableViewControllerExistingProgramsTests.h"
#import "ProgramTableViewController+UnitTestingExtensions.h"
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

@interface ProgramTableViewControllerExistingProgramsTests ()
@property (nonatomic, strong) ProgramTableViewController *programTableViewController;
@property (nonatomic, strong) FileManager *fileManager;
@end

@implementation ProgramTableViewControllerExistingProgramsTests

- (void)setUp
{
    [super setUp];
    if (! [self.fileManager directoryExists:[Program basePath]]) {
        [self.fileManager createDirectory:[Program basePath]];
    }
    self.programTableViewController.delegate = nil; // no delegate needed for our tests
    [Util activateTestMode:YES];
}

- (void)tearDown
{
    self.programTableViewController = nil;
    self.fileManager = nil;
    [super tearDown];
}

#pragma mark - Tests for all existing programs
// existing programs like Whack a mole, ...
- (void)testExistingProgramsIfFolderExists
{
    NSArray *allProgramLoadingInfos = [Program allProgramLoadingInfos];
    for (ProgramLoadingInfo *programLoadingInfo in allProgramLoadingInfos) {
        // exclude new program
        if ([programLoadingInfo.visibleName isEqualToString:kLocalizedNewProgram])
            continue;

        NSDebug(@"Program name: %@", programLoadingInfo.visibleName);
        self.programTableViewController.delegate = nil; // no delegate needed for this test
        self.programTableViewController.program = [Program programWithLoadingInfo:programLoadingInfo];
        [self.programTableViewController viewDidLoad];
        [self.programTableViewController viewWillAppear:NO];
        XCTAssertTrue([self.fileManager directoryExists:programLoadingInfo.basePath], @"The ProgramTableViewController did not create the project folder for the project %@", programLoadingInfo.visibleName);
        self.programTableViewController = nil; // unload program table view controller
    }
}

- (void)testExistingProgramsObjectCells
{
    NSArray *allProgramLoadingInfos = [Program allProgramLoadingInfos];
    for (ProgramLoadingInfo *programLoadingInfo in allProgramLoadingInfos) {
        // exclude new program
        if ([programLoadingInfo.visibleName isEqualToString:kLocalizedNewProgram])
            continue;

        NSDebug(@"Program name: %@", programLoadingInfo.visibleName);
        Program *program = [self loadProgram:programLoadingInfo];
        XCTAssertNotNil(program, @"Could not create program");
        if (! program) {
            NSLog(@"Loading program %@ failed", programLoadingInfo.visibleName);
            continue;
        }

        self.programTableViewController.delegate = nil; // no delegate needed for this test
        self.programTableViewController.program = [Program programWithLoadingInfo:programLoadingInfo];
        [self.programTableViewController performSelectorOnMainThread:@selector(view) withObject:nil waitUntilDone:YES];
        [self.programTableViewController viewDidLoad];
        [self.programTableViewController viewWillAppear:NO];

        // test background object cell
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:kBackgroundObjectIndex inSection:kBackgroundSectionIndex];
        UITableViewCell *cell = [self.programTableViewController tableView:self.programTableViewController.tableView cellForRowAtIndexPath:indexPath];
        NSString *backgroundObjectCellTitle = nil;
        if ([cell conformsToProtocol:@protocol(CatrobatImageCell)]) {
            UITableViewCell<CatrobatImageCell> *imageCell = (UITableViewCell<CatrobatImageCell>*)cell;
            backgroundObjectCellTitle = imageCell.titleLabel.text;
        }
        XCTAssertTrue(([backgroundObjectCellTitle isEqualToString:kLocalizedBackground]
                       || [backgroundObjectCellTitle isEqualToString:@"Background"]
                       || [backgroundObjectCellTitle isEqualToString:@"Hintergrund"]),
                      @"The ProgramTableViewController did not create the background object cell correctly.");

        NSUInteger objectCounter = 0;
        NSDebug(@"Program: %@", program.header.programName);
        NSDebug(@"Number of objects: %lu", (unsigned long)[program numberOfTotalObjects]);
        for (SpriteObject *object in program.objectList) {
            if (! objectCounter) {
                ++objectCounter;
                continue; // first object is background
            }

            indexPath = [NSIndexPath indexPathForRow:(objectCounter-1) inSection:kObjectSectionIndex];
            NSDebug(@"%@", [indexPath description]);
            cell = [self.programTableViewController tableView:self.programTableViewController.tableView cellForRowAtIndexPath:indexPath];
            NSString *objectCellTitle = nil;
            if ([cell conformsToProtocol:@protocol(CatrobatImageCell)]) {
                UITableViewCell <CatrobatImageCell>* imageCell = (UITableViewCell <CatrobatImageCell>*)cell;
                objectCellTitle = imageCell.titleLabel.text;
            }
            NSDebug(@"Name for object cell %@ - should be: %@", objectCellTitle, object.name);
            XCTAssertNotNil(object.name, @"Name of SpriteObject is nil, testing an empty string...");
            XCTAssertTrue([objectCellTitle isEqualToString:object.name], @"Wrong name for object cell %@ in program %@. Should be: %@", objectCellTitle, program.header.programName, object.name);
            ++objectCounter;
        }
        self.programTableViewController = nil; // unload program table view controller
    }
}

- (void)testExistingProgramsNumberOfSections
{
    NSArray *allProgramLoadingInfos = [Program allProgramLoadingInfos];
    for (ProgramLoadingInfo *programLoadingInfo in allProgramLoadingInfos) {
        // exclude new program
        if ([programLoadingInfo.visibleName isEqualToString:kLocalizedNewProgram])
            continue;

        NSLog(@"Program name: %@", programLoadingInfo.visibleName);
        self.programTableViewController.delegate = nil; // no delegate needed for this test
        self.programTableViewController.program = [Program programWithLoadingInfo:programLoadingInfo];
        [self.programTableViewController performSelectorOnMainThread:@selector(view) withObject:nil waitUntilDone:YES];
        [self.programTableViewController viewDidLoad];
        [self.programTableViewController viewWillAppear:NO];
        NSInteger numberOfSections = (NSInteger)[self.programTableViewController numberOfSectionsInTableView:self.programTableViewController.tableView];
        XCTAssertEqual(numberOfSections, kNumberOfSectionsInProgramTableViewController, @"Wrong number of sections in ProgramTableViewController for program: %@", programLoadingInfo.visibleName);
        self.programTableViewController = nil; // unload program table view controller
    }
}

- (void)testExistingProgramsNumberOfBackgroundRows
{
    NSArray *allProgramLoadingInfos = [Program allProgramLoadingInfos];
    for (ProgramLoadingInfo *programLoadingInfo in allProgramLoadingInfos) {
        // exclude new program
        if ([programLoadingInfo.visibleName isEqualToString:kLocalizedNewProgram])
            continue;

        NSDebug(@"Program name: %@", programLoadingInfo.visibleName);
        self.programTableViewController.delegate = nil; // no delegate needed for this test
        self.programTableViewController.program = [Program programWithLoadingInfo:programLoadingInfo];
        [self.programTableViewController performSelectorOnMainThread:@selector(view) withObject:nil waitUntilDone:YES];
        [self.programTableViewController viewDidLoad];
        [self.programTableViewController viewWillAppear:NO];

        NSInteger numberOfBackgroundRows = (NSInteger)[self.programTableViewController tableView:self.programTableViewController.tableView numberOfRowsInSection:kBackgroundSectionIndex];
        XCTAssertEqual(numberOfBackgroundRows, kBackgroundObjects, @"Wrong number of background rows in ProgramTableViewController for program: %@", programLoadingInfo.visibleName);
        self.programTableViewController = nil; // unload program table view controller
    }
}

- (void)testExistingProgramsNumberOfObjectRows
{
    NSArray *allProgramLoadingInfos = [Program allProgramLoadingInfos];
    for (ProgramLoadingInfo *programLoadingInfo in allProgramLoadingInfos) {
        // exclude new program
        if ([programLoadingInfo.visibleName isEqualToString:kLocalizedNewProgram])
            continue;

        NSDebug(@"Program name: %@", programLoadingInfo.visibleName);
        Program *program = [self loadProgram:programLoadingInfo];
        XCTAssertNotNil(program, @"Could not create program");
        if (! program) {
            NSLog(@"Loading program %@ failed", programLoadingInfo.visibleName);
            continue;
        }

        self.programTableViewController.delegate = nil; // no delegate needed for this test
        self.programTableViewController.program = [Program programWithLoadingInfo:programLoadingInfo];
        [self.programTableViewController performSelectorOnMainThread:@selector(view) withObject:nil waitUntilDone:YES];
        [self.programTableViewController viewDidLoad];
        [self.programTableViewController viewWillAppear:NO];

        NSUInteger numberOfObjectRows = (NSUInteger)[self.programTableViewController tableView:self.programTableViewController.tableView numberOfRowsInSection:kObjectSectionIndex];
        XCTAssertEqual(numberOfObjectRows, [program numberOfNormalObjects], @"Wrong number of object rows in ProgramTableViewController for program: %@", program.header.programName);
        self.programTableViewController = nil; // unload program table view controller
    }
}

- (void)testExistingProgramsTestRemoveBackgroundObjectTestMustFail
{
    NSArray *allProgramLoadingInfos = [Program allProgramLoadingInfos];
    for (ProgramLoadingInfo *programLoadingInfo in allProgramLoadingInfos) {
        // exclude new program
        if ([programLoadingInfo.visibleName isEqualToString:kLocalizedNewProgram])
            continue;

        NSDebug(@"Program name: %@", programLoadingInfo.visibleName);
        self.programTableViewController.delegate = nil; // no delegate needed for this test
        self.programTableViewController.program = [Program programWithLoadingInfo:programLoadingInfo];
        [self.programTableViewController performSelectorOnMainThread:@selector(view) withObject:nil waitUntilDone:YES];
        [self.programTableViewController viewDidLoad];
        [self.programTableViewController viewWillAppear:NO];

        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:kBackgroundObjectIndex inSection:kBackgroundSectionIndex];
        BOOL result = [self.programTableViewController tableView:self.programTableViewController.tableView canEditRowAtIndexPath:indexPath];
        XCTAssertFalse(result, @"ProgramTableViewController permits removing background cell in program %@", programLoadingInfo.visibleName);
        self.programTableViewController = nil; // unload program table view controller
    }
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
    NSDebug(@"Try to load project '%@'", loadingInfo.visibleName);
    NSDebug(@"Path: %@", loadingInfo.basePath);
    NSString *xmlPath = [NSString stringWithFormat:@"%@", loadingInfo.basePath];
    NSDebug(@"XML-Path: %@", xmlPath);
    Program *program = [[[Parser alloc] init] generateObjectForProgramWithPath:[xmlPath stringByAppendingFormat:@"%@", kProgramCodeFileName]];

    if (! program)
        return nil;

    NSDebug(@"ProjectResolution: width/height:  %f / %f", program.header.screenWidth.floatValue, program.header.screenHeight.floatValue);
//    for (SpriteObject *sprite in program.objectList) {
//        sprite.spriteManagerDelegate = self;
//        sprite.broadcastWaitDelegate = self.broadcastWaitHandler;
//    }
    [Util setLastProgramWithName:program.header.programName programID:program.header.programID];
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
