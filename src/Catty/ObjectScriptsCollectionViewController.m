/**
 *  Copyright (C) 2010-2013 The Catrobat Team
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

#import "ObjectScriptsCollectionViewController.h"
#import "UIDefines.h"
#import "SpriteObject.h"
#import "SegueDefines.h"
#import "ScenePresenterViewController.h"
#import "ObjectScriptCategoriesTableViewController.h"
#import "ScriptCell.h"

@interface ObjectScriptsCollectionViewController () <UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@end

@implementation ObjectScriptsCollectionViewController

#pragma marks init
- (void)initCollectionView
{
    //[super initCollectionView];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"darkblue"]];
}

#pragma view events
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initCollectionView];
    [super initPlaceHolder];
    [super setPlaceHolderTitle:kScriptsTitle
                   Description:[NSString stringWithFormat:NSLocalizedString(kEmptyViewPlaceHolder, nil),
                                kScriptsTitle]];
    [super showPlaceHolder:(!(BOOL)[self.object.lookList count])];

    self.title = self.object.name;
    self.navigationItem.title = self.object.name;
    [self setupToolBar];
    [super setPlaceHolderTitle:kScriptsTitle
                   Description:[NSString stringWithFormat:NSLocalizedString(kEmptyViewPlaceHolder, nil), kScriptsTitle]];
    [super showPlaceHolder:(! (BOOL)[self.object.scriptList count])];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSLog(@"Number of scripts: %d", [self.object.scriptList count]);
    return [self.object.scriptList count];
}

#pragma mark - collection view delegate
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ScriptCell *cell = (ScriptCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"Brick" forIndexPath:indexPath];
    // TODO: continue here
    return cell;
}


#pragma mark -CollectionViewLayout
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0.f, 0.f, 0.f, 0.f);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 5.f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.f;
}



#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    static NSString* toSceneSegueID = kSegueToScene;
    static NSString* toScriptCategoriesSegueID = kSegueToScriptCategories;
    UIViewController* destController = segue.destinationViewController;
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        if ([segue.identifier isEqualToString:toSceneSegueID]) {
            if ([destController isKindOfClass:[ScenePresenterViewController class]]) {
                ScenePresenterViewController* scvc = (ScenePresenterViewController*) destController;
                if ([scvc respondsToSelector:@selector(setProgram:)]) {
                    [scvc setController:(UITableViewController *)self];
                  [scvc performSelector:@selector(setProgram:) withObject:self.object.program];
                }
          }
        } else if ([segue.identifier isEqualToString:toScriptCategoriesSegueID]) {
            if ([destController isKindOfClass:[ObjectScriptCategoriesTableViewController class]]) {
                ObjectScriptCategoriesTableViewController* scvc = (ObjectScriptCategoriesTableViewController*) destController;
                if ([scvc respondsToSelector:@selector(setObject:)]) {
                    [scvc performSelector:@selector(setObject:) withObject:self.object];
                }
            }
        }
    }
}

#pragma mark - Helper Methods
- (void)addScriptAction:(id)sender
{
    [self performSegueWithIdentifier:kSegueToScriptCategories sender:sender];
}

- (void)playSceneAction:(id)sender
{
    [self.navigationController setToolbarHidden:YES];
    [self performSegueWithIdentifier:kSegueToScene sender:sender];
}

- (void)setupToolBar
{
    [self.navigationController setToolbarHidden:NO];
    self.navigationController.toolbar.barStyle = UIBarStyleBlack;
    self.navigationController.toolbar.tintColor = [UIColor orangeColor];
    self.navigationController.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                              target:nil
                                                                              action:nil];
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                         target:self
                                                                         action:@selector(addScriptAction:)];
    UIBarButtonItem *play = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
                                                                          target:self
                                                                          action:@selector(playSceneAction:)];
    // XXX: workaround for tap area problem:
    // http://stackoverflow.com/questions/5113258/uitoolbar-unexpectedly-registers-taps-on-uibarbuttonitem-instances-even-when-tap
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transparent1x1.png"]];
    UIBarButtonItem *invisibleButton = [[UIBarButtonItem alloc] initWithCustomView:imageView];
    self.toolbarItems = [NSArray arrayWithObjects:flexItem, invisibleButton, add, invisibleButton, flexItem,
                         flexItem, flexItem, invisibleButton, play, invisibleButton, flexItem, nil];
}

@end
