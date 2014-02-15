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
#import "Brick.h"

@interface BrickCell ()
@property (nonatomic, strong) NSDictionary *classNameBrickNameMap;
@property (nonatomic) kBrickCategoryType categoryType;
@property (nonatomic) NSInteger brickType;
@property (nonatomic) BOOL scriptBrickCell;
@property (nonatomic, strong) NSArray *brickCategoryColors;
@property (nonatomic) BOOL alreadyDone;

// subviews
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *inlineView;
//@property (nonatomic, strong) UIImageView *overlayView;
@end

@implementation BrickCell

#pragma mark - getters and setters
- (NSDictionary*)classNameBrickNameMap
{
    static NSDictionary *classNameBrickNameMap = nil;
    if (classNameBrickNameMap == nil) {
        classNameBrickNameMap = kClassNameBrickNameMap;
    }
    return classNameBrickNameMap;
}

- (BOOL)scriptBrickCell
{
    if (self.categoryType == kControlBrick) {
        switch (self.brickType) {
            case kProgramStartedBrick:
            case kTappedBrick:
            case kReceiveBrick:
                return YES;
            default:
                break;
        }
    }
    return NO;
}

- (void)setBrickType:(NSInteger)brickType
{
    if (self.categoryType == kControlBrick) {
        if (self.brickType >= [kControlBrickNames count]) {
            NSError(@"unknown brick type given");
            abort();
        }
    } else if (self.categoryType == kMotionBrick) {
        if (self.brickType >= [kMotionBrickNames count]) {
            NSError(@"unknown brick type given");
            abort();
        }
    } else if (self.categoryType == kSoundBrick) {
        if (self.brickType >= [kSoundBrickNames count]){
            NSError(@"unknown brick type given");
            abort();
        }
    } else if (self.categoryType == kLookBrick) {
        if (self.brickType >= [kLookBrickNames count]){
            NSError(@"unknown brick type given");
            abort();
        }
    } else if (self.categoryType == kVariableBrick) {
        if (self.brickType >= [kVariableBrickNames count]){
            NSError(@"unknown brick type given");
            abort();
        }
    } else {
        NSError(@"unknown brick type given");
        abort();
    }
    _brickType = brickType;
}

//#pragma mark - layout
//- (void)layoutSubviews
//{
//    [super layoutSubviews];
//    
//    UIImage *brickImage = self.imageView.image;
//    brickImage = [brickImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    self.overlayView.image = brickImage;
//    self.overlayView.tintColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.4f];
//    
//    // TODO get correct frame
//    self.overlayView.frame = self.imageView.frame;
//}
//
//#pragma mark Highlight state / collection view cell delegate
//- (void)setHighlighted:(BOOL)highlighted
//{
//    [super setHighlighted:highlighted];
//    
//    if (highlighted) {
//        [self.contentView addSubview:self.overlayView];
//    } else {
//        
//        [self.overlayView removeFromSuperview];
//    }
//    [self setNeedsDisplay];
//}
//
//- (UIImageView *)overlayView
//{
//    if (!_overlayView) {
//        _overlayView = [[UIImageView alloc] initWithFrame:CGRectZero];
//        // _overlayView.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.4f];
//    }
//    return _overlayView;
//}

- (NSArray*)brickCategoryColors
{
    if (! _brickCategoryColors) {
        _brickCategoryColors = kBrickCategoryColors;
    }
    return _brickCategoryColors;
}

// lazy instantiation
//- (UIView*)inlineView
//{
//    if (! _inlineView) {
//        _inlineView = [[UIView alloc] init];
//        [self addSubview:_inlineView];
//    }
//    return _inlineView;
//}

#pragma mark - setup for subviews
- (void)setView
{
    CGRect frame = self.frame;
    frame.size.height = [BrickCell brickCellHeightForCategoryType:self.categoryType AndBrickType:self.brickType];
    self.frame = frame;
}

- (void)set
{
    CGFloat inlineViewHeight = [BrickCell brickCellHeightForCategoryType:self.categoryType AndBrickType:self.brickType];
    kBrickShapeType brickShapeType = [BrickCell shapeTypeForCategoryType:self.categoryType AndBrickType:self.brickType];
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
    self.inlineView.frame = CGRectMake(kBrickInlineViewOffsetX, inlineViewOffsetY, (self.frame.size.width - kBrickInlineViewOffsetX), inlineViewHeight);
    self.inlineView.backgroundColor = [UIColor clearColor];
}

- (void)setBrickPatternImage
{
    // TODO: Cache!!! Performance!!! Don't load same images (shared between different bricks) again and again
    UIImage *brickPatternImage = [UIImage imageNamed:[BrickCell brickPatternImageNameForCategoryType:self.categoryType AndBrickType:self.brickType]];
    self.imageView.frame = CGRectMake(kBrickPatternImageViewOffsetX, kBrickPatternImageViewOffsetY, brickPatternImage.size.width, brickPatternImage.size.height);
    self.imageView.image = brickPatternImage;
    self.imageView.backgroundColor = [UIColor clearColor];
    // just to test layout
//    self.imageView.layer.borderWidth=1.0f;
//    self.imageView.layer.borderColor=[UIColor whiteColor].CGColor;
}

