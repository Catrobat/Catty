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
#import "BrickCellInlineView.h"
#import "UIUtil.h"

@interface BrickCell ()
@property (nonatomic, strong) NSDictionary *classNameBrickNameMap;
@property (nonatomic) kBrickCategoryType categoryType;
@property (nonatomic) NSInteger brickType;
@property (nonatomic) BOOL scriptBrickCell;
@property (nonatomic, strong) NSArray *brickCategoryColors;

// subviews
@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) BrickCellInlineView *inlineView;
@property (strong, nonatomic) UIImageView *overlayView;
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

// lazy instantiation
- (UIImageView*)backgroundImageView
{
    if (! _backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_backgroundImageView];
    }
    return _backgroundImageView;
}

// lazy instantiation
- (UIImageView*)imageView
{
    if (! _imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_imageView];
    }
    return _imageView;
}

// lazy instantiation
- (BrickCellInlineView*)inlineView
{
    if (! _inlineView) {
        _inlineView = [[BrickCellInlineView alloc] initWithFrame:CGRectZero];
        [self addSubview:_inlineView];
    }
    return _inlineView;
}

#pragma mark - layout
- (void)layoutSubviews
{
    [super layoutSubviews];

    UIImage *brickImage = self.imageView.image;
    brickImage = [brickImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.overlayView.image = brickImage;
    self.overlayView.tintColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.4f];

    // TODO get correct frame
    self.overlayView.frame = self.imageView.frame;
}

#pragma mark Highlight state / collection view cell delegate
- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        [self.contentView addSubview:self.overlayView];
    } else {
        
        [self.overlayView removeFromSuperview];
    }
    [self setNeedsDisplay];
}

- (UIImageView *)overlayView
{
    if (!_overlayView) {
        _overlayView = [[UIImageView alloc] initWithFrame:CGRectZero];
        // _overlayView.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.4f];
    }
    return _overlayView;
}

- (NSArray*)brickCategoryColors
{
    if (! _brickCategoryColors) {
        _brickCategoryColors = kBrickCategoryColors;
    }
    return _brickCategoryColors;
}

#pragma mark - static getters and setters
+ (NSMutableDictionary*)imageCache
{
    static NSMutableDictionary *imageCache = nil;
    if (! imageCache) {
        imageCache = [NSMutableDictionary dictionary];
    }
    return imageCache;
}

#pragma mark - setup for subviews
- (void)setupView
{
    CGRect frame = self.frame;
    frame.size.height = [BrickCell brickCellHeightForCategoryType:self.categoryType AndBrickType:self.brickType];
    self.frame = frame;
}

- (void)setupInlineView
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
    CGRect frame = CGRectMake(kBrickInlineViewOffsetX, inlineViewOffsetY, (self.frame.size.width - kBrickInlineViewOffsetX), inlineViewHeight);
    self.inlineView.frame = frame;
    self.inlineView.backgroundColor = [UIColor clearColor];

    NSArray *inlineViewSubViews = [self inlineViewSubviews];
    // call specific subclass method (virtual)
#warning remove this "try-catch-check" later
    @try {
        [self hookUpSubViews:inlineViewSubViews];
    } @catch (NSException *exception) {
        NSLog(@"Exception: %@", [exception description]);
        frame.origin.x = 0.0f;
        frame.origin.y = 0.0f;
        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        label.font = [UIFont systemFontOfSize:10.0f];
        label.text = [@"Please implement hookUpSubViews in " stringByAppendingString:NSStringFromClass([self class])];
        label.textColor = [UIColor redColor];
        label.backgroundColor = [UIColor whiteColor];
        [label sizeThatFits:frame.size];
        [self.inlineView addSubview:label];
    }
    // just to test layout
//    self.inlineView.layer.borderWidth=1.0f;
//    self.inlineView.layer.borderColor=[UIColor whiteColor].CGColor;
}

- (void)setupBrickPatternImage
{
    NSMutableDictionary *imageCache = [BrickCell imageCache];
    NSString *imageName = [BrickCell brickPatternImageNameForCategoryType:self.categoryType
                                                             AndBrickType:self.brickType];
    UIImage *brickPatternImage = [imageCache objectForKey:imageName];
    if (! brickPatternImage) {
        brickPatternImage = [UIImage imageNamed:imageName];
        [imageCache setObject:brickPatternImage forKey:imageName];
    }
    self.imageView.frame = CGRectMake(kBrickPatternImageViewOffsetX, kBrickPatternImageViewOffsetY, brickPatternImage.size.width, brickPatternImage.size.height);
    self.imageView.image = brickPatternImage;
    self.imageView.backgroundColor = [UIColor clearColor];
    // just to test layout
//    self.imageView.layer.borderWidth=1.0f;
//    self.imageView.layer.borderColor=[UIColor whiteColor].CGColor;
}

