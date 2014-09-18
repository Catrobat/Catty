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
#import "Parser.h"
#import "SpriteObject.h"
#import "Script.h"
#import "Brick.h"
#import "Util.h"
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
#import "InfoPopupViewController.h"
#import "MYBlurIntroductionView.h"

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
@property (nonatomic, strong) NSArray *identifiers;
@property (nonatomic, strong) Program *lastProgram;
@property (nonatomic, strong) Program *defaultProgram;
@property (nonatomic, strong) Reachability *reachability;

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
- (Program*)lastProgram
{
    if (! _lastProgram) {
        _lastProgram = [Program lastProgram];
    }
    return _lastProgram;
}

#pragma mark - view events
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initTableView];

    self.lastProgram = nil;
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
    self.tableView.separatorColor = UIColor.skyBlueColor;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (! [defaults objectForKey:kUserIsFirstAppLaunch] || [defaults boolForKey:kUserShowIntroductionOnLaunch]) {
        self.tableView.scrollEnabled = NO;
        [Util showIntroductionScreenInView:self.navigationController.view delegate:self];
    } else {
        self.tableView.scrollEnabled = YES;
        [self initNavigationBar];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.lastProgram = nil;
    self.defaultProgram = nil;
    [self.navigationController setToolbarHidden:YES];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (! [defaults objectForKey:kUserIsFirstAppLaunch] || [defaults boolForKey:kUserShowIntroductionOnLaunch]) {
        [self.navigationController setNavigationBarHidden:YES];
    } else {
        [self.navigationController setNavigationBarHidden:NO];
    }
     NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    BOOL lockIphoneEnabeled = [self shouldLockIphoneInAppWithoutScenePresenter];
    [[UIApplication sharedApplication] setIdleTimerDisabled:(lockIphoneEnabeled)];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
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
    self.identifiers = [[NSArray alloc] initWithObjects:kSegueToContinue, kSegueToNewProgram, kSegueToPrograms, kSegueToHelp, kSegueToExplore, kSegueToUpload, nil];
}