- (void)setBrickPatternBackgroundImage
{
    // TODO: Cache!!! Performance!!! Don't load same images (shared between different bricks) again and again
    NSString *imageName = [BrickCell brickPatternImageNameForCategoryType:self.categoryType AndBrickType:self.brickType];
    UIImage *brickBackgroundPatternImage = [UIImage imageNamed:[imageName stringByAppendingString:kBrickBackgroundImageNameSuffix]];
    CGRect frame = CGRectMake(kBrickPatternBackgroundImageViewOffsetX, kBrickPatternBackgroundImageViewOffsetY, (self.frame.size.width-kBrickInlineViewOffsetX), brickBackgroundPatternImage.size.height);
    self.backgroundImageView.frame = frame;
    UIGraphicsBeginImageContext(self.backgroundImageView.frame.size);
    [brickBackgroundPatternImage drawInRect:self.backgroundImageView.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.backgroundImageView.backgroundColor = [UIColor colorWithPatternImage:image];
}

#pragma mark - setup methods
//- (void)setupInlineView
//{
//    @throw [NSException exceptionWithName:NSInternalInconsistencyException
//                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
//                                 userInfo:nil];
//}

- (void)setupForInlineViewClassName:(NSString*)inlineViewClassName
{
    // only execute this once
    if (self.alreadyDone) {
        return;
    }

    NSDictionary *allCategoriesAndBrickTypes = self.classNameBrickNameMap;
//    NSDictionary *categoryAndBrickType = allCategoriesAndBrickTypes[[subclassName stringByReplacingOccurrencesOfString:@"Cell" withString:@""]];
    NSDictionary *categoryAndBrickType = allCategoriesAndBrickTypes[inlineViewClassName];
    self.categoryType = (kBrickCategoryType) [categoryAndBrickType[@"categoryType"] integerValue];
    self.brickType = [categoryAndBrickType[@"brickType"] integerValue];
    NSLog(@"SubClassName: %@, BrickCategoryType: %d, BrickType: %d", inlineViewClassName, self.categoryType, self.brickType);

    [self setView];
    [self setBrickPatternImage];
    [self setBrickPatternBackgroundImage];
    [self set];
//    [self setup];
    self.alreadyDone = YES;

    // just to test layout
//    self.layer.borderWidth=1.0f;
//    self.layer.borderColor=[UIColor whiteColor].CGColor;
}

#pragma mark - init
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.alreadyDone = NO;
        self.backgroundColor = [UIColor clearColor];
//        [self setupForSubclass:NSStringFromClass([self class])];
        self.contentMode = UIViewContentModeScaleToFill;
        self.clipsToBounds = NO;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.alreadyDone = NO;
        self.backgroundColor = [UIColor clearColor];
//        [self setupForSubclass:NSStringFromClass([self class])];
        self.contentMode = UIViewContentModeScaleToFill;
        self.clipsToBounds = NO;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark - helpers
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
        if (brickType >= [kControlBrickImageNames count]) {
            NSError(@"unknown brick type given");
            abort();
        }
        return kControlBrickImageNames[brickType];
    } else if (categoryType == kMotionBrick) {
        if (brickType >= [kMotionBrickImageNames count]) {
            NSError(@"unknown brick type given");
            abort();
        }
        return kMotionBrickImageNames[brickType];
    } else if (categoryType == kSoundBrick) {
        if (brickType >= [kSoundBrickImageNames count]) {
            NSError(@"unknown brick type given");
            abort();
        }
        return kSoundBrickImageNames[brickType];
    } else if (categoryType == kLookBrick) {
        if (brickType >= [kLookBrickImageNames count]) {
            NSError(@"unknown brick type given");
            abort();
        }
        return kLookBrickImageNames[brickType];
    } else if (categoryType == kVariableBrick) {
        if (brickType >= [kVariableBrickImageNames count]) {
            NSError(@"unknown brick type given");
            abort();
        }
        return kVariableBrickImageNames[brickType];
    }
    NSError(@"unknown brick category type given");
    abort();
}

#pragma mark - helpers
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
    if (categoryType == kControlBrick) {
        if (brickType >= [kControlBrickHeights count]) {
            NSError(@"unknown brick type given");
            abort();
        }
        return [kControlBrickHeights[brickType] floatValue];
    } else if (categoryType == kMotionBrick) {
        if (brickType >= [kMotionBrickHeights count]) {
            NSError(@"unknown brick type given");
            abort();
        }
        return [kMotionBrickHeights[brickType] floatValue];
    } else if (categoryType == kSoundBrick) {
        if (brickType >= [kSoundBrickHeights count]) {
            NSError(@"unknown brick type given");
            abort();
        }
        return [kSoundBrickHeights[brickType] floatValue];
    } else if (categoryType == kLookBrick) {
        if (brickType >= [kLookBrickHeights count]) {
            NSError(@"unknown brick type given");
            abort();
        }
        return [kLookBrickHeights[brickType] floatValue];
    } else if (categoryType == kVariableBrick) {
        if (brickType >= [kVariableBrickHeights count]) {
            NSError(@"unknown brick type given");
            abort();
        }
        return [kVariableBrickHeights[brickType] floatValue];
    }
    NSError(@"unknown brick category type given");
    abort();
}

@end
