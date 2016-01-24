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

#import "BrickSelectionViewController.h"
#import "BrickCategoryViewController.h"
#import "ScriptCollectionViewController.h"
#import "UIColor+CatrobatUIColorExtensions.h"

@interface BrickSelectionViewController() <UIPageViewControllerDataSource, UIPageViewControllerDelegate>
@end

@implementation BrickSelectionViewController

-(id)initWithTransitionStyle:(UIPageViewControllerTransitionStyle)style navigationOrientation:(UIPageViewControllerNavigationOrientation)navigationOrientation options:(NSDictionary<NSString *,id> *)options
{
    self = [super initWithTransitionStyle:style navigationOrientation:navigationOrientation options:options];
    self.pageIndexArray = [[NSMutableArray alloc] initWithArray:@[[NSNumber numberWithInteger:kPageIndexScriptFavourites],[NSNumber numberWithInteger:kPageIndexControlBrick],[NSNumber numberWithInteger:kPageIndexMotionBrick],[NSNumber numberWithInteger:kPageIndexLookBrick],[NSNumber numberWithInteger:kPageIndexSoundBrick],[NSNumber numberWithInteger:kPageIndexVariableBrick]]];
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataSource = self;
    self.delegate = self;
    self.view.backgroundColor = [UIColor backgroundColor];
    self.navigationController.toolbarHidden = YES;
    [self setupNavBar];
    [self updateTitle];
}

#pragma mark - UIPageViewControllerDataSource
- (UIViewController*)pageViewController:(UIPageViewController*)pageViewController
     viewControllerBeforeViewController:(UIViewController*)viewController
{
    BrickCategoryViewController *bcVC = (BrickCategoryViewController *)viewController;
    NSInteger pageIndex = bcVC.pageIndex - 1;
    if (pageIndex >= 0) {
        NSNumber *index = self.pageIndexArray[pageIndex];
        return [BrickCategoryViewController brickCategoryViewControllerForPageIndex:index.unsignedIntegerValue andObject:bcVC.spriteObject andMaxPage:self.pageIndexArray.count];
    }
    return nil;
}

- (UIViewController*)pageViewController:(UIPageViewController*)pageViewController
     viewControllerAfterViewController:(UIViewController*)viewController
{
    BrickCategoryViewController *bcVC = (BrickCategoryViewController *)viewController;
    NSUInteger pageIndex = bcVC.pageIndex + 1;
    if (pageIndex < self.pageIndexArray.count) {
        NSNumber *index = self.pageIndexArray[pageIndex];
        return [BrickCategoryViewController brickCategoryViewControllerForPageIndex:index.unsignedIntegerValue andObject:bcVC.spriteObject andMaxPage:self.pageIndexArray.count];
    }
    return nil;
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
    return self.pageIndexArray.count;
}

- (void)overwritePageControl
{
    UIPageControl *pageControl = [[self.view.subviews
                                   filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"class = %@", [UIPageControl class]]] lastObject];
    pageControl.currentPageIndicatorTintColor = [UIColor backgroundColor];
    pageControl.pageIndicatorTintColor = [UIColor toolTintColor];
    pageControl.backgroundColor = [UIColor toolBarColor];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController*)pageViewController
{
    BrickCategoryViewController *bcvc = [pageViewController.viewControllers objectAtIndex:0];
    return bcvc.pageIndex;
}

#pragma mark - Setup

- (void)setupNavBar
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                           target:self
                                                                                           action:@selector(dismiss:)];
    
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor navTintColor];
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
    if (pageIndex >= 0) {
        self.title = CBTitleFromPageIndexCategoryType(pageIndex);
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
