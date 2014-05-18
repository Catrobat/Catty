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
#import "MessageComboBoxView.h"
#import "ObjectComboBoxView.h"
#import "SoundComboBoxView.h"
#import "LookComboBoxView.h"
#import "VariableComboBoxView.h"
#import "BrickManager.h"
#import "BrickProtocol.h"

// uncomment this to get special log outputs, etc...
//#define LAYOUT_DEBUG 0
#define kDeleteButtonOffset 1.0f

@interface BrickCell ()
@property (nonatomic, strong) NSArray *brickCategoryColors;

// subviews
@property (nonatomic, weak) BrickCellInlineView *inlineView;
@property (nonatomic, weak) UIImageView *backgroundImageView;
@property (nonatomic, weak) UIImageView *imageView;

@property (nonatomic, assign) BOOL editing;

@end

@implementation BrickCell

#pragma mark - getters and setters
- (kBrickCategoryType)categoryType
{
    return self.brick.brickCategoryType;
}

- (kBrickType)brickType
{
    return self.brick.brickType;
}

- (void)setEnabled:(BOOL)enabled
{
    for (UIView *view in self.inlineView.subviews) {
        if ([view isKindOfClass:[UITextField class]]) {
            ((UITextField*) view).enabled = enabled;
        } else if ([view isKindOfClass:[ComboBoxView class]]) {
            ((ComboBoxView*) view).enabled = enabled;
        }
    }
}

// lazy instantiation
- (UIImageView*)backgroundImageView
{
    if (! _backgroundImageView) {
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:backgroundImageView];
        _backgroundImageView = backgroundImageView;
    }
    return _backgroundImageView;
}

// lazy instantiation
- (UIImageView*)imageView
{
    if (! _imageView) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:imageView];
        _imageView = imageView;
    }
    return _imageView;
}

// lazy instantiation
- (BrickCellInlineView*)inlineView
{
    if (! _inlineView) {
        BrickCellInlineView *inlineView = [[BrickCellInlineView alloc] initWithFrame:CGRectZero];
        [self addSubview:inlineView];
        _inlineView = inlineView;
    }
    return _inlineView;
}

- (ScriptDeleteButton *)deleteButton
{
    if (!_deleteButton) {
        _deleteButton = [[ScriptDeleteButton alloc]initWithFrame:CGRectZero];
        _deleteButton.hidden = YES;
    }
    return _deleteButton;
}

#pragma mark - layout subviews
- (void)layoutSubviews
{
    [super layoutSubviews];
    self.deleteButton.frame = CGRectIntegral(CGRectMake(self.bounds.origin.x + kDeleteButtonOffset,
                                                        self.bounds.origin.y,
                                                        kBrickDeleteButtonSize,
                                                        kBrickDeleteButtonSize)) ;
    
}

- (NSArray*)brickCategoryColors
{
    if (! _brickCategoryColors) {
        _brickCategoryColors = kBrickCategoryColors;
    }
    return _brickCategoryColors;
}

#pragma mark - static getters and setters
+ (NSMutableDictionary*)imageCacheAndClear:(BOOL)clear
{
    static NSMutableDictionary *imageCache = nil;
    if (! imageCache) {
        imageCache = [NSMutableDictionary dictionary];
    }
    if (clear) {
        imageCache = nil;
    }
    return imageCache;
}

+ (NSMutableDictionary*)imageCache
{
    return [BrickCell imageCacheAndClear:NO];
}

+ (void)clearImageCache
{
    [BrickCell imageCacheAndClear:YES];
}

#pragma mark - setup for subviews
- (void)setupView
{
    CGRect frame = self.frame;
    frame.size.height = [BrickCell brickCellHeightForBrickType:self.brickType];
    self.frame = frame;
}

