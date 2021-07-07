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

#import "InsertItemIntoUserListBrickCell.h"
#import "Pocket_Code-Swift.h"

@interface InsertItemIntoUserListBrickCell ()
@property (nonatomic, strong) UILabel *firstRowTextLabel1;
@property (nonatomic, strong) UILabel *firstRowTextLabel2;
@property (nonatomic, strong) UILabel *thirdRowTextLabel;
@end

@implementation InsertItemIntoUserListBrickCell

+ (CGFloat)cellHeight
{
    return UIDefines.brickHeight3h;
}

- (void)hookUpSubViews:(NSArray *)inlineViewSubViews
{
    self.firstRowTextLabel1 = inlineViewSubViews[0];
    self.valueTextField = inlineViewSubViews[1];
    self.firstRowTextLabel2 = inlineViewSubViews[2];
    self.listComboBoxView = inlineViewSubViews[3];
    self.thirdRowTextLabel = inlineViewSubViews[4];
    self.positionTextField = inlineViewSubViews[5];
}

- (NSString*)brickTitleForBackground:(BOOL)isBackground andInsertionScreen:(BOOL)isInsertion
{
    return [[[[[kLocalizedUserListInsert
                stringByAppendingString:@" %@ "]
               stringByAppendingString:kLocalizedUserListInto]
              stringByAppendingString:@"\n%@\n"]
             stringByAppendingString:kLocalizedUserListAtPosition]
            stringByAppendingString:@" %@"];
}

- (NSArray<NSString*>*)parameters
{
    return [[NSArray alloc] initWithObjects:@"{FLOAT;range=(-inf,inf)}",@"{LIST}",@"{INT;range=(1,inf)}", nil];
}

@end
