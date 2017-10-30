/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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

#import "GlideToBrickCell.h"

@interface GlideToBrickCell ()
@property (nonatomic, strong) UILabel *firstRowLeftLabel;
@property (nonatomic, strong) UILabel *firstRowRightLabel;
@property (nonatomic, strong) UILabel *secondRowLeftLabel;
@property (nonatomic, strong) UILabel *secondRowRightLabel;
@end

@implementation GlideToBrickCell

- (void)drawRect:(CGRect)rect
{
    [BrickShapeFactory drawSquareBrickShapeWithFillColor:UIColor.motionBrickBlueColor strokeColor:UIColor.motionBrickStrokeColor height:largeBrick width:[Util screenWidth]];
}

+ (CGFloat)cellHeight
{
    return kBrickHeight3h;
}

- (void)hookUpSubViews:(NSArray *)inlineViewSubViews
{
    self.firstRowLeftLabel = inlineViewSubViews[0];
    self.durationTextField = inlineViewSubViews[1];
    self.firstRowRightLabel = inlineViewSubViews[2];
    self.secondRowLeftLabel = inlineViewSubViews[3];
    self.xCoordTextField = inlineViewSubViews[4];
    self.secondRowRightLabel = inlineViewSubViews[5];
    self.yCoordTextField = inlineViewSubViews[6];
}

@end
