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

#import "BaseTableViewController.h"
#import "TableUtil.h"
#import "UIDefines.h"
#import "Util.h"
#import "BDKNotifyHUD.h"
#import "PlaceHolderView.h"
#import "CBFileManager.h"
#import "Pocket_Code-Swift.h"

// identifiers
#define kTableHeaderIdentifier @"Header"

// tags
#define kSelectAllItemsTag 0
#define kUnselectAllItemsTag 1

@interface BaseTableViewController ()
@property (nonatomic, strong) LoadingView* loadingView;
@property (nonatomic, strong) UIBarButtonItem *selectAllRowsButtonItem;
@property (nonatomic, strong) UIBarButtonItem *normalModeRightBarButtonItem;
@property (nonatomic, strong) StagePresenterViewController *stagePresenterViewController;
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
    self.tableView.backgroundColor = UIColor.background;
    self.tableView.separatorColor = UIColor.utilityTint;
    self.view.backgroundColor = UIColor.background;
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(hideLoadingView)
                               name:NotificationName.hideLoadingView
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(showSavedView)
                               name:NotificationName.showSaved
                             object:nil];
  
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
    
    self.stagePresenterViewController = [StagePresenterViewController new];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    for (UIView *view in self.view.subviews) {
        if (view.tag == UIDefines.savedViewTag)
            [view removeFromSuperview];
    }
    [self hideLoadingView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationName.baseTableViewControllerDidAppear object:self];
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

#pragma mark - helpers
- (void)setupToolBar
{
    if (@available(iOS 15.0, *)) {
        UIToolbarAppearance *toolBarAppearance = [[UIToolbarAppearance alloc] init];
        toolBarAppearance.backgroundColor = UIColor.toolBar;
        self.navigationController.toolbar.standardAppearance = toolBarAppearance;
        self.navigationController.toolbar.scrollEdgeAppearance = toolBarAppearance;
    }
    [self.navigationController setToolbarHidden:NO];
    self.navigationController.toolbar.barStyle = UIBarStyleDefault;
    self.navigationController.toolbar.tintColor = UIColor.toolTint;
    self.navigationController.toolbar.barTintColor = UIColor.toolBar;
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

- (void)changeToCopyMode:(id)sender
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

- (void)playSceneAction:(id)sender
{
    ((AppDelegate*)[UIApplication sharedApplication].delegate).enabledOrientation = true;
    if (!Project.lastUsedProject.header.landscapeMode) {
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
        [UINavigationController attemptRotationToDeviceOrientation];
    } else {
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeRight) forKey:@"orientation"];
        [UINavigationController attemptRotationToDeviceOrientation];
    }
    [self.stagePresenterViewController checkResourcesAndPushViewControllerTo:self.navigationController];
}

- (void)showLoadingView
{
    self.tableView.userInteractionEnabled = NO;
    self.navigationController.navigationBar.userInteractionEnabled = NO;
    self.navigationController.toolbar.userInteractionEnabled = NO;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    [self showPlaceHolder:NO];
    [self.loadingView show];
}

- (void)hideLoadingView
{
    self.tableView.userInteractionEnabled = YES;
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    self.navigationController.toolbar.userInteractionEnabled = YES;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [self.loadingView hide];
}

- (void)showSavedView
{
    [Util showNotificationForSaveAction];
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

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
