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

#import "CatrobatAlertController.h"
#import "ActionSheetAlertViewTags.h"
#import "Util.h"
#import "BaseTableViewController.h"

@interface CatrobatAlertController()

@property (strong, nonatomic) id delegate;

@end

@implementation CatrobatAlertController

#pragma mark AlertView initialization
- (id)initAlertViewWithTitle:(NSString *)title
            message:(NSString *)message
           delegate:(id<CatrobatAlertViewDelegate>)delegate
  cancelButtonTitle:(NSString *)cancelButtonTitle
  otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION
{
    
    NSMutableArray *titles = [[NSMutableArray alloc] init];
    if (otherButtonTitles) {
        va_list args;
        va_start(args, otherButtonTitles);
        for (NSString *arg = otherButtonTitles; arg != nil; arg = va_arg(args, NSString* )) {
            [titles addObject:arg];
        }
        va_end(args);
    }
    
    return [self initAlertViewWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:@"" otherButtonTitlesArray:titles];
}


- (id)initAlertViewWithTitle:(NSString *)title
                     message:(NSString *)message
                      delegate:(id<CatrobatAlertViewDelegate>)delegate
             cancelButtonTitle:(NSString *)cancelTitle
        destructiveButtonTitle:(NSString *)destructiveTitle
        otherButtonTitlesArray:(NSArray *)otherTitlesArray
{
    CatrobatAlertController *alertView = [CatrobatAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    if (![cancelTitle isEqualToString:@""]) {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * action)
                                       {
                                           [delegate alertView:alertView clickedButtonAtIndex:0];
                                           
                                       }];
        
        [alertView addAction:cancelAction];
    }
    
    NSInteger i = 0;
    for (NSString * title in otherTitlesArray) {
        i++;
        UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                 {
                                     [delegate alertView:alertView clickedButtonAtIndex:i];
                                     
                                 }];
        
        [alertView addAction:action];
    }
    alertView.delegate = delegate;
    alertView.view.tintColor = [UIColor globalTintColor];
    return alertView;

}

#pragma mark - ActionSheet initialization
- (id)initActionSheetWithTitle:(NSString*)title
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

    return [self initActionSheetWithTitle:title delegate:delegate cancelButtonTitle:cancelTitle destructiveButtonTitle:destructiveTitle otherButtonTitlesArray:titles];
}

- (id)initActionSheetWithTitle:(NSString *)title
           delegate:(id<CatrobatActionSheetDelegate>)delegate
  cancelButtonTitle:(NSString *)cancelTitle
destructiveButtonTitle:(NSString *)destructiveTitle
otherButtonTitlesArray:(NSArray *)otherTitlesArray
{
    
    CatrobatAlertController *actionSheet = [CatrobatAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSInteger i = 0;
    if (![cancelTitle isEqualToString:@""] && cancelTitle != nil) {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * action)
                                       {
                                           [delegate actionSheet:actionSheet clickedButtonAtIndex:0];
                                           
                                       }];
        i++;
        [actionSheet addAction:cancelAction];
    }
    if (![destructiveTitle isEqualToString:@""] && destructiveTitle != nil) {
        UIAlertAction *destructiveAction = [UIAlertAction actionWithTitle:destructiveTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action)
                                            {
                                                [delegate actionSheet:actionSheet clickedButtonAtIndex:1];
                                                
                                            }];
        i++;
        [actionSheet addAction:destructiveAction];
    }
    

    for (NSString * title in otherTitlesArray) {
        if(title != nil){
            UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                     {
                                         [delegate actionSheet:actionSheet clickedButtonAtIndex:i];
                                         
                                     }];
            
            [actionSheet addAction:action];
            i++;
        }
    }
    
    actionSheet.delegate = delegate;
    actionSheet.view.tintColor = [UIColor globalTintColor];
    actionSheet.view.backgroundColor = [UIColor clearColor];
    return actionSheet;
}



- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [textField resignFirstResponder]; // dismiss the keyboard
    [[Util class] alertView:self clickedButtonAtIndex:kAlertViewButtonOK];
    return YES;
}
- (UIWindow *)alertWindow {
    if (_alertWindow == nil) {
        _alertWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _alertWindow.rootViewController = [UIViewController new];
        _alertWindow.windowLevel = UIWindowLevelAlert + 1;
    }
    return _alertWindow;
}

- (void)show:(BOOL)animated {
    [self.alertWindow makeKeyAndVisible];
    [self.alertWindow.rootViewController presentViewController:self animated:animated completion:^{}];
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([self.delegate conformsToProtocol:@protocol(CatrobatActionSheetDelegate)] && [self.delegate respondsToSelector:@selector(willPresentActionSheet:)]) {
        [self.delegate willPresentActionSheet:self];
    }
    if ([self.delegate conformsToProtocol:@protocol(CatrobatAlertViewDelegate)] && [self.delegate respondsToSelector:@selector(willPresentAlertView:)]) {
        [self.delegate willPresentAlertView:self];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    if ([self.delegate conformsToProtocol:@protocol(CatrobatActionSheetDelegate)] && [self.delegate respondsToSelector:@selector(didPresentActionSheet:)]) {
        [self.delegate didPresentActionSheet:self];
    }
    if ([self.delegate conformsToProtocol:@protocol(CatrobatAlertViewDelegate)] && [self.delegate respondsToSelector:@selector(didPresentAlertView:)]) {
        [self.delegate didPresentAlertView:self];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.alertWindow.hidden = true;
    [super viewWillDisappear:animated];
    
    if ([self.delegate conformsToProtocol:@protocol(CatrobatActionSheetDelegate)] && [self.delegate respondsToSelector:@selector(actionSheetWillDisappear:)]) {
        [self.delegate actionSheetWillDisappear:self];
    }
    if ([self.delegate conformsToProtocol:@protocol(CatrobatAlertViewDelegate)] && [self.delegate respondsToSelector:@selector(alertViewWillDisappear:)]) {
        [self.delegate alertViewWillDisappear:self];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    if ([self.delegate conformsToProtocol:@protocol(CatrobatActionSheetDelegate)] && [self.delegate respondsToSelector:@selector(actionSheetDidDisappear:)]) {
        [self.delegate actionSheetDidDisappear:self];
    }
    if ([self.delegate conformsToProtocol:@protocol(CatrobatAlertViewDelegate)] && [self.delegate respondsToSelector:@selector(alertViewDidDisappear:)]) {
        [self.delegate alertViewDidDisappear:self];
    }
}

@end
