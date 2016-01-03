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

#import "UIUtil.h"
#import "UIDefines.h"
#import "Util.h"
#import "iOSCombobox.h"
#import "ScriptCollectionViewController.h"
#import "SetLookBrick.h"
#import "SetLookBrick.h"
#import "UIColor+CatrobatUIColorExtensions.h"

@implementation UIUtil

+ (UITableViewRowAction*)tableViewMoreRowActionWithHandler:(row_action_block_t)handler {
    UITableViewRowAction *moreRowAction = nil;
    moreRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault
                                                       title:kLocalizedMore
                                                     handler:handler];
    moreRowAction.backgroundColor = [UIColor clearColor];
    return moreRowAction;
}



+ (UITableViewRowAction*)tableViewDeleteRowActionWithHandler:(row_action_block_t)handler {
    UITableViewRowAction *deleteRowAction = nil;
    deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault
                                                         title:kLocalizedDelete
                                                       handler:handler];
    deleteRowAction.backgroundColor = [UIColor destructiveTintColor];
    return deleteRowAction;
}

+ (UILabel*)newDefaultBrickLabelWithFrame:(CGRect)frame {
    return [self newDefaultBrickLabelWithFrame:frame AndText:nil andRemainingSpace:kBrickInputFieldMaxWidth];
}

+ (UILabel*)newDefaultBrickLabelWithFrame:(CGRect)frame AndText:(NSString*)text
                        andRemainingSpace:(NSInteger)remainingSpace
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"Helvetica-Bold" size:kBrickLabelFontSize];
    if (text) {
        label.text = text;
        // adapt size to fit text
        [label sizeToFit];
        if (label.frame.size.width >= remainingSpace) {
            label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, remainingSpace, label.frame.size.height);
            label.numberOfLines = 1;
            [label setAdjustsFontSizeToFitWidth:YES];
            label.lineBreakMode = NSLineBreakByTruncatingTail;
            label.minimumScaleFactor = 14./label.font.pointSize;
        } else {
            label.numberOfLines = 1;
            label.lineBreakMode = NSLineBreakByTruncatingTail;
            [label setAdjustsFontSizeToFitWidth:YES];
            label.minimumScaleFactor = 14./label.font.pointSize;
        }
        CGRect labelFrame = label.frame;
        labelFrame.size.height = frame.size.height;
        label.frame = labelFrame;
    }
    return label;
}

+ (iOSCombobox*)newDefaultBrickComboBoxWithFrame:(CGRect)frame AndItems:(NSArray*)items {
    iOSCombobox *comboBox = [[iOSCombobox alloc] initWithFrame:frame];
    [comboBox setValues:items];
    return comboBox;
}

@end
