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
@property (nonatomic, strong) UIPageControl *pageControl;
@end

@implementation BrickSelectionViewController

-(id)initWithTransitionStyle:(UIPageViewControllerTransitionStyle)style navigationOrientation:(UIPageViewControllerNavigationOrientation)navigationOrientation options:(NSDictionary<NSString *,id> *)options
{
    self = [super initWithTransitionStyle:style navigationOrientation:navigationOrientation options:options];

    self.pageIndexArray = [[NSMutableArray alloc] initWithArray:@[[NSNumber numberWithInteger:kPageIndexControlBrick],[NSNumber numberWithInteger:kPageIndexMotionBrick],[NSNumber numberWithInteger:kPageIndexSoundBrick],[NSNumber numberWithInteger:kPageIndexLookBrick],[NSNumber numberWithInteger:kPageIndexVariableBrick]]];
    NSDictionary * favouritesDict = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsBrickSelectionStatisticsMap];
    if (favouritesDict.count) {
        [self.pageIndexArray insertObject:[NSNumber numberWithInteger:kPageIndexScriptFavourites] atIndex:0];
    }
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

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateNumberOfPageIndicator];
}

#pragma mark - UIPageViewControllerDataSource
- (UIViewController*)pageViewController:(UIPageViewController*)pageViewController
     viewControllerBeforeViewController:(UIViewController*)viewController
{
    BrickCategoryViewController *bcVC = (BrickCategoryViewController *)viewController;
    NSDictionary * favouritesDict = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsBrickSelectionStatisticsMap];
    NSInteger pageIndex = bcVC.pageIndex - 1;
    if (!favouritesDict.count) {
        pageIndex -= 1;
    }
    if (pageIndex == 0) {
        pageIndex = 0;
    }
    NSNumber* number = self.pageIndexArray[0];
    if (pageIndex >= number.integerValue || (!favouritesDict.count && pageIndex == 0)) {
        NSNumber *index = self.pageIndexArray[pageIndex];
        return [BrickCategoryViewController brickCategoryViewControllerForPageIndex:index.unsignedIntegerValue object:bcVC.spriteObject maxPage:self.pageIndexArray.count andPageIndexArray:self.pageIndexArray];
    }
    return nil;
}

- (UIViewController*)pageViewController:(UIPageViewController*)pageViewController
     viewControllerAfterViewController:(UIViewController*)viewController
{
    BrickCategoryViewController *bcVC = (BrickCategoryViewController *)viewController;
    NSDictionary * favouritesDict = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsBrickSelectionStatisticsMap];
    NSUInteger pageIndex = bcVC.pageIndex;
    if (favouritesDict.count) {
       pageIndex += 1;
    }
    if (pageIndex < self.pageIndexArray.count) {
        NSNumber *index = self.pageIndexArray[pageIndex];
        return [BrickCategoryViewController brickCategoryViewControllerForPageIndex:index.unsignedIntegerValue object:bcVC.spriteObject maxPage:self.pageIndexArray.count andPageIndexArray:self.pageIndexArray];
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
    [self updateNumberOfPageIndicator];
}



#pragma mark - Pageindicator
- (NSInteger)presentationCountForPageViewController:(UIPageViewController*)pageViewController
{
    [self overwritePageControl];
    NSDictionary * favouritesDict = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsBrickSelectionStatisticsMap];
    if (!favouritesDict.count) {
        return self.pageIndexArray.count+1;
    }
    return self.pageIndexArray.count;
}

- (void)overwritePageControl
{
    self.pageControl = [[self.view.subviews
                                   filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"class = %@", [UIPageControl class]]] lastObject];
    self.pageControl.currentPageIndicatorTintColor = [UIColor backgroundColor];
    self.pageControl.pageIndicatorTintColor = [UIColor toolTintColor];
    self.pageControl.backgroundColor = [UIColor toolBarColor];

}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController*)pageViewController
{
    BrickCategoryViewController *bcvc = [pageViewController.viewControllers objectAtIndex:0];
    return bcvc.pageIndex;
}

- (void)updateNumberOfPageIndicator
{
    NSNumber* number = self.pageIndexArray[0];
    if (number.integerValue == 1) {
        UIView * view = self.pageControl.subviews[0];
        view.hidden = YES;
    }
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
    NSNumber* number = self.pageIndexArray[0];
    if (pageIndex >= number.integerValue) {
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
