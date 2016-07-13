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

#import "BaseTableViewController.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "TableUtil.h"
#import "UIDefines.h"
#import "Util.h"
#import "ActionSheetAlertViewTags.h"
#import "LanguageTranslationDefines.h"
#import <tgmath.h>
#import "CatrobatAlertController.h"
#import "LoadingView.h"
#import "BDKNotifyHUD.h"
#import "PlaceHolderView.h"
#import "Pocket_Code-Swift.h"
#import "ResourceHelper.h"
#import "Reachability.h"
#import "MediaLibraryViewController.h"
#import "SegueDefines.h"
#import <CoreBluetooth/CoreBluetooth.h>

@class BluetoothPopupVC;

// identifiers
#define kTableHeaderIdentifier @"Header"

// tags
#define kSelectAllItemsTag 0
#define kUnselectAllItemsTag 1

@interface BaseTableViewController () <CatrobatAlertViewDelegate,BluetoothSelection>
@property (nonatomic, strong) LoadingView* loadingView;
@property (nonatomic, strong) UIBarButtonItem *selectAllRowsButtonItem;
@property (nonatomic, strong) UIBarButtonItem *normalModeRightBarButtonItem;
@property (nonatomic) SEL confirmedAction;
@property (nonatomic) SEL canceledAction;
@property (nonatomic, strong) id target;
@property (nonatomic, strong) id passingObject;
@property (nonatomic, strong) Reachability *reachability;
@end

@implementation BaseTableViewController

#pragma mark - init
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataCache = nil;
    self.editing = NO;
    self.editableSections = nil;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor backgroundColor];
    self.tableView.separatorColor = [UIColor utilityTintColor];
    self.view.backgroundColor = [UIColor backgroundColor];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(hideLoadingView)
                               name:kHideLoadingViewNotification
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(showSavedView)
                               name:kShowSavedViewNotification
                             object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStatusChanged:) name:kReachabilityChangedNotification object:nil];
    
    self.reachability = [Reachability reachabilityForInternetConnection];
    [self.reachability startNotifier];
    
  
  NSLayoutConstraint *topConstraint = [NSLayoutConstraint
                                       constraintWithItem:self.placeHolderView
                                       attribute:NSLayoutAttributeTop
                                       relatedBy:NSLayoutRelationEqual
                                       toItem:self.placeHolderView.superview
                                       attribute: NSLayoutAttributeTop
                                       multiplier:1.0f constant:0];
  
  NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint
                                           constraintWithItem:self.placeHolderView
                                           attribute:NSLayoutAttributeLeading
                                           relatedBy:NSLayoutRelationEqual
                                           toItem:self.placeHolderView.superview
                                           attribute: NSLayoutAttributeLeading
                                           multiplier:1.0f constant:0];
  
  
  NSLayoutConstraint *widthConstraint = [NSLayoutConstraint
                                         constraintWithItem:self.placeHolderView
                                         attribute:NSLayoutAttributeWidth
                                         relatedBy:NSLayoutRelationEqual
                                         toItem:self.placeHolderView.superview
                                         attribute: NSLayoutAttributeWidth
                                         multiplier:1.0f constant:0];
  
  NSLayoutConstraint *heightConstraint = [NSLayoutConstraint
                                          constraintWithItem:self.placeHolderView
                                          attribute:NSLayoutAttributeHeight
                                          relatedBy:NSLayoutRelationEqual
                                          toItem:self.placeHolderView.superview
                                          attribute: NSLayoutAttributeHeight
                                          multiplier:1.0f constant:0];
    NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint
                                            constraintWithItem:self.placeHolderView.contentView
                                            attribute:NSLayoutAttributeCenterX
                                            relatedBy:NSLayoutRelationEqual
                                            toItem:self.placeHolderView.contentView.superview
                                            attribute: NSLayoutAttributeCenterX
                                            multiplier:1.0f constant:0];
    
    NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint
                                            constraintWithItem:self.placeHolderView.contentView
                                            attribute:NSLayoutAttributeCenterY
                                            relatedBy:NSLayoutRelationEqual
                                            toItem:self.placeHolderView.contentView.superview
                                            attribute: NSLayoutAttributeCenterY
                                            multiplier:1.0f constant:0];
    
  [self.placeHolderView addConstraints:@[centerXConstraint, centerYConstraint]];
  [self.view addConstraints:@[topConstraint, leadingConstraint, widthConstraint, heightConstraint]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    for (UIView *view in self.view.subviews) {
        if (view.tag == kSavedViewTag)
            [view removeFromSuperview];
    }
    [self hideLoadingView];
}

