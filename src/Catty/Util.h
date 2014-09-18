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


#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#define IS_IPAD (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
#define IS_IPHONE5 ((UIScreen.mainScreen.bounds.size.height - 568) ? NO : YES)

#define IS_OS_5_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0)
#define IS_OS_6_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
#define IS_OS_7_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#define TIMEOUT 30.0f

@protocol MYIntroductionDelegate;
@class SceneViewController;
@class ProgramLoadingInfo;
@class CatrobatAlertView;
@protocol CatrobatAlertViewDelegate;
@class CatrobatActionSheet;
@protocol CatrobatActionSheetDelegate;

@interface Util : NSObject

#ifdef CATTY_TESTS
+ (void)activateTestMode:(BOOL)activate;
#endif

+ (NSString*)applicationDocumentsDirectory;

+ (void)showComingSoonAlertView;

+ (void)showIntroductionScreenInView:(UIView*)view delegate:(id<MYIntroductionDelegate>)delegate;

+ (CatrobatAlertView*)alertWithText:(NSString*)text;

+ (CatrobatAlertView*)alertWithText:(NSString*)text
                           delegate:(id<CatrobatAlertViewDelegate>)delegate
                                tag:(NSInteger)tag;

+ (CatrobatAlertView*)confirmAlertWithTitle:(NSString*)title
                                    message:(NSString*)message
                                   delegate:(id<CatrobatAlertViewDelegate>)delegate
                                        tag:(NSInteger)tag;

+ (CatrobatAlertView*)promptWithTitle:(NSString*)title
                              message:(NSString*)message
                             delegate:(id<CatrobatAlertViewDelegate>)delegate
                          placeholder:(NSString*)placeholder
                                  tag:(NSInteger)tag
                    textFieldDelegate:(id<UITextFieldDelegate>)textFieldDelegate;

+ (CatrobatAlertView*)promptWithTitle:(NSString*)title
                              message:(NSString*)message
                             delegate:(id<CatrobatAlertViewDelegate>)delegate
                          placeholder:(NSString*)placeholder
                                  tag:(NSInteger)tag
                                value:(NSString*)value
                    textFieldDelegate:(id<UITextFieldDelegate>)textFieldDelegate;

+ (CatrobatActionSheet*)actionSheetWithTitle:(NSString*)title
                                    delegate:(id<CatrobatActionSheetDelegate>)delegate
                      destructiveButtonTitle:(NSString*)destructiveButtonTitle
                           otherButtonTitles:(NSArray*)otherButtonTitles
                                         tag:(NSInteger)tag
                                        view:(UIView*)view;

+ (UIButton*)slideViewButtonWithTitle:(NSString*)title backgroundColor:(UIColor*)backgroundColor;

+ (UIButton*)slideViewButtonMore;

+ (UIButton*)slideViewButtonDelete;

+ (NSString*)getProjectName;

+ (NSString*)getProjectVersion;

+ (NSString*)getDeviceName;

+ (NSString*)getPlatformName;

+ (NSString*)getPlatformVersion;

+ (CGFloat)getScreenHeight;

+ (CGFloat)getScreenWidth;

+ (CATransition*)getPushCATransition;

+ (ProgramLoadingInfo*)programLoadingInfoForProgramWithName:(NSString*)program;

+ (NSString*)lastProgram;

+ (void)setLastProgram:(NSString*)visibleName;

+ (void)askUserForUniqueNameAndPerformAction:(SEL)action
                                      target:(id)target
                                 promptTitle:(NSString*)title
                               promptMessage:(NSString*)message
                                 promptValue:(NSString*)value
                           promptPlaceholder:(NSString*)placeholder
                              minInputLength:(NSUInteger)minInputLength
                              maxInputLength:(NSUInteger)maxInputLength
                         blockedCharacterSet:(NSCharacterSet*)blockedCharacterSet
                    invalidInputAlertMessage:(NSString*)invalidInputAlertMessage
                               existingNames:(NSArray*)existingNames;

+ (void)askUserForUniqueNameAndPerformAction:(SEL)action
                                      target:(id)target
                                  withObject:(id)passingObject
                                 promptTitle:(NSString*)title
                               promptMessage:(NSString*)message
                                 promptValue:(NSString*)value
                           promptPlaceholder:(NSString*)placeholder
                              minInputLength:(NSUInteger)minInputLength
                              maxInputLength:(NSUInteger)maxInputLength
                         blockedCharacterSet:(NSCharacterSet*)blockedCharacterSet
                    invalidInputAlertMessage:(NSString*)invalidInputAlertMessage
                               existingNames:(NSArray*)existingNames;

+ (void)askUserForTextAndPerformAction:(SEL)action
                                target:(id)target
                           promptTitle:(NSString*)title
                         promptMessage:(NSString*)message
                           promptValue:(NSString*)value
                     promptPlaceholder:(NSString*)placeholder
                        minInputLength:(NSUInteger)minInputLength
                        maxInputLength:(NSUInteger)maxInputLength
                   blockedCharacterSet:(NSCharacterSet*)blockedCharacterSet
              invalidInputAlertMessage:(NSString*)invalidInputAlertMessage;

+ (void)askUserForTextAndPerformAction:(SEL)action
                                target:(id)target
                            withObject:(id)passingObject
                           promptTitle:(NSString*)title
                         promptMessage:(NSString*)message
                           promptValue:(NSString*)value
                     promptPlaceholder:(NSString*)placeholder
                        minInputLength:(NSUInteger)minInputLength
                        maxInputLength:(NSUInteger)maxInputLength
                   blockedCharacterSet:(NSCharacterSet*)blockedCharacterSet
              invalidInputAlertMessage:(NSString*)invalidInputAlertMessage;

+ (NSString*)uniqueName:(NSString*)nameToCheck existingNames:(NSArray*)existingNames;

+ (double)radiansToDegree:(double)rad;

+ (double)degreeToRadians:(double)deg;

@end