- (void)setupInlineView
{
    CGFloat inlineViewHeight = [BrickCell brickCellHeightForBrickType:self.brickType];
    kBrickShapeType brickShapeType = [BrickCell shapeTypeForBrickType:self.brickType];
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

    // call corresponding subclass method, specific implementation (overridden method)
    // TODO: remove this "try-catch-check" later
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
    NSString *imageName = [BrickCell brickPatternImageNameForBrickType:self.brickType];
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
    NSString *imageName = [[BrickCell brickPatternImageNameForBrickType:self.brickType]
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

- (void)renderSubViews
{
    [self.backgroundImageView removeFromSuperview];
    [self.imageView removeFromSuperview];
    [self.inlineView removeFromSuperview];
    self.backgroundImageView = nil;
    self.imageView = nil;
    self.inlineView = nil;
    [self setupView];
    [self setupBrickPatternImage];
    [self setupBrickPatternBackgroundImage];
    [self setupInlineView];
    [self addSubview:self.deleteButton];
}

#pragma mark - init
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.editing = NO;
        self.backgroundColor = [UIColor clearColor];
        self.contentMode = UIViewContentModeScaleToFill;
        self.clipsToBounds = NO;
        self.backgroundImageView.clipsToBounds = NO;
        self.imageView.clipsToBounds = NO;
        self.opaque = NO;
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.editing = NO;
        self.backgroundColor = [UIColor clearColor];
        self.contentMode = UIViewContentModeScaleToFill;
        self.clipsToBounds = NO;
        self.backgroundColor = [UIColor clearColor];
        self.backgroundImageView.clipsToBounds = NO;
        self.imageView.clipsToBounds = NO;
        self.opaque = NO;
    }
    return self;
}

