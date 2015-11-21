/**
 *  Copyright (C) 2010-2015 The Catrobat Team
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

#import "BaseCollectionViewController.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "TableUtil.h"
#import "UIDefines.h"
#import "Util.h"
#import "ActionSheetAlertViewTags.h"
#import "LanguageTranslationDefines.h"
#import <tgmath.h>
#import "CatrobatAlertView.h"
#import "LoadingView.h"
#import "BDKNotifyHUD.h"
#import "PlaceHolderView.h"
#import "ResourceHelper.h"


#import <CoreBluetooth/CoreBluetooth.h>

@class BluetoothPopupVC;

@interface BaseCollectionViewController ()
@property (nonatomic, strong) LoadingView* loadingView;
@end

@implementation BaseCollectionViewController

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self hideLoadingView];
}

- (PlaceHolderView*)placeHolderView
{
    if (!_placeHolderView) {
        _placeHolderView = [[PlaceHolderView alloc] initWithFrame:self.collectionView.bounds];
        [self.view insertSubview:_placeHolderView aboveSubview:self.collectionView];
        _placeHolderView.hidden = YES;
    }
    return _placeHolderView;
}

- (void)showPlaceHolder:(BOOL)show
{
    self.collectionView.alwaysBounceVertical = self.placeHolderView.hidden = (! show);
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
    [self.navigationController setToolbarHidden:YES animated:YES];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Setup Toolbar
- (void)setupToolBar
{
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                              target:nil
                                                                              action:nil];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transparent1x1"]];
    UIBarButtonItem *invisibleButton = [[UIBarButtonItem alloc] initWithCustomView:imageView];
    UIBarButtonItem *delete = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                            target:self
                                                                            action:@selector(deleteAlertView)];
    delete.tintColor = [UIColor redColor];
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                         target:self
                                                                         action:@selector(showBrickPickerAction:)];
    add.enabled = (! self.editing);
    UIBarButtonItem *play = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
                                                                          target:self
                                                                          action:@selector(playSceneAction:)];
    play.enabled = (! self.editing);
    if (self.editing) {
        self.toolbarItems = @[flexItem,invisibleButton, delete, invisibleButton, flexItem];
    } else {
        self.toolbarItems = @[flexItem,invisibleButton, add, invisibleButton, flexItem,
                              flexItem, flexItem, invisibleButton, play, invisibleButton, flexItem];
    }
}

- (void)showLoadingView
{
    //    self.loadingView.backgroundColor = [UIColor whiteColor];
    self.loadingView.alpha = 1.0;

    self.collectionView.scrollEnabled = NO;
    self.collectionView.userInteractionEnabled = NO;
    self.navigationController.navigationBar.userInteractionEnabled = NO;
    self.navigationController.toolbar.userInteractionEnabled = NO;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    [self showPlaceHolder:NO];
    [self.loadingView show];
}

- (void)hideLoadingView
{
    self.collectionView.scrollEnabled = YES;
    self.collectionView.userInteractionEnabled = YES;
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    self.navigationController.toolbar.userInteractionEnabled = YES;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [self.loadingView hide];
}

-(LoadingView*)loadingView
{
    if (! _loadingView) {
        _loadingView = [[LoadingView alloc] init];
        [self.view addSubview:_loadingView];
    }
    return _loadingView;
}


@end
