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

#import "IBActionSheet.h"

@class CatrobatActionSheet;
@class DataTransferMessage;

// Protocol needed to receive notifications from the IBActionSheet (Will receive UIActionSheet notifications as well)
@protocol CatrobatActionSheetDelegate <NSObject>

- (void)actionSheet:(CatrobatActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

@interface CatrobatActionSheet : IBActionSheet

@property (nonatomic, strong) DataTransferMessage *dataTransferMessage; // DTO design pattern
@property (nonatomic) NSInteger destructiveButtonIndex;        // sets destructive (red) button. -1 means none set. default is -1. ignored if only one button
@property (nonatomic) NSInteger cancelButtonIndex;      // if the delegate does not implement -actionSheetCancel:, we pretend this button was clicked on. default is -1

- (void)addDestructiveButtonWithTitle:(NSString*)destructiveTitle;
- (void)addCancelButtonWithTitle:(NSString*)cancelTitle;
- (id)initWithTitle:(NSString*)title
           delegate:(id<CatrobatActionSheetDelegate>)delegate
  cancelButtonTitle:(NSString*)cancelTitle
destructiveButtonTitle:(NSString*)destructiveTitle
  otherButtonTitles:(NSString*)otherTitles, ... NS_REQUIRES_NIL_TERMINATION;
- (id)initWithTitle:(NSString *)title
           delegate:(id<CatrobatActionSheetDelegate>)delegate
  cancelButtonTitle:(NSString *)cancelTitle
destructiveButtonTitle:(NSString *)destructiveTitle
otherButtonTitlesArray:(NSArray *)otherTitlesArray;

@end
