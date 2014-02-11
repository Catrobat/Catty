/**
 *  Copyright (C) 2010-2013 The Catrobat Team
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

#import "WaitBrickCell.h"

@interface WaitBrickCell ()
@property (nonatomic, strong) UILabel *textLabelLeft;
@property (nonatomic, strong) UILabel *textLabelRight;
@end

@implementation WaitBrickCell

- (UITextField*)delayInput
{
    if (! _delayInput) {
        _delayInput = [[UITextField alloc] init];
        _delayInput.borderStyle = UITextBorderStyleRoundedRect;
        _delayInput.font = [UIFont systemFontOfSize:15];
        _delayInput.autocorrectionType = UITextAutocorrectionTypeNo;
        _delayInput.keyboardType = UIKeyboardTypeDefault;
        _delayInput.returnKeyType = UIReturnKeyDone;
        _delayInput.clearButtonMode = UITextFieldViewModeWhileEditing;
        _delayInput.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [self.inlineView addSubview:_delayInput];
    }
    return _delayInput;
}

- (UILabel*)textLabelLeft
{
    if (! _textLabelLeft) {
        _textLabelLeft = [[UILabel alloc] init];
        _textLabelLeft.textColor = [UIColor whiteColor];
        _textLabelLeft.font = [UIFont boldSystemFontOfSize:16];
        [self.inlineView addSubview:_textLabelLeft];
    }
    return _textLabelLeft;
}

- (UILabel*)textLabelRight
{
    if (! _textLabelRight) {
        _textLabelRight = [[UILabel alloc] init];
        _textLabelRight.textColor = [UIColor whiteColor];
        _textLabelRight.font = [UIFont boldSystemFontOfSize:16];
        [self.inlineView addSubview:_textLabelRight];
    }
    return _textLabelRight;
}

- (void)setupInlineView
{
    NSArray *parts = [kControlBrickNames[kWaitBrick] componentsSeparatedByString: @"%d"];
    self.textLabelLeft.frame = CGRectMake(kBrickLabelOffsetX, kBrickLabelOffsetY, self.inlineView.frame.size.width, self.inlineView.frame.size.height);
    self.textLabelLeft.text = parts[0];
    [self.textLabelLeft sizeToFit];
    CGRect frame = self.textLabelLeft.frame;
    frame.size.height = self.inlineView.frame.size.height;
    self.textLabelLeft.frame = frame;
    NSInteger offsetX = self.textLabelLeft.frame.size.width;

    self.delayInput.text = @"1";
    self.delayInput.frame = CGRectMake(offsetX, kBrickLabelOffsetY, 40.0f, self.inlineView.frame.size.height);
    offsetX += 40.0f;

//    self.textLabelRight.frame = CGRectMake(offsetX, kBrickLabelOffsetY, (self.inlineView.frame.size.width - offsetX), self.inlineView.frame.size.height);
//    self.textLabelRight.text = parts[1];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

@end