#pragma mark - system events
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    self.dataCache = nil;
}

#pragma mark - getters and setters
- (NSMutableDictionary*)dataCache
{
    if (! _dataCache) {
        _dataCache = [NSMutableDictionary dictionary];
    }
    return _dataCache;
}

- (PlaceHolderView*)placeHolderView
{
    if (! _placeHolderView) {
//        CGFloat height = __tg_ceil(CGRectGetHeight(self.view.bounds) / 4.0f);
//        _placeHolderView = [[PlaceHolderView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(UIScreen.mainScreen.bounds) / 2.0f - height, CGRectGetWidth(self.view.bounds), height)];
        _placeHolderView = [[PlaceHolderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
      

      
        [self.view insertSubview:_placeHolderView aboveSubview:self.tableView];
      


        _placeHolderView.hidden = YES;
    }
    return _placeHolderView;
}

- (UIBarButtonItem*)selectAllRowsButtonItem
{
    if (! _selectAllRowsButtonItem) {
        _selectAllRowsButtonItem = [[UIBarButtonItem alloc] initWithTitle:kLocalizedSelectAllItems
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(selectAllRows:)];
    }
    return _selectAllRowsButtonItem;
}

#pragma mark - table view delegates
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isEditing && (! self.editableSections)) {
        return YES;
    }
    for (NSNumber *section in self.editableSections) {
        if (indexPath.section == [section integerValue]) {
            return YES;
        }
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (! self.isEditing) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    // check if all rows are selected and if so, change SelectAll button to UnselectAll button
    NSArray *editableSections = self.editableSections;
    if (! self.editableSections) {
        NSInteger numberOfSections = [self numberOfSectionsInTableView:self.tableView];
        NSMutableArray *temp = [[NSMutableArray alloc] initWithCapacity:numberOfSections];
        for (NSInteger index = 0; index < numberOfSections; ++index) {
            [temp addObject:@(index)];
        }
        editableSections = [temp copy];
    }
    BOOL selectedRowWithinEditableSection = NO;
    BOOL allItemsInAllSectionsSelected = YES;
    for (NSNumber *section in editableSections) {
        if (indexPath.section == [section integerValue]) {
            selectedRowWithinEditableSection = YES;
        }
        if (! [self areAllCellsSelectedInSection:[section integerValue]]) {
            allItemsInAllSectionsSelected = NO;
        }
    }
    if (! selectedRowWithinEditableSection) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    if (allItemsInAllSectionsSelected) {
        self.selectAllRowsButtonItem.tag = kUnselectAllItemsTag;
        self.selectAllRowsButtonItem.title = kLocalizedUnselectAllItems;
    } else {
        self.selectAllRowsButtonItem.tag = kSelectAllItemsTag;
        self.selectAllRowsButtonItem.title = kLocalizedSelectAllItems;
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // check if all rows are selected and if so, change SelectAll button to UnselectAll button
    BOOL allItemsInAllSectionsSelected = YES;
    NSArray *editableSections = self.editableSections;
    if (! self.editableSections) {
        NSInteger numberOfSections = [self numberOfSectionsInTableView:self.tableView];
        NSMutableArray *temp = [[NSMutableArray alloc] initWithCapacity:numberOfSections];
        for (NSInteger index = 0; index < numberOfSections; ++index) {
            [temp addObject:@(index)];
        }
        editableSections = [temp copy];
    }
    for (NSNumber *section in editableSections) {
        if (! [self areAllCellsSelectedInSection:[section integerValue]]) {
            allItemsInAllSectionsSelected = NO;
            break;
        }
    }
    if (allItemsInAllSectionsSelected) {
        self.selectAllRowsButtonItem.tag = kUnselectAllItemsTag;
        self.selectAllRowsButtonItem.title = kLocalizedUnselectAllItems;
    } else {
        self.selectAllRowsButtonItem.tag = kSelectAllItemsTag;
        self.selectAllRowsButtonItem.title = kLocalizedSelectAllItems;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [TableUtil heightForImageCell];
}

#pragma mark - segue handlers
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if (self.isEditing) {
        return NO;
    }
    
    return YES;
}

//- (BOOL)shouldPerformSegueWithIdentifierForWebView:(NSString *)identifier sender:(id)sender
//{
//    if([identifier isEqualToString:kSegueToMediaLibrary]){
//        NetworkStatus remoteHostStatus = [self.reachability currentReachabilityStatus];
//        
//        if(remoteHostStatus == NotReachable) {
//            [Util alertWithTitle:kLocalizedNoInternetConnection andText:kLocalizedNoInternetConnectionAvailable];
//            NSDebug(@"not reachable");
//            return NO;
//        } else if (remoteHostStatus == ReachableViaWiFi) {
//            if (!self.reachability.connectionRequired) {
//                NSDebug(@"reachable via Wifi");
//                return YES;
//            }else{
//                NSDebug(@"reachable via wifi but no data");
//                if ([self.navigationController.topViewController isKindOfClass:[MediaLibraryViewController class]]) {
//                    [Util alertWithTitle:kLocalizedNoInternetConnection andText:kLocalizedNoInternetConnectionAvailable];
//                    [self.navigationController popViewControllerAnimated:YES];
//                    return NO;
//                }
//                return NO;
//            }
//            return YES;
//        } else if (remoteHostStatus == ReachableViaWWAN){
//            if (!self.reachability.connectionRequired) {
//                NSDebug(@"reachable via celullar");
//                return YES;
//            }else{
//                NSDebug(@" not reachable via celullar");
//                [Util alertWithTitle:kLocalizedNoInternetConnection andText:kLocalizedNoInternetConnectionAvailable];
//                return NO;
//            }
//            return YES;
//        }
//    }
//    return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
//}

#pragma mark - helpers
- (void)setupToolBar
{
    [self.navigationController setToolbarHidden:NO];
    self.navigationController.toolbar.barStyle = UIBarStyleDefault;
    self.navigationController.toolbar.tintColor = [UIColor toolTintColor];
    self.navigationController.toolbar.barTintColor = [UIColor toolBarColor];
    self.navigationController.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
}

- (void)setupEditingToolBar
{
    [self setupToolBar];
    // force to reinstantiate new UIBarButtonItem
    self.selectAllRowsButtonItem = nil;
}

- (BOOL)areAllCellsSelectedInSection:(NSInteger)section
{
    NSInteger totalNumberOfRows = [self.tableView numberOfRowsInSection:section];
    if (! totalNumberOfRows) {
        return NO;
    }

    NSArray *indexPaths = [self.tableView indexPathsForSelectedRows];
    NSInteger counter = 0;
    for (NSIndexPath *indexPath in indexPaths) {
        if (indexPath.section == section) {
            ++counter;
        }
    }
    return (totalNumberOfRows == counter);
}

- (void)changeToEditingMode:(id)sender
{
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:kLocalizedCancel
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(exitEditingMode)];
    self.navigationItem.hidesBackButton = YES;
    self.normalModeRightBarButtonItem = self.navigationItem.rightBarButtonItem;
    self.navigationItem.rightBarButtonItem = cancelButton;
    [self.tableView reloadData];
    [self.tableView setEditing:YES animated:YES];
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.editing = YES;
}

- (void)changeToMoveMode:(id)sender
{
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:kLocalizedDone
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(exitEditingMode)];
    self.navigationItem.hidesBackButton = YES;
    self.normalModeRightBarButtonItem = self.navigationItem.rightBarButtonItem;
    self.navigationItem.rightBarButtonItem = cancelButton;
    [self.tableView reloadData];
    [self.tableView setEditing:YES animated:YES];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    self.navigationController.toolbar.userInteractionEnabled = NO;
    self.editing = YES;
}

