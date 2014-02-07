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
@property (nonatomic, strong) UIView *backgroundImageView;
@property (nonatomic, strong) UIView *inlineView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *textLabel;
@end

@implementation BrickCell

#pragma mark - getters and setters (lazy instantiation)
- (NSArray*)categoryColors
{
    if (! _categoryColors) {
        _categoryColors = kBrickTypeColors;
    }
    return _categoryColors;
}

- (UIView*)inlineView
{
    if (! _inlineView) {
        _inlineView = [[UIView alloc] init];
        [self addSubview:_inlineView];
    }
    return _inlineView;
}

- (UIView*)backgroundImageView
{
    if (! _backgroundImageView) {
        _backgroundImageView = [[UIView alloc] init];
        [self addSubview:_backgroundImageView];
        [self sendSubviewToBack:_backgroundImageView];
    }
    return _backgroundImageView;
}

- (UIImageView*)imageView
{
    if (! _imageView) {
        _imageView = [[UIImageView alloc] init];
        self.imageView.backgroundColor = [UIColor clearColor];
        [self addSubview:_imageView];
        [self sendSubviewToBack:_imageView];
    }
    return _imageView;
}

- (UILabel*)textLabel
{
    if (! _textLabel) {
        _textLabel = [[UILabel alloc] init];
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.font = [UIFont boldSystemFontOfSize:16];
        [self.inlineView addSubview:_textLabel];
    }
    return _textLabel;
}

#pragma mark creation methods
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