- (void)setupBrickPatternBackgroundImage
{
    NSMutableDictionary *imageCache = [BrickCell imageCache];
    NSString *imageName = [[BrickCell brickPatternImageNameForCategoryType:self.categoryType
                                                              AndBrickType:self.brickType]
                           stringByAppendingString:kBrickBackgroundImageNameSuffix];
    UIImage *brickBackgroundPatternImage = [imageCache objectForKey:imageName];
    if (! brickBackgroundPatternImage) {
        brickBackgroundPatternImage = [UIImage imageNamed:imageName];
        [imageCache setObject:brickBackgroundPatternImage forKey:imageName];
    }
    CGRect frame = CGRectMake(kBrickPatternBackgroundImageViewOffsetX, kBrickPatternBackgroundImageViewOffsetY, (self.frame.size.width-kBrickInlineViewOffsetX), brickBackgroundPatternImage.size.height);
    self.backgroundImageView.frame = frame;
    UIGraphicsBeginImageContext(self.backgroundImageView.frame.size);
    [brickBackgroundPatternImage drawInRect:self.backgroundImageView.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.backgroundImageView.backgroundColor = [UIColor colorWithPatternImage:image];
    [self sendSubviewToBack:self.backgroundImageView];
}

#pragma mark - setup methods
- (void)hookUpSubViews:(NSArray *)inlineViewSubViews
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)setupForSubclassWithName:(NSString*)subclassName
{
    NSDictionary *allCategoriesAndBrickTypes = self.classNameBrickNameMap;
    NSDictionary *categoryAndBrickType = allCategoriesAndBrickTypes[[subclassName stringByReplacingOccurrencesOfString:@"Cell" withString:@""]];
    self.categoryType = (kBrickCategoryType) [categoryAndBrickType[@"categoryType"] integerValue];
    self.brickType = [categoryAndBrickType[@"brickType"] integerValue];
    NSLog(@"SubClassName: %@, BrickCategoryType: %d, BrickType: %d", subclassName, self.categoryType, self.brickType);

    [self setupView];
    [self setupBrickPatternImage];
    [self setupBrickPatternBackgroundImage];
    [self setupInlineView];

    // just to test layout
//    self.layer.borderWidth=1.0f;
//    self.layer.borderColor=[UIColor whiteColor].CGColor;
}

#pragma mark - init
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setupForSubclassWithName:NSStringFromClass([self class])];
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
        self.backgroundColor = [UIColor clearColor];
        [self setupForSubclassWithName:NSStringFromClass([self class])];
        self.contentMode = UIViewContentModeScaleToFill;
        self.clipsToBounds = NO;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark - helpers
- (NSArray*)inlineViewSubviews
{
    CGRect canvasFrame = CGRectMake(kBrickInlineViewCanvasOffsetX, kBrickInlineViewCanvasOffsetY, self.inlineView.frame.size.width, self.inlineView.frame.size.height);

    // get correct NSString array
    NSArray *brickCategoryTitles = nil;
    NSArray *brickCategoryParams = nil;
    switch (self.categoryType) {
        case kControlBrick:
            brickCategoryTitles = kControlBrickNames;
            brickCategoryParams = kControlBrickNameParams;
            break;
        case kMotionBrick:
            brickCategoryTitles = kMotionBrickNames;
            brickCategoryParams = kMotionBrickNameParams;
            break;
        case kSoundBrick:
            brickCategoryTitles = kSoundBrickNames;
            brickCategoryParams = kSoundBrickNameParams;
            break;
        case kLookBrick:
            brickCategoryTitles = kLookBrickNames;
            brickCategoryParams = kLookBrickNameParams;
            break;
        case kVariableBrick:
            brickCategoryTitles = kVariableBrickNames;
            brickCategoryParams = kVariableBrickNameParams;
            break;
        default:
            NSError(@"unknown brick category type given");
            abort();
    }
    NSString *brickTitle = brickCategoryTitles[self.brickType];
    id brickParamsUnconverted = brickCategoryParams[self.brickType];
    NSArray *brickParams = (([brickParamsUnconverted isKindOfClass:[NSString class]]) ? @[brickParamsUnconverted] : brickParamsUnconverted);
    NSArray *subviews = nil;

    // check if it is a "two-liner" or a "one-liner" brick
    NSRange range = [brickTitle rangeOfString:@"\n"];
    if (range.location != NSNotFound) {
        // first case: it's a two liner
        NSError *error = NULL;
        NSString *topLine = [brickTitle substringToIndex:range.location];
        NSString *bottomLine = [brickTitle substringFromIndex:(range.location+range.length)];
        NSDebug(@"String1 = %@",topLine);
        NSDebug(@"String2 = %@",bottomLine);
        NSArray *topParams = @[];
        NSArray *bottomParams = @[];

        NSUInteger totalNumberOfParams = [brickParams count];
        NSUInteger numberOfTopParams = 0;
        NSUInteger numberOfBottomParams = 0;
        if (totalNumberOfParams) {
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"%@" options:NSRegularExpressionCaseInsensitive error:&error];
            numberOfTopParams = [regex numberOfMatchesInString:topLine options:0 range:NSMakeRange(0, [topLine length])];
            numberOfBottomParams = totalNumberOfParams - numberOfTopParams;
            if (numberOfTopParams) {
                topParams = [brickParams subarrayWithRange:NSMakeRange(0, numberOfTopParams)];
            }
            if (numberOfTopParams < totalNumberOfParams) {
                bottomParams = [brickParams subarrayWithRange:NSMakeRange(numberOfTopParams, numberOfBottomParams)];
            }
        }
        CGRect topFrame = canvasFrame;
        CGRect bottomFrame = canvasFrame;
        topFrame.size.height /= 2.0f;
        bottomFrame.origin.y = topFrame.size.height;
        bottomFrame.size.height -= topFrame.size.height;

        // if at least one input field in only one line occurs, update height of this row to fixed size
        if (numberOfTopParams && (! numberOfBottomParams)) {
            bottomFrame.origin.y = topFrame.size.height = kBrickInputFieldMinRowHeight;
            bottomFrame.size.height -= topFrame.size.height;
        } else if ((! numberOfTopParams) && numberOfBottomParams) {
            bottomFrame.size.height = kBrickInputFieldMinRowHeight;
            bottomFrame.origin.y = topFrame.size.height = (canvasFrame.size.height - bottomFrame.size.height);
        }

        NSMutableArray *bothLinesSubviews = [NSMutableArray array];
        [bothLinesSubviews addObjectsFromArray:[self inlineViewSubviewsOfLabel:topLine WithParams:topParams WithFrame:topFrame]];
        [bothLinesSubviews addObjectsFromArray:[self inlineViewSubviewsOfLabel:bottomLine WithParams:bottomParams WithFrame:bottomFrame]];
        subviews = [bothLinesSubviews copy]; // makes immutable copy of (NSMutableArray*) => returns (NSArray*)
    } else {
        // second case: it's a one liner
        subviews = [[self inlineViewSubviewsOfLabel:brickTitle WithParams:brickParams WithFrame:canvasFrame] copy]; // makes immutable copy of (NSMutableArray*) => returns (NSArray*)
    }
    // finally add all subviews to the inline view
    for (UIView* subview in subviews) {
        [self.inlineView addSubview:subview];
    }
    return subviews;
}

