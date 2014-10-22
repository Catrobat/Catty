/**
 *  Copyright (C) 2010-2014 The Catrobat Team
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

#import "CatrobatActionSheet.h"

@implementation CatrobatActionSheet

#pragma mark - getters and setters
- (void)addDestructiveButtonWithTitle:(NSString *)destructiveTitle
{
    self.destructiveButtonIndex = [self addButtonWithTitle:destructiveTitle];
    IBActionSheetButton *destructiveButton = [self.buttons objectAtIndex:self.destructiveButtonIndex];
    self.hasDestructiveButton = YES;

    // set color for destructive button
    [destructiveButton setTextColor:[UIColor colorWithRed:1.000f green:0.229f blue:0.000f alpha:1.000f]];
    [destructiveButton setOriginalTextColor:[UIColor colorWithRed:1.000f green:0.229f blue:0.000f alpha:1.000f]];

    // force destructive button to always be on top!
    if (self.destructiveButtonIndex != 0) {
        [self.buttons removeObjectAtIndex:self.destructiveButtonIndex];
        [self.buttons insertObject:destructiveButton atIndex:0];
        self.destructiveButtonIndex = 0;
    }
}

- (void)addCancelButtonWithTitle:(NSString*)cancelTitle
{
    IBActionSheetButton *cancelButton = [[IBActionSheetButton alloc] initWithAllCornersRounded];
    cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:21];
    [cancelButton setTitle:cancelTitle forState:UIControlStateAll];
    [self.buttons addObject:cancelButton];
    self.hasCancelButton = YES;
    self.shouldCancelOnTouch = YES;
    self.cancelButtonIndex = cancelButton.index;
}

#pragma mark - initialization
- (id)initWithTitle:(NSString*)title
           delegate:(id<CatrobatActionSheetDelegate>)delegate
  cancelButtonTitle:(NSString*)cancelTitle
destructiveButtonTitle:(NSString*)destructiveTitle
  otherButtonTitles:(NSString*)otherTitles, ... NS_REQUIRES_NIL_TERMINATION
{
    NSMutableArray *titles = [[NSMutableArray alloc] init];
    if (otherTitles) {
        va_list args;
        va_start(args, otherTitles);
        for (NSString *arg = otherTitles; arg != nil; arg = va_arg(args, NSString* )) {
            [titles addObject:arg];
        }
        va_end(args);
    }
    CatrobatActionSheet *actionSheet = [self initWithTitle:title
                                                  delegate:delegate
                                         cancelButtonTitle:cancelTitle
                                    destructiveButtonTitle:destructiveTitle
                                    otherButtonTitlesArray:titles];
    actionSheet.dataTransferMessage = nil;
    if (actionSheet.hasCancelButton) {
        actionSheet.cancelButtonIndex = ([actionSheet.buttons count] - 1);
    } else {
        actionSheet.cancelButtonIndex = NSIntegerMin;
    }
    return actionSheet;
}

- (id)initWithTitle:(NSString *)title
           delegate:(id<CatrobatActionSheetDelegate>)delegate
  cancelButtonTitle:(NSString *)cancelTitle
destructiveButtonTitle:(NSString *)destructiveTitle
otherButtonTitlesArray:(NSArray *)otherTitlesArray
{
    CatrobatActionSheet *actionSheet = [super initWithTitle:title
                                                   delegate:(id<IBActionSheetDelegate>)delegate
                                          cancelButtonTitle:cancelTitle
                                     destructiveButtonTitle:destructiveTitle
                                     otherButtonTitlesArray:otherTitlesArray];
    actionSheet.dataTransferMessage = nil;
    if (actionSheet.hasCancelButton) {
        actionSheet.cancelButtonIndex = ([actionSheet.buttons count] - 1);
    } else {
        actionSheet.cancelButtonIndex = NSIntegerMin;
    }
    return actionSheet;
}

@end
