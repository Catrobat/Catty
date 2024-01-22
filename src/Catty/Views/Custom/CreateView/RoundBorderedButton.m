/**
 *  Copyright (C) 2010-2024 The Catrobat Team
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

#import "RoundBorderedButton.h"
#import "Pocket_Code-Swift.h"

@interface RoundBorderedButton()

@property(nonatomic, assign) BOOL plusIconVisible;
@property(nonatomic, assign) BOOL visibleBorder;
@property(nonatomic, assign) BOOL invertedColor;

#define INSET_HORIZONTAL 12
#define INSET_VERTICAL 6

@end

@implementation RoundBorderedButton

- (id)init
{
    self = [super init];
    if (self) {
        self.visibleBorder = YES;
        self.invertedColor = NO;
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.visibleBorder = YES;
        self.invertedColor = NO;
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andInvertedColor:(BOOL)invertedColor
{
    self = [super initWithFrame:frame];
    if (self) {
        self.visibleBorder = YES;
        self.invertedColor = invertedColor;
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andBorder:(BOOL)visibleBorder
{
    self = [super initWithFrame:frame];
    if (self) {
        self.invertedColor = NO;
        self.visibleBorder = visibleBorder;
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame andBorder:YES];
}

- (void)setup
{
    if (self.invertedColor) {
        [self setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [self setTitleColor:UIColor.buttonTint forState:UIControlStateHighlighted];
        [self setTitleColor:UIColor.buttonTint forState:UIControlStateSelected];
        [self setTitleColor:UIColor.grayColor forState:UIControlStateDisabled];
        [self setBackgroundColor:UIColor.buttonTint];
         self.tintColor = UIColor.whiteColor;
    } else {
        [self setTitleColor:UIColor.buttonTint forState:UIControlStateNormal];
        [self setTitleColor:UIColor.whiteColor forState:UIControlStateHighlighted];
        [self setTitleColor:UIColor.whiteColor forState:UIControlStateSelected];
        [self setTitleColor:UIColor.grayColor forState:UIControlStateDisabled];
        self.tintColor = UIColor.buttonTint;
    }
    
    [self.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [self.titleLabel setMinimumScaleFactor:0.6];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.contentEdgeInsets = UIEdgeInsetsMake(INSET_VERTICAL, INSET_HORIZONTAL, INSET_VERTICAL, INSET_HORIZONTAL);
    
    if (self.visibleBorder) {
        self.layer.cornerRadius = 5;
        self.layer.borderWidth = 1.0;
        self.layer.borderColor = UIColor.buttonTint.CGColor;
    }
    [self refreshBorderColor];
}

- (void)setPlusIconVisibility:(BOOL)show
{
    self.plusIconVisible = show;
}

- (void)setTintColor:(UIColor *)tintColor
{
    [super setTintColor:tintColor];
    [self setTitleColor:tintColor forState:UIControlStateNormal];
    [self refreshBorderColor];
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    [self refreshBorderColor];
}

- (void)refreshBorderColor
{
    self.layer.borderColor = [self isEnabled] ? UIColor.buttonTint.CGColor : UIColor.grayColor.CGColor;
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [self refreshBorderColor];
    
    UIColor *defaultBackgroundColor = self.invertedColor ? UIColor.buttonTint : UIColor.clearColor;
    
    [UIView animateWithDuration:0.05f animations:^{
        self.layer.backgroundColor = highlighted ? self.tintColor.CGColor : defaultBackgroundColor.CGColor;
    }];
}

@end
