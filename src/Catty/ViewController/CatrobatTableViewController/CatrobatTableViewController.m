/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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

#import "CatrobatTableViewController.h"
#import "CellTagDefines.h"
#import "TableUtil.h"
#import "AppDelegate.h"
#import "Util.h"
#import "CatrobatImageCell.h"
#import "DownloadTabBarController.h"
#import "ProjectDetailStoreViewController.h"
#import "SegueDefines.h"
#import "Script.h"
#import "ProjectTableViewController.h"
#import "LoginViewController.h"
#import "SettingsTableViewController.h"
#import "Pocket_Code-Swift.h"

NS_ENUM(NSInteger, ViewControllerIndex) {
    kContinueProjectVC = 0,
    kNewProjectVC,
    kLocalProjectsVC,
    kHelpVC,
    kExploreVC,
    kUploadVC
};

@interface CatrobatTableViewController () <UITextFieldDelegate>

@property (nonatomic, strong) NSArray *cells;
@property (nonatomic, strong) NSArray *imageNames;
@property (nonatomic, strong) NSMutableArray *identifiers;
@property (nonatomic, strong) Project *lastUsedProject;
@property (nonatomic, strong) Project *defaultProject;
@property (nonatomic, assign) BOOL freshLogin;

@end

@implementation CatrobatTableViewController

#pragma mark - getters and setters
- (Project*)lastUsedProject
{
    if (! _lastUsedProject) {
        _lastUsedProject = [Project lastUsedProject];
    }
    return _lastUsedProject;
}

#pragma mark - view events
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initTableView];

    self.freshLogin = false;
    self.lastUsedProject = nil;
    self.defaultProject = nil;
    CBFileManager *fileManager = [CBFileManager sharedManager];
    if (! [fileManager directoryExists:[Project basePath]]) {
        [fileManager createDirectory:[Project basePath]];
    }
    [fileManager addDefaultProjectToProjectsRootDirectoryIfNoProjectsExist];

    self.tableView.delaysContentTouches = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;

    self.tableView.separatorInset = UIEdgeInsetsZero;

    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    [self presentIntroductionIfNeeded];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.lastUsedProject = nil;
    self.defaultProject = nil;
    self.navigationController.toolbarHidden = YES;
    [self.navigationController.navigationBar setHidden:NO];
     NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    BOOL lockIphoneEnabeled = [self shouldLockIphoneInAppWithoutScenePresenter];
    [[UIApplication sharedApplication] setIdleTimerDisabled:(lockIphoneEnabeled)];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    self.tableView.scrollEnabled = YES;
    [self initNavigationBar];
}

- (BOOL)shouldLockIphoneInAppWithoutScenePresenter
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return (! [defaults boolForKey:@"lockiphone"]);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    self.tableView.alwaysBounceVertical = NO;
}

#pragma mark init
- (void)initTableView
{
    self.cells = [[NSArray alloc] initWithObjects:
                  kLocalizedContinueProject,
                  kLocalizedNewProject,
                  kLocalizedProjectsOnDevice,
                  kLocalizedHelp,
                  kLocalizedCatrobatCommunity,
                  kLocalizedUploadProject, nil];

    self.imageNames = [[NSArray alloc] initWithObjects:kMenuImageNameContinue, kMenuImageNameNew, kMenuImageNameProjects, kMenuImageNameHelp, kMenuImageNameExplore, kMenuImageNameUpload, nil];
    self.identifiers = [[NSMutableArray alloc] initWithObjects:kSegueToContinue, kSegueToNewProject, kSegueToProjects, kSegueToHelp, kSegueToExplore, kSegueToUpload, nil];
}

- (void)initNavigationBar
{
    self.navigationItem.title = kLocalizedPocketCode;
    self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName : UIColor.navTint };
    self.navigationController.navigationBar.tintColor = UIColor.navTint;
}

- (IBAction)openSettings:(id)sender {
    [self infoPressed:sender];
}

#pragma mark - introduction

- (void)presentIntroductionIfNeeded {
    if (!IntroductionPageViewController.hasBeenShown || IntroductionPageViewController.showOnEveryLaunch) {
        UIViewController *viewController = [IntroductionPageViewController new];
        viewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
        viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self.navigationController presentViewController:viewController animated:NO completion:nil];
    }
}

