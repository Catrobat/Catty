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
- (void)willPresentAlertView:(CatrobatAlertController*)alertView;  // before animation and showing view

@optional
- (void)didPresentAlertView:(CatrobatAlertController*)alertView;  // after animation

@end

@protocol CatrobatActionSheetDelegate <NSObject>

- (void)actionSheet:(CatrobatAlertController*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;

@optional
- (void)willPresentActionSheet:(CatrobatAlertController*)actionSheet;  // before animation and showing view

@optional
- (void)didPresentActionSheet:(CatrobatAlertController*)actionSheet;  // after animation

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
