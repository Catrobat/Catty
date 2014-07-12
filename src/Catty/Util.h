/**
 *  Copyright (C) 2010-2013 The Catrobat Team
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

#define IS_IPHONE  (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
#define IS_IPAD  (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)

#define TIMEOUT 30.0f

@protocol UIAlertViewDelegate;

@class SceneViewController;
@class ProgramLoadingInfo;

@interface Util : NSObject

#ifdef CATTY_TESTS
+ (void)activateTestMode:(BOOL)activate;
#endif

+ (NSString*)applicationDocumentsDirectory;

+ (void)showComingSoonAlertView;

+ (UIAlertView*)alertWithText:(NSString*)text;

+ (UIAlertView*)alertWithText:(NSString*)text delegate:(id<UIAlertViewDelegate>)delegate tag:(NSInteger)tag;

+ (UIAlertView*)confirmAlertWithTitle:(NSString*)title
                              message:(NSString*)message
                             delegate:(id<UIAlertViewDelegate>)delegate
                                  tag:(NSInteger)tag;

+ (UIAlertView*)promptWithTitle:(NSString*)title
                        message:(NSString*)message
                       delegate:(id<UIAlertViewDelegate>)delegate
                    placeholder:(NSString*)placeholder
                            tag:(NSInteger)tag
              textFieldDelegate:(id<UITextFieldDelegate>)textFieldDelegate;

+ (UIAlertView*)promptWithTitle:(NSString*)title
                        message:(NSString*)message
                       delegate:(id<UIAlertViewDelegate>)delegate
                    placeholder:(NSString*)placeholder
                            tag:(NSInteger)tag
                          value:(NSString*)value
              textFieldDelegate:(id<UITextFieldDelegate>)textFieldDelegate;

+ (UIActionSheet*)actionSheetWithTitle:(NSString*)title
                              delegate:(id<UIActionSheetDelegate>)delegate
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

+ (ProgramLoadingInfo*) programLoadingInfoForProgramWithName:(NSString*)program;

+ (NSString*)lastProgram;

+ (void)setLastProgram:(NSString*)visibleName;

+ (NSString*)uniqueName:(NSString*)nameToCheck existingNames:(NSArray*)existingNames;

+ (double)radiansToDegree:(float)rad;

+ (double)degreeToRadians:(float)deg;

@end
