/**
 *  Copyright (C) 2010-2016 The Catrobat Team
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


#import "BrickCellTextData.h"
#import "BrickCell.h"
#import "Brick.h"
#import "BrickTextProtocol.h"
#import "UIColor+CatrobatUIColorExtensions.h"

@interface BrickCellTextData() <UITextFieldDelegate>
@property (nonatomic, strong) CAShapeLayer *border;
@end

@implementation BrickCellTextData

#define BORDER_WIDTH 1.0
#define BORDER_HEIGHT 4
#define BORDER_TRANSPARENCY 0.9
#define BORDER_PADDING 3.8

- (instancetype)initWithFrame:(CGRect)frame andBrickCell:(BrickCell*)brickCell andLineNumber:(NSInteger)line andParameterNumber:(NSInteger)parameter
{
    if(self = [super initWithFrame:frame]) {
        _brickCell = brickCell;
        _lineNumber = line;
        _parameterNumber = parameter;
        Brick<BrickTextProtocol> *textBrick = (Brick<BrickTextProtocol>*)brickCell.scriptOrBrick;
        self.text = [textBrick textForLineNumber:line andParameterNumber:parameter];
        
        self.borderStyle = UITextBorderStyleNone;
        self.font = [UIFont systemFontOfSize:kBrickTextFieldFontSize];
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        self.keyboardType = UIKeyboardTypeDefault;
        self.returnKeyType = UIReturnKeyDone;
        self.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        //        self.userInteractionEnabled = NO;
        self.textColor = [UIColor whiteColor];
        
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 1)];
        self.leftView = paddingView;
        self.leftViewMode = UITextFieldViewModeAlways;
        [self sizeToFit];
        
        NSInteger availableHeightWithBorder = frame.size.height + 2 * BORDER_WIDTH;
        if (self.frame.size.height < availableHeightWithBorder)
        {
            CGRect newFrame = self.frame;
            newFrame.size.height = availableHeightWithBorder;
            self.frame = newFrame;
        }
        
        if (self.frame.origin.x + self.frame.size.width + 60 > [Util screenWidth]) {
            self.frame = CGRectMake(self.frame.origin.x,self.frame.origin.y,[Util screenWidth] - 60 - self.frame.origin.x, self.frame.size.height);
        }
        [self setNeedsDisplay];
        [self drawBorder:NO];
        
        self.delegate = self;
        [self addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];

    }
    return self;
}


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
    
    if(isActive) {
        
        self.border.strokeColor = [UIColor globalTintColor].CGColor;
        
        self.border.shadowColor = [UIColor globalTintColor].CGColor;
        self.border.shadowRadius = 1;
        self.border.shadowOpacity = 1.0;
        self.border.shadowOffset = CGSizeMake(0, 0);
        
    } else {
        
        UIColor *borderColor = [UIColor controlBrickStrokeColor];
        self.border.strokeColor = borderColor.CGColor;
        
    }
    
    [self.layer addSublayer:self.border];
}

- (void)update
{
    [self sizeToFit];
    if(self.frame.size.width > 250)
    {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 250, self.frame.size.height);
    }
    [self drawBorder:NO];
    
}

#pragma mark - delegates

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
}

- (void)textFieldDone:(id)sender
{
    [self.brickCell.dataDelegate updateBrickCellData:self withValue:self.text];
    [self resignFirstResponder];
}

# pragma mark - User interaction
- (BOOL)isUserInteractionEnabled
{
    return self.brickCell.scriptOrBrick.isAnimatedInsertBrick == NO;
}

@end