#pragma mark - helpers
- (NSArray*)inlineViewSubviews
{
    CGRect canvasFrame = CGRectMake(kBrickInlineViewCanvasOffsetX, kBrickInlineViewCanvasOffsetY, self.inlineView.frame.size.width, self.inlineView.frame.size.height);

    // get correct NSString array
    NSArray *brickCategoryParams = nil;
    switch (self.categoryType) {
        case kControlBrick:
            brickCategoryParams = kControlBrickNameParams;
            break;
        case kMotionBrick:
            brickCategoryParams = kMotionBrickNameParams;
            break;
        case kSoundBrick:
            brickCategoryParams = kSoundBrickNameParams;
            break;
        case kLookBrick:
            brickCategoryParams = kLookBrickNameParams;
            break;
        case kVariableBrick:
            brickCategoryParams = kVariableBrickNameParams;
            break;
        default:
            NSError(@"unknown brick category type given");
            abort();
    }

    BrickManager *brickManager = [BrickManager sharedBrickManager];
    NSUInteger brickIndex = [brickManager brickIndexForBrickType:self.brickType];
    NSString *brickTitle = self.brick.brickTitle;
    id brickParamsUnconverted = brickCategoryParams[brickIndex];
    NSArray *brickParams = (([brickParamsUnconverted isKindOfClass:[NSString class]]) ? @[brickParamsUnconverted] : brickParamsUnconverted);
    NSArray *subviews = nil;

    // check if it is a "two-liner" or a "one-liner" brick
    NSArray *lines = [brickTitle componentsSeparatedByString:@"\n"];
    NSUInteger numberOfLines = [lines count];

    if (! numberOfLines) {
        return nil;
    }

    if (numberOfLines > 1) {
        // determine number of params per line
        NSUInteger totalNumberOfParams = [brickParams count];
        NSMutableArray *paramsOfLines = [NSMutableArray arrayWithCapacity:numberOfLines];
        NSUInteger numberOfPreviousLineParams = 0;
        NSUInteger numberOfLinesWithParams = 0;
        for (NSInteger lineIndex = 0; lineIndex < numberOfLines; ++lineIndex) {
            NSString *currentLine = [lines objectAtIndex:lineIndex];
            NSUInteger numberOfCurrentLineParams = 0;
            NSArray *currentLineParams = @[];
            if (totalNumberOfParams) {
                NSError *error = NULL;
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"%@" options:NSRegularExpressionCaseInsensitive error:&error];
                numberOfCurrentLineParams = [regex numberOfMatchesInString:currentLine options:0 range:NSMakeRange(0, [currentLine length])];

                if (numberOfCurrentLineParams) {
                    currentLineParams = [brickParams subarrayWithRange:NSMakeRange(numberOfPreviousLineParams, numberOfCurrentLineParams)];
                    ++numberOfLinesWithParams;
                }
            }
            numberOfPreviousLineParams = numberOfCurrentLineParams;
            [paramsOfLines addObject:currentLineParams];
        }

        // determine height per line and generate subviews of all lines
        CGFloat totalHeight = canvasFrame.size.height;
        CGFloat averageHeight = totalHeight / (CGFloat)numberOfLines;
        CGFloat heightForLineWithParams = ((averageHeight > kBrickInputFieldMinRowHeight) ? averageHeight : kBrickInputFieldMinRowHeight);
        CGFloat remainingTotalHeight = (totalHeight - (heightForLineWithParams * numberOfLinesWithParams));
        CGFloat heightForLineWithNoParams = (remainingTotalHeight / (numberOfLines - numberOfLinesWithParams));
        NSMutableArray *allLinesSubviews = [NSMutableArray array];
        CGFloat yOffset = 0.0f;
        for (NSInteger lineIndex = 0; lineIndex < numberOfLines; ++lineIndex) {
            NSString *line = [lines objectAtIndex:lineIndex];
            NSArray *params = [paramsOfLines objectAtIndex:lineIndex];
            CGRect frame = canvasFrame;
            frame.origin.y = yOffset;
            frame.size.height = ([params count] ? heightForLineWithParams : heightForLineWithNoParams);
            yOffset += frame.size.height;
            [allLinesSubviews addObjectsFromArray:[self inlineViewSubviewsOfLabel:line WithParams:params WithFrame:frame]];
        }
        subviews = [allLinesSubviews copy]; // makes immutable copy of (NSMutableArray*) => returns (NSArray*)
    } else {
        // case: one line
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
#ifdef LAYOUT_DEBUG
        NSLog(@"Label Title: %@, Width: %f, Height: %f", labelTitle, remainingFrame.size.width, remainingFrame.size.height);
        textLabel.backgroundColor = [UIColor yellowColor];
#endif
        [subviews addObject:textLabel];
        return subviews;
    }

    // case: more than one subview
    NSArray *partLabels = [labelTitle componentsSeparatedByString:@"%@"];
    NSUInteger totalNumberOfPartLabels = [partLabels count];
    NSUInteger totalNumberOfSubViews = totalNumberOfPartLabels + totalNumberOfParams;
    NSMutableArray *subviews = [NSMutableArray arrayWithCapacity:totalNumberOfSubViews];
    NSInteger counter = 0;
    for (NSString *partLabelTitle in partLabels) {

        // -----------------------------------
        // TODO: make x-offset calculation much more smarter...

        if (partLabelTitle.length) {
            UILabel *textLabel = [UIUtil newDefaultBrickLabelWithFrame:remainingFrame AndText:partLabelTitle];
    #ifdef LAYOUT_DEBUG
            NSLog(@"Label Title: %@, Width: %f, Height: %f", partLabelTitle, remainingFrame.size.width, remainingFrame.size.height);
            textLabel.backgroundColor = [UIColor blueColor];
    #endif
            remainingFrame.origin.x += (textLabel.frame.size.width + kBrickInputFieldLeftMargin);
            remainingFrame.size.width -= (textLabel.frame.size.width + kBrickInputFieldLeftMargin);
            [subviews addObject:textLabel];
        }

        // determine UI component
        if (counter < totalNumberOfParams) {

            // -----------------------------------
            // TODO: This is only code used for testing purposes. TO BE REFACTORED...
            // TODO: Pickers, Pluralization, Hook Ups only for inputFields ...

            CGRect inputViewFrame = remainingFrame;
//            inputViewFrame.origin.y += kBrickInputFieldTopMargin;
//            inputViewFrame.size.height -= (kBrickInputFieldTopMargin + kBrickInputFieldBottomMargin);
            inputViewFrame.origin.y += kBrickInputFieldTopMargin/(kBrickInputFieldTopMargin + kBrickInputFieldBottomMargin) * (remainingFrame.size.height - kBrickInputFieldHeight);
            inputViewFrame.size.height = kBrickInputFieldHeight;
            inputViewFrame.size.width = kBrickInputFieldMinWidth;
            NSString *afterLabelParam = [params objectAtIndex:counter];
            UIView *inputField = nil;
            if ([afterLabelParam rangeOfString:@"FLOAT"].location != NSNotFound) {
                UITextField *textField = [UIUtil newDefaultBrickTextFieldWithFrame:inputViewFrame];
                inputField = (UIView*)textField;
            } else if ([afterLabelParam rangeOfString:@"INT"].location != NSNotFound) {
                UITextField *textField = [UIUtil newDefaultBrickTextFieldWithFrame:inputViewFrame];
                inputField = (UIView*)textField;
            } else if ([afterLabelParam rangeOfString:@"TEXT"].location != NSNotFound) {
//                inputViewFrame.origin.y = (remainingFrame.size.height - kBrickInputFieldHeight)/2.0f+(kBrickInputFieldTopMargin - kBrickInputFieldBottomMargin);
//                inputViewFrame.size.height = kBrickInputFieldHeight;
                UITextField *textField = [UIUtil newDefaultBrickTextFieldWithFrame:inputViewFrame];
                inputField = (UIView*)textField;
            } else if ([afterLabelParam rangeOfString:@"MESSAGE"].location != NSNotFound) {
                inputViewFrame.size.width = kBrickComboBoxWidth;
                NSMutableArray* messages = [[NSMutableArray alloc] init];
                [messages addObject:@"New..."];
                [messages addObject:@"message 1"];
                ComboBoxView *comboBox = [UIUtil newDefaultBrickMessageComboBoxWithFrame:inputViewFrame AndItems:messages];
                [comboBox preselectItemAtIndex:1];
                inputField = (UIView*)comboBox;
            } else if ([afterLabelParam rangeOfString:@"OBJECT"].location != NSNotFound) {
                inputViewFrame.size.width = kBrickComboBoxWidth;
                NSMutableArray* objects = [[NSMutableArray alloc] init];
                [objects addObject:@"New..."];
                [objects addObject:@"object 1"];
                ComboBoxView *comboBox = [UIUtil newDefaultBrickObjectComboBoxWithFrame:inputViewFrame AndItems:objects];
                [comboBox preselectItemAtIndex:1];
                inputField = (UIView*)comboBox;
            } else if ([afterLabelParam rangeOfString:@"SOUND"].location != NSNotFound) {
                inputViewFrame.size.width = kBrickComboBoxWidth;
                NSMutableArray* sounds = [[NSMutableArray alloc] init];
                [sounds addObject:@"New..."];
                [sounds addObject:@"sound 1"];
                ComboBoxView *comboBox = [UIUtil newDefaultBrickSoundComboBoxWithFrame:inputViewFrame AndItems:sounds];
                [comboBox preselectItemAtIndex:1];
                inputField = (UIView*)comboBox;
            } else if ([afterLabelParam rangeOfString:@"LOOK"].location != NSNotFound) {
                inputViewFrame.size.width = kBrickComboBoxWidth;
                NSMutableArray* looks = [[NSMutableArray alloc] init];
                [looks addObject:@"New..."];
                [looks addObject:@"look 1"];
                ComboBoxView *comboBox = [UIUtil newDefaultBrickLookComboBoxWithFrame:inputViewFrame AndItems:looks];
                [comboBox preselectItemAtIndex:1];
                inputField = (UIView*)comboBox;
            } else if ([afterLabelParam rangeOfString:@"VARIABLE"].location != NSNotFound) {
                inputViewFrame.size.width = kBrickComboBoxWidth;
                NSMutableArray* variables = [[NSMutableArray alloc] init];
                [variables addObject:@"New..."];
                [variables addObject:@"variable 1"];
                ComboBoxView *comboBox = [UIUtil newDefaultBrickLookComboBoxWithFrame:inputViewFrame AndItems:variables];
                [comboBox preselectItemAtIndex:1];
                inputField = (UIView*)comboBox;
            } else {
                NSError(@"unknown data type %@ given", afterLabelParam);
                abort();
            }

            remainingFrame.origin.x += (inputField.frame.size.width + kBrickInputFieldRightMargin);
            remainingFrame.size.width -= (inputField.frame.size.width + kBrickInputFieldRightMargin);
            [subviews addObject:inputField];
        }
        counter++;
    }
    return subviews;
}