#pragma mark - actions
- (void)infoPressed:(id)sender
{
    SettingsTableViewController *sTVC = [SettingsTableViewController new];
    [self.navigationController pushViewController:sTVC animated:YES];
}

- (void)addProjectAndSegueToItActionForProjectWithName:(NSString*)projectName
{
    static NSString *segueToNewProjectIdentifier = kSegueToNewProject;
    [self showLoadingView];
    self.defaultProject = [Project defaultProjectWithName:projectName projectID:nil];
    if ([self shouldPerformSegueWithIdentifier:segueToNewProjectIdentifier sender:self]) {
        [self hideLoadingView];
        [self performSegueWithIdentifier:segueToNewProjectIdentifier sender:self];
    }
}

#pragma mark - table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.cells count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSString *CellIdentifier = (indexPath.row == 0) ? kContinueCell : kImageCell;
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    if (! cell) {
        NSError(@"Should Never happen - since iOS5 Storyboard *always* instantiates our cell!");
        return [UITableViewCell new];
    }
    if ([cell conformsToProtocol:@protocol(CatrobatImageCell)]) {
        UITableViewCell<CatrobatImageCell> *imageCell = (UITableViewCell<CatrobatImageCell>*)cell;
        [self configureImageCell:imageCell atIndexPath:indexPath];
    }
    if (indexPath.row == 0) {
        [self configureSubtitleLabelForCell:cell];
    }
    
    cell.layoutMargins = UIEdgeInsetsZero;
    cell.preservesSuperviewLayoutMargins = NO;
    
    return cell;
}

#pragma mark - table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSString* identifier = [self.identifiers objectAtIndex:indexPath.row];
    switch (indexPath.row) {
        case kNewProjectVC:
            [Util askUserForUniqueNameAndPerformAction:@selector(addProjectAndSegueToItActionForProjectWithName:)
                                                target:self
                                           promptTitle:kLocalizedNewProject
                                         promptMessage:[NSString stringWithFormat:@"%@:", kLocalizedProjectName]
                                           promptValue:nil
                                     promptPlaceholder:kLocalizedEnterYourProjectNameHere
                                        minInputLength:kMinNumOfProjectNameCharacters
                                        maxInputLength:kMaxNumOfProjectNameCharacters
                              invalidInputAlertMessage:kLocalizedProjectNameAlreadyExistsDescription
                                         existingNames:[Project allProjectNames]];
            break;
        case kContinueProjectVC:
        case kLocalProjectsVC:
        case kExploreVC:
        case kHelpVC:
            if ([self shouldPerformSegueWithIdentifier:identifier sender:self]) {
                [self performSegueWithIdentifier:identifier sender:self];
            }
            break;
        case kUploadVC:
            if ([[[NSUserDefaults standardUserDefaults] valueForKey:kUserIsLoggedIn] boolValue]) {
                if ([self shouldPerformSegueWithIdentifier:identifier sender:self]) {
                    [self performSegueWithIdentifier:@"segueToUpload" sender:self];
                }
    
            } else {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPhone" bundle: nil];
                LoginViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"LoginController"];
                vc.catTVC = self;
                [self.navigationController pushViewController:vc animated:YES];
            }

            break;
            
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)afterSuccessfulLogin
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:kUserIsLoggedIn] boolValue]) {
            static NSString *segueToUploadIdentifier = kSegueToUpload;
            
            if ([self shouldPerformSegueWithIdentifier:segueToUploadIdentifier sender:self]) {
                self.freshLogin = true;
                [self performSegueWithIdentifier:segueToUploadIdentifier sender:self];
            }
        }
    });
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return [self getHeightForCellAtIndexPath:indexPath];
}

