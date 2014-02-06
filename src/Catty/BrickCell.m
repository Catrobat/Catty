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

#import "BrickCell.h"
#import "UIDefines.h"
#import "UIColor+CatrobatUIColorExtensions.h"

@interface BrickCell ()
@property (nonatomic, strong) NSArray *categoryColors;
@end

@implementation BrickCell

#pragma marks - getters and setters
- (NSArray*)categoryColors
{
  if (! _categoryColors) {
    _categoryColors = kBrickTypeColors;
  }
  return _categoryColors;
}

#pragma marks creation methods
+ (NSInteger)numberOfAvailableBricksForCategoryType:(kBrickCategoryType)categoryType
{
    switch (categoryType) {
        case kControlBrick:
            return [kControlBrickTypeNames count];
        case kMotionBrick:
            return [kMotionBrickTypeNames count];
        case kSoundBrick:
            return [kSoundBrickTypeNames count];
        case kLookBrick:
            return [kLookBrickTypeNames count];
        case kVariableBrick:
            return [kVariableBrickTypeNames count];
        default:
          break;
    }
    return 0;
}

+ (CGFloat) getBrickCellHeightForCategoryType:(kBrickCategoryType)categoryType AndBrickType:(NSInteger)brickType
{
  // TODO: outsource all these numbers to define-consts...
  CGFloat height = 44.0f;
  if (categoryType == kControlBrick) {
    switch (brickType) {
      case kProgramStartedBrick:
      case kTappedBrick:
        height = 62.0f;
        break;
      case kReceiveBrick:
        height = 88.0f;
        break;
      case kBroadcastBrick:
      case kBroadcastWaitBrick:
      case kNoteBrick:
        height = 71.0f;
        break;
      default:
        height = 44.0f;
        break;
    }
  } else if (categoryType == kMotionBrick) {
    switch (brickType) {
      case kPlaceAtBrick:
      case kPointToBrick:
          height = 71.0f;
          break;
      case kGlideToBrick:
          height = 94.0f;
          break;
      default:
        height = 44.0f;
        break;
    }
  } else if (categoryType == kSoundBrick) {
    switch (brickType) {
      case kPlaySoundBrick:
      case kSpeakBrick:
        height = 71.0f;
        break;
      default:
        height = 44.0f;
        break;
    }
  } else if (categoryType == kLookBrick) {
    switch (brickType) {
      case kSetBackgroundBrick:
      case kSetGhostEffectBrick:
      case kChangeGhostEffectByNBrick:
      case kSetBrightnessBrick:
      case kChangeBrightnessByNBrick:
        height = 71.0f;
        break;
      default:
        height = 44.0f;
        break;
    }
  } else if (categoryType == kVariableBrick) {
    switch (brickType) {
      case kSetVariableBrick:
      case kChangeVariableBrick:
        height = 94.0f;
        break;
      default:
        height = 44.0f;
        break;
    }
  }
  return height;
}

