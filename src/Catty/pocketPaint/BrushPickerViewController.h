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

#import <UIKit/UIKit.h>

enum LineEnding {
  Round,
  Square
};
typedef enum LineEnding BrushEnding;

@protocol BrushPickerViewControllerDelegate <NSObject>
- (void)closeBrushPicker:(id)sender;
@end

@interface BrushPickerViewController : UIViewController
@property (nonatomic)CGFloat brush;
@property (nonatomic,strong) UIColor* color;
@property (strong, nonatomic)  UIToolbar *toolBar;
@property (strong, nonatomic)  UIBarButtonItem *doneButton;
@property (nonatomic)BrushEnding brushEnding;
@property (nonatomic) UIViewController* paintController;
@property (nonatomic, weak) id<BrushPickerViewControllerDelegate> delegate;
- (IBAction)doneAction:(UIBarButtonItem *)sender;

- (id)initWithFrame:(CGRect)frame andController:(UIViewController*)controller;
@end
