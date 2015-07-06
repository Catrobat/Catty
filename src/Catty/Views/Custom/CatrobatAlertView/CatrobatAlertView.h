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

#import <UIKit/UIKit.h>

@class CatrobatAlertView;
@class DataTransferMessage;

// Protocol needed to receive notifications from the IBActionSheet (Will receive UIActionSheet notifications as well)
@protocol CatrobatAlertViewDelegate <NSObject>
@optional
// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(CatrobatAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button
- (void)alertViewCancel:(CatrobatAlertView*)alertView;
- (void)willPresentAlertView:(CatrobatAlertView*)alertView;  // before animation and showing view
- (void)didPresentAlertView:(CatrobatAlertView*)alertView;  // after animation
- (void)alertView:(CatrobatAlertView*)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex; // before animation and hiding view
- (void)alertView:(CatrobatAlertView*)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;  // after animation
// Called after edits in any of the default fields added by the style
- (BOOL)alertViewShouldEnableFirstOtherButton:(CatrobatAlertView*)alertView;
@end

@interface CatrobatAlertView : UIAlertController <UITextFieldDelegate>

@property (nonatomic, strong) DataTransferMessage *dataTransferMessage; // DTO design pattern
@property (nonatomic) NSInteger tag;

- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
           delegate:(id<CatrobatAlertViewDelegate>)delegate
  cancelButtonTitle:(NSString *)cancelButtonTitle
  otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

@end
