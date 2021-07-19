/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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
#import "CBFileManager.h"
#import "Util.h"
#import "CatrobatImageCell.h"
#import "DownloadTabBarController.h"
#import "ProjectDetailStoreViewController.h"
#import "SegueDefines.h"
#import "Script.h"
#import "SceneTableViewController.h"
#import "LoginViewController.h"
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
@property (nonatomic, strong) Project *lastUsedProject;
@property (nonatomic, strong) Project *defaultProject;
@property (nonatomic, strong) ProjectManager *projectManager;
@property (nonatomic, assign) BOOL freshLogin;
@property (nonatomic, assign) CGFloat dynamicStatusBarHeight;
@property (nonatomic, assign) CGFloat fixedStatusBarHeight;
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

- (ProjectManager*)projectManager
{
    if (! _projectManager) {
        _projectManager = [ProjectManager shared];
    }
    return _projectManager;
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

    [self presentPrivacyPolicyIfNeeded];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[UploadViewController class]]) {
        ((UploadViewController*) segue.destinationViewController).delegate = self;
    }
}

#pragma mark init
- (void)initTableView
{
    self.fixedStatusBarHeight = [Util statusBarHeight];
    self.dynamicStatusBarHeight = self.fixedStatusBarHeight;
    
    self.cells = [[NSArray alloc] initWithObjects:
                  kLocalizedContinueProject,
                  kLocalizedNewProject,
                  kLocalizedProjectsOnDevice,
                  kLocalizedHelp,
                  kLocalizedCatrobatCommunity,
                  kLocalizedUploadProject, nil];

    self.imageNames = [[NSArray alloc] initWithObjects:UIDefines.menuImageNameContinue, UIDefines.menuImageNameNew, UIDefines.menuImageNameProjects, UIDefines.menuImageNameHelp, UIDefines.menuImageNameExplore, UIDefines.menuImageNameUpload, nil];
}

- (void)initNavigationBar
{
    self.navigationItem.title = kLocalizedPocketCode;
    self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName : UIColor.navTint };
}

- (IBAction)openSettings:(id)sender
{
    [self infoPressed:sender];
}

