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

#import "ProgramTests.h"
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

@interface ProgramTests ()
@property (nonatomic, strong) ProgramTableViewController *programTableViewController;
@property (nonatomic, strong) FileManager *fileManager;
@end

@implementation ProgramTests

- (void)setUp
{
    [super setUp];
    [self removeProject:[self defaultProjectPath]];
}

- (void)tearDown
{
    [super tearDown];
    [self removeProject:[self defaultProjectPath]];
    self.programTableViewController = nil;
    self.fileManager = nil;
}

#pragma mark - Tests
- (void)testNewProgramWithDefaultProgramIfFolderExists
{
    self.programTableViewController.delegate = nil; // no delegate needed for this test
    NSString *projectPath = [NSString stringWithFormat:@"%@%@/", [Program basePath], kDefaultProgramName];
    XCTAssertFalse([self.fileManager directoryExists:projectPath], @"The ProgramTableViewController did not create the project folder for the new project");
}

- (void)testNewProgramHasBackgroundObjectCell
{
    self.programTableViewController.delegate = nil; // no delegate needed for this test
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:kBackgroundIndex inSection:0];
    [self.programTableViewController.tableView registerClass:[DarkBlueGradientBorderedImageCell class] forCellReuseIdentifier:@"cellId"];
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
        [self.programTableViewController loadProgram:loadingInfo];
        XCTAssertFalse([self.fileManager directoryExists:loadingInfo.basePath], @"The ProgramTableViewController did not create the project folder for the new project");
        self.programTableViewController = nil; // unload program table view controller
    }
}

#pragma mark - Getters and setters
- (ProgramTableViewController*)programTableViewController
{
    if (! _programTableViewController) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPhone" bundle:[NSBundle mainBundle]];
        _programTableViewController = [storyboard instantiateViewControllerWithIdentifier:@"ProgramTableViewController"];
        [_programTableViewController.tableView registerClass:NSClassFromString(@"DarkBlueGradientBorderedImageCell") forCellReuseIdentifier:kObjectCell];
        [_programTableViewController performSelectorOnMainThread:@selector(view) withObject:nil waitUntilDone:YES];
//        _programTableViewController = [[ProgramTableViewController alloc] initWithNibName:nil bundle:nil];
//        XCTAssertNotNil(_programTableViewController.view, @"Could not create view for ProgramTableViewController");
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
- (void)removeProject:(NSString*)projectPath
{
    FileManager *fileManager = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).fileManager;
    if ([fileManager directoryExists:projectPath])
        [fileManager deleteDirectory:projectPath];
    [Util setLastProgram:nil];
}

- (NSString*)defaultProjectPath
{
    return [NSString stringWithFormat:@"%@%@/", [Program basePath], kDefaultProgramName];
}

@end