- (void)convertToBrickCellForCategoryType:(kBrickCategoryType)categoryType AndBrickType:(NSInteger)brickType
{
    // Note: for performance reasons we use reusable cells, so we have to remove all subviews first
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    NSString *brickTitle = nil;
    kBrickShapeType brickShapeType = kBrickShapeNormal;
    UIImage *brickPatternImage = nil;
    if (categoryType == kControlBrick) {
        brickTitle = kControlBrickTypeNames[brickType];
        switch (brickType) {
            case kProgramStartedBrick:
            case kTappedBrick:
                // TODO: Performance!!! Don't load same images (shared between different bricks) again and again
                brickPatternImage = [UIImage imageNamed:@"brick_control_1h"];
                brickShapeType = kBrickShapeRoundedThin;
                break;
            case kReceiveBrick:
                brickPatternImage = [UIImage imageNamed:@"brick_control_2h"];
                brickShapeType = kBrickShapeRoundedBig;
                break;
            case kWaitBrick:
            case kForeverBrick:
            case kIfBrick:
            case kRepeatBrick:
                brickPatternImage = [UIImage imageNamed:@"brick_orange_1h"];
                break;
            case kBroadcastBrick:
            case kBroadcastWaitBrick:
            case kNoteBrick:
                brickPatternImage = [UIImage imageNamed:@"brick_orange_2h"];
                break;
            default:
                return;
        }
    } else if (categoryType == kMotionBrick) {
        brickTitle = kMotionBrickTypeNames[brickType];
        switch (brickType) {
            case kPlaceAtBrick:
            case kPointToBrick:
                brickPatternImage = [UIImage imageNamed:@"brick_blue_2h"];
                break;
            case kGlideToBrick:
                brickPatternImage = [UIImage imageNamed:@"brick_blue_3h"];
                break;
            case kSetXBrick:
            case kSetYBrick:
            case kChangeXByNBrick:
            case kChangeYByNBrick:
            case kIfOnEdgeBounceBrick:
            case kMoveNStepsBrick:
            case kTurnLeftBrick:
            case kTurnRightBrick:
            case kPointInDirectionBrick:
            case kGoNStepsBackBrick:
            case kComeToFrontBrick:
                brickPatternImage = [UIImage imageNamed:@"brick_blue_1h"];
                break;
            default:
                return;
        }
    } else if (categoryType == kSoundBrick) {
        brickTitle = kSoundBrickTypeNames[brickType];
        switch (brickType) {
            case kStopAllSoundsBrick:
            case kSetVolumeToBrick:
            case kChangeVolumeByBrick:
                brickPatternImage = [UIImage imageNamed:@"brick_violet_1h"];
                break;
            case kPlaySoundBrick:
            case kSpeakBrick:
                brickPatternImage = [UIImage imageNamed:@"brick_violet_2h"];
                break;
            default:
                return;
        }
    } else if (categoryType == kLookBrick) {
        brickTitle = kLookBrickTypeNames[brickType];
        switch (brickType) {
            case kNextBackgroundBrick:
            case kSetSizeToBrick:
            case kChangeSizeByNBrick:
            case kHideBrick:
            case kShowBrick:
            case kClearGraphicEffectBrick:
                brickPatternImage = [UIImage imageNamed:@"brick_green_1h"];
                break;
            case kSetBackgroundBrick:
            case kSetGhostEffectBrick:
            case kChangeGhostEffectByNBrick:
            case kSetBrightnessBrick:
            case kChangeBrightnessByNBrick:
                brickPatternImage = [UIImage imageNamed:@"brick_green_2h"];
                break;
            default:
                return;
        }
    } else if (categoryType == kVariableBrick) {
        brickTitle = kVariableBrickTypeNames[brickType];
        switch (brickType) {
            case kSetVariableBrick:
            case kChangeVariableBrick:
                brickPatternImage = [UIImage imageNamed:@"brick_red_3h"];
                break;
            default:
                return;
        }
    }

    // resize frame height
    CGRect frame = self.frame;
    frame.size.height = brickPatternImage.size.height;
    self.frame = frame;
    self.backgroundColor = [UIColor clearColor];

    // determine inlineView height via brickPatternImageHeight
    CGFloat inlineViewWidth = self.frame.size.width - kBrickInlineViewOffsetX;
    CGFloat inlineViewHeight = brickPatternImage.size.height;
    CGFloat inlineViewOffsetY = 0.0f;
    switch (brickShapeType) {
        case kBrickShapeNormal:
            inlineViewHeight -= kBrickShapeNormalMarginHeight;
            inlineViewOffsetY = kBrickShapeNormalInlineViewOffsetY;
            break;
        case kBrickShapeRoundedThin:
            inlineViewHeight -= kBrickShapeRoundedThinMarginHeight;
            inlineViewOffsetY = kBrickShapeRoundedThinInlineViewOffsetY;
            break;
        case kBrickShapeRoundedBig:
            inlineViewHeight -= kBrickShapeRoundedBigMarginHeight;
            inlineViewOffsetY = kBrickShapeRoundedBigInlineViewOffsetY;
            break;
        default:
            break;
    }
    UIView *inlineView = [[UIView alloc] initWithFrame:CGRectMake(kBrickInlineViewOffsetX, inlineViewOffsetY, inlineViewWidth, inlineViewHeight)];
    inlineView.backgroundColor = self.categoryColors[categoryType];

    UIImageView *imageView = [[UIImageView alloc] initWithImage:brickPatternImage];
    CGRect imageViewFrame = imageView.frame;
    imageViewFrame.origin.x = kBrickPatternImageViewOffsetX;
    imageViewFrame.origin.y = kBrickPatternImageViewOffsetY;
    imageView.frame = imageViewFrame;
    imageView.backgroundColor = [UIColor clearColor];
    [self addSubview:imageView];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, inlineViewWidth, inlineViewHeight)];
//    [label adjustsFontSizeToFitWidth];
    label.textColor = [UIColor blackColor];
    label.text = brickTitle;
    [inlineView addSubview:label];

// just to test layout
//    self.layer.borderWidth=1.0f;
//    self.layer.borderColor=[UIColor whiteColor].CGColor;
    [self addSubview:inlineView];
}

#pragma marks init
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      self.contentMode = UIViewContentModeScaleToFill;
      self.clipsToBounds = YES;
    }
    return self;
}

@end
