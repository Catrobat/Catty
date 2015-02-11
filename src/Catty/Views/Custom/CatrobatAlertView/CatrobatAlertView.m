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

#import "CatrobatAlertView.h"
#import "ActionSheetAlertViewTags.h"
#import "Util.h"

@implementation CatrobatAlertView

- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
           delegate:(id<CatrobatAlertViewDelegate>)delegate
  cancelButtonTitle:(NSString *)cancelButtonTitle
  otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION
{
    CatrobatAlertView *alertView = [super initWithTitle:title
                                                message:message
                                               delegate:(id<UIAlertViewDelegate>)delegate
                                      cancelButtonTitle:cancelButtonTitle
                                      otherButtonTitles:otherButtonTitles, nil];
    alertView.dataTransferMessage = nil;
    return alertView;
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    [self dismissWithClickedButtonIndex:0 animated:YES];
    [textField resignFirstResponder]; // dismiss the keyboard
    [[Util class] alertView:self clickedButtonAtIndex:kAlertViewButtonOK];
    return YES;
}

@end
