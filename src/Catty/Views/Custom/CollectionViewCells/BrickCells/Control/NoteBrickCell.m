/**
 *  Copyright (C) 2010-2017 The Catrobat Team
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

#import "NoteBrickCell.h"

@interface NoteBrickCell ()
@property (nonatomic, strong) UILabel *textLabel;
@end

@implementation NoteBrickCell

- (void)drawRect:(CGRect)rect
{
    [BrickShapeFactory drawSquareBrickShapeWithFillColor:UIColor.controlBrickOrangeColor strokeColor:UIColor.controlBrickStrokeColor height:mediumBrick width:[Util screenWidth]];
}

+ (CGFloat)cellHeight
{
    return kBrickHeight2h;
}

- (void)hookUpSubViews:(NSArray *)inlineViewSubViews
{
    self.textLabel = inlineViewSubViews[0];
    self.noteTextField = inlineViewSubViews[1];
    
    // register for keyboard notifications
    // avoid multiple registrations
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

#pragma mark Keyboard Delegates

-(void)keyboardWillShow:(NSNotification *)notification {
    
    if ([self.noteTextField isFirstResponder]) {
        
        NSDictionary* keyboardInfo = [notification userInfo];
        NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
        CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
        
        if (self.frame.origin.y > (keyboardFrameBeginRect.origin.y - keyboardFrameBeginRect.size.height) &&
            [self.superview isKindOfClass:[UICollectionView class]]) {
            
            UICollectionView *parentView = (UICollectionView *)self.superview;
            [parentView setContentOffset:CGPointMake(0, parentView.contentOffset.y + keyboardFrameBeginRect.size.height) animated:YES];
        }
    }
}

-(void)keyboardWillHide:(NSNotification *)notification {
    
    if ([self.noteTextField isFirstResponder]) {
        
        if ([self.superview isKindOfClass:[UICollectionView class]]) {
            
            UICollectionView *parentView = (UICollectionView *)self.superview;
            [parentView setContentOffset:CGPointMake(0, 0) animated:YES];
        }
    }
}

@end
