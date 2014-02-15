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

#import "StartScriptCell.h"

@interface StartScriptCell ()
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@end

@implementation StartScriptCell

- (UILabel*)textLabel
{
    if (! _textLabel) {
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.font = [UIFont boldSystemFontOfSize:16];
        [self.inlineView addSubview:_textLabel];
    }
    return _textLabel;
}

- (void)setupInlineView
{
    NSString *brickTitle = kControlBrickNames[kProgramStartedBrick];
    self.textLabel.frame = CGRectMake(kBrickLabelOffsetX, kBrickLabelOffsetY, self.inlineView.frame.size.width, self.inlineView.frame.size.height);
    self.textLabel.text = brickTitle;
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
