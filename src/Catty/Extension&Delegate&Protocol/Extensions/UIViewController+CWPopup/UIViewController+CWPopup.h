//
//  UIViewController+CWPopup.h
//  CWPopupDemo
//
//  Created by Cezary Wojcik on 8/21/13.
//  Copyright (c) 2013 Cezary Wojcik. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol DismissPopupDelegate <NSObject>

- (BOOL)dismissPopup;

@end





@interface UIViewController (CWPopup)

@property (nonatomic, readwrite) UIViewController *popupViewController;

-(void)presentPopupViewController:(UIViewController *)viewControllerToPresent WithFrame:(CGRect)frame;
-(void)dismissPopupViewController;

@end
