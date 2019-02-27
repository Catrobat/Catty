/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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

#import "PlaynoteBrickCell.h"

@interface PlayNoteBrickCell ()
@property (nonatomic, strong) UILabel *firstTextLabel;
@property (nonatomic, strong) UILabel *secondTextLabel;
@property (nonatomic, strong) UILabel *thirdTextLabel;
@end

@implementation PlayNoteBrickCell

- (void)drawRect:(CGRect)rect
{
    [BrickShapeFactory drawSquareBrickShapeWithFillColor:UIColor.soundBrickVioletColor strokeColor:UIColor.soundBrickStrokeColor height:smallBrick width:[Util screenWidth]];
}

+ (CGFloat)cellHeight
{
    return kBrickHeight1h;
}

- (void)hookUpSubViews:(NSArray *)inlineViewSubViews
{
    self.firstTextLabel = inlineViewSubViews[0];
    self.pitchTextField = inlineViewSubViews[1];
    self.secondTextLabel = inlineViewSubViews[2];
    self.durationTextField = inlineViewSubViews[3];
    self.thirdTextLabel = inlineViewSubViews[4];
}

@end