+ (kBrickShapeType)shapeTypeForBrickType:(NSUInteger)brickType
{
    BrickManager *brickManager = [BrickManager sharedBrickManager];
    kBrickCategoryType categoryType = [brickManager brickCategoryTypeForBrickType:brickType];
    if (categoryType == kControlBrick) {
        if ((brickType == kProgramStartedBrick) || (brickType == kTappedBrick)) {
            return kBrickShapeRoundedSmall;
        } else if (brickType == kReceiveBrick) {
            return kBrickShapeRoundedBig;
        }
    }
    return kBrickShapeNormal;
}

+ (NSString*)brickPatternImageNameForBrickType:(NSUInteger)brickType
{
    BrickManager *brickManager = [BrickManager sharedBrickManager];
    kBrickCategoryType categoryType = [brickManager brickCategoryTypeForBrickType:brickType];
    NSUInteger brickTypeIndex = [brickManager brickIndexForBrickType:brickType];
    if (categoryType == kControlBrick) {
        if (brickTypeIndex >= [kControlBrickImageNames count]) {
            NSError(@"unknown brick type given");
            abort();
        }
        return kControlBrickImageNames[brickTypeIndex];
    } else if (categoryType == kMotionBrick) {
        if (brickTypeIndex >= [kMotionBrickImageNames count]) {
            NSError(@"unknown brick type given");
            abort();
        }
        return kMotionBrickImageNames[brickTypeIndex];
    } else if (categoryType == kSoundBrick) {
        if (brickTypeIndex >= [kSoundBrickImageNames count]) {
            NSError(@"unknown brick type given");
            abort();
        }
        return kSoundBrickImageNames[brickTypeIndex];
    } else if (categoryType == kLookBrick) {
        if (brickTypeIndex >= [kLookBrickImageNames count]) {
            NSError(@"unknown brick type given");
            abort();
        }
        return kLookBrickImageNames[brickTypeIndex];
    } else if (categoryType == kVariableBrick) {
        if (brickTypeIndex >= [kVariableBrickImageNames count]) {
            NSError(@"unknown brick type given");
            abort();
        }
        return kVariableBrickImageNames[brickTypeIndex];
    }
    NSError(@"unknown brick category type given");
    abort();
}

