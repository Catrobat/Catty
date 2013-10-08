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

#import "ObjectScriptsCVC.h"
#import "PrototypScriptCell.h"
#import "SpriteObject.h"
#import "SegueDefines.h"
#import "SceneViewController.h"

@interface ObjectScriptsCVC () <UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@end

@implementation ObjectScriptsCVC

- (void)viewDidLoad
{
  [super viewDidLoad];
  //[self.collectionView registerClass:[PrototypScriptCell class] forCellWithReuseIdentifier:@"Brick"];
  [self setupToolBar];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
  return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
  //return [self.scripts count];
  return 3;
}

#pragma mark - collection view delegate
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  PrototypScriptCell *cell = (PrototypScriptCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"Brick" forIndexPath:indexPath];
  
  cell.leftLabel.text = @"x:";
  cell.rightLabel.text = @"y:";
  cell.backgroundColor = [UIColor blueColor];
  
  return cell;
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  static NSString* toSceneSegueID = kSegueToScene;
  UIViewController* destController = segue.destinationViewController;
  if ([sender isKindOfClass:[UIBarButtonItem class]]) {
    if ([segue.identifier isEqualToString:toSceneSegueID]) {
      if ([destController isKindOfClass:[SceneViewController class]]) {
        SceneViewController* scvc = (SceneViewController*) destController;
        if ([scvc respondsToSelector:@selector(setProgram:)]) {
          [scvc performSelector:@selector(setProgram:) withObject:self.object.program];
        }
      }
    }
  }
}

#pragma mark - Helper Methods
- (void)addScriptAction:(id)sender
{
}

- (void)playSceneAction:(id)sender
{
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
  self.toolbarItems = [NSArray arrayWithObjects:add, flexItem, play, nil];
}

@end