- (void)exitEditingMode
{
    self.navigationItem.hidesBackButton = NO;
    self.navigationItem.rightBarButtonItem = self.normalModeRightBarButtonItem;
    self.navigationController.toolbar.userInteractionEnabled = YES;
    [self.tableView setEditing:NO animated:YES];
    [self setupToolBar];
    self.editing = NO;
}

- (void)selectAllRows:(id)sender
{
    BOOL selectAll = NO;
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *button = (UIBarButtonItem*)sender;
        if (button.tag == kSelectAllItemsTag) {
            button.tag = kUnselectAllItemsTag;
            selectAll = YES;
            button.title = kLocalizedUnselectAllItems;
        } else {
            button.tag = kSelectAllItemsTag;
            selectAll = NO;
            button.title = kLocalizedSelectAllItems;
        }
    }
    NSArray *editableSections = self.editableSections;
    if (! self.editableSections) {
        NSInteger numberOfSections = [self numberOfSectionsInTableView:self.tableView];
        NSMutableArray *temp = [[NSMutableArray alloc] initWithCapacity:numberOfSections];
        for (NSInteger index = 0; index < numberOfSections; ++index) {
            [temp addObject:@(index)];
        }
        editableSections = [temp copy];
    }
    for (NSNumber *section in editableSections) {
        for (NSInteger index = 0; index < [self.tableView numberOfRowsInSection:[section integerValue]]; ++index) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:[section integerValue]];
            if (selectAll) {
                [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            } else {
                [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
            }
        }
    }
}