#pragma mark - helpers
+ (CGFloat)brickCellHeightForBrickType:(NSUInteger)brickType
{
    BrickManager *brickManager = [BrickManager sharedBrickManager];
    kBrickCategoryType categoryType = [brickManager brickCategoryTypeForBrickType:brickType];
    NSUInteger brickTypeIndex = [brickManager brickIndexForBrickType:brickType];
    if (categoryType == kControlBrick) {
        if (brickTypeIndex >= [kControlBrickHeights count]) {
            NSError(@"unknown brick type given");
            abort();
        }
        return [kControlBrickHeights[brickTypeIndex] floatValue];
    } else if (categoryType == kMotionBrick) {
        if (brickTypeIndex >= [kMotionBrickHeights count]) {
            NSError(@"unknown brick type given");
            abort();
        }
        return [kMotionBrickHeights[brickTypeIndex] floatValue];
    } else if (categoryType == kSoundBrick) {
        if (brickTypeIndex >= [kSoundBrickHeights count]) {
            NSError(@"unknown brick type given");
            abort();
        }
        return [kSoundBrickHeights[brickTypeIndex] floatValue];
    } else if (categoryType == kLookBrick) {
        if (brickTypeIndex >= [kLookBrickHeights count]) {
            NSError(@"unknown brick type given");
            abort();
        }
        return [kLookBrickHeights[brickTypeIndex] floatValue];
    } else if (categoryType == kVariableBrick) {
        if (brickTypeIndex >= [kVariableBrickHeights count]) {
            NSError(@"unknown brick type given");
            abort();
        }
        return [kVariableBrickHeights[brickTypeIndex] floatValue];
    }
    NSError(@"unknown brick category type given");
    abort();
}

#pragma mark - cell editing
- (void)setBrickEditing:(BOOL)editing {
    self.editing = editing;

    if (self.editing) {
        //  self.transform = CGAffineTransformMakeScale(0.8f, 0.8f);
        self.alpha = 0.2f;
        self.userInteractionEnabled = NO;
        self.hideDeleteButton = NO;
    } else {
        // self.transform = CGAffineTransformIdentity;
        self.alpha = 1.0f;
        self.userInteractionEnabled = YES;
        self.hideDeleteButton = YES;
    }
}

#pragma mark delete button
- (void)setHideDeleteButton:(BOOL)hideDeleteButton {
    _hideDeleteButton = hideDeleteButton;
    self.deleteButton.hidden = hideDeleteButton;
}

@end
