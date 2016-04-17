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

#import "ShapeButton.h"

@interface ShapeButton ()
@property (nonatomic, assign) ShapeButtonType internalType;
@property (nonatomic, strong) CALayer *backGroundLayer;
@property (nonatomic, strong) CAShapeLayer *buttonShapeLayer;

@end

@implementation ShapeButton

#pragma mark UIView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    self.backGroundLayer.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
}

#pragma mark - NSObject

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self defaultSetup];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self defaultSetup];
    }
    
    return self;
}

+ (instancetype)shapeButtonWithType:(ShapeButtonType)type frame:(CGRect)frame
{
    ShapeButton *button = [[ShapeButton alloc] initWithFrame:frame];
    button.internalType = type;
    
    return button;
}

- (void)setShapeType:(NSInteger)shapeType
{
    if (shapeType >= 0) {
        _shapeType = shapeType;
        self.internalType = (ShapeButtonType)shapeType;
    }
}

- (void)setInternalType:(ShapeButtonType)internalType
{
    _internalType = internalType;
    [self setup];
}

- (void)setShapeStrokeColor:(UIColor *)shapeStrokeColor {
    _shapeStrokeColor = shapeStrokeColor;
    
    if (self.buttonShapeLayer) {
        self.buttonShapeLayer.strokeColor = shapeStrokeColor.CGColor;
    }
}

- (void)setLineWidth:(CGFloat)lineWidth {
    _lineWidth = lineWidth;
    
    if (self.buttonShapeLayer) {
        self.buttonShapeLayer.lineWidth = lineWidth;
    }
}

- (void)setLeftShapeInset:(CGFloat)leftShapeInset {
    _leftShapeInset = leftShapeInset;
    
    if (self.buttonShapeLayer) {
        [self setup];
    }
}

- (void)setTopShapeInset:(CGFloat)topShapeInset {
    _topShapeInset = topShapeInset;
    
    if (self.buttonShapeLayer) {
        [self setup];
    }
}

#pragma mark Private

- (void)setup
{
    CAShapeLayer *shapeLayer = nil;
    
    switch (self.internalType) {
        case ShapeButtonTypeBackSpace:
            shapeLayer = [self backSpaceShapeLayer];
            break;
        default:
            break;
    }
    
    self.buttonShapeLayer = shapeLayer;
    __weak typeof(self) weakself = self;
    [UIView performWithoutAnimation:^{
        [weakself.backGroundLayer removeFromSuperlayer];
        weakself.layer.sublayers = nil;
        [weakself.layer addSublayer:weakself.backGroundLayer];
        [weakself.backGroundLayer addSublayer:weakself.buttonShapeLayer];
        [weakself layoutIfNeeded];
    }];
}

- (void)defaultSetup
{
    self.lineWidth = 1.f;
    self.shapeStrokeColor = [UIColor whiteColor];
    self.leftShapeInset = 20.f;
    self.topShapeInset = 10.f;
    self.shapePathOffsetX = 18.f;
    self.shapePathOffsetY = 10.f;
}

- (CAShapeLayer *)backSpaceShapeLayer
{
    self.backGroundLayer = [CALayer layer];
    self.backGroundLayer.frame = self.bounds;
    self.backGroundLayer.backgroundColor = [UIColor clearColor].CGColor;
    [self.layer addSublayer:self.backGroundLayer];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.strokeColor = self.shapeStrokeColor.CGColor;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.lineWidth = self.lineWidth;
    shapeLayer.miterLimit = 2.f;
    
    CGFloat pathOffsetX = self.shapePathOffsetX;
    CGFloat pathOffsetY = self.shapePathOffsetY;
    CGRect shapeRect = CGRectInset(self.backGroundLayer.bounds, pathOffsetX, pathOffsetY);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(pathOffsetX, CGRectGetHeight(shapeRect) / 2.f + pathOffsetY)];
    [path addLineToPoint:CGPointMake(CGRectGetWidth(shapeRect) / 3.f + pathOffsetX, pathOffsetY)];
    [path addLineToPoint:CGPointMake(CGRectGetWidth(shapeRect) + pathOffsetX, pathOffsetY)];
    [path addLineToPoint:CGPointMake(CGRectGetWidth(shapeRect) + pathOffsetX, CGRectGetHeight(shapeRect) + pathOffsetY)];
    [path addLineToPoint:CGPointMake(CGRectGetWidth(shapeRect) / 3.f +  pathOffsetX, CGRectGetHeight(shapeRect) + pathOffsetY)];
    [path closePath];

    CGFloat subPathOffSetX = ceilf(CGRectGetWidth(shapeRect) / 5.f);
    CGFloat subPathOffSetY = ceilf(CGRectGetHeight(shapeRect) / 6.f);
    
    UIBezierPath *leftLinePath = [UIBezierPath bezierPath];
    [leftLinePath moveToPoint:CGPointMake(CGRectGetWidth(shapeRect) - pathOffsetX + subPathOffSetX, pathOffsetY + subPathOffSetY)];
    [leftLinePath addLineToPoint:CGPointMake(CGRectGetWidth(shapeRect) + pathOffsetX - subPathOffSetX, CGRectGetHeight(shapeRect) + pathOffsetY - subPathOffSetY)];
    [leftLinePath closePath];
    [path appendPath:leftLinePath];
    
    UIBezierPath *rightLinePath = [UIBezierPath bezierPath];
    [rightLinePath moveToPoint:CGPointMake(CGRectGetWidth(shapeRect) + pathOffsetX - subPathOffSetX, pathOffsetY + subPathOffSetY)];
    [rightLinePath addLineToPoint:CGPointMake(CGRectGetWidth(shapeRect) - pathOffsetX + subPathOffSetX, CGRectGetHeight(shapeRect) + pathOffsetY - subPathOffSetY)];
    [rightLinePath closePath];
    [path appendPath:rightLinePath];
    
    shapeLayer.path = path.CGPath;

    return shapeLayer;
}

@end
