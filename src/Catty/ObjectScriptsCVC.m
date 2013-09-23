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

@interface ObjectScriptsCVC () <UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@end

@implementation ObjectScriptsCVC

- (void)viewDidLoad
{
   [super viewDidLoad];
  //[self.collectionView registerClass:[PrototypScriptCell class] forCellWithReuseIdentifier:@"Brick"];
  
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


@end
