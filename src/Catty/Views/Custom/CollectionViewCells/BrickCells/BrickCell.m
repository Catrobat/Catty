/**
 *  Copyright (C) 2010-2023 The Catrobat Team
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
#import "Brick.h"
#import "BrickCellInlineView.h"
#import "UIUtil.h"
#import "iOSCombobox.h"
#import "BrickManager.h"
#import "Script.h"
#import "BrickCellDataProtocol.h"
#import "BrickCellLookData.h"
#import "BrickCellSoundData.h"
#import "BrickCellObjectData.h"
#import "BrickCellFormulaData.h"
#import "BrickCellTextData.h"
#import "BrickCellMessageData.h"
#import "BrickCellStaticChoiceData.h"
#import "BrickCellVariableData.h"
#import "BrickCellListData.h"
#import "BrickCellPhiroMotorData.h"
#import "BrickCellPhiroLightData.h"
#import "BrickCellPhiroToneData.h"
#import "BrickCellPhiroIfSensorData.h"
#import "LoopEndBrickCell.h"
#import "Pocket_Code-Swift.h"

@interface BrickCell ()
@property (nonatomic, weak) BrickCellInlineView *inlineView;
@property (nonatomic, strong) NSString* brickTitle;
@property (nonatomic, assign, getter = isEditing) BOOL editing;

@end

@implementation BrickCell

#pragma mark - UICollectionViewCellDelegate

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        self.clearsContextBeforeDrawing = YES;
        self.opaque = NO;
        self.clipsToBounds = NO;
        self.isInserting = NO;
        self.maxInputFormulaFrameLength = 0;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.contentView.frame = CGRectIntegral(self.bounds);
    self.selectButton.center = CGPointMake(self.bounds.origin.x - UIDefines.selectButtonOffset,
                                           CGRectGetMidY(self.bounds));
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    self.alpha = highlighted ? 0.7f : 1.0f;
}

- (void)setupBrickCell
{
    [self setupBrickCellinSelectionView:false inBackground:false];
}

- (void)setupBrickCellinSelectionView:(BOOL)inSelectionView inBackground:(BOOL)inBackground
{
    self.brickTitle = [(id<BrickCellProtocol>)self brickTitleForBackground:inBackground andInsertionScreen:inSelectionView];
    
    if ([self isKindOfClass:[LoopEndBrickCell class]]) {
        LoopEndBrickCell* cell = (LoopEndBrickCell*)self;
        cell.type = [[BrickManager sharedBrickManager] checkEndLoopBrickTypeForDrawing:cell];
    }
    [self renderSubViews];
    if (self.editing) {
        if (self.frame.origin.x == 0.0f) {
            self.center = CGPointMake(self.center.x + UIDefines.selectButtonTranslationOffsetX, self.center.y);
            self.selectButton.alpha = 1.0f;
        }
    } else {
        if (self.frame.origin.x > 0.0f) {
            self.center = CGPointMake(CGRectGetMidX(UIScreen.mainScreen.bounds), self.center.y);
            self.selectButton.alpha = 0.0f;
        }
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    [super hitTest:point withEvent:event];
    CGPoint subPoint = [self.selectButton convertPoint:point fromView:self];
    UIView *result = [self.selectButton hitTest:subPoint withEvent:event];
    if (result != nil) {
        return result;
    }
    return [super hitTest:point withEvent:event];
}

#pragma mark - getters and setters
- (void)setEnabled:(BOOL)enabled
{
    for (UIView *view in self.inlineView.subviews) {
        if ([view isKindOfClass:[UITextField class]]) {
            ((UITextField*) view).enabled = enabled;
        } else if ([view isKindOfClass:[iOSCombobox class]]) {
            ((iOSCombobox*) view).enabled = enabled;
        }
    }
}

// lazy instantiation
- (BrickCellInlineView*)inlineView
{
    if (! _inlineView) {
        BrickCellInlineView *inlineView = [[BrickCellInlineView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:inlineView];
        _inlineView = inlineView;
    }
    return _inlineView;
}

- (SelectButton *)selectButton
{
    if (!_selectButton) {
        _selectButton = [[SelectButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f,
                        UIDefines.brickCellDeleteButtonWidthHeight, UIDefines.brickCellDeleteButtonWidthHeight)];
        _selectButton.alpha = 0.0f;
        [self addSubview:_selectButton];
        [_selectButton addTarget:self action:@selector(selectButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectButton;
}

- (void)selectButtonSelected:(id)sender
{
    if ([sender isKindOfClass:SelectButton.class]) {
        if ([self.delegate respondsToSelector:@selector(brickCell:didSelectBrickCellButton:)]) {
            [self.delegate brickCell:self didSelectBrickCellButton:self.selectButton];
        }
    }
}

#pragma mark - setup for subviews
- (void)setupView
{
    CGRect frame = self.frame;
    frame.size.height = [[self class] cellHeight];
    self.frame = frame;
}

- (void)setupInlineView
{
    CGFloat inlineViewHeight = [[self class] cellHeight];
    kBrickShapeType brickShapeType = [self brickShapeType];
    CGFloat inlineViewOffsetY = 0.0f;
    if (brickShapeType != kBrickShapeRoundedSmall && brickShapeType != kBrickShapeRoundedBig) {
        inlineViewHeight -= UIDefines.brickShapeNormalMarginHeightDeduction;
        inlineViewOffsetY = UIDefines.brickShapeNormalInlineViewOffsetY;
    } else if (brickShapeType == kBrickShapeRoundedSmall) {
        inlineViewHeight -= UIDefines.brickShapeRoundedSmallMarginHeightDeduction;
        inlineViewOffsetY = UIDefines.brickShapeRoundedSmallInlineViewOffsetY;
    } else if (brickShapeType == kBrickShapeRoundedBig) {
        inlineViewHeight -= UIDefines.brickShapeRoundedBigMarginHeightDeduction;
        inlineViewOffsetY = UIDefines.brickShapeRoundedBigInlineViewOffsetY;
    } else {
        NSError(@"unknown brick shape type given");
    }
    CGRect frame = CGRectMake(UIDefines.brickInlineViewOffsetX, inlineViewOffsetY, (self.frame.size.width - UIDefines.brickInlineViewOffsetX), inlineViewHeight);
    self.inlineView.frame = frame;
    self.inlineView.backgroundColor = UIColor.clearColor;

    NSArray *inlineViewSubViews = [self inlineViewSubviews];

    // call corresponding subclass method, specific implementation (overridden method)
    @try {
        [self hookUpSubViews:inlineViewSubViews];
    } @catch (NSException *exception) {
        NSLog(@"Exception: %@", [exception description]);
        frame.origin.x = 0.0f;
        frame.origin.y = 0.0f;
        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        label.font = [UIFont systemFontOfSize:10.0f];
        label.text = [@"Please implement hookUpSubViews in " stringByAppendingString:NSStringFromClass([self class])];
        label.textColor = UIColor.redColor;
        label.backgroundColor = UIColor.whiteColor;
        [label sizeThatFits:frame.size];
        [self.inlineView addSubview:label];
    }
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
    [self.inlineView removeFromSuperview];
    self.inlineView = nil;
    [self setupView];
    [self setupInlineView];
}

#pragma mark - helpers
- (NSArray*)inlineViewSubviews
{
    CGRect canvasFrame = CGRectMake(UIDefines.brickInlineViewCanvasOffsetX, UIDefines.brickInlineViewCanvasOffsetY, self.inlineView.frame.size.width, self.inlineView.frame.size.height);

    NSString *brickTitle = self.brickTitle;
    NSArray *brickParams = self.parameters;
    NSArray *subviews = nil;

    // check if it is a "two-liner" or a "one-liner" brick
    NSArray *lines = [brickTitle componentsSeparatedByString:@"\n"];
    NSUInteger numberOfLines = [lines count];

    if (! numberOfLines) {
        return nil;
    }

    NSUInteger numberOfPreviousLineParams = 0;
    if (numberOfLines > 1) {
        // determine number of params per line
        NSUInteger totalNumberOfParams = [brickParams count];
        NSMutableArray *paramsOfLines = [NSMutableArray arrayWithCapacity:numberOfLines];
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
            numberOfPreviousLineParams = numberOfPreviousLineParams + numberOfCurrentLineParams;
            [paramsOfLines addObject:currentLineParams];
        }

        // determine height per line and generate subviews of all lines
        CGFloat totalHeight = canvasFrame.size.height;
        CGFloat averageHeight = totalHeight / (CGFloat)numberOfLines;
        CGFloat heightForLineWithParams = ((averageHeight > UIDefines.brickInputFieldMinRowHeight) ? averageHeight : UIDefines.brickInputFieldMinRowHeight);
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
            [allLinesSubviews addObjectsFromArray:[self inlineViewSubviewsOfLabel:line WithParams:params WithFrame:frame ForLineNumber:lineIndex]];
        }
        subviews = [allLinesSubviews copy]; // makes immutable copy of (NSMutableArray*) => returns (NSArray*)
    } else {
        // case: one line
        subviews = [[self inlineViewSubviewsOfLabel:brickTitle WithParams:brickParams WithFrame:canvasFrame ForLineNumber:0] copy]; // makes immutable copy of (NSMutableArray*) => returns (NSArray*)
    }
    // finally add all subviews to the inline view
    for (UIView* subview in subviews) {
        [self.inlineView addSubview:subview];
    }
    return subviews;
}

- (void)calcMaxInputFormulaFrameLength: (NSArray*) partLabels WithFrame:(CGRect)frame WithParams:(NSArray*)params
{
    NSUInteger formulaCounter = 0;
    
    for (NSString* afterLabelParam in params) {
        if ([afterLabelParam rangeOfString:@"FLOAT"].location != NSNotFound || [afterLabelParam rangeOfString:@"INT"].location != NSNotFound) {
            formulaCounter++;
        }
    }
    
    if(!formulaCounter)
        return;
    
    NSString* labelTitle = @"";
    
    for (NSString* partLabelTitle in partLabels) {
        labelTitle = [labelTitle stringByAppendingString:partLabelTitle];
    }
    
    UILabel* textLabel = [UIUtil newDefaultBrickLabelWithFrame:frame AndText:labelTitle andRemainingSpace:frame.size.width];
    
    self.maxInputFormulaFrameLength = (frame.size.width - ((NSInteger)textLabel.frame.size.width + UIDefines.brickInputFieldLeftMargin * [partLabels count]) - UIDefines.brickTextFieldFontSize) / formulaCounter;
}

- (NSMutableArray*)inlineViewSubviewsOfLabel:(NSString*)labelTitle WithParams:(NSArray*)params WithFrame:(CGRect)frame ForLineNumber:(NSInteger)lineNumber
{
    CGRect remainingFrame = frame;
    NSUInteger totalNumberOfParams = [params count];
    if (! totalNumberOfParams) {
        NSMutableArray *subviews = [NSMutableArray array];
        UILabel *textLabel = [UIUtil newDefaultBrickLabelWithFrame:remainingFrame AndText:labelTitle andRemainingSpace:remainingFrame.size.width];
        [subviews addObject:textLabel];
        return subviews;
    }

    // case: more than one subview
    NSArray *partLabels = [labelTitle componentsSeparatedByString:@"%@"];
    NSUInteger totalNumberOfPartLabels = [partLabels count];
    NSUInteger totalNumberOfSubViews = totalNumberOfPartLabels + totalNumberOfParams;
    NSMutableArray *subviews = [NSMutableArray arrayWithCapacity:totalNumberOfSubViews];
    NSInteger counter = 0;
    [self calcMaxInputFormulaFrameLength:partLabels WithFrame:frame WithParams:params];
    
    for (NSString *partLabelTitle in partLabels) {
        if (partLabelTitle.length) {
            UILabel *textLabel = [UIUtil newDefaultBrickLabelWithFrame:remainingFrame AndText:partLabelTitle andRemainingSpace:remainingFrame.size.width];
            remainingFrame.origin.x += (textLabel.frame.size.width + UIDefines.brickInputFieldLeftMargin);
            remainingFrame.size.width -= (textLabel.frame.size.width + UIDefines.brickInputFieldLeftMargin);
            [subviews addObject:textLabel];
        }

        // determine UI component
        if (counter < totalNumberOfParams) {

            // -----------------------------------
            // NOTE: * This is only code used for testing purposes. TO BE REFACTORED...
            //       * Pickers, Pluralization, Hook Ups only for inputFields ...
            CGRect inputViewFrame = remainingFrame;
//            inputViewFrame.origin.y += UIDefines.brickInputFieldTopMargin;
//            inputViewFrame.size.height -= (UIDefines.brickInputFieldTopMargin + UIDefines.brickInputFieldBottomMargin);
            inputViewFrame.origin.y += (inputViewFrame.size.height - UIDefines.brickInputFieldHeight)/2 - 0.5;
            inputViewFrame.size.height = UIDefines.brickInputFieldHeight;
            inputViewFrame.size.width = UIDefines.brickInputFieldMinWidth;
            NSString *afterLabelParam = [params objectAtIndex:counter];
            UIView *inputField = nil;
            if ([afterLabelParam rangeOfString:@"FLOAT"].location != NSNotFound || [afterLabelParam rangeOfString:@"INT"].location != NSNotFound) {
                inputField = [[BrickCellFormulaData alloc] initWithFrame:inputViewFrame andBrickCell:self andLineNumber:lineNumber andParameterNumber:counter];
            } else if ([afterLabelParam rangeOfString:@"TEXT"].location != NSNotFound) {
                inputViewFrame.size.height = UIDefines.brickInputFieldHeight;
                inputField = [[BrickCellTextData alloc] initWithFrame:inputViewFrame andBrickCell:self andLineNumber:lineNumber andParameterNumber:counter];
            } else if ([afterLabelParam rangeOfString:@"MESSAGE"].location != NSNotFound) {
                inputViewFrame.size.width = UIDefines.brickComboBoxWidth;
                inputField = [[BrickCellMessageData alloc] initWithFrame:inputViewFrame andBrickCell:self andLineNumber:lineNumber andParameterNumber:counter];
            } else if ([afterLabelParam rangeOfString:@"OBJECT"].location != NSNotFound) {
                inputViewFrame.size.width = UIDefines.brickComboBoxWidth;
                inputField = [[BrickCellObjectData alloc] initWithFrame:inputViewFrame andBrickCell:self andLineNumber:lineNumber andParameterNumber:counter];
            } else if ([afterLabelParam rangeOfString:@"SOUND"].location != NSNotFound) {
                inputViewFrame.size.width = UIDefines.brickComboBoxWidth;
                inputField = [[BrickCellSoundData alloc] initWithFrame:inputViewFrame andBrickCell:self andLineNumber:lineNumber andParameterNumber:counter];
            } else if ([afterLabelParam rangeOfString:@"LOOK"].location != NSNotFound) {
                inputViewFrame.size.width = UIDefines.brickComboBoxWidth;
                inputField = [[BrickCellLookData alloc] initWithFrame:inputViewFrame andBrickCell:self andLineNumber:lineNumber andParameterNumber:counter];
            } else if ([afterLabelParam rangeOfString:@"BACKGROUND"].location != NSNotFound) {
                inputViewFrame.size.width = UIDefines.brickComboBoxWidth;
                inputField = [[BrickCellBackgroundData alloc] initWithFrame:inputViewFrame andBrickCell:self andLineNumber:lineNumber andParameterNumber:counter];
            } else if ([afterLabelParam rangeOfString:@"VARIABLE"].location != NSNotFound) {
                inputViewFrame.size.width = UIDefines.brickComboBoxWidth;
                inputField = [[BrickCellVariableData alloc] initWithFrame:inputViewFrame andBrickCell:self andLineNumber:lineNumber andParameterNumber:counter];
            } else if ([afterLabelParam rangeOfString:@"LIST"].location != NSNotFound) {
                inputViewFrame.size.width = UIDefines.brickComboBoxWidth;
                inputField = [[BrickCellListData alloc] initWithFrame:inputViewFrame andBrickCell:self andLineNumber:lineNumber andParameterNumber:counter];
            } else if ([afterLabelParam rangeOfString:@"STATICCHOICE"].location != NSNotFound) {
                inputViewFrame.size.width = UIDefines.brickComboBoxWidth;
                inputField = [[BrickCellStaticChoiceData alloc] initWithFrame:inputViewFrame andBrickCell:self andLineNumber:lineNumber andParameterNumber:counter];
            } else if ([afterLabelParam rangeOfString:@"MOTOR"].location != NSNotFound) {
                inputViewFrame.size.width = UIDefines.brickComboBoxWidth;
                inputField = [[BrickCellPhiroMotorData alloc] initWithFrame:inputViewFrame andBrickCell:self andLineNumber:lineNumber andParameterNumber:counter];
            } else if ([afterLabelParam rangeOfString:@"LIGHT"].location != NSNotFound) {
                inputViewFrame.size.width = UIDefines.brickComboBoxWidth;
                inputField = [[BrickCellPhiroLightData alloc] initWithFrame:inputViewFrame andBrickCell:self andLineNumber:lineNumber andParameterNumber:counter];
            } else if ([afterLabelParam rangeOfString:@"TONE"].location != NSNotFound) {
                inputViewFrame.size.width = UIDefines.brickComboBoxWidth;
                inputField = [[BrickCellPhiroToneData alloc] initWithFrame:inputViewFrame andBrickCell:self andLineNumber:lineNumber andParameterNumber:counter];
            } else if ([afterLabelParam rangeOfString:@"PHIROIF"].location != NSNotFound) {
                inputViewFrame.size.width = UIDefines.brickComboBoxWidth;
                inputField = [[BrickCellPhiroIfSensorData alloc] initWithFrame:inputViewFrame andBrickCell:self andLineNumber:lineNumber andParameterNumber:counter];
            }else {
                NSError(@"unknown data type %@ given", afterLabelParam);
                abort();
            }

            remainingFrame.origin.x += (inputField.frame.size.width + UIDefines.brickInputFieldRightMargin);
            remainingFrame.size.width -= (inputField.frame.size.width + UIDefines.brickInputFieldRightMargin);
            [subviews addObject:inputField];
        }
        counter++;
    }
    return subviews;
}

#pragma mark - drawing
- (void)drawRect:(CGRect)rect
{
    CGFloat height = [[self class] cellHeight];
    CGFloat width = [Util screenWidth];
    BrickCategory *category = [[[BrickManager class] sharedBrickManager] categoryForType:(kBrickCategoryType) (NSUInteger) [self.scriptOrBrick.category[0] integerValue]];
    
    UIColor *fillColor = category.color;
    UIColor *strokeColor = category.strokeColor;
    UIColor *grayColor = [category colorDisabled];
    UIColor *grayStrokeColor = [category strokeColorDisabled];
        
    if ([self isScriptBrick]) {
        Script *script = (Script*)[self scriptOrBrick];
        if (script.isDisabled) {
            fillColor = grayColor;
            strokeColor = grayStrokeColor;
        }
    } else {
        Brick *brick = (Brick*)[self scriptOrBrick];
        if (brick.isDisabled) {
            fillColor = grayColor;
            strokeColor = grayStrokeColor;
        }
    }
    kBrickShapeType shapeType = [self brickShapeType];
    
    if (shapeType == kBrickShapeSquareSmall) {
        [BrickShapeFactory drawSquareBrickShapeWithFillColor:fillColor strokeColor:strokeColor height:height width:width];
    } else {
        [BrickShapeFactory drawRoundedControlBrickShapeWithFillColor:fillColor strokeColor:strokeColor height:height width:width brickShape:shapeType];
    }
}

#pragma mark - helpers
// BrickCells that do not have default shape type have to override this method in their corresponding subclass
- (kBrickShapeType)brickShapeType
{
    return kBrickShapeSquareSmall;
}

- (CGFloat)inlineViewHeight
{
    return self.inlineView.frame.size.height;
}

- (CGFloat)inlineViewOffsetY
{
    return self.inlineView.frame.origin.y;
}

- (BOOL)isScriptBrick
{
    return [(id)self.scriptOrBrick isKindOfClass:[Script class]];
}

#pragma mark - cell editing
- (void)selectedState:(BOOL)selected setEditingState:(BOOL)editing
{
    self.selectButton.selected = selected;
    self.editing = editing;
}

#pragma mark - animations
- (void)animate:(BOOL)animate
{
    self.scriptOrBrick.animate = animate;
    if (! animate) {
        return;
    }
    self.alpha = 0.7f;
    NSDate *startTime = [NSDate date];
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                                | UIViewAnimationOptionRepeat
                                | UIViewAnimationOptionAutoreverse
                                | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         [UIView setAnimationRepeatCount:4];
                         self.alpha = 1.0f;
                     }
                     completion:^(BOOL finished) {
                         self.alpha = 1.0f;
                         NSTimeInterval duration = [[NSDate date] timeIntervalSinceDate:startTime];
                         self.scriptOrBrick.animate = (duration < 2.0f);
    }];
}

- (void)insertAnimate:(BOOL)animate
{
    self.scriptOrBrick.animateInsertBrick = animate;
    if (! animate) {
        return;
    }
            self.alpha = 0.2f;
            [UIView animateWithDuration:0.8
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseInOut
             | UIViewAnimationOptionRepeat
             | UIViewAnimationOptionAutoreverse
             | UIViewAnimationOptionAllowUserInteraction
                             animations:^{
                                 self.alpha = 1.0f;
                             }
                             completion:^(BOOL finished) {
                                 self.alpha = 1.0f;
                                 if (self.scriptOrBrick.animateInsertBrick) {
                                     [self insertAnimate:self.scriptOrBrick.animateInsertBrick];
                                 }
                             }];

}


#pragma mark - BrickCellData
- (id<BrickCellDataProtocol>)dataSubviewForLineNumber:(NSInteger)line andParameterNumber:(NSInteger)parameter
{
    return [self.inlineView dataSubviewForLineNumber:line andParameterNumber:parameter];
}

- (id<BrickCellDataProtocol>)dataSubviewWithType:(Class)className
{
    return [self.inlineView dataSubviewWithType:className];
}

- (NSArray*)dataSubviews
{
    return [self.inlineView dataSubviews];
}

- (NSArray<NSString*>*)parameters
{
    return [NSArray new];
}

@end
