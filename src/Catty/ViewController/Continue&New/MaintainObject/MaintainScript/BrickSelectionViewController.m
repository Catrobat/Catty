/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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
#import "KeychainUserDefaultsDefines.h"
#import "Pocket_Code-Swift.h"

@interface BrickSelectionViewController() <UIPageViewControllerDataSource, UIPageViewControllerDelegate>
@property (nonatomic, strong) UIPageControl *pageControl;
@end

@implementation BrickSelectionViewController

-(id)initWithTransitionStyle:(UIPageViewControllerTransitionStyle)style navigationOrientation:(UIPageViewControllerNavigationOrientation)navigationOrientation options:(NSDictionary<NSString *,id> *)options
{
    self = [super initWithTransitionStyle:style navigationOrientation:navigationOrientation options:options];

    self.categories = [[NSMutableArray alloc] initWithArray:[[CatrobatSetup class] registeredBrickCategories]];
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataSource = self;
    self.delegate = self;
    self.view.backgroundColor = UIColor.background;
    self.navigationController.toolbarHidden = YES;
    [self setupNavBar];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

#pragma mark - UIPageViewControllerDataSource
- (UIViewController*)pageViewController:(UIPageViewController*)pageViewController
     viewControllerBeforeViewController:(UIViewController*)viewController
{
    BrickCategoryViewController *bcVC = (BrickCategoryViewController *)viewController;
    if (bcVC.category == nil) {
        return [[BrickCategoryViewController alloc] initWithBrickCategory:[self.categories firstObject] andObject:bcVC.spriteObject];
    }
    
    for (BrickCategory *category in self.categories) {
        NSUInteger previousPageIndex = [self.categories indexOfObject:category] - 1;
        
        if (category.type == bcVC.category.type && previousPageIndex >= 0 && previousPageIndex < [self.categories count]) {
            BrickCategory *previousCategory = [self.categories objectAtIndex:previousPageIndex];
            return [[BrickCategoryViewController alloc] initWithBrickCategory:previousCategory andObject:bcVC.spriteObject];
        }
    }
    return nil;
}

- (UIViewController*)pageViewController:(UIPageViewController*)pageViewController
     viewControllerAfterViewController:(UIViewController*)viewController
{
    BrickCategoryViewController *bcVC = (BrickCategoryViewController *)viewController;
    if (bcVC.category == nil) {
        return [[BrickCategoryViewController alloc] initWithBrickCategory:[self.categories firstObject] andObject:bcVC.spriteObject];
    }
    
    for (BrickCategory *category in self.categories) {
        NSUInteger nextPageIndex = [self.categories indexOfObject:category] + 1;
        
        if (category.type == bcVC.category.type && nextPageIndex < [self.categories count]) {
            BrickCategory *nextCategory = [self.categories objectAtIndex:nextPageIndex];
            return [[BrickCategoryViewController alloc] initWithBrickCategory:nextCategory andObject:bcVC.spriteObject];
        }
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
    return self.categories.count;
}

- (void)overwritePageControl
{
    self.pageControl = [[self.view.subviews
                                   filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"class = %@", [UIPageControl class]]] lastObject];
    self.pageControl.currentPageIndicatorTintColor = UIColor.background;
    self.pageControl.pageIndicatorTintColor = UIColor.toolTint;
    self.pageControl.backgroundColor = UIColor.toolBar;

}

#pragma mark - Setup

- (void)setupNavBar
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                           target:self
                                                                                           action:@selector(dismiss:)];
    
    self.navigationItem.leftBarButtonItem.tintColor = UIColor.navTint;
    
    [self updateTitle];
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
    self.title = bcvc.category.name;
}

#pragma mark Button Actions

- (void)dismiss:(id)sender
{
    if ([sender isKindOfClass:UIBarButtonItem.class]) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
    }
}

@end
