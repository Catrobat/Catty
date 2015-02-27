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

#import "BrickSelectionViewController.h"
#import "BrickCategoryViewController.h"
#import "ScriptCollectionViewController.h"
#import "UIColor+CatrobatUIColorExtensions.h"

@interface BrickSelectionViewController() <UIPageViewControllerDataSource, UIPageViewControllerDelegate>
@end

@implementation BrickSelectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataSource = self;
    self.delegate = self;
    self.view.backgroundColor = [UIColor darkBlueColor];
    self.navigationController.toolbarHidden = YES;
    [self setupNavBar];
    [self updateTitle];
}

#pragma mark - UIPageViewControllerDataSource
- (UIViewController*)pageViewController:(UIPageViewController*)pageViewController
     viewControllerBeforeViewController:(UIViewController*)viewController
{
    BrickCategoryViewController *bcVC = (BrickCategoryViewController*)viewController;
    NSUInteger pageIndex = bcVC.pageIndex - 1;
    return [BrickCategoryViewController brickCategoryViewControllerForPageIndex:pageIndex];
}

- (UIViewController*)pageViewController:(UIPageViewController*)pageViewController
     viewControllerAfterViewController:(UIViewController*)viewController
{
    BrickCategoryViewController *bcVC = (BrickCategoryViewController*)viewController;
    NSUInteger pageIndex = bcVC.pageIndex + 1;
    return [BrickCategoryViewController brickCategoryViewControllerForPageIndex:pageIndex];
}

- (void)pageViewController:(UIPageViewController*)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray*)previousViewControllers
       transitionCompleted:(BOOL)completed
{
    if (completed) {
        [self updateTitle];
        [self updateBrickCategoryViewControllerDelegate];
    }
}

#pragma mark - Pageindicator
- (NSInteger)presentationCountForPageViewController:(UIPageViewController*)pageViewController
{
    [self overwritePageControl];
    return kCategoryCount;
}

- (void)overwritePageControl
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"class = %@", [UIPageControl class]];
    UIPageControl *pageControl = [[self.view.subviews filteredArrayUsingPredicate:predicate] lastObject];
    pageControl.currentPageIndicatorTintColor = [UIColor lightOrangeColor];
    pageControl.backgroundColor = [UIColor colorWithWhite:1.f alpha:0.1f];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController*)pageViewController
{
    BrickCategoryViewController *bcvc = [pageViewController.viewControllers objectAtIndex:0];
    return bcvc.pageIndex;
}

#pragma mark - Setup
- (void)setupNavBar
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                          target:self
                                                                                          action:@selector(dismiss:)];
}

- (void)updateBrickCategoryViewControllerDelegate
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(class = %@)",[ScriptCollectionViewController class]];
    ScriptCollectionViewController *scvc = [self.presentingViewController.childViewControllers filteredArrayUsingPredicate:predicate].lastObject;
    NSAssert(scvc != nil, @"Error, no valid presenting VC found.");
    BrickCategoryViewController *bcvc = [self.viewControllers objectAtIndex:0];
    bcvc.delegate = scvc;
}

- (void)updateTitle
{
    BrickCategoryViewController *bcvc = [self.viewControllers objectAtIndex:0];
    NSInteger pageIndex = bcvc.pageIndex;
    if (pageIndex >= 0 && pageIndex < kCategoryCount) {
        self.title = kBrickCategoryNames[pageIndex];
    }
}

#pragma mark Button Actions

- (void)dismiss:(id)sender
{
    if ([sender isKindOfClass:UIBarButtonItem.class]) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
    }
}

@end