#pragma mark - privacy policy
- (void)presentPrivacyPolicyIfNeeded
{
    #if DEBUG
    if ([[[NSProcessInfo processInfo] arguments] containsObject:LaunchArguments.skipPrivacyPolicy]) {
        return;
    }
    #endif

    if (!PrivacyPolicyViewController.hasBeenShown || PrivacyPolicyViewController.showOnEveryLaunch) {
        UIViewController *viewController = [PrivacyPolicyViewController new];
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

- (void)createAndOpenProjectWithName:(NSString*)projectName
{
    [self showLoadingView];
    self.defaultProject = [self.projectManager createProjectWithName:projectName projectId:nil];
    if (self.defaultProject) {
        [self hideLoadingView];
        [self openProject:self.defaultProject];
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
        [self configureTitleLabelForCell:(UITableViewCell <CatrobatImageCell>*) cell];
    } else {
        
        DarkBlueGradientImageCell *imageCell = (DarkBlueGradientImageCell*) cell;
        if (([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft) || ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight)) {
            
            imageCell.imageViewBottomConstraint.constant = 0;
            imageCell.imageViewTopConstraint.constant = 0;
            
        } else {
            
            imageCell.imageViewBottomConstraint.constant = -10;
            imageCell.imageViewTopConstraint.constant = 10;
            
        }
        
    }
    
    if (indexPath.row == [self.tableView numberOfRowsInSection:indexPath.section] - 1) {
        cell.separatorInset = UIEdgeInsetsMake(0.f, MAX([Util screenHeight],[Util screenWidth]), 0.f, 0.f);
    }
    
    cell.layoutMargins = UIEdgeInsetsZero;
    cell.preservesSuperviewLayoutMargins = NO;
    
    return cell;
}

#pragma mark - table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSString *segueIdentifier = nil;
    
    switch (indexPath.row) {
        case kNewProjectVC:
            [Util askUserForUniqueNameAndPerformAction:@selector(createAndOpenProjectWithName:)
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
            if (!self.lastUsedProject) {
                [Util setLastProjectWithName:nil projectID:nil];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                [Util alertWithText:kLocalizedUnableToLoadProject];
                
                return;
            }
            
            [self openProject:self.lastUsedProject];
            break;
        case kLocalProjectsVC:
            segueIdentifier = kSegueToProjects;
            break;
        case kExploreVC:
            segueIdentifier = kSegueToExplore;
            break;
        case kHelpVC:
            segueIdentifier = kSegueToHelp;
            break;
        case kUploadVC:
            if ([[[NSUserDefaults standardUserDefaults] valueForKey:NetworkDefines.kUserIsLoggedIn] boolValue]) {
                segueIdentifier = kSegueToUpload;
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
    
    if (segueIdentifier && [self shouldPerformSegueWithIdentifier:segueIdentifier sender:self]) {
        [self performSegueWithIdentifier:segueIdentifier sender:self];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)afterSuccessfulLogin
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([[[NSUserDefaults standardUserDefaults] valueForKey: NetworkDefines.kUserIsLoggedIn] boolValue]) {
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
    if (indexPath.row == 0) {
        UILabel *subtitleLabel = (UILabel*)[cell viewWithTag:kSubtitleLabelTag];
        subtitleLabel.textColor = UIColor.textTint;
        subtitleLabel.text = [self.cells objectAtIndex:indexPath.row];
        
        cell.iconImageView.image = [UIImage imageWithColor:UIColor.whiteColor];
        [cell setNeedsLayout];
    } else {
        cell.titleLabel.text = [self.cells objectAtIndex:indexPath.row];
    }
    
    ProjectLoadingInfo *info = [ProjectLoadingInfo projectLoadingInfoForProjectWithName:self.lastUsedProject.header.programName projectID:self.lastUsedProject.header.programID];

    if (indexPath.row == 0) {
        
        [self.projectManager loadPreviewImageAndCacheWithProjectLoadingInfo:info completion:^(UIImage * image, NSString * path) {
            
            if(image && cell) {
                dispatch_queue_main_t queue = dispatch_get_main_queue();
                dispatch_async(queue, ^{
                    cell.iconImageView.image = image;
                    cell.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
                    [self.tableView endUpdates];
                });
            }
            
        }];
        
    } else {
        cell.iconImageView.image = [UIImage imageNamed:[self.imageNames objectAtIndex:indexPath.row]];
        cell.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
}

- (void)configureTitleLabelForCell:(UITableViewCell <CatrobatImageCell>*)cell
{
    Project *lastProject = self.lastUsedProject;
    cell.titleLabel.text = (lastProject) ? lastProject.header.programName :  @"";
}

- (CGFloat)getHeightForCellAtIndexPath:(NSIndexPath*)indexPath
{
    CGFloat height;
    CGFloat navBarHeight = self.navigationController.navigationBar.frame.size.height;
    if (indexPath.row == 0) {
        height= [TableUtil heightForContinueCell:navBarHeight withStatusBarHeight:self.dynamicStatusBarHeight];
    } else {
        height = [TableUtil heightForCatrobatTableViewImageCell:navBarHeight withStatusBarHeight:self.dynamicStatusBarHeight];
    }
    return height; // for scrolling reasons
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    CGFloat height = size.height;
    CGFloat width = size.width;
    
    if(self.fixedStatusBarHeight == 0) {
        [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {}
                                     completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            self.fixedStatusBarHeight = [Util statusBarHeight];
            self.dynamicStatusBarHeight = self.fixedStatusBarHeight;
            [self.tableView reloadData];
        }];
    }
    
    if (height >= width) {
        self.dynamicStatusBarHeight = self.fixedStatusBarHeight;
    } else {
        self.dynamicStatusBarHeight = 0;
    }
    [self.tableView reloadData];
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

@end