- (NSMutableArray*)inlineViewSubviewsOfLabel:(NSString*)labelTitle WithParams:(NSArray*)params WithFrame:(CGRect)frame
{
    CGRect remainingFrame = frame;
    NSUInteger totalNumberOfParams = [params count];
    if (! totalNumberOfParams) {
        NSMutableArray *subviews = [NSMutableArray array];
        UILabel *textLabel = [UIUtil newDefaultBrickLabelWithFrame:remainingFrame AndText:labelTitle];
        [subviews addObject:textLabel];
        return subviews;
    }

    // case: more than one subview
    // TODO: make x-offset calculation much more smarter...
    NSArray *partLabels = [labelTitle componentsSeparatedByString:@"%@"];
    NSUInteger totalNumberOfPartLabels = [partLabels count];
    NSUInteger totalNumberOfSubViews = totalNumberOfPartLabels + totalNumberOfParams;
    NSMutableArray *subviews = [NSMutableArray arrayWithCapacity:totalNumberOfSubViews];
    NSInteger counter = 0;
    for (NSString *partLabelTitle in partLabels) {
        UILabel *textLabel = [UIUtil newDefaultBrickLabelWithFrame:remainingFrame AndText:partLabelTitle];
//        textLabel.backgroundColor = [UIColor blueColor];
        remainingFrame.origin.x += (textLabel.frame.size.width + kBrickInputFieldLeftMargin);
        remainingFrame.size.width -= (textLabel.frame.size.width + kBrickInputFieldLeftMargin);
        [subviews addObject:textLabel];

        // determine UI component
        if (counter < totalNumberOfParams) {
            // TODO: continue to implement here
            CGRect inputViewFrame = remainingFrame;
            inputViewFrame.origin.y += kBrickInputFieldTopMargin;
            inputViewFrame.size.height -= (kBrickInputFieldTopMargin + kBrickInputFieldBottomMargin);
            inputViewFrame.size.width = kBrickInputFieldMinWidth;
            NSString *afterLabelParam = [params objectAtIndex:counter];
            UIView *inputField = nil;
            if ([afterLabelParam rangeOfString:@"FLOAT"].location != NSNotFound) {
                UITextField *textField = [UIUtil newDefaultBrickTextFieldWithFrame:inputViewFrame];
                textField.enabled = NO;
                inputField = (UIView*)textField;
            } else if ([afterLabelParam rangeOfString:@"INT"].location != NSNotFound) {
                UITextField *textField = [UIUtil newDefaultBrickTextFieldWithFrame:inputViewFrame];
                textField.enabled = NO;
                inputField = (UIView*)textField;
            } else {
                UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:inputViewFrame];
                inputField = (UIView*)pickerView;
            }

            remainingFrame.origin.x += (inputField.frame.size.width + kBrickInputFieldRightMargin);
            remainingFrame.size.width -= (inputField.frame.size.width + kBrickInputFieldRightMargin);
            [subviews addObject:inputField];
        }
        counter++;
    }
    return subviews;
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
