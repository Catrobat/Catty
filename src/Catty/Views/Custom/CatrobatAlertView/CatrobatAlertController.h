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

@class CatrobatAlertController;
@class DataTransferMessage;


@protocol CatrobatAlertViewDelegate <NSObject>
@optional
// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(CatrobatAlertController*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@optional
// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button
- (void)alertViewCancel:(CatrobatAlertController*)alertView;

@optional
- (void)willPresentAlertView:(CatrobatAlertController*)alertView;  // before animation and showing view

@optional
- (void)didPresentAlertView:(CatrobatAlertController*)alertView;  // after animation

@optional
- (void)alertView:(CatrobatAlertController*)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex; // before animation and hiding view

@optional
- (void)alertView:(CatrobatAlertController*)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;  // after animation

@optional
// Called after edits in any of the default fields added by the style
- (BOOL)alertViewShouldEnableFirstOtherButton:(CatrobatAlertController*)alertView;
@end

@protocol CatrobatActionSheetDelegate <NSObject>

- (void)actionSheet:(CatrobatAlertController*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;

@optional
- (void)willPresentActionSheet:(CatrobatAlertController*)actionSheet;  // before animation and showing view

@optional
- (void)didPresentActionSheet:(CatrobatAlertController*)actionSheet;  // after animation

@optional
// Called when we cancel the action sheet (e.g. the user clicks somewhere on the screen). This is not called when the user clicks the cancel button or any other button.
- (void)actionSheetCancelOnTouch:(CatrobatAlertController *)actionSheet;

@end

@interface CatrobatAlertController : UIAlertController <UITextFieldDelegate>

@property (nonatomic, strong) DataTransferMessage *dataTransferMessage; // DTO design pattern
@property (nonatomic) NSInteger tag;
@property (nonatomic, strong) UIWindow *alertWindow;

- (id)initAlertViewWithTitle:(NSString *)title
            message:(NSString *)message
           delegate:(id<CatrobatAlertViewDelegate>)delegate
  cancelButtonTitle:(NSString *)cancelButtonTitle
  otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

- (id)initActionSheetWithTitle:(NSString*)title
                      delegate:(id<CatrobatActionSheetDelegate>)delegate
             cancelButtonTitle:(NSString*)cancelTitle
        destructiveButtonTitle:(NSString*)destructiveTitle
             otherButtonTitles:(NSString*)otherTitles, ... NS_REQUIRES_NIL_TERMINATION;
- (id)initActionSheetWithTitle:(NSString *)title
                      delegate:(id<CatrobatActionSheetDelegate>)delegate
             cancelButtonTitle:(NSString *)cancelTitle
        destructiveButtonTitle:(NSString *)destructiveTitle
        otherButtonTitlesArray:(NSArray *)otherTitlesArray;


- (void)show:(BOOL)animated;

@end
