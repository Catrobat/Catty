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

- (void)convertToBrickCellForCategoryType:(kBrickCategoryType)categoryType AndBrickType:(NSInteger)brickType
{
    NSString *brickTitle = nil;
    if (categoryType == kControlBrick) {
        brickTitle = kControlBrickTypeNames[brickType];
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
    } else if (categoryType == kMotionBrick) {
        brickTitle = kMotionBrickTypeNames[brickType];
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
    } else if (categoryType == kSoundBrick) {
        brickTitle = kSoundBrickTypeNames[brickType];
        switch (brickType) {
            case kPlaySoundBrick:
            case kStopAllSoundsBrick:
            case kSetVolumeToBrick:
            case kChangeVolumeByBrick:
            case kSpeakBrick:
            default:
                break;
        }
    } else if (categoryType == kLookBrick) {
        brickTitle = kLookBrickTypeNames[brickType];
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
    } else if (categoryType == kVariableBrick) {
        brickTitle = kVariableBrickTypeNames[brickType];
        switch (brickType) {
            case kSetVariableBrick:
            case kChangeVariableBrick:
            default:
                break;
        }
    }
    UILabel *label = [[UILabel alloc] init];
    label.text = brickTitle;
    label.textColor = [UIColor blackColor];
    label.backgroundColor = [UIColor whiteColor];
    [label adjustsFontSizeToFitWidth];
  //  CGRect frame = self.frame;
  //  frame.size.height = 40.0f;
  //  self.frame = frame;
    [self addSubview:label];
    self.backgroundColor = self.categoryColors[categoryType];
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

#pragma mark layout
- (void)setupBrickView:(NSDictionary *)labels
{
   NSAssert(NO, @"Must be overridden");
}

- (void)layoutSubviews
{
  [super layoutSubviews];

  if (self.backgroundImage) {
    self.backgroundImage.frame = self.frame;
    [self.contentView addSubview:self.backgroundImage];
    [self.contentView sendSubviewToBack:self.backgroundImage];
  }
}

#pragma mark Background Image

- (UIImageView *)backgroundImage
{
  if (!_backgroundImage) {
    _backgroundImage = [UIImageView new];
    return _backgroundImage;
  }
  return nil;
}

- (void)setBackgroundImage:(UIImageView *)backgroundImage withTintColor:(UIColor *)tintColor
{
  UIImage *stencilImage = [UIImage imageNamed:@"background_image__brick"];
  stencilImage = [stencilImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  self.backgroundImage.image = stencilImage;
  self.backgroundImage.tintColor = tintColor;
}

@end
