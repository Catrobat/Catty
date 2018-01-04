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

#import "NavigationController.h"
#import "PaintViewController.h"
#import "ScriptCollectionViewController.h"
#import "CatrobatTableViewController.h"

@implementation NavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    // Do any additional setup after loading the view.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)shouldAutorotate
{
    id currentViewController = self.topViewController;
    
    if ([currentViewController isKindOfClass:[PaintViewController class]])
        return NO;
    if ([currentViewController isKindOfClass:[ScenePresenterViewController class]])
        return NO;
    if ([currentViewController isKindOfClass:[CatrobatTableViewController class]]){
        CatrobatTableViewController *ctvc = (CatrobatTableViewController*)currentViewController;
        return ctvc.tableView.scrollEnabled;
    }
    
    if ([currentViewController isKindOfClass:[ScriptCollectionViewController class]]) {
        ScriptCollectionViewController *scv = (ScriptCollectionViewController*)currentViewController;
        return ![scv.presentedViewController isKindOfClass:[FormulaEditorViewController class]];
    }

    return YES;
}


@end