- (void)performActionOnConfirmation:(SEL)confirmedAction
                     canceledAction:(SEL)canceledAction
                         withObject:(id)object
                             target:(id)target
                       confirmTitle:(NSString*)confirmTitle
                     confirmMessage:(NSString*)confirmMessage
{
    [Util confirmAlertWithTitle:confirmTitle
                        message:confirmMessage
                       delegate:self
                            tag:kConfirmAlertViewTag];
    self.confirmedAction = confirmedAction;
    self.canceledAction = canceledAction;
    self.target = target;
    self.passingObject = object;
}

- (void)performActionOnConfirmation:(SEL)confirmedAction
                     canceledAction:(SEL)canceledAction
                             target:(id)target
                       confirmTitle:(NSString*)confirmTitle
                     confirmMessage:(NSString*)confirmMessage
{
    [self performActionOnConfirmation:confirmedAction
                       canceledAction:canceledAction
                           withObject:nil
                               target:target
                         confirmTitle:confirmTitle
                       confirmMessage:confirmMessage];
}

- (void)playSceneAction:(id)sender
{
    [self showLoadingView];
    [self playSceneAction:sender animated:YES];
}

- (void)playSceneAction:(id)sender animated:(BOOL)animated;
{
    if ([self respondsToSelector:@selector(stopAllSounds)]) {
        [self performSelector:@selector(stopAllSounds)];
    }
    
    self.scenePresenterViewController = [ScenePresenterViewController new];
    self.scenePresenterViewController.program = [Program programWithLoadingInfo:[Util lastUsedProgramLoadingInfo]];
    NSInteger resources = [self.scenePresenterViewController.program getRequiredResources];
    if ([ResourceHelper checkResources:resources delegate:self]) {
        [self startSceneWithVC:self.scenePresenterViewController];
    } else {
        [self hideLoadingView];
    }
}

-(void)startSceneWithVC:(ScenePresenterViewController*)vc
{
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    [self.navigationController setToolbarHidden:YES animated:YES];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - alert view delegate handlers
- (void)alertView:(CatrobatAlertController*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kConfirmAlertViewTag) {
        // check if user agreed
        if (buttonIndex != 0) {
            // XXX: hack to avoid compiler warning
            // http://stackoverflow.com/questions/7017281/performselector-may-cause-a-leak-because-its-selector-is-unknown
            SEL selector = self.confirmedAction;
            if (selector) {
                IMP imp = [self.target methodForSelector:selector];
                if (! self.passingObject) {
                    void (*func)(id, SEL) = (void *)imp;
                    func(self.target, selector);
                } else {
                    void (*func)(id, SEL, id) = (void *)imp;
                    func(self.target, selector, self.passingObject);
                }
            }
        } else {
            SEL selector = self.canceledAction;
            if (selector) {
                IMP imp = [self.target methodForSelector:selector];
                void (*func)(id, SEL) = (void *)imp;
                func(self.target, selector);
            }
        }
    }
    if (alertView.tag == kResourcesAlertView) {
        // check if user agreed
        if (buttonIndex != 0) {
            [self startSceneWithVC:self.scenePresenterViewController];
        } else {
            
        }
    }
}

- (void)showLoadingView
{
//    self.loadingView.backgroundColor = [UIColor whiteColor];
    self.loadingView.alpha = 1.0;
    CGPoint top = CGPointMake(0, -self.navigationController.navigationBar.frame.size.height);
    [self.tableView setContentOffset:top animated:NO];
    self.tableView.scrollEnabled = NO;
    self.tableView.userInteractionEnabled = NO;
    self.navigationController.navigationBar.userInteractionEnabled = NO;
    self.navigationController.toolbar.userInteractionEnabled = NO;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    [self showPlaceHolder:NO];
    [self.loadingView show];
}

