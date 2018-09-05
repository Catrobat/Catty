/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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

#import <UIKit/UIKit.h>
#import "ScenePresenterViewController.h"
@class PlaceHolderView;

@interface BaseTableViewController : UITableViewController
@property (nonatomic, strong) NSMutableDictionary *dataCache;
@property (nonatomic, strong) NSArray *editableSections;
@property (nonatomic, strong, readonly) UIBarButtonItem *selectAllRowsButtonItem;
@property (nonatomic, strong) PlaceHolderView *placeHolderView;

- (void)showPlaceHolder:(BOOL)show;
- (BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath;
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath;
- (void)tableView:(UITableView*)tableView didDeselectRowAtIndexPath:(NSIndexPath*)indexPath;
- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath;
- (BOOL)shouldPerformSegueWithIdentifier:(NSString*)identifier sender:(id)sender;
- (void)setupToolBar;
- (void)setupEditingToolBar;
- (BOOL)areAllCellsSelectedInSection:(NSInteger)section;
- (void)changeToEditingMode:(id)sender;
- (void)changeToMoveMode:(id)sender;
- (void)exitEditingMode;
- (void)showLoadingView;
- (void)hideLoadingView;
- (void)playSceneAction:(id)sender;

@end
