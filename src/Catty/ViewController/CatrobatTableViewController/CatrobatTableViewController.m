/**
 *  Copyright (C) 2010-2016 The Catrobat Team
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
#import "UIColor+CatrobatUIColorExtensions.h"
#import "AppDelegate.h"
#import "Util.h"
#import "CatrobatImageCell.h"
#import "DownloadTabBarController.h"
#import "ProgramDetailStoreViewController.h"
#import "ProgramLoadingInfo.h"
#import "SegueDefines.h"
#import "SpriteObject.h"
#import "Script.h"
#import "Brick.h"
#import "ScenePresenterViewController.h"
#import "ProgramTableViewController.h"
#import "ProgramDefines.h"
#import "UIDefines.h"
#import "ActionSheetAlertViewTags.h"
#import "Reachability.h"
#import "LanguageTranslationDefines.h"
#import "HelpWebViewController.h"
#import "NetworkDefines.h"
#import "DataTransferMessage.h"
#import "MYBlurIntroductionView.h"
#import "ProgramsForUploadViewController.h"
#import "Util.h"
#import "UIImage+CatrobatUIImageExtensions.h"
#import "LoginViewController.h"
#import "SettingsTableViewController.h"

NS_ENUM(NSInteger, ViewControllerIndex) {
    kContinueProgramVC = 0,
    kNewProgramVC,
    kLocalProgramsVC,
    kHelpVC,
    kExploreVC,
    kUploadVC
};

@interface CatrobatTableViewController () <UITextFieldDelegate, MYIntroductionDelegate>

@property (nonatomic, strong) NSArray *cells;
@property (nonatomic, strong) NSArray *imageNames;
@property (nonatomic, strong) NSMutableArray *identifiers;
@property (nonatomic, strong) Program *lastUsedProgram;
@property (nonatomic, strong) Program *defaultProgram;
@property (nonatomic, strong) Reachability *reachability;
@property (nonatomic, assign) BOOL freshLogin;

@end

@implementation CatrobatTableViewController

#pragma mark - data helpers
static NSCharacterSet *blockedCharacterSet = nil;
- (NSCharacterSet*)blockedCharacterSet
{
    if (! blockedCharacterSet) {
        blockedCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:kTextFieldAllowedCharacters]
                               invertedSet];
    }
    return blockedCharacterSet;
}

#pragma mark - getters and setters
- (Program*)lastUsedProgram
{
    if (! _lastUsedProgram) {
        _lastUsedProgram = [Program lastUsedProgram];
    }
    return _lastUsedProgram;
}

#pragma mark - view events
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initTableView];

    self.freshLogin = false;
    self.lastUsedProgram = nil;
    self.defaultProgram = nil;
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if (! [appDelegate.fileManager directoryExists:[Program basePath]]) {
        [appDelegate.fileManager createDirectory:[Program basePath]];
    }
    [appDelegate.fileManager addDefaultProgramToProgramsRootDirectoryIfNoProgramsExist];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStatusChanged:) name:kReachabilityChangedNotification object:nil];

    self.reachability = [Reachability reachabilityForInternetConnection];
    [self.reachability startNotifier];
    self.tableView.delaysContentTouches = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;

    self.tableView.separatorInset = UIEdgeInsetsZero;

    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.lastUsedProgram = nil;
    self.defaultProgram = nil;
    self.navigationController.toolbarHidden = YES;
    [self.navigationController.navigationBar setHidden:NO];
     NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    BOOL lockIphoneEnabeled = [self shouldLockIphoneInAppWithoutScenePresenter];
    [[UIApplication sharedApplication] setIdleTimerDisabled:(lockIphoneEnabeled)];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ((! [defaults objectForKey:kUserIsFirstAppLaunch] || [defaults boolForKey:kUserShowIntroductionOnLaunch]) && animated == NO) {
        self.tableView.scrollEnabled = NO;
        [Util showIntroductionScreenInView:self.navigationController.view delegate:self];
    } else {
        self.tableView.scrollEnabled = YES;
        [self initNavigationBar];
    }
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
                  kLocalizedContinue,
                  kLocalizedNew,
                  kLocalizedPrograms,
                  kLocalizedHelp,
                  kLocalizedExplore,
                  kLocalizedUpload, nil];

    self.imageNames = [[NSArray alloc] initWithObjects:kMenuImageNameContinue, kMenuImageNameNew, kMenuImageNamePrograms, kMenuImageNameHelp, kMenuImageNameExplore, kMenuImageNameUpload, nil];
    self.identifiers = [[NSMutableArray alloc] initWithObjects:kSegueToContinue, kSegueToNewProgram, kSegueToPrograms, kSegueToHelp, kSegueToExplore, kSegueToUpload, nil];
}

- (void)initNavigationBar
{
    self.navigationItem.title = kLocalizedPocketCode;
    self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor navTintColor] };
    self.navigationController.navigationBar.tintColor = [UIColor navTintColor];

#if DEBUG == 1
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:kLocalizedDebugModeTitle
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(debugInfo:)];
#endif
}

#if DEBUG == 1
- (void)debugInfo:(id)sender
{
    NSString *message = [NSString stringWithFormat:@"%@\n\n-------------------\n\nBuild version:\n\n%@",
                         kLocalizedStartedInDebugMode, [Util appBuildVersion]];
    [[[UIAlertView alloc] initWithTitle:kLocalizedDebugModeTitle
                                message:message
                               delegate:nil
                      cancelButtonTitle:kLocalizedOK
                      otherButtonTitles:nil] show];
}
#endif

- (IBAction)openSettings:(id)sender {
    [self infoPressed:sender];
}
#pragma mark - actions
- (void)infoPressed:(id)sender
{
    SettingsTableViewController *sTVC = [SettingsTableViewController new];
    [self.navigationController pushViewController:sTVC animated:YES];
}

- (void)addProgramAndSegueToItActionForProgramWithName:(NSString*)programName
{
    static NSString *segueToNewProgramIdentifier = kSegueToNewProgram;
    [self showLoadingView];
    self.defaultProgram = [Program defaultProgramWithName:programName programID:nil];
    if ([self shouldPerformSegueWithIdentifier:segueToNewProgramIdentifier sender:self]) {
        [self hideLoadingView];
        [self performSegueWithIdentifier:segueToNewProgramIdentifier sender:self];
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
        case kNewProgramVC:
            [Util askUserForUniqueNameAndPerformAction:@selector(addProgramAndSegueToItActionForProgramWithName:)
                                                target:self
                                           promptTitle:kLocalizedNewProgram
                                         promptMessage:[NSString stringWithFormat:@"%@:", kLocalizedProgramName]
                                           promptValue:nil
                                     promptPlaceholder:kLocalizedEnterYourProgramNameHere
                                        minInputLength:kMinNumOfProgramNameCharacters
                                        maxInputLength:kMaxNumOfProgramNameCharacters
                                   blockedCharacterSet:[self blockedCharacterSet]
                              invalidInputAlertMessage:kLocalizedProgramNameAlreadyExistsDescription
                                         existingNames:[Program allProgramNames]];
            break;
        case kContinueProgramVC:
        case kLocalProgramsVC:
        case kExploreVC:
        case kHelpVC:
            if ([self shouldPerformSegueWithIdentifier:identifier sender:self]) {
                [self performSegueWithIdentifier:identifier sender:self];
            }
            break;
//        case kHelpVC:
//            if ([self shouldPerformSegueWithIdentifier:identifier sender:self]) {
////                HelpWebViewController *webVC = [[HelpWebViewController alloc] initWithURL:[NSURL URLWithString:kForumURL]];
////                [self.navigationController pushViewController:webVC animated:YES];
//                
//            }
//            break;
        case kUploadVC:
            //[[NSUserDefaults standardUserDefaults] setValue:false forKey:kUserIsLoggedIn];    //Just for testing purpose
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
    cell.titleLabel.text = [self.cells objectAtIndex:indexPath.row];
    cell.iconImageView.image = [UIImage imageNamed:[self.imageNames objectAtIndex:indexPath.row]];
    cell.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)configureSubtitleLabelForCell:(UITableViewCell*)cell
{
    UILabel *subtitleLabel = (UILabel*)[cell viewWithTag:kSubtitleLabelTag];
    subtitleLabel.textColor = [UIColor textTintColor];
    Program *lastProgram = self.lastUsedProgram;
    subtitleLabel.text = (lastProgram) ? lastProgram.header.programName :  @"";
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
        // check if program loaded successfully -> not nil
        if (self.lastUsedProgram) {
            return YES;
        }

        // program failed loading...
        // update continue cell
        [Util setLastProgramWithName:nil programID:nil];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [Util alertWithText:kLocalizedUnableToLoadProgram];
        return NO;
    } else if ([identifier isEqualToString:kSegueToNewProgram]) {
        // if there is no program name, abort performing this segue and ask user for program name
        // after user entered a valid program name this segue will be called again and accepted
        if (! self.defaultProgram) {
            return NO;
        }
        return YES;
    } else if([identifier isEqualToString:kSegueToExplore]||[identifier isEqualToString:kSegueToHelp]||[identifier isEqualToString:kSegueToUpload]){
        NetworkStatus remoteHostStatus = [self.reachability currentReachabilityStatus];
        
        if(remoteHostStatus == NotReachable) {
            [Util defaultAlertForNetworkError];
            NSDebug(@"not reachable");
            return NO;
        } else if (remoteHostStatus == ReachableViaWiFi) {
            if (!self.reachability.connectionRequired) {
                NSDebug(@"reachable via Wifi");
                return YES;
            }else{
                NSDebug(@"reachable via wifi but no data");
                if ([self.navigationController.topViewController isKindOfClass:[DownloadTabBarController class]] ||
                    [self.navigationController.topViewController isKindOfClass:[ProgramDetailStoreViewController class]] ||
                    [self.navigationController.topViewController isKindOfClass:[LoginViewController class]] ||
                    [self.navigationController.topViewController isKindOfClass:[ProgramsForUploadViewController class]] ) {
                    [Util defaultAlertForNetworkError];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    return NO;
                }
                return NO;
            }
            return YES;
        } else if (remoteHostStatus == ReachableViaWWAN){
            if (!self.reachability.connectionRequired) {
                NSDebug(@"reachable via celullar");
                return YES;
            }else{
                NSDebug(@" not reachable via celullar");
                [Util defaultAlertForNetworkError];
                return NO;
            }
            return YES;
        }
    }
    return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
}

#pragma mark - segue handling
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kSegueToContinue]) {
        if ([segue.destinationViewController isKindOfClass:[ProgramTableViewController class]]) {
            ProgramTableViewController *programTableViewController = (ProgramTableViewController*)segue.destinationViewController;
            programTableViewController.program = self.lastUsedProgram;
            self.lastUsedProgram = nil;
        }
    } else if ([segue.identifier isEqualToString:kSegueToNewProgram]) {
        if ([segue.destinationViewController isKindOfClass:[ProgramTableViewController class]]) {
            ProgramTableViewController *programTableViewController = (ProgramTableViewController*)segue.destinationViewController;
            programTableViewController.program = self.defaultProgram;
            self.defaultProgram = nil;
        }
    } else if ([segue.identifier isEqualToString:kSegueToUpload] && _freshLogin) {
        ProgramsForUploadViewController *destinationVC = [segue destinationViewController];
        self.freshLogin = false;
        destinationVC .showLoginFeedback = true;
    }
}

#pragma mark - network status
- (void)networkStatusChanged:(NSNotification *)notification
{
    NetworkStatus remoteHostStatus = [self.reachability currentReachabilityStatus];
    if(remoteHostStatus == NotReachable) {
        if ([self.navigationController.topViewController isKindOfClass:[DownloadTabBarController class]] ||
            [self.navigationController.topViewController isKindOfClass:[ProgramDetailStoreViewController class]] ||
            [self.navigationController.topViewController isKindOfClass:[HelpWebViewController class]] ||
            [self.navigationController.topViewController isKindOfClass:[LoginViewController class]] ||
            [self.navigationController.topViewController isKindOfClass:[ProgramsForUploadViewController class]] ) {
            [Util defaultAlertForNetworkError];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        NSDebug(@"not reachable");
    } else if (remoteHostStatus == ReachableViaWiFi) {
        if (!self.reachability.connectionRequired) {
            NSDebug(@"reachable via Wifi");
        }else{
            NSDebug(@"reachable via wifi but no data");
            if ([self.navigationController.topViewController isKindOfClass:[DownloadTabBarController class]] ||
                [self.navigationController.topViewController isKindOfClass:[ProgramDetailStoreViewController class]]||
                [self.navigationController.topViewController isKindOfClass:[HelpWebViewController class]] ||
                [self.navigationController.topViewController isKindOfClass:[LoginViewController class]] ||
                [self.navigationController.topViewController isKindOfClass:[ProgramsForUploadViewController class]] ) {
                [Util defaultAlertForNetworkError];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }
    }  else if (remoteHostStatus == ReachableViaWWAN){
        if (! self.reachability.connectionRequired) {
            NSDebug(@"celluar data ok");
        } else {
           NSDebug(@"reachable via cellular but no data");
            if ([self.navigationController.topViewController isKindOfClass:[DownloadTabBarController class]] ||
                [self.navigationController.topViewController isKindOfClass:[ProgramDetailStoreViewController class]]||
                [self.navigationController.topViewController isKindOfClass:[HelpWebViewController class]] ||
                [self.navigationController.topViewController isKindOfClass:[LoginViewController class]] ||
                [self.navigationController.topViewController isKindOfClass:[ProgramsForUploadViewController class]] ) {
                [Util defaultAlertForNetworkError];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }
    }
}

- (void)dealloc
{
    [self.identifiers removeAllObjects];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

#pragma mark - MYIntroduction Delegate
- (void)introduction:(MYBlurIntroductionView*)introductionView didChangeToPanel:(MYIntroductionPanel*)panel
           withIndex:(NSInteger)panelIndex
{
}

- (void)introduction:(MYBlurIntroductionView *)introductionView didFinishWithType:(MYFinishType)finishType
{
    NSDebug(@"Introduction did finish");
    [self initNavigationBar];
    self.tableView.scrollEnabled = YES;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:YES] forKey:kUserIsFirstAppLaunch];
    [defaults synchronize];
}

-(void)addProgramFromInboxWithName:(NSString*)newProgramName
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
    NSString* newProgramPath = [NSString stringWithFormat:@"%@/%@", inboxPath, [dirFiles firstObject]];
    
    NSData* newProgram = [NSData dataWithContentsOfFile:newProgramPath];
    
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    [appDelegate.fileManager unzipAndStore:newProgram
                             withProgramID:nil
                                  withName:newProgramName];
    
    [[NSFileManager defaultManager] removeItemAtPath:newProgramPath
                                               error:nil];
}

-(void)addProgramFromInbox
{
    NSCharacterSet* blockedCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:kTextFieldAllowedCharacters]
                                           invertedSet];
    
    [Util askUserForUniqueNameAndPerformAction:@selector(addProgramFromInboxWithName:)
                                        target:self
                                   promptTitle:kLocalizedEnterNameForImportedProgramTitle
                                 promptMessage:[NSString stringWithFormat:@"%@:", kLocalizedProgramName]
                                   promptValue:nil
                             promptPlaceholder:kLocalizedEnterYourProgramNameHere
                                minInputLength:kMinNumOfProgramNameCharacters
                                maxInputLength:kMaxNumOfProgramNameCharacters
                           blockedCharacterSet:blockedCharacterSet
                      invalidInputAlertMessage:kLocalizedProgramNameAlreadyExistsDescription
                                 existingNames:[Program allProgramNames]];
}

@end
