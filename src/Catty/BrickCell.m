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
            return [kControlBrickNames count];
        case kMotionBrick:
            return [kMotionBrickNames count];
        case kSoundBrick:
            return [kSoundBrickNames count];
        case kLookBrick:
            return [kLookBrickNames count];
        case kVariableBrick:
            return [kVariableBrickNames count];
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
    NSString *brickPatternImageName = nil;
    if (categoryType == kControlBrick) {
        // TODO cast and check if valid brickType to NS_ENUM...
        brickTitle = kControlBrickNames[brickType];
        brickPatternImageName = kControlBrickImageNames[brickType];
        if ((brickType == kProgramStartedBrick) || (brickType == kTappedBrick)) {
            brickShapeType = kBrickShapeRoundedSmall;
        } else if (brickType == kReceiveBrick) {
            brickShapeType = kBrickShapeRoundedBig;
        }
    } else if (categoryType == kMotionBrick) {
      // TODO cast and check if valid brickType to NS_ENUM...
        brickTitle = kMotionBrickNames[brickType];
        brickPatternImageName = kMotionBrickImageNames[brickType];
    } else if (categoryType == kSoundBrick) {
      // TODO cast and check if valid brickType to NS_ENUM...
        brickTitle = kSoundBrickNames[brickType];
        brickPatternImageName = kSoundBrickImageNames[brickType];
    } else if (categoryType == kLookBrick) {
        brickTitle = kLookBrickNames[brickType];
        brickPatternImageName = kLookBrickImageNames[brickType];
    } else if (categoryType == kVariableBrick) {
        brickTitle = kVariableBrickNames[brickType];
        brickPatternImageName = kVariableBrickImageNames[brickType];
    }

    // background pattern image
    // TODO: Performance!!! Don't load same images (shared between different bricks) again and again
    static NSString *backgroundImageNameSuffix = kBrickBackgroundImageNameSuffix;
    UIImage *brickBackgroundPatternImage = [UIImage imageNamed:[brickPatternImageName stringByAppendingString:backgroundImageNameSuffix]];
    CGFloat backgroundViewOffsetX = 54.0f;
    if (brickShapeType == kBrickShapeRoundedSmall) {
        backgroundViewOffsetX = 206.0f;
    } else if (brickShapeType == kBrickShapeRoundedBig) {
        backgroundViewOffsetX = 205.0f;
    }
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(backgroundViewOffsetX, 0.0f, (self.frame.size.width - kBrickInlineViewOffsetX), brickBackgroundPatternImage.size.height)];
    UIGraphicsBeginImageContext(backgroundView.frame.size);
    [brickBackgroundPatternImage drawInRect:backgroundView.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    backgroundView.backgroundColor = [UIColor colorWithPatternImage:image];
    [self addSubview:backgroundView];
    [self sendSubviewToBack:backgroundView];

    // brick pattern image
    // TODO: Performance!!! Don't load same images (shared between different bricks) again and again
    UIImage *brickPatternImage = [UIImage imageNamed:brickPatternImageName];

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
        case kBrickShapeRoundedSmall:
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
    UIImageView *imageView = [[UIImageView alloc] initWithImage:brickPatternImage];
    CGRect imageViewFrame = imageView.frame;
    imageViewFrame.origin.x = kBrickPatternImageViewOffsetX;
    imageViewFrame.origin.y = kBrickPatternImageViewOffsetY;
    imageView.frame = imageViewFrame;
    imageView.backgroundColor = [UIColor clearColor];
    [self addSubview:imageView];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, inlineViewWidth, inlineViewHeight)];
//    [label adjustsFontSizeToFitWidth];
    label.textColor = [UIColor whiteColor];
    label.text = brickTitle;
    label.font = [UIFont boldSystemFontOfSize:16];
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