- (void)initNavigationBar
{
    self.navigationItem.title = kLocalizedPocketCode;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [button addTarget:self action:@selector(infoPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *infoItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = infoItem;
}

#pragma mark - actions
- (void)infoPressed:(id)sender
{
    if (self.popupViewController == nil) {
        InfoPopupViewController *popupViewController = [[InfoPopupViewController alloc] init];
        popupViewController.delegate = self;
        self.tableView.scrollEnabled = NO;
        [self presentPopupViewController:popupViewController WithFrame:self.tableView.frame];
    } else {
        [self dismissPopup];
    }

}

- (void)addProgramAndSegueToItActionForProgramWithName:(NSString*)programName
{
    static NSString *segueToNewProgramIdentifier = kSegueToNewProgram;
    [self showLoadingView];
    self.defaultProgram = [Program defaultProgramWithName:programName];
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
    
    return cell;
}

#pragma mark - table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    if ([self dismissPopup]) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        return;
    }
    
    NSString* identifier = [self.identifiers objectAtIndex:indexPath.row];
    switch (indexPath.row) {
        case kNewProgramVC:
#if kIsRelease // kIsRelease
            [Util showComingSoonAlertView];
#else // kIsRelease
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
#endif // kIsRelease
            break;
        case kContinueProgramVC:
        case kLocalProgramsVC:
        case kExploreVC:
            if ([self shouldPerformSegueWithIdentifier:identifier sender:self]) {
                [self performSegueWithIdentifier:identifier sender:self];
            }
            break;
        case kHelpVC:
            if ([self shouldPerformSegueWithIdentifier:identifier sender:self]) {
                HelpWebViewController *webVC = [[HelpWebViewController alloc] initWithURL:[NSURL URLWithString:kForumURL]];
                [self.navigationController pushViewController:webVC animated:YES];
            }
            break;
        case kUploadVC:
            [Util showComingSoonAlertView];
            break;
            
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
}

- (void)configureSubtitleLabelForCell:(UITableViewCell*)cell
{
    UILabel* subtitleLabel = (UILabel*)[cell viewWithTag:kSubtitleLabelTag];
    subtitleLabel.textColor = [UIColor brightGrayColor];
    NSString* lastProject = [Util lastProgram];
    subtitleLabel.text = lastProject;
}

- (CGFloat)getHeightForCellAtIndexPath:(NSIndexPath*)indexPath
{
    CGFloat height;
    if (indexPath.row == 0) {
        height= [TableUtil getHeightForContinueCell];
        if ([Util getScreenHeight] == kIphone4ScreenHeight) {
            height = height*kIphone4ScreenHeight/kIphone5ScreenHeight;
        }
    }
    else {
        height = [TableUtil getHeightForImageCell];
        if ([Util getScreenHeight] == kIphone4ScreenHeight) {
            height = height*kIphone4ScreenHeight/kIphone5ScreenHeight;
        }
    }
    if ([Util getScreenHeight] == kIphone5ScreenHeight){
    }
    return height; // for scrolling reasons
}

#pragma mark - segue handling
- (BOOL)shouldPerformSegueWithIdentifier:(NSString*)identifier sender:(id)sender
{
    if ([self dismissPopup]) {
        return NO;
    }
    if ([identifier isEqualToString:kSegueToContinue]) {
        // check if program loaded successfully -> not nil
        if (self.lastProgram) {
            return YES;
        }
        
        // program failed loading...
        // update continue cell
        [Util setLastProgram:nil];
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
    } else if([identifier isEqualToString:kSegueToExplore]||[identifier isEqualToString:kSegueToHelp]){
        NetworkStatus remoteHostStatus = [self.reachability currentReachabilityStatus];
        
        if(remoteHostStatus == NotReachable) {
            [Util alertWithText:kLocalizedNoInternetConnectionAvailable];
            NSDebug(@"not reachable");
            return NO;
        } else if (remoteHostStatus == ReachableViaWiFi) {
            if (!self.reachability.connectionRequired) {
                NSDebug(@"reachable via Wifi");
                return YES;
            }else{
                NSDebug(@"reachable via wifi but no data");
                if ([self.navigationController.topViewController isKindOfClass:[DownloadTabBarController class]] ||
                    [self.navigationController.topViewController isKindOfClass:[ProgramDetailStoreViewController class]]) {
                    [Util alertWithText:kLocalizedNoInternetConnectionAvailable];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    return NO;
                }
            }
            return YES;
        } else if (remoteHostStatus == ReachableViaWWAN){
            if (!self.reachability.connectionRequired) {
                NSDebug(@"reachable via celullar");
                return YES;
            }else{
                NSDebug(@" not reachable via celullar");
                [Util alertWithText:kLocalizedNoInternetConnectionAvailable];
                return NO;
            }
            return YES;
        }
    }
    return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kSegueToContinue]) {
        if ([segue.destinationViewController isKindOfClass:[ProgramTableViewController class]]) {
            ProgramTableViewController *programTableViewController = (ProgramTableViewController*)segue.destinationViewController;
            programTableViewController.program = self.lastProgram;
            self.lastProgram = nil;
        }
    } else if ([segue.identifier isEqualToString:kSegueToNewProgram]) {
        if ([segue.destinationViewController isKindOfClass:[ProgramTableViewController class]]) {
            ProgramTableViewController *programTableViewController = (ProgramTableViewController*)segue.destinationViewController;
            programTableViewController.program = self.defaultProgram;
            self.defaultProgram = nil;
        }
    }
}

- (void)networkStatusChanged:(NSNotification *)notification
{
    NetworkStatus remoteHostStatus = [self.reachability currentReachabilityStatus];
    if(remoteHostStatus == NotReachable) {
        if ([self.navigationController.topViewController isKindOfClass:[DownloadTabBarController class]] ||
            [self.navigationController.topViewController isKindOfClass:[ProgramDetailStoreViewController class]] ||
            [self.navigationController.topViewController isKindOfClass:[HelpWebViewController class]] ) {
            [Util alertWithText:kLocalizedNoInternetConnectionAvailable];
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
                [self.navigationController.topViewController isKindOfClass:[HelpWebViewController class]]) {
                [Util alertWithText:kLocalizedNoInternetConnectionAvailable];
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
                [self.navigationController.topViewController isKindOfClass:[HelpWebViewController class]]) {
                [Util alertWithText:kLocalizedNoInternetConnectionAvailable];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}


#pragma mark - MYIntroduction Delegate

-(void)introduction:(MYBlurIntroductionView *)introductionView didChangeToPanel:(MYIntroductionPanel *)panel withIndex:(NSInteger)panelIndex{

}

-(void)introduction:(MYBlurIntroductionView *)introductionView didFinishWithType:(MYFinishType)finishType {
    NSLog(@"Introduction did finish");
    [self initNavigationBar];
    self.tableView.scrollEnabled = YES;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:YES] forKey:kUserIsFirstAppLaunch];
    [defaults synchronize];
}

#pragma mark - popup delegate
- (BOOL)dismissPopup
{
    if (self.popupViewController != nil) {
        self.tableView.scrollEnabled = YES;
        [self dismissPopupViewController];
        return YES;
    }
    return NO;
}

@end
