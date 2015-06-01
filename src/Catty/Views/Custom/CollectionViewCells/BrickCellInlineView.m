/**
 *  Copyright (C) 2010-2015 The Catrobat Team
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

#import "BrickCellInlineView.h"
#import "BrickCellDataProtocol.h"

@implementation BrickCellInlineView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - BrickCellData
- (id<BrickCellDataProtocol>)dataForLineNumber:(NSInteger)line andParameterNumber:(NSInteger)parameter
{
    for (UIView *view in self.subviews) {
        if([view conformsToProtocol:@protocol(BrickCellDataProtocol)]) {
            id<BrickCellDataProtocol> brickCellData = (id<BrickCellDataProtocol>)view;
            if(brickCellData.lineNumber == line && brickCellData.parameterNumber == parameter)
                return brickCellData;
        }
    }
    return nil;
}

- (id<BrickCellDataProtocol>)dataWithType:(Class)className
{
    for (UIView *view in self.subviews) {
        if([view conformsToProtocol:@protocol(BrickCellDataProtocol)] && [view isKindOfClass:className]) {
            id<BrickCellDataProtocol> brickCellData = (id<BrickCellDataProtocol>)view;
            return brickCellData;
        }
    }
    return nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
