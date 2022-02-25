/**
 *  Copyright (C) 2010-2022 The Catrobat Team
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

#import "LoopEndBrickCell.h"
#import "Brick.h"
#import "Util.h"
#import "Pocket_Code-Swift.h"

@interface LoopEndBrickCell ()
@property (nonatomic, strong) UILabel *textLabel;
@end

@implementation LoopEndBrickCell

+ (CGFloat)cellHeight
{
    return UIDefines.brickHeight1h;
}

- (void)drawRect:(CGRect)rect
{
    LoopEndBrick *brick = (LoopEndBrick*)[self scriptOrBrick];
    BrickCategory *category = [[[BrickManager class] sharedBrickManager] categoryForType:brick.category];
    
    CGFloat height = [[self class] cellHeight] + marginBottomSquaredBrick;
    CGFloat width = [Util screenWidth];
    UIColor *fillColor = brick.isDisabled ? [category colorDisabled] : UIColor.controlBrickOrange;
    UIColor *strokeColor = brick.isDisabled ? [category strokeColorDisabled] : UIColor.controlBrickStroke;
        
    if (self.type == 2) {
        [BrickShapeFactory drawEndForeverLoopShape2WithFillColor: fillColor strokeColor:strokeColor height:height width:width];
    } else if ( self.type == 1){
        [BrickShapeFactory drawEndForeverLoopShape1WithFillColor:fillColor strokeColor:strokeColor height:height width:width];
    } else if ( self.type == 3){
        [BrickShapeFactory drawEndForeverLoopShape3WithFillColor:fillColor strokeColor:strokeColor height:height width:width];
    } else {
        [BrickShapeFactory drawSquareBrickShapeWithFillColor:fillColor strokeColor:strokeColor height:height-marginBottomSquaredBrick width:width];
    }
}

- (void)hookUpSubViews:(NSArray *)inlineViewSubViews
{
    self.textLabel = inlineViewSubViews[0];
}

- (NSString*)brickTitleForBackground:(BOOL)isBackground andInsertionScreen:(BOOL)isInsertion
{
    return kLocalizedEndOfLoop;
}

@end
