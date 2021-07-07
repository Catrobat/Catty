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

#import "PhiroRGBLightBrickCell.h"
#import "Pocket_Code-Swift.h"

@interface PhiroRGBLightBrickCell ()
@property (nonatomic, strong) UILabel *firstRowTextLabel;
@property (nonatomic, strong) UILabel *thirdRowTextLabel1;
@property (nonatomic, strong) UILabel *thirdRowTextLabel2;
@property (nonatomic, strong) UILabel *thirdRowTextLabel3;
@end

@implementation PhiroRGBLightBrickCell

+ (CGFloat)cellHeight
{
    return UIDefines.brickHeight3h;
}

- (void)hookUpSubViews:(NSArray *)inlineViewSubViews
{
    self.firstRowTextLabel = inlineViewSubViews[0];
    self.variableComboBoxView = inlineViewSubViews[1];
    self.thirdRowTextLabel1 = inlineViewSubViews[2];
    self.valueTextField1 = inlineViewSubViews[3];
    self.thirdRowTextLabel2 = inlineViewSubViews[4];
    self.valueTextField2 = inlineViewSubViews[5];
    self.thirdRowTextLabel3 = inlineViewSubViews[6];
    self.valueTextField3 = inlineViewSubViews[7];
}

- (NSString*)brickTitleForBackground:(BOOL)isBackground andInsertionScreen:(BOOL)isInsertion
{
    return [[[[[[[kLocalizedPhiroRGBLight
                  stringByAppendingString:@"\n%@\n"]
                 stringByAppendingString:kLocalizedPhiroRGBLightRed]
                stringByAppendingString:@" %@ "]
               stringByAppendingString:kLocalizedPhiroRGBLightGreen]
              stringByAppendingString:@" %@ "]
             stringByAppendingString:kLocalizedPhiroRGBLightBlue]
            stringByAppendingString:@" %@"];
}

- (NSArray<NSString*>*)parameters
{
    return [[NSArray alloc] initWithObjects:@"{LIGHT}",@"{FLOAT;range=(-inf,inf)}",@"{FLOAT;range=(-inf,inf)}",@"{FLOAT;range=(-inf,inf)}", nil];
}

@end