#pragma mark - table view helpers
- (void)configureImageCell:(UITableViewCell <CatrobatImageCell>*)cell atIndexPath:(NSIndexPath*)indexPath
{
    cell.backgroundColor = UIColor.background;
    cell.titleLabel.text = [self.cells objectAtIndex:indexPath.row];
    cell.iconImageView.image = [UIImage imageNamed:[self.imageNames objectAtIndex:indexPath.row]];
    cell.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)configureSubtitleLabelForCell:(UITableViewCell*)cell
{
    UILabel *subtitleLabel = (UILabel*)[cell viewWithTag:kSubtitleLabelTag];
    subtitleLabel.textColor = UIColor.textTint;
    Project *lastProject = self.lastUsedProject;
    subtitleLabel.text = (lastProject) ? lastProject.header.programName :  @"";
}

- (CGFloat)getHeightForCellAtIndexPath:(NSIndexPath*)indexPath
{
    CGFloat height;
    CGFloat navBarHeight = self.navigationController.navigationBar.frame.size.height;
    if (indexPath.row == 0) {
        height= [TableUtil heightForContinueCell:navBarHeight];
    } else {
        height = [TableUtil heightForCatrobatTableViewImageCell:navBarHeight];
    }
    return height; // for scrolling reasons
}

#pragma mark - segue handling
- (BOOL)shouldPerformSegueWithIdentifier:(NSString*)identifier sender:(id)sender
{
    if ([identifier isEqualToString:kSegueToContinue]) {
        // check if project loaded successfully -> not nil
        if (self.lastUsedProject) {
            return YES;
        }

        // project failed loading...
        // update continue cell
        [Util setLastProjectWithName:nil projectID:nil];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [Util alertWithText:kLocalizedUnableToLoadProject];
        return NO;
    } else if ([identifier isEqualToString:kSegueToNewProject]) {
        // if there is no project name, abort performing this segue and ask user for project name
        // after user entered a valid project name this segue will be called again and accepted
        if (! self.defaultProject) {
            return NO;
        }
        return YES;
    }
    
    return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
}

#pragma mark - segue handling
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kSegueToContinue]) {
        if ([segue.destinationViewController isKindOfClass:[ProjectTableViewController class]]) {
            ProjectTableViewController *projectTableViewController = (ProjectTableViewController*)segue.destinationViewController;
            projectTableViewController.project = self.lastUsedProject;
            self.lastUsedProject = nil;
        }
    } else if ([segue.identifier isEqualToString:kSegueToNewProject]) {
        if ([segue.destinationViewController isKindOfClass:[ProjectTableViewController class]]) {
            ProjectTableViewController *projectTableViewController = (ProjectTableViewController*)segue.destinationViewController;
            projectTableViewController.project = self.defaultProject;
            self.defaultProject = nil;
        }
    }
}

#pragma mark - network status

- (void)dealloc
{
    [self.identifiers removeAllObjects];
}

-(void)addProjectFromInboxWithName:(NSString*)newProjectName
{
    NSFileManager* filemgr = [NSFileManager defaultManager];
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* inboxPath = [documentsDirectory stringByAppendingPathComponent:@"Inbox"];
    NSArray* dirFiles = [filemgr contentsOfDirectoryAtPath:inboxPath
                                                     error:nil];
    if(![dirFiles firstObject])
    {
        return;
    }
    NSString* newProjectPath = [NSString stringWithFormat:@"%@/%@", inboxPath, [dirFiles firstObject]];
    
    NSData* newProject = [NSData dataWithContentsOfFile:newProjectPath];
    
    CBFileManager *fileManager = [CBFileManager sharedManager];
    [fileManager unzipAndStore:newProject withProjectID:nil withName:newProjectName];
    
    [[NSFileManager defaultManager] removeItemAtPath:newProjectPath error:nil];
}

-(void)addProjectFromInbox
{
    [Util askUserForUniqueNameAndPerformAction:@selector(addProjectFromInboxWithName:)
                                        target:self
                                   promptTitle:kLocalizedEnterNameForImportedProjectTitle
                                 promptMessage:[NSString stringWithFormat:@"%@:", kLocalizedProjectName]
                                   promptValue:nil
                             promptPlaceholder:kLocalizedEnterYourProjectNameHere
                                minInputLength:kMinNumOfProjectNameCharacters
                                maxInputLength:kMaxNumOfProjectNameCharacters
                      invalidInputAlertMessage:kLocalizedProjectNameAlreadyExistsDescription
                                 existingNames:[Project allProjectNames]];
}

@end
