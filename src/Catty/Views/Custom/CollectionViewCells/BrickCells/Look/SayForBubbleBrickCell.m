/**
 *  Copyright (C) 2010-2023 The Catrobat Team
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

#import "SayForBubbleBrickCell.h"
#import "SayForBubbleBrick.h"
#import "Pocket_Code-Swift.h"

@interface SayForBubbleBrickCell ()
@property (nonatomic, strong) UILabel *firstRowTextLabel;
@property (nonatomic, strong) UILabel *secondRowLeftTextLabel;
@property (nonatomic, strong) UILabel *secondRowRightTextLabel;
@end

@implementation SayForBubbleBrickCell

+ (CGFloat)cellHeight
{
    return UIDefines.brickHeight2h;
}

- (void)hookUpSubViews:(NSArray *)inlineViewSubViews
{
    self.firstRowTextLabel = inlineViewSubViews[0];
    self.sayTextField = inlineViewSubViews[1];
    self.secondRowLeftTextLabel = inlineViewSubViews[2];
    self.forTextField = inlineViewSubViews[3];
    self.secondRowRightTextLabel = inlineViewSubViews[4];
}

- (NSString*)brickTitleForBackground:(BOOL)isBackground andInsertionScreen:(BOOL)isInsertion
{
    NSString* localizedSecond = kLocalizedSeconds;
    SayForBubbleBrick *brick = (SayForBubbleBrick*)self.scriptOrBrick;
    
    if (brick && [brick.intFormula isSingularNumber]) {
        localizedSecond = kLocalizedSecond;
    }
    
    return [[[[kLocalizedSay stringByAppendingString:@" %@\n"] stringByAppendingString:kLocalizedFor] stringByAppendingString:@" %@ "] stringByAppendingString:localizedSecond];
}

- (NSArray<NSString*>*)parameters
{
    return [[NSArray alloc] initWithObjects:@"{INT}", @"{INT}", nil];
}

@end
