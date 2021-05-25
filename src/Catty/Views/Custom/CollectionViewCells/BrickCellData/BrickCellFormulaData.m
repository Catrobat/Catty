/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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


#import "BrickCellFormulaData.h"
#import "BrickCell.h"
#import "BrickFormulaProtocol.h"
#import "PlaceAtBrickCell.h"
#import "GlideToBrickCell.h"
#import "BrickManager.h"
#import "Pocket_Code-Swift.h"

@interface BrickCellFormulaData()
@property (nonatomic, strong) CAShapeLayer *border;
@end

@implementation BrickCellFormulaData

#define SPACE_DISTRIBUTE_VALUE 3.1f

- (instancetype)initWithFrame:(CGRect)frame andBrickCell:(BrickCell*)brickCell andLineNumber:(NSInteger)line andParameterNumber:(NSInteger)parameter
{
    Brick<BrickFormulaProtocol> *formulaBrick = (Brick<BrickFormulaProtocol>*)brickCell.scriptOrBrick;
    Formula *formula = [formulaBrick formulaForLineNumber:line andParameterNumber:parameter];
    
    if(self = [super initWithFrame:frame]) {
        _brickCell = brickCell;
        _lineNumber = line;
        _parameterNumber = parameter;
        
        self.titleLabel.textColor = UIColor.whiteColor;
        self.titleLabel.font = [UIFont systemFontOfSize:kBrickTextFieldFontSize];
        self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self setTitle:[formula getDisplayString] forState:UIControlStateNormal];
        
        [self sizeToFit];
        if (self.frame.size.width >= brickCell.maxInputFormulaFrameLength) {
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, brickCell.maxInputFormulaFrameLength, self.frame.size.height);
            self.titleLabel.frame = CGRectMake(self.titleLabel.frame.origin.x, self.titleLabel.frame.origin.y, brickCell.maxInputFormulaFrameLength, self.titleLabel.frame.size.height);
            self.titleLabel.numberOfLines = 1;
            self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        } else {
            self.titleLabel.numberOfLines = 1;
            self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        }
        
        CGRect labelFrame = self.frame;
        labelFrame.size.height = self.frame.size.height;
        self.frame = labelFrame;
        
        [self addTarget:brickCell.delegate action:@selector(openFormulaEditor:withEvent:) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:brickCell.delegate action:@selector(openFormulaEditor:withEvent:) forControlEvents:UIControlEventTouchDownRepeat];
        [self drawBorder:NO];
    }
    return self;
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state
{
    title = [NSString stringWithFormat:@" %@ ", title];
    [super setTitle:title forState:state];
}

#define BORDER_WIDTH 1.0
#define BORDER_HEIGHT 4
#define BORDER_TRANSPARENCY 0.9
#define BORDER_PADDING 3.8

- (void)drawBorder:(BOOL)isActive
{
    if(self.border)
        [self.border removeFromSuperlayer];
    
    self.border = [[CAShapeLayer alloc] init];
    
    UIBezierPath *borderPath = [[UIBezierPath alloc] init];
    
    CGPoint startPoint = CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMaxY(self.bounds) - BORDER_PADDING);
    CGPoint endPoint = CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMaxY(self.bounds) - BORDER_PADDING - BORDER_HEIGHT);
    [borderPath moveToPoint:startPoint];
    [borderPath addLineToPoint:endPoint];
    
    startPoint = CGPointMake(0, CGRectGetMaxY(self.bounds) - BORDER_PADDING);
    endPoint = CGPointMake(0, CGRectGetMaxY(self.bounds) - BORDER_PADDING - BORDER_HEIGHT);
    [borderPath moveToPoint:startPoint];
    [borderPath addLineToPoint:endPoint];
    
    startPoint = CGPointMake(-BORDER_WIDTH / 2, CGRectGetMaxY(self.bounds) - BORDER_PADDING);
    endPoint = CGPointMake(CGRectGetMaxX(self.bounds) + BORDER_WIDTH / 2, CGRectGetMaxY(self.bounds) - BORDER_PADDING);
    [borderPath moveToPoint:startPoint];
    [borderPath addLineToPoint:endPoint];
    
    self.border.frame = self.bounds;
    self.border.path = borderPath.CGPath;
    self.border.lineWidth = BORDER_WIDTH;
    [self.border setOpacity:BORDER_TRANSPARENCY];
    
    
    
    if (isActive) {
        self.border.strokeColor = UIColor.background.CGColor;
        self.border.shadowColor = UIColor.clearColor.CGColor;
        self.border.shadowRadius = 1;
        self.border.shadowOpacity = 1.0;
        self.border.shadowOffset = CGSizeMake(0, 0);
    } else {
        BrickCategory *category = [[[BrickManager class] sharedBrickManager] categoryForType:self.brickCell.scriptOrBrick.category];
        self.border.strokeColor = self.brickCell.scriptOrBrick.isDisabled ? [category strokeColorDisabled].CGColor : category.strokeColor.CGColor;
    }
    
    [self.layer addSublayer:self.border];
}

- (Formula*)formula
{
    Brick<BrickFormulaProtocol> *formulaBrick = (Brick<BrickFormulaProtocol>*)self.brickCell.scriptOrBrick;
    return [formulaBrick formulaForLineNumber:self.lineNumber andParameterNumber:self.parameterNumber];
}


# pragma mark - Delegate
- (void)saveFormula:(Formula *)formula
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationName.formulaSaved object:formula];
    
    [self.formula setRoot:formula.formulaTree];
    [self.brickCell.dataDelegate updateBrickCellData:self withValue:self.formula];
}

# pragma mark - User interaction
- (BOOL)isUserInteractionEnabled
{
    return self.brickCell.scriptOrBrick.isAnimatedInsertBrick == NO;
}

@end