+ (CGFloat) brickCellHeightForCategoryType:(kBrickCategoryType)categoryType AndBrickType:(NSInteger)brickType
{
    // FIXME: outsource all these numbers to define-consts...
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

+ (kBrickShapeType)shapeTypeForCategoryType:(kBrickCategoryType)categoryType AndBrickType:(NSInteger)brickType
{
    if (categoryType == kControlBrick) {
        if ((brickType == kProgramStartedBrick) || (brickType == kTappedBrick)) {
            return kBrickShapeRoundedSmall;
        } else if (brickType == kReceiveBrick) {
            return kBrickShapeRoundedBig;
        }
    }
    return kBrickShapeNormal;
}

+ (NSString*)brickPatternImageNameForCategoryType:(kBrickCategoryType)categoryType AndBrickType:(NSInteger)brickType
{
    if (categoryType == kControlBrick) {
        if (brickType >= [kControlBrickNames count])
            return nil; // invalid

        return kControlBrickImageNames[brickType];
    } else if (categoryType == kMotionBrick) {
        if (brickType >= [kMotionBrickNames count])
            return nil; // invalid

        return kMotionBrickImageNames[brickType];
    } else if (categoryType == kSoundBrick) {
        if (brickType >= [kSoundBrickNames count])
            return nil; // invalid

        return kSoundBrickImageNames[brickType];
    } else if (categoryType == kLookBrick) {
        if (brickType >= [kLookBrickNames count])
            return nil; // invalid

        return kLookBrickImageNames[brickType];
    } else if (categoryType == kVariableBrick) {
        if (brickType >= [kVariableBrickNames count])
            return nil; // invalid

        return kVariableBrickImageNames[brickType];
    }
    return nil; // invalid
}

- (void)setViewForCategoryType:(kBrickCategoryType)categoryType AndBrickType:(NSInteger)brickType
{
    CGRect frame = self.frame;
    frame.size.height = [BrickCell brickCellHeightForCategoryType:categoryType AndBrickType:brickType];
    self.frame = frame;
}

- (void)setInlineViewForCategoryType:(kBrickCategoryType)categoryType AndBrickType:(NSInteger)brickType
{
    CGFloat inlineViewWidth = self.frame.size.width - kBrickInlineViewOffsetX;
    CGFloat inlineViewHeight = [BrickCell brickCellHeightForCategoryType:categoryType AndBrickType:brickType];
    kBrickShapeType brickShapeType = [BrickCell shapeTypeForCategoryType:categoryType AndBrickType:brickType];
    CGFloat inlineViewOffsetY = 0.0f;
    if (brickShapeType == kBrickShapeNormal) {
        inlineViewHeight -= kBrickShapeNormalMarginHeightDeduction;
        inlineViewOffsetY = kBrickShapeNormalInlineViewOffsetY;
    } else if (brickShapeType == kBrickShapeRoundedSmall) {
        inlineViewHeight -= kBrickShapeRoundedSmallMarginHeightDeduction;
        inlineViewOffsetY = kBrickShapeRoundedSmallInlineViewOffsetY;
    } else if (brickShapeType == kBrickShapeRoundedBig) {
        inlineViewHeight -= kBrickShapeRoundedBigMarginHeightDeduction;
        inlineViewOffsetY = kBrickShapeRoundedBigInlineViewOffsetY;
    } else {
        NSError(@"unknown brick shape type given");
    }
    self.inlineView.frame = CGRectMake(kBrickInlineViewOffsetX, inlineViewOffsetY, inlineViewWidth, inlineViewHeight);
}

- (void)setBrickPatternImageForCategoryType:(kBrickCategoryType)categoryType AndBrickType:(NSInteger)brickType
{
    // TODO: Performance!!! Don't load same images (shared between different bricks) again and again
    UIImage *brickPatternImage = [UIImage imageNamed:[BrickCell brickPatternImageNameForCategoryType:categoryType AndBrickType:brickType]];
    self.imageView.frame = CGRectMake(kBrickPatternImageViewOffsetX, kBrickPatternImageViewOffsetY, brickPatternImage.size.width, brickPatternImage.size.height);
    self.imageView.image = brickPatternImage;
}

- (void)setBrickPatternBackgroundImageForCategoryType:(kBrickCategoryType)categoryType AndBrickType:(NSInteger)brickType
{
    NSString *imageName = [BrickCell brickPatternImageNameForCategoryType:categoryType AndBrickType:brickType];
    UIImage *brickBackgroundPatternImage = [UIImage imageNamed:[imageName stringByAppendingString:kBrickBackgroundImageNameSuffix]];
    CGRect frame = CGRectMake(kBrickPatternBackgroundImageViewOffsetX, kBrickPatternBackgroundImageViewOffsetY, (self.frame.size.width-kBrickInlineViewOffsetX), brickBackgroundPatternImage.size.height);
    self.backgroundImageView.frame = frame;
    UIGraphicsBeginImageContext(self.backgroundImageView.frame.size);
    [brickBackgroundPatternImage drawInRect:self.backgroundImageView.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.backgroundImageView.backgroundColor = [UIColor colorWithPatternImage:image];
}

- (void)setBrickLabelForCategoryType:(kBrickCategoryType)categoryType AndBrickType:(NSInteger)brickType
{
    NSString *brickTitle = nil;
    if (categoryType == kControlBrick) {
        if (brickType >= [kControlBrickNames count])
            return; // invalid

        brickTitle = kControlBrickNames[brickType];
    } else if (categoryType == kMotionBrick) {
        if (brickType >= [kMotionBrickNames count])
            return; // invalid

        brickTitle = kMotionBrickNames[brickType];
    } else if (categoryType == kSoundBrick) {
        if (brickType >= [kSoundBrickNames count])
            return; // invalid

        brickTitle = kSoundBrickNames[brickType];
    } else if (categoryType == kLookBrick) {
        if (brickType >= [kLookBrickNames count])
            return; // invalid

        brickTitle = kLookBrickNames[brickType];
    } else if (categoryType == kVariableBrick) {
        if (brickType >= [kVariableBrickNames count])
            return; // invalid

        brickTitle = kVariableBrickNames[brickType];
    } else {
        return; // invalid
    }
    self.textLabel.frame = CGRectMake(kBrickLabelOffsetX, kBrickLabelOffsetY, self.inlineView.frame.size.width, self.inlineView.frame.size.height);
    self.textLabel.text = brickTitle;
//    [self.textLabel adjustsFontSizeToFitWidth];
}

//    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
//    self.inlineView = nil;
- (void)convertToBrickCellForCategoryType:(kBrickCategoryType)categoryType AndBrickType:(NSInteger)brickType
{
    [self setViewForCategoryType:categoryType AndBrickType:brickType];
    [self setBrickPatternImageForCategoryType:categoryType AndBrickType:brickType];
    [self setBrickPatternBackgroundImageForCategoryType:categoryType AndBrickType:brickType];
    [self setInlineViewForCategoryType:categoryType AndBrickType:brickType];
    [self setBrickLabelForCategoryType:categoryType AndBrickType:brickType];

// just to test layout
//    self.layer.borderWidth=1.0f;
//    self.layer.borderColor=[UIColor whiteColor].CGColor;
}

#pragma mark init
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentMode = UIViewContentModeScaleToFill;
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.contentMode = UIViewContentModeScaleToFill;
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

@end