- (void)hideLoadingView
{
    self.tableView.scrollEnabled = YES;
    self.tableView.userInteractionEnabled = YES;
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    self.navigationController.toolbar.userInteractionEnabled = YES;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [self.loadingView hide];
}

- (void)showSavedView
{
    BDKNotifyHUD *hud = [BDKNotifyHUD notifyHUDWithImage:[UIImage imageNamed:kBDKNotifyHUDCheckmarkImageName]
                                                    text:kLocalizedSaved];
    hud.destinationOpacity = kBDKNotifyHUDDestinationOpacity;
    hud.center = CGPointMake(self.view.center.x, self.view.center.y + kBDKNotifyHUDCenterOffsetY);
    hud.tag = kSavedViewTag;
    [self.view addSubview:hud];
    [hud presentWithDuration:kBDKNotifyHUDPresentationDuration
                       speed:kBDKNotifyHUDPresentationSpeed
                       inView:self.view
                       completion:^{ [hud removeFromSuperview]; }];
}

- (void)showPlaceHolder:(BOOL)show
{
    self.tableView.alwaysBounceVertical = self.placeHolderView.hidden = (! show);
}

-(LoadingView*)loadingView
{
    if (! _loadingView) {
        _loadingView = [[LoadingView alloc] init];
        [self.view addSubview:_loadingView];
    }
    return _loadingView;
}

#pragma mark - network status
- (void)networkStatusChanged:(NSNotification *)notification
{
    NetworkStatus remoteHostStatus = [self.reachability currentReachabilityStatus];
    if(remoteHostStatus == NotReachable) {
        if ([self.navigationController.topViewController isKindOfClass:[MediaLibraryViewController class]] ) {
            [Util defaultAlertForNetworkError];
            [self.navigationController popViewControllerAnimated:YES];
        }
        NSDebug(@"not reachable");
    } else if (remoteHostStatus == ReachableViaWiFi) {
        if (!self.reachability.connectionRequired) {
            NSDebug(@"reachable via Wifi");
        }else{
            NSDebug(@"reachable via wifi but no data");
            if ([self.navigationController.topViewController isKindOfClass:[MediaLibraryViewController class]] ) {
                [Util defaultAlertForNetworkError];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }  else if (remoteHostStatus == ReachableViaWWAN){
        if (! self.reachability.connectionRequired) {
            NSDebug(@"celluar data ok");
        } else {
            NSDebug(@"reachable via cellular but no data");
            if ([self.navigationController.topViewController isKindOfClass:[MediaLibraryViewController class]] ) {
                [Util defaultAlertForNetworkError];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }
}

//#pragma mark - segue handling
//- (BOOL)shouldPerformSegueWithIdentifier:(NSString*)identifier sender:(id)sender
//{
//    if([identifier isEqualToString:kSegueToExplore]){
//        NetworkStatus remoteHostStatus = [self.reachability currentReachabilityStatus];
//        
//        if(remoteHostStatus == NotReachable) {
//            [Util alertWithTitle:kLocalizedNoInternetConnection andText:kLocalizedNoInternetConnectionAvailable];
//            NSDebug(@"not reachable");
//            return NO;
//        } else if (remoteHostStatus == ReachableViaWiFi) {
//            if (!self.reachability.connectionRequired) {
//                NSDebug(@"reachable via Wifi");
//                return YES;
//            }else{
//                NSDebug(@"reachable via wifi but no data");
//                if ([self.navigationController.topViewController isKindOfClass:[MediaLibraryViewController class]]) {
//                    [Util alertWithTitle:kLocalizedNoInternetConnection andText:kLocalizedNoInternetConnectionAvailable];
//                    [self.navigationController popToRootViewControllerAnimated:YES];
//                    return NO;
//                }
//                return NO;
//            }
//            return YES;
//        } else if (remoteHostStatus == ReachableViaWWAN){
//            if (!self.reachability.connectionRequired) {
//                NSDebug(@"reachable via celullar");
//                return YES;
//            }else{
//                NSDebug(@" not reachable via celullar");
//                [Util alertWithTitle:kLocalizedNoInternetConnection andText:kLocalizedNoInternetConnectionAvailable];
//                return NO;
//            }
//            return YES;
//        }
//    }
//    return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
//}



@end
