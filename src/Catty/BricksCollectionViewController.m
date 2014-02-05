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

#import "BricksCollectionViewController.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "SegueDefines.h"

#define kTableHeaderIdentifier @"Header"
#define kCategoryCell @"BrickCell"

@interface BrickCollectionViewController ()
@property (nonatomic, strong) NSArray *categoryColors;
@property (nonatomic, strong) NSArray *currentCategoryBricks;
@end

@implementation BrickCollectionViewController

#pragma marks - getters and setters
- (NSArray*)currentCategoryBricks
{
    if (! _currentCategoryBricks) {
        if (self.categoryType == kControlBrick) {
            _currentCategoryBricks = kControlBrickTypeNames;
        } else if (self.categoryType == kMotionBrick) {
            _currentCategoryBricks = kMotionBrickTypeNames;
        } else if (self.categoryType == kSoundBrick) {
            _currentCategoryBricks = kSoundBrickTypeNames;
        } else if (self.categoryType == kLookBrick) {
            _currentCategoryBricks = kLookBrickTypeNames;
        } else if (self.categoryType == kVariableBrick) {
            _currentCategoryBricks = kVariableBrickTypeNames;
        } else {
            _currentCategoryBricks = nil;
        }
    }
    return _currentCategoryBricks;
}

- (NSArray*)categoryColors
{
    if (! _categoryColors) {
        _categoryColors = kBrickTypeColors;
    }
    return _categoryColors;
}

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

    NSString *title = NSLocalizedString(@"Categories", nil);
    self.title = title;
    self.navigationItem.title = title;
    self.collectionView.alwaysBounceVertical = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.currentCategoryBricks count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = kCategoryCell;
  UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
  //  if ([cell isKindOfClass:[UI class]]) {
  //    ColoredCell *coloredCell = (ColoredCell*)cell;
  //    coloredCell.textLabel.text = self.cells[[@(indexPath.row) stringValue]];
  //  }
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.0, 150.0, 43.0)];
  [label sizeToFit];
  label.text = self.currentCategoryBricks[indexPath.row];
  [cell addSubview:label];
  //    [cell addSubview:[self createBrickCell:indexPath.row]];
  return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = self.categoryColors[self.categoryType];
}

// TODO: Move this code to UserInterface section
- (UIView*)createBrickCell:(NSInteger)brickType
{
    CGRect frame;
//    frame.origin.x;
//    frame.origin.y;
//    frame.size.width;
//    frame.size.height;
//    BrickCell
    if (self.categoryType == kControlBrick) {
        switch (brickType) {
            case kProgramStartedBrick:
            case kTappedBrick:
            case kWaitBrick:
            case kReceiveBrick:
            case kBroadcastBrick:
            case kBroadcastWaitBrick:
            case kNoteBrick:
            case kForeverBrick:
            case kIfBrick:
            case kRepeatBrick:
            default:
                break;
        }
    } else if (self.categoryType == kMotionBrick) {
        switch (brickType) {
            case kPlaceAtBrick:
            case kSetXBrick:
            case kSetYBrick:
            case kChangeXByNBrick:
            case kChangeYByNBrick:
            case kIfOnEdgeBounceBrick:
            case kMoveNStepsBrick:
            case kTurnLeftBrick:
            case kTurnRightBrick:
            case kPointInDirectionBrick:
            case kPointToBrick:
            case kGlideToBrick:
            case kGoNStepsBackBrick:
            case kComeToFrontBrick:
            default:
                break;
        }
    } else if (self.categoryType == kSoundBrick) {
        switch (brickType) {
            case kPlaySoundBrick:
            case kStopAllSoundsBrick:
            case kSetVolumeToBrick:
            case kChangeVolumeByBrick:
            case kSpeakBrick:
            default:
                break;
        }
    } else if (self.categoryType == kLookBrick) {
        switch (brickType) {
            case kSetBackgroundBrick:
            case kNextBackgroundBrick:
            case kSetSizeToBrick:
            case kChangeSizeByNBrick:
            case kHideBrick:
            case kShowBrick:
            case kSetGhostEffectBrick:
            case kChangeGhostEffectByNBrick:
            case kSetBrightnessBrick:
            case kChangeBrightnessByNBrick:
            case kClearGraphicEffectBrick:
            default:
                break;
        }
    } else if (self.categoryType == kVariableBrick) {
        switch (brickType) {
            case kSetVariableBrick:
            case kChangeVariableBrick:
            default:
                break;
        }
    }
//    UICollectionViewCell *cell = [[UICollectionViewCell alloc] init];
    UILabel *label = [[UILabel alloc] init];
    label.text = self.currentCategoryBricks[brickType];
    label.textColor = [UIColor blackColor];
    label.backgroundColor = [UIColor whiteColor];
    [label adjustsFontSizeToFitWidth];
    frame.origin.x = 0.0f;
    frame.origin.y = 0.0f;
    frame.size.width = self.collectionView.frame.size.width;
    frame.size.height = 40.0f;
    UIView *view = [[UIView alloc] initWithFrame:frame];
    [view addSubview:label];
//    cell.backgroundColor = self.categoryColors[self.categoryType];
//    [cell addSubview:view];
//    return cell;
    return view;
}

@end
